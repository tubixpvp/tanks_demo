package alternativa.resource {
	import alternativa.types.Long;
	import flash.system.ApplicationDomain;
	import alternativa.types.LongFactory;
	
	
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
			return LongFactory.getLong(library.id.high,library.id.low);
		}
		
		public function set id(value:Long):void {
			var loaderLong:Class = Class(ApplicationDomain.currentDomain.getDefinition("alternativa.loader.Long"));
			library.id = new loaderLong(value.high, value.low);
		}
		
		public function set version(value:int):void {
			library.version = value;
		}
		
		public function get version():int {
			return library.version;
		}

	}
}