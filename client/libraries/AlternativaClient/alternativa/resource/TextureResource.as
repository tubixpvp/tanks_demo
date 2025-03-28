package alternativa.resource {
	import alternativa.types.Texture;
	import alternativa.utils.BitmapUtils;
	
	import flash.display.Bitmap;
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
	public class TextureResource extends Resource {
		
		private var textureInfoLoader:URLLoader;
		private var diffuseMapLoader:Loader;
		private var alphaMapLoader:Loader;
		
		private var xml:XML;
		private var bmp:BitmapData;
		private var _data:Texture;
		
		private var bytesTotal:Number;

		/**
		 * 
		 * @param batchLoader
		 */
		public function TextureResource(batchLoader:BatchResourceLoader) {
			super("текстура", batchLoader);
			
			textureInfoLoader = new URLLoader();
			textureInfoLoader.addEventListener(Event.COMPLETE, onTextureInfoLoad);
			textureInfoLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			textureInfoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			
			diffuseMapLoader = new Loader();
			diffuseMapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onDiffuseMapLoad);
			diffuseMapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			diffuseMapLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

			alphaMapLoader = new Loader();
			alphaMapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			alphaMapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			alphaMapLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
		}
		
		/**
		 * 
		 * @param url
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
			_data = null;
		}
		
		/**
		 * Загружает описание текстуры.
		 */
		override protected function loadResourceData():void {
			textureInfoLoader.load(new URLRequest(url + "texture.xml"));
		}
		
		/**
		 * Разбирает описание текстуры и запускает загрузку jpg файла.
		 */
		private function onTextureInfoLoad(e:Event):void {
			bytesTotal += URLLoader(e.target).bytesTotal;
			xml = new XML(URLLoader(e.target).data);
			// Загружаем текстуру
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			context.securityDomain = SecurityDomain.currentDomain;
			diffuseMapLoader.load(new URLRequest(url + "texture.jpg"), context);
		}
		
		/**
		 * Спрайт загружен.
		 */
		private function onDiffuseMapLoad(e:Event):void {
			bytesTotal += LoaderInfo(e.target).bytesTotal;

			if (xml.@alpha != "false") {
				// Загружаем альфу
				var context:LoaderContext = new LoaderContext();
				context.applicationDomain = ApplicationDomain.currentDomain;
				context.securityDomain = SecurityDomain.currentDomain;
				alphaMapLoader.load(new URLRequest(url + "alpha.gif"), context);
			} else {
				onLoadComplete();
			}
		}
		
		/**
		 * Всё загружено.
		 */
		protected function onLoadComplete(e:Event = null):void {
			if (e != null) {
				// Загружена карта прозрачности
				bytesTotal += LoaderInfo(e.target).bytesTotal;
				bmp = BitmapUtils.mergeBitmapAlpha(Bitmap(diffuseMapLoader.content).bitmapData, Bitmap(alphaMapLoader.content).bitmapData, true);
			} else {
				bmp = Bitmap(diffuseMapLoader.content).bitmapData;
			}
			
			diffuseMapLoader = null;
			alphaMapLoader = null;

			_data = new Texture(bmp);
			
			// Рассылка события
			completeLoading();
		}
		
		/**
		 * 
		 */
		public function get data():Texture {
			return _data;
		}
		
	}
}