package alternativa.osgi.bundle {
	import flash.utils.Dictionary;
	
	
	public class Bundle	{
		
		public var name:String;
		public var activator:IBundleActivator;
		public var params:Dictionary;
		
		public function Bundle(name:String, activator:IBundleActivator, params:Dictionary) {
			this.name = name;
			this.activator = activator;
			this.params = params;
		}

	}
}