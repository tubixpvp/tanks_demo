package alternativa.resource.factory {
	import alternativa.resource.BatchResourceLoader;
	import alternativa.resource.Resource;
	import alternativa.resource.SoundResource;
	
	
	public class SoundResourceFactory implements IResourceFactory {
		
		public function SoundResourceFactory() {}
		
		/**
		 * @inheritDoc
		 */
		public function createResource(resourceType:int, batchLoader:BatchResourceLoader):Resource {
			return new SoundResource(batchLoader);
		}

	}
}