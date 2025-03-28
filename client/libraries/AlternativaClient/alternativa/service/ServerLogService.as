package alternativa.service {
	import alternativa.network.CommandSocket;
	import alternativa.network.ICommandSender;
	import alternativa.network.command.ControlCommand;
	import alternativa.osgi.service.log.ILogService;
	

	public class ServerLogService implements ILogService {
		
		private var controlSocket:CommandSocket;
		
		public function ServerLogService(controlSocket:CommandSocket) {
			this.controlSocket = controlSocket;
		}
		
		public function log(level:int, message:String, exception:String = null):void {
			ICommandSender(controlSocket).sendCommand(new ControlCommand(ControlCommand.LOG, "log", [level, message]));
		}
		
	}
}