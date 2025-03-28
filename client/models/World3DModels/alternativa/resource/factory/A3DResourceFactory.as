package alternativa.resource.factory {
	import alternativa.resource.A3DCollisionResource;
	import alternativa.resource.A3DResource;
	import alternativa.resource.BatchResourceLoader;
	import alternativa.resource.Resource;

	public class A3DResourceFactory implements IResourceFactory {
		
		public function A3DResourceFactory() {
		}

		public function createResource(resourceType:int, batchLoader:BatchResourceLoader):Resource {
			switch (resourceType) {
				case 5:
					return new A3DResource(batchLoader);
					break;
				case 7:
					return new A3DCollisionResource(batchLoader);
					break;
			}
			return null;
		}
	}
}