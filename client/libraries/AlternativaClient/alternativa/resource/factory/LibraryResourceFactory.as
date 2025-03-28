package alternativa.resource.factory {
	import alternativa.resource.BatchResourceLoader;
	import alternativa.resource.LibraryResource;
	import alternativa.resource.Resource;

	/**
	 * Фабрика библиотечных ресурсов.
	 */
	public class LibraryResourceFactory implements IResourceFactory {

		public function LibraryResourceFactory() {
		}

		/**
		 * @inheritDoc
		 */
		public function createResource(resourceType:int, batchLoader:BatchResourceLoader):Resource {
			return new LibraryResource(batchLoader);
		}
		
	}
}