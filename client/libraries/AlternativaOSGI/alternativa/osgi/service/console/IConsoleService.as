package alternativa.osgi.service.console {
	
	public interface IConsoleService {
		
		function showConsole():void;
		
		function hideConsole():void;
		
		function writeToConsole(message:String, ... vars):void;
		
		function get console():Object;
		
	}
	
}