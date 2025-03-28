package alternativa.register {
	import alternativa.network.ICommandHandler;
	import alternativa.network.ICommandSender;
	import alternativa.types.Long;
	
	
	public class SpaceInfo {
		
		public var id:Long;
		
		public var handler:ICommandHandler;
		
		public var sender:ICommandSender;
		
		public var objectRegister:ObjectRegister;
		
		
		public function SpaceInfo(handler:ICommandHandler, sender:ICommandSender, objectRegister:ObjectRegister) {
			this.handler = handler;
			this.sender = sender;
			this.objectRegister = objectRegister;
		}

	}
}