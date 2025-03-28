package alternativa.tanks.loader {
	import alternativa.osgi.service.loader.ILoaderService;
	import alternativa.osgi.service.loader.ILoadingProgressListener;
	import alternativa.osgi.service.mainContainer.IMainContainerService;
	import alternativa.osgi.service.loader.LoadingProgress;
	import alternativa.init.OSGi
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	
	public class LoadingWindow extends Sprite implements ILoadingProgressListener {
		
		[Embed(source="resource/images/loading_window.png")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
		
		/*[Embed(source="sounds/load.mp3")]
        public var soundClass:Class;*/
		
		//private var loadingSound:Sound;
		//private var soundLoaded:Boolean;
		
		private var loadingProgress:LoadingProgress;
		
		//private var closeWindowInt:int;
		
		private var currentProcessId:int = -1;
		
		private var lockWindow:Boolean;
		
		private var back:Bitmap;
		
		private var _currentSize:Point;
		
		private var progressBar:LoadingProgressBar;
		
		private var layer:DisplayObjectContainer;
		
		private var statusLabel:TextField; 
		
		private var _stage:Stage;
		
		public static var window:LoadingWindow;
		
		
		public function LoadingWindow(osgi:OSGi) {
			super();
			
			LoadingWindow.window = this;
			
			loadingProgress = ILoaderService(osgi.getService(ILoaderService)).loadingProgress;
			
			layer = IMainContainerService(osgi.getService(IMainContainerService)).systemUILayer;
			_stage = IMainContainerService(osgi.getService(IMainContainerService)).stage;
			
			mouseEnabled = false;
			tabEnabled = false;
			mouseChildren = false;
			tabChildren = false;
			
			back = new Bitmap(backBd);
			addChild(back);
			back.x = -8;
			back.y = -58;
			
			statusLabel = new TextField();
			statusLabel.thickness = -100;
			statusLabel.sharpness = 100;
			with (statusLabel) {
				defaultTextFormat = new TextFormat("Sign", 12, 0xffffff);
				type = TextFieldType.DYNAMIC;
				autoSize = TextFieldAutoSize.CENTER;
				antiAliasType = AntiAliasType.ADVANCED;
				embedFonts = true;
				selectable = false;
				multiline = false;
				mouseEnabled = false;
				tabEnabled = false;
				text = "LOADING..."
			}
			addChild(statusLabel);
			
			progressBar = new LoadingProgressBar();
			progressBar.mouseEnabled = false;
			progressBar.tabEnabled = false;
			progressBar.mouseChildren = false;
			progressBar.tabChildren = false;
			
			addChild(progressBar);
			
			_currentSize = new Point(365, 140);
			
			repaint();
			
			/*loadingSound = new soundClass() as Sound;
			if (loadingSound != null) {
				soundLoaded = true;
			}*/
		}
		
		public function changeStatus(processId:int, value:String):void {
			if (currentProcessId == -1) {
				currentProcessId = processId;
				setStatus(value);
				openWindow();
			} else {
				if (currentProcessId == processId) {
					setStatus(value);
				}
			}
		}
		
		public function changeProgress(processId:int, value:Number):void {
			if (currentProcessId == -1) {
				currentProcessId = processId;
				setProgress(value);
				openWindow();
			} else {
				if (currentProcessId == processId) {
					setProgress(value);
				}
			}
			if (value == 1 && currentProcessId == processId) {
				currentProcessId = -1;
			}
		}
		
		private function setStatus(value:String):void {
			statusLabel.text = value;
			statusLabel.x = (_currentSize.x - statusLabel.textWidth)*0.5;
		}
		
		private function setProgress(value:Number):void {
			var progress:Number = value;//Math.floor(value*10)/10;
			if (progressBar.value != progress) {
				progressBar.value = progress;
				// запуск звука
				/*if (soundLoaded) {
					loadingSound.play(0);
				}*/
			}
		}
		
		public function get currentSize():Point {
			return _currentSize;
		}
		
		private function repaint():void {
			/*this.graphics.clear();
			this.graphics.beginFill(0x505560, 1);
			this.graphics.drawRect(0, 0, _currentSize.x, _currentSize.y);
			*/
			statusLabel.x = (_currentSize.x - statusLabel.textWidth)*0.5;
			statusLabel.y = 30;
			
			progressBar.repaint(progressBar.currentSize.x);
			progressBar.x = Math.round((currentSize.x - progressBar.currentSize.x)*0.5);
			progressBar.y = _currentSize.y - 30 - progressBar.currentSize.y;
		}
		
		private function openWindow():void {
			if (!layer.contains(this) && !lockWindow) {
				layer.addChild(this);
				onStageResize();
			}
		}
		
		private function closeWindow():void {
			//clearInterval(closeWindowInt);
			if (layer.contains(this) && !lockWindow) {
				layer.removeChild(this);
			}
		}
		
		public function lockLoadingWindow():void {
			lockWindow = true;
		}
		public function unlockLoadingWindow():void {
			lockWindow = false;
		}
		
		private function onStageResize(e:Event = null):void {
			if (layer.contains(this)) {
				this.x = Math.round((_stage.stageWidth - this.currentSize.x)*0.5);
	    		this.y = Math.round((_stage.stageHeight - this.currentSize.y)*0.5);
	  		}
		}

	}
}