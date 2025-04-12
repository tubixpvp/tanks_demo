package alternativa.init {
	
	import alternativa.osgi.bundle.IBundleActivator;
	import alternativa.model.AlternativaClientModels;

	public class ClientModelsActivator implements IBundleActivator {
		
		public static var osgi:OSGi;
		
		public function ClientModelsActivator() {}
		
		public function start(osgi:OSGi):void {
			ClientModelsActivator.osgi = osgi;
			AlternativaClientModels.init();
		}
			
		public function stop(osgi:OSGi):void {
			ClientModelsActivator.osgi = null;
		}

	}
}