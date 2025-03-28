package alternativa.osgi.service.log {
	
	public class LogService implements ILogService {
		
		public static const LOG_ERROR_COLOR:uint = 0xff0000;
		public static const LOG_WARNING_COLOR:uint = 0xee6600;
		public static const LOG_INFO_COLOR:uint = 0x3366ff;
		public static const LOG_DEBUG_COLOR:uint = 0x000000;
		public static const LOG_TRACE_COLOR:uint = 0x666666;
		public static const LOG_NONE_COLOR:uint = 0x999999;
		
		private var console:Object;
		
		public function LogService(console:Object) {
			this.console = console;
		}
		
		public function log(level:int, message:String, exception:String = null):void {
			var color:uint;
			switch (level) {
				case LogLevel.LOG_ERROR:
					color = LOG_ERROR_COLOR;
					break;
				case LogLevel.LOG_WARNING:
					color = LOG_WARNING_COLOR;
					break;
				case LogLevel.LOG_INFO:
					color = LOG_INFO_COLOR;
					break;
				case LogLevel.LOG_DEBUG:
					color = LOG_DEBUG_COLOR;
					break;
				case LogLevel.LOG_TRACE:
					color = LOG_TRACE_COLOR;
					break;
				case LogLevel.LOG_NONE:
					color = LOG_NONE_COLOR;
					break;
			}
			console.write(message, color);
		}

	}
}