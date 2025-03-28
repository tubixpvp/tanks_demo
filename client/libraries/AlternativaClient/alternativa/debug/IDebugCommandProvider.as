package alternativa.debug {
	import alternativa.network.ICommandHandler;
	
	
	public interface IDebugCommandProvider {
		
		function registerCommand(command:String, handler:IDebugCommandHandler):void;
		
		function unregisterCommand(command:String):void;
		
		function executeCommand(command:String):String;

	}
}