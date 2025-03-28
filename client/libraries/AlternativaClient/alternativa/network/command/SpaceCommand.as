package alternativa.network.command {
	import alternativa.protocol.codec.NullMap;
	import alternativa.types.Long;
	
	import flash.utils.IDataInput;
	
	
	public class SpaceCommand {
		
		public static const PRODUCE_HASH:int = 0;
		
		public var objectId:Long;
		public var methodId:Long;
		public var params:IDataInput;
		public var nullMap:NullMap;
		
		public function SpaceCommand(objectId:Long,
									 methodId:Long,
									 params:IDataInput,
									 nullMap:NullMap) {
			this.objectId = objectId;
			this.methodId = methodId;
			this.params = params;
			this.nullMap = nullMap;
		}

	}
}