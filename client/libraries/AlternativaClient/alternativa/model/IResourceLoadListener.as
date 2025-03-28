package alternativa.model {
	import alternativa.resource.IResource;
	import alternativa.types.Long;
	
	
	public interface IResourceLoadListener {
		
		function resourceLoaded(resource:IResource):void;
			
		function resourceUnloaded(resourceId:Long):void;
			
	}
	
}