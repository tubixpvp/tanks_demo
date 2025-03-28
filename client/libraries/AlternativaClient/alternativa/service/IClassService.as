package alternativa.service {
	import alternativa.register.ClientClass;
	import alternativa.types.Long;
	
	import flash.utils.Dictionary;
	
	
	public interface IClassService {
		
		function createClass(id:Long, parent:ClientClass, name:String, modelsToAdd:Array = null, modelsToRemove:Array = null, modelsParams:Dictionary = null):ClientClass;
		
		function destroyClass(id:Long):void;
		
		function get classes():Dictionary;
		
		function get classList():Array;
		
	}
}