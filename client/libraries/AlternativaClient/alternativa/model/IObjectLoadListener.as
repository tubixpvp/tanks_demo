package alternativa.model {
	import alternativa.object.ClientObject;
	
	public interface IObjectLoadListener {
		
		function objectLoaded(object:ClientObject):void;
			
		function objectUnloaded(object:ClientObject):void;
			
	}
	
}