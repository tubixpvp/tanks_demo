package alternativa.resource {
	import alternativa.init.Main;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	
	public class LoadingProgress {
		
		private var listeners:Array;
		
		private var loadingWindow:LoadingWindow;
		
		private var progressData:Dictionary;
		
		private var closeWindowInt:int;
		
		private var currentProcessId:int = -1;
		
		private var lockWindow:Boolean;
		
		public function LoadingProgress() {
			listeners = new Array();
			progressData = new Dictionary();
			
			loadingWindow = new LoadingWindow();
			
			Main.stage.addEventListener(Event.RESIZE, onStageResize);
		}
		
		private function onStageResize(e:Event = null):void {
			if (Main.systemUILayer.contains(loadingWindow)) {
				loadingWindow.x = Math.round((Main.stage.stageWidth - loadingWindow.currentSize.x)*0.5);
				//loadingWindow.x = Main.stage.stageWidth - loadingWindow.currentSize.x;
	    		loadingWindow.y = Math.round((Main.stage.stageHeight - loadingWindow.currentSize.y)*0.5);
	  		}
		}
		
		public function addEventListener(listener:ILoadingProgressListener):void {
			listeners.push(listener);
		}
		public function removeEventListener(listener:ILoadingProgressListener):void {
			listeners.splice(listeners.indexOf(listener), 1);
		}
		
		public function setStatus(processId:int, value:String):void {
			// Сохранение
			if (progressData[processId] == null) {
				progressData[processId] = new LoadingProgressData(value, 0);
			}  else {
				LoadingProgressData(progressData[processId]).status = value;
			}
			// Отображение
			if (currentProcessId == -1) {
				currentProcessId = processId;
				loadingWindow.changeStatus(value);
				openWindow();
			} else {
				if (currentProcessId == processId) {
					loadingWindow.changeStatus(value);
				}
			}
			// Рассылка
			for (var i:int = 0; i< listeners.length; i++) {
				ILoadingProgressListener(listeners[i]).changeStatus(processId, value);
			}
		}
		public function setProgress(processId:int, value:Number):void {
			if (value < 0) {
				value = 0;
			}
			if (value > 1) {
				value = 1;
			}
			// Сохранение
			if (progressData[processId] == null) {
				if (value != 1) {
					progressData[processId] = new LoadingProgressData("", value);
					openWindow();
				}
			}  else {
				if (value != 1) {
					LoadingProgressData(progressData[processId]).progress = value;
				} else {
					progressData[processId] = null;
				}
			}
			// Отображение
			if (currentProcessId == -1) {
				currentProcessId = processId;
				loadingWindow.changeProgress(value);
				openWindow();
			} else {
				if (currentProcessId == processId) {
					loadingWindow.changeProgress(value);
				}
			}
			if (value == 1 && currentProcessId == processId) {
				currentProcessId = -1;
			}
			// Рассылка
			for (var i:int = 0; i< listeners.length; i++) {
				ILoadingProgressListener(listeners[i]).changeProgress(processId, value);
			}
		}
		
		private function openWindow():void {
			Main.writeToConsole("LoadingProgress openWindow");
			if (!Main.systemUILayer.contains(loadingWindow) && !lockWindow) {
				Main.systemUILayer.addChild(loadingWindow);
				onStageResize();
			}
		}
		
		public function closeLoadingWindow():void {
			closeWindow();
		}
		
		public function lockLoadingWindow():void {
			lockWindow = true;
		}
		public function unlockLoadingWindow():void {
			lockWindow = false;
		}
		
		private function closeWindow():void {
			Main.writeToConsole("LoadingProgress closeWindow");
			//clearInterval(closeWindowInt);
			if (Main.systemUILayer.contains(loadingWindow) && !lockWindow) {
				Main.systemUILayer.removeChild(loadingWindow);
			}
		}
		
		public function getStatus(processId:int):String {
			var status:String = (progressData[processId] != null) ? LoadingProgressData(progressData[processId]).status : "";
			return status;
		}
		public function getProgress(processId:int):Number {
			var progress:Number = (progressData[processId] != null) ? LoadingProgressData(progressData[processId]).progress : 0;
			return progress;
		}

	}
}