package alternativa.init {
	import alternativa.osgi.bundle.IBundleActivator;
	
	public class ProtocolActivator implements IBundleActivator {
		
		public static var osgi:OSGi;
		
		public function ProtocolActivator() {}
		
		public function start(osgi:OSGi):void {
			ProtocolActivator.osgi = osgi;
		}
			
		public function stop(osgi:OSGi):void {
			ProtocolActivator.osgi = null;
		}

	}
}