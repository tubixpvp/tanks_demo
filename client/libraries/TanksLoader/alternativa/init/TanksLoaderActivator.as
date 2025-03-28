package alternativa.init {
	import alternativa.osgi.bundle.IBundleActivator;
	import alternativa.tanks.loader.LoadingWindow;
	
	
	public class TanksLoaderActivator implements IBundleActivator {
		
		public static var osgi:OSGi;
		
		public static var loadingWindow:LoadingWindow;
		
		
		public function TanksLoaderActivator() {}
		
		public function start(osgi:OSGi):void {
			TanksLoaderActivator.osgi = osgi;
			
			loadingWindow = new LoadingWindow(osgi);
		}
			
		public function stop(osgi:OSGi):void {
			TanksLoaderActivator.osgi = null;
		}

	}
}