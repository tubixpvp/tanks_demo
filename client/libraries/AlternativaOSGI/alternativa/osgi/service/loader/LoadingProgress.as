package alternativa.osgi.service.loader {
	import __AS3__.vec.Vector;
	
	import flash.utils.Dictionary;
	
	
	public class LoadingProgress {
		
		private var listeners:Vector.<ILoadingProgressListener>;
		
		private var progressData:Dictionary;
		
		
		public function LoadingProgress() {
			listeners = new Vector.<ILoadingProgressListener>();
			progressData = new Dictionary();
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
				}
			} else {
				if (value != 1) {
					LoadingProgressData(progressData[processId]).progress = value;
				} else {
					progressData[processId] = null;
				}
			}
			// Рассылка
			for (var i:int = 0; i< listeners.length; i++) {
				ILoadingProgressListener(listeners[i]).changeProgress(processId, value);
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