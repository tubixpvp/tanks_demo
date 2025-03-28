package alternativa.resource {
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	
	public class MovieClipResource extends Resource {
		
		private var loader:Loader;
		
		//private var _mc:MovieClip;
		
		
		public function MovieClipResource(batchLoader:BatchResourceLoader) {
			super("мувик", batchLoader);
			
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
			loader.load(new URLRequest(url + "mc.swf"), context);
		}
		
		// Библиотека загружена
		protected function onLoadComplete(e:Event = null):void {
			// Рассылка события
			completeLoading();
		}
		
		public function get mc():MovieClip {
			return MovieClip(loader.content);
		}

	}
}