package alternativa.resource {
	import alternativa.types.Long;
	
	
	/**
	 * Обертка для ресурса, не реализующего IResource. 
	 */	
	public class ResourceWrapper implements IResource {
		
		private var library:Object;
		
		public function ResourceWrapper(library:Object)	{
			this.library = library;
		}
		
		public function load(url:String):void {
			library.load(url);
		}
		
		public function unload():void {
			library.unload();
		}
		
		public function get name():String {
			return library.name;
		}
		
		public function get id():Long {
			return library.id;
		}
		
		public function set id(value:Long):void {
			library.id = value;
		}
		
		public function set version(value:int):void {
			library.version = value;
		}
		
		public function get version():int {
			return library.version;
		}

	}
}