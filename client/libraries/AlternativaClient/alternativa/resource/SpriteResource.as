package alternativa.resource {
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	/**
	 * 
	 */
	public class SpriteResource extends Resource {

		private var xmlLoader:URLLoader;
		private var bmpLoader:Loader;
		private var alphaLoader:Loader;
		
		private var xml:XML;
		private var bmp:BitmapData;
		
		private var bytesTotal:Number;
		
		/**
		 * 
		 */
		public function SpriteResource(batchLoader:BatchResourceLoader) {
			super("спрайт", batchLoader);
			
			xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, onXmlLoad);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			
			bmpLoader = new Loader();
			bmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBmpLoad);
			bmpLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			bmpLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

			alphaLoader = new Loader();
			alphaLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			alphaLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			alphaLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
		}
		
		/**
		 * 
		 */
		override public function load(url:String):void {
			super.load(url);
			bytesTotal = 0;
		}
		
		/**
		 * 
		 */
		override public function unload():void {
			super.unload();
			bmp.dispose();
			bmp = null;
		}
		
		/**
		 * 
		 */
		override protected function loadResourceData():void {
			xmlLoader.load(new URLRequest(url + "slice.xml"));
		}
		
		/**
		 * Слайсы загружены.
		 */
		private function onXmlLoad(e:Event):void {
			bytesTotal += URLLoader(e.target).bytesTotal;

			xml = new XML(URLLoader(e.target).data);

			// Загружаем спрайт
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			context.securityDomain = SecurityDomain.currentDomain;
			bmpLoader.load(new URLRequest(url + "sprite.jpg"), context);
		}
		
		/**
		 * Спрайт загружен
		 */
		private function onBmpLoad(e:Event):void {
			bytesTotal += LoaderInfo(e.target).bytesTotal;

			// Загружаем альфу
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			context.securityDomain = SecurityDomain.currentDomain;
			alphaLoader.load(new URLRequest(url + "alpha.gif"), context);
		}
		
		/**
		 * Всё загружено.
		 */		
		protected function onLoadComplete(e:Event = null):void {
			/*bytesTotal += LoaderInfo(e.target).bytesTotal;
			
			bmp = BitmapUtility.mergeBitmapAlpha(Bitmap(bmpLoader.content).bitmapData, Bitmap(alphaLoader.content).bitmapData, true);
			bmpLoader = null;
			alphaLoader = null;

			_data = new SpriteData(false, false);
			
			for (var i:uint = 0; i < xml.children().length(); i++) {
				var slice:XML = xml.children()[i];
				var name:Array = String(slice.@name).split(" ");
				var rect:XML = slice.child("rect")[0];
				var point:XML = slice.child("point")[0];
				_data.addPhase(bmp, new Rectangle(rect.@x, rect.@y, rect.@w, rect.@h), name[0], name[1], name[2], new Point(point.@x, point.@y));
			}*/
			// Рассылка события
			completeLoading();
		}
		
		// Спрайт-дата
		/*public function get data():SpriteData {
			return _data;
		}*/
		
	}
}