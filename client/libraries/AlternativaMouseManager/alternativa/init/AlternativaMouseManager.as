package alternativa.init {
	import alternativa.iointerfaces.mouse.IMouseManager;
	import alternativa.iointerfaces.mouse.MouseManager;
	
	
	public class AlternativaMouseManager {
		
		public static function init():void {
			// менеджер курсора
			var mouseManager:IMouseManager = new MouseManager();
			mouseManager.init(Main.cursorLayer);
		}

	}
}