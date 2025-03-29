package alternativa.init {
	
	import alternativa.osgi.bundle.IBundleActivator;

	public class ClientModelsActivator implements IBundleActivator {
		
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