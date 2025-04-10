package alternativa.resource {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	
	public class LoadingWindow extends Sprite {
		
		[Embed(source="images/loading_window.png")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
		
		[Embed(source="sounds/load.mp3")]
        public var soundClass:Class;
		
		private var loadingSound:Sound;
		private var soundLoaded:Boolean;
		
		private var back:Bitmap;
		
		private var _currentSize:Point;
		
		private var progressBar:LoadingProgressBar;
		
		private var statusLabel:TextField; 
		
		
		public function LoadingWindow() {
			super();
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
			
			loadingSound = new soundClass() as Sound;
			if (loadingSound != null) {
				soundLoaded = true;
			}
		}
		
		public function changeStatus(value:String):void {
			statusLabel.text = value;
			statusLabel.x = (_currentSize.x - statusLabel.textWidth)*0.5;
		}
		
		public function changeProgress(value:Number):void {
			var progress:Number = Math.floor(value*10)/10;
			if (progressBar.value != progress) {
				progressBar.value = progress;
				// запуск звука
				if (soundLoaded) {
					loadingSound.play(0);
				}
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

	}
}