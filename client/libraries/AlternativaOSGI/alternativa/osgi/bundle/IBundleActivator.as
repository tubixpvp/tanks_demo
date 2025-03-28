package alternativa.osgi.bundle {
	import alternativa.init.OSGi;
	
	
	public interface IBundleActivator {
		
		function start(osgi:OSGi):void;
			
		function stop(osgi:OSGi):void;
		
	}
	
}