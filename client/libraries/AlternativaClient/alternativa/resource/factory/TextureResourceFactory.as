package alternativa.resource.factory {
	import alternativa.resource.BatchResourceLoader;
	import alternativa.resource.Resource;
	import alternativa.resource.TextureResource;

	/**
	 * Фабрика текстурных ресурсов.
	 */
	public class TextureResourceFactory implements IResourceFactory {
		
		public function TextureResourceFactory() {
		}

		/**
		 * @inheritDoc
		 */
		public function createResource(resourceType:int, batchLoader:BatchResourceLoader):Resource {
			return new TextureResource(batchLoader);
		}
		
	}
}