package alternativa.init {
	
	public class ClientModelsActivator {
		
		public static var osgi:OSGi;
		
		public function ClientModelsActivator() {}
		
		public function start(osgi:OSGi):void {
			ClientModelsActivator.osgi = osgi;
		}
			
		public function stop(osgi:OSGi):void {
			ClientModelsActivator.osgi = null;
		}

	}
}