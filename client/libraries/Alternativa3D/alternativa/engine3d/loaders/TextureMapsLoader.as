package alternativa.engine3d.loaders {
	import alternativa.engine3d.loaders.events.LoaderEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * Событие рассылается в начале загрузки каждой текстуры.
	 * 
	 * @eventType alternativa.engine3d.loaders.events.LoaderEvent.LOADING_START
	 */
	[Event (name="loadingStart", type="alternativa.engine3d.loaders.events.LoaderEvent")]
	/**
	 * Событие рассылается после окончания загрузки каждой текстуры.
	 * 
	 * @eventType alternativa.engine3d.loaders.events.LoaderEvent.LOADING_COMPLETE
	 */
	[Event (name="loadingComplete", type="alternativa.engine3d.loaders.events.LoaderEvent")]
	/**
	 * Событие рассылается после завершения загрузки.
	 * 
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event (name="complete", type="flash.events.Event")]
	/**
	 * Событие рассылается при возникновении ошибки, приводящей к прерыванию загрузки.
	 * 
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event (name="ioError", type="flash.events.IOErrorEvent")]
	/**
	 * Событие рассылается в процессе получения данных во время загрузки.
	 * 
	 * @eventType flash.events.ProgressEvent.PROGRESS
	 */
	[Event (name="progress", type="flash.events.ProgressEvent")]
	/**
	 * Загрузчик битмапов диффузной текстуры и карты прозрачности.
	 * @private 
	 */
	public class TextureMapsLoader extends EventDispatcher {
		
		private static const STATE_IDLE:int = 0;
		private static const STATE_LOADING_DIFFUSE_MAP:int = 1;
		private static const STATE_LOADING_ALPHA_MAP:int = 2;
		
		private var _bitmapData:BitmapData;
		private var bitmapLoader:Loader;
		private var alphaTextureUrl:String;
		private var loaderContext:LoaderContext;

		private var loaderState:int = STATE_IDLE;
		
		/**
		 * Создаёт новый экземпляр класса. Если параметр <code>diffuseTextureUrl</code> не равен <code>null</code>, конструктор запускает процесс
		 * загрузки.
		 * 
		 * @param diffuseTextureUrl URL файла диффузной карты
		 * @param alphaTextureUrl URL файла карты прозрачности 
		 * @param loaderContext LoaderContext, используемый для загрузки файлов
		 */
		public function TextureMapsLoader(diffuseTextureUrl:String = null, alphaTextureUrl:String = null, loaderContext:LoaderContext = null) {
			if (diffuseTextureUrl != null) {
				load(diffuseTextureUrl, alphaTextureUrl, loaderContext);
			}
		}
		
		/**
		 * Загружает текстурные карты. Если помимо файла диффузной текстуры указан файл карты прозрачности, результирующая текстура будет получена из диффузной карты путём заполнения
		 * её альфа-канала на основе карты прозрачности. Карта прозрачности должна быть задана оттенками серого, при этом белый цвет должен задавать полностью непрозрачную область.
		 * <p>
		 * После завершения загрузки текстура становится доступной через свойство <code>bitmapData</code>.
		 * </p>
		 * 
		 * @param diffuseTextureUrl URL файла диффузной карты
		 * @param alphaTextureUrl URL файла карты прозрачности 
		 * @param loaderContext LoaderContext, используемый для загрузки файлов
		 * 
		 * @see #bitmapData
		 */		
		public function load(diffuseTextureUrl:String, alphaTextureUrl:String = null, loaderContext:LoaderContext = null):void {
			this.alphaTextureUrl = alphaTextureUrl;
			this.loaderContext = loaderContext;
			if (bitmapLoader == null) {
				bitmapLoader = new Loader();
				bitmapLoader.contentLoaderInfo.addEventListener(Event.OPEN, onOpen);
				bitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				bitmapLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
				bitmapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			} else {
				close();
			}
			startLoading(STATE_LOADING_DIFFUSE_MAP, diffuseTextureUrl);
		}
		
		/**
		 *
		 */
		private function onOpen(e:Event):void {
			dispatchEvent(new LoaderEvent(LoaderEvent.LOADING_START, LoadingStage.TEXTURE));
		}

		/**
		 *
		 */
		private function onProgress(e:Event):void {
			dispatchEvent(e);
		}
		
		/**
		 * Запускает загрузку файла текстуры.
		 * 
		 * @param state фаза загрузки
		 * @param url URL загружаемого файла
		 */		
		private function startLoading(state:int, url:String):void {
			loaderState = state;
			bitmapLoader.load(new URLRequest(url), loaderContext);
		}
		
		/**
		 * 
		 */		
		private function onComplete(e:Event):void {
			dispatchEvent(new LoaderEvent(LoaderEvent.LOADING_COMPLETE, LoadingStage.TEXTURE));
			switch (loaderState) {
				case STATE_LOADING_DIFFUSE_MAP:
					// Загрузилась диффузная текстура. При необходимости загружается карта прозрачности.
					_bitmapData = Bitmap(bitmapLoader.content).bitmapData;
					if (alphaTextureUrl != null) {
						startLoading(STATE_LOADING_ALPHA_MAP, alphaTextureUrl);
					} else {
						complete();
					}
					break;
				case STATE_LOADING_ALPHA_MAP:
					// Загрузилась карта прозрачности. Выполняется копирование прозрачности в альфа-канал диффузной текстуры.
					var tmpBmp:BitmapData = _bitmapData;
					_bitmapData = new BitmapData(_bitmapData.width, _bitmapData.height, true, 0);
					_bitmapData.copyPixels(tmpBmp, tmpBmp.rect, new Point());
					
					var alpha:BitmapData = Bitmap(bitmapLoader.content).bitmapData;
					if (_bitmapData.width != alpha.width || _bitmapData.height != alpha.height) {
						tmpBmp.draw(alpha, new Matrix(_bitmapData.width/alpha.width, 0, 0, _bitmapData.height/alpha.height), null, BlendMode.NORMAL, null, true);
						alpha.dispose();
						alpha = tmpBmp;
					}
					_bitmapData.copyChannel(alpha, alpha.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
					alpha.dispose();
					complete();
					break;
			}
		}

		/**
		 * 
		 */
		private function onLoadError(e:IOErrorEvent):void {
			loaderState = STATE_IDLE;
			dispatchEvent(e);
		}
		
		/**
		 * 
		 */
		private function complete():void {
			loaderState = STATE_IDLE;
			bitmapLoader.unload();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Загруженная текстура.
		 */
		public function get bitmapData():BitmapData {
			return _bitmapData;
		}
		
		/**
		 * Прекращает текущую загрузку.
		 */
		public function close():void {
			if (loaderState != STATE_IDLE) {
				loaderState = STATE_IDLE;
				bitmapLoader.close();
			}
			unload();
		}

		/**
		 * Очищает внутренние ссылки на загруженные объекты.
		 */
		public function unload():void {
			if (loaderState == STATE_IDLE) {
				if (bitmapLoader != null) {
					bitmapLoader.unload();
				}
				loaderContext = null;
				_bitmapData = null;
			}
		}
	}
}