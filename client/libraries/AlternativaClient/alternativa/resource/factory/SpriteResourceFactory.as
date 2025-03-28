package alternativa.resource.factory {
	import alternativa.resource.BatchResourceLoader;
	import alternativa.resource.Resource;
	import alternativa.resource.SpriteResource;

	/**
	 * Фабрика спрайтовых ресурсов.
	 */
	public class SpriteResourceFactory implements IResourceFactory {

		public function SpriteResourceFactory() {
		}

		/**
		 * @inheritDoc
		 */
		public function createResource(resourceType:int, batchLoader:BatchResourceLoader):Resource {
			return new SpriteResource(batchLoader);
		}
		
	}
}