package alternativa.osgi.service.log {
	
	public interface ILogService {
		
		function log(level:int, message:String, exception:String = null):void;
		
	}
	
}