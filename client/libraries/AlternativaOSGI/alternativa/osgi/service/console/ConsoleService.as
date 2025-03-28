package alternativa.osgi.service.console {
	
	public class ConsoleService implements IConsoleService {
		
		private var _console:Object;
		
		public function ConsoleService(console:Object) {
			_console = console;
		}
		
		public function writeToConsole(message:String, ... vars):void {
			if (console != null) {
				for (var i:int = 0; i < vars.length; i++) {
					message = message.replace("%" + (i + 1), vars[i]);
				}
				_console.write(message, 0);
			}
		}
		
		public function hideConsole():void {
			if (_console != null) {
				_console.hide();
			}
		}

		public function showConsole():void {
			if (_console != null) {
				_console.show();
			}
		}
		
		public function get console():Object {
			return _console;
		}

	}
}