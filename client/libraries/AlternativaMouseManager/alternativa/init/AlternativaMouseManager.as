package alternativa.init {
	import alternativa.iointerfaces.mouse.IMouseManager;
	import alternativa.iointerfaces.mouse.MouseManager;
	import alternativa.osgi.bundle.IBundleActivator;
	
	
	public class AlternativaMouseManager implements IBundleActivator {
		
		public function start(osgi:OSGi):void {
			// менеджер курсора
			var mouseManager:IMouseManager = new MouseManager();
			mouseManager.init(Main.cursorLayer);
		}

		public function stop(osgi:OSGi) : void
		{
		}

	}
}