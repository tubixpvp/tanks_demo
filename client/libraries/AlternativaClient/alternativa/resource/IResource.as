package alternativa.resource {
	import alternativa.types.Long;
	
	
	public interface IResource {
		
		function load(url:String):void;
		function unload():void;
		function get name():String;
		function get id():Long;
		function set id(value:Long):void;
		function get version():int;
		function set version(value:int):void;
			
	}
	
}