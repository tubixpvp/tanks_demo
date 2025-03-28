package alternativa.resource {
	import alternativa.init.Main;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	public class LibraryResource extends Resource {
		
		private static const initClassPath:String = "alternativa.init";
		
		private var loader:Loader;
		
		public function LibraryResource(batchLoader:BatchResourceLoader) {
			super("библиотека", batchLoader);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
		}
		
		override public function unload():void {
			super.unload();
			loader.unload();
			loader = null;
		}
		
		override protected function loadResourceData():void {
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			context.securityDomain = SecurityDomain.currentDomain;
			loader.load(new URLRequest(url + "library.swf"), context);
		}
		
		// Библиотека загружена
		protected function onLoadComplete(e:Event = null):void {
			var initName:String;
			
			//Main.writeToConsole("onLoadComplete " + _name + " " + e, 0xff0000);
			
			if (_name.indexOf("libraries") != -1) {
				if (_name.indexOf("platform") != -1) {
					initName = _name.replace("platform.clients.fp9", "alternativa");
				} else {
					initName = _name.replace("projects", "alternativa");
					initName = initName.replace("clients.fp9.", "");
				}
				initName = initName.replace("libraries", "init");
			} else {
				if (_name.indexOf("projects") != -1) {
					initName = _name.replace("projects", "alternativa");
					initName = initName.replace("clients.fp9.", "");
				} else {
					initName = _name.replace("platform.clients.fp9", "alternativa");
				}
				initName = initName.replace("models", "model");
			}
			
			/*if (ApplicationDomain.currentDomain.hasDefinition("alternativa.tanks.model.LobbyModel")) {
				Main.writeToConsole("LobbyModel already loaded!!!", 0xff0000);
			} else {
				Main.writeToConsole("LobbyModel not loaded yet...", 0x666666);
			}*/
			
			// Инициализация библиотеки
			if (ApplicationDomain.currentDomain.hasDefinition(initName)) {
				Main.writeToConsole("LibraryResource init class " + initName, 0x00aa00);
				ApplicationDomain.currentDomain.getDefinition(initName).init();
			} else {
				Main.writeToConsole("LibraryResource init class " + initName + " не найден!", 0xff0000);
			}
			/*if (ApplicationDomain.currentDomain.hasDefinition(initClassPath + "." + _name)) {
				ApplicationDomain.currentDomain.getDefinition(initClassPath + "." + _name).init();
			}*/
			
			// Рассылка события
			completeLoading();
		}

	}
}