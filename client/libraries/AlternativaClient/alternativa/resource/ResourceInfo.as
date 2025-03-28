package alternativa.resource {
	import alternativa.types.Long;
	
	
	public class ResourceInfo {
		
		public var id:Long;
		public var version:Long;
		public var type:int;
		public var isOptional:Boolean;
		
		public function ResourceInfo(id:Long, version:Long, type:int, isOptional:Boolean) {
			this.id = id;
			this.version = version;
			this.type = type;
			this.isOptional = isOptional;
		}

	}
}