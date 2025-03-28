package alternativa.resource.factory {
	import alternativa.resource.BatchResourceLoader;
	import alternativa.resource.MovieClipResource;
	import alternativa.resource.Resource;
	
	
	public class MovieClipResourceFactory implements IResourceFactory {
		
		public function MovieClipResourceFactory() {}
		
		public function createResource(resourceType:int, batchLoader:BatchResourceLoader):Resource {
			return new MovieClipResource(batchLoader);
		}

	}
}