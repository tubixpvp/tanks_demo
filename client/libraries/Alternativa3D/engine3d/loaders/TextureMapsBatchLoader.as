package alternativa.engine3d.loaders {
	import alternativa.engine3d.loaders.events.LoaderEvent;
	import alternativa.engine3d.loaders.events.LoaderProgressEvent;
	import alternativa.types.Map;
	
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.system.LoaderContext;
	
	/**
	 * Событие рассылается в начале очередного этапа загрузки сцены.
	 * 
	 * @eventType alternativa.engine3d.loaders.events.LoaderEvent.LOADING_START
	 */
	[Event (name="loadingStart", type="alternativa.engine3d.loaders.events.LoaderEvent")]
	/**
	 * Событие рассылается в процессе получения данных во время загрузки.
	 * 
	 * @eventType alternativa.engine3d.loaders.events.LoaderProgressEvent.LOADING_PROGRESS
	 */
	[Event (name="loadingProgress", type="alternativa.engine3d.loaders.events.LoaderProgressEvent")]
	/**
	 * Событие рассылается после окончания очередного этапа загрузки сцены.
	 * 
	 * @eventType alternativa.engine3d.loaders.events.LoaderEvent.LOADING_COMPLETE
	 */
	[Event (name="loadingComplete", type="alternativa.engine3d.loaders.events.LoaderEvent")]
	/**
	 * Событие рассылается после окончания загрузки сцены.
	 * 
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event (name="complete", type="flash.events.Event")]
	/**
	 * Тип события, рассылаемого при возникновении ошибки загрузки текстуры.
	 * 
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event (name="ioError", type="flash.events.IOErrorEvent")]
	
	/**
	 * @private
	 * Пакетный загрузчик текстур. Используется загрузчиками внешних сцен для получения битмапов текстур материалов.
	 */
	public class TextureMapsBatchLoader extends EventDispatcher {
		/**
		 * Текстура-заглушка для замены незагруженных текстур.
		 */
		public static var stubBitmapData:BitmapData;
		
		// Загрузчик файлов текстур.
		private var loader:TextureMapsLoader;
		// Контекст безопасности загрузчика.
		private var loaderContext:LoaderContext;
		// Базовый URL файлов текстур.
		private var baseUrl:String;
		// Пакет с описанием текстур материалов.
		private var batch:Map;
		// Список имён материалов.
		private var materialNames:Array;
		// Общее количество файлов текстур.
		private var totalFiles:int;
		// Номер текущего 
		private var currFileIndex:int;
		// Индекс текущего материала.
		private var materialIndex:int;
		// Результирующий список битмапов для каждого материала.
		private var _textures:Map;
		
		/**
		 * Создаёт новый экземпляр загрузчика.
		 */
		public function TextureMapsBatchLoader() {
		}
		
		/**
		 * Результирующий список битмапов для каждого материала. Ключами являются имена материалов, значениями -- объекты класса BitmapData.
		 */
		public function get textures():Map {
			return _textures;
		}
		
		/**
		 * Метод для получения текстуры-заглушки.
		 * 	
		 * @return текстура-заглушка для замещения незагруженных текстур
		 */
		private function getStubBitmapData():BitmapData {
			if (stubBitmapData == null) {
				var size:uint = 20;
				stubBitmapData = new BitmapData(size, size, false, 0);
				for (var i:uint = 0; i < size; i++) {
					for (var j:uint = 0; j < size; j += 2) {
						stubBitmapData.setPixel((i%2) ? j : (j + 1), i, 0xFF00FF);
					}
				}
			}
			return stubBitmapData;
		}

		/**
		 * Прекращает текущую загрузку.
		 */
		public function close():void {
			if (loader != null) {
				loader.close();
			}
		}
		
		/**
		 * Очищает внутренние ссылки на объекты.
		 */
		private function clean():void {
			loaderContext = null;
			batch = null;
			materialNames = null;
		}
		
		/**
		 * Очищает ссылку на загруженный список текстур материалов.
		 */
		public function unload():void {
			_textures = null;
		}
		
		/**
		 * Загружает текстуры для материалов.
		 * 
		 * @param baseURL базовый URL файлов текстур
		 * @param batch массив соответствий имён текстурных материалов и их текстур, описываемых объектами класса TextureMapsInfo
		 * @param loaderContext LoaderContext для загрузки файлов текстур
		 */
		public function load(baseURL:String, batch:Map, loaderContext:LoaderContext):void {
			this.baseUrl = baseURL;
			this.batch = batch;
			this.loaderContext = loaderContext;
			
			if (loader == null) {
				loader = new TextureMapsLoader();
				loader.addEventListener(LoaderEvent.LOADING_START, onTextureLoadingStart);
				loader.addEventListener(LoaderEvent.LOADING_COMPLETE, onTextureLoadingComplete);
				loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.addEventListener(Event.COMPLETE, onMaterialTexturesLoadingComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onMaterialTexturesLoadingComplete);
			} else {
				close();
			}
			// Получение массива имён материалов и подсчёт количества файлов текстур
			totalFiles = 0;
			materialNames = new Array();
			for (var materialName:String in batch) {
				materialNames.push(materialName);
				var info:TextureMapsInfo = batch[materialName];
				totalFiles += info.opacityMapFileName == null ? 1 : 2;
			}
			// Старт загрузки
			currFileIndex = 0;
			materialIndex = 0;
			_textures = new Map();
			loadNextTextureFile();
		}
		
		/**
		 * Загружает очередной файл с текстурой.
		 */
		private function loadNextTextureFile():void {
			var info:TextureMapsInfo = batch[materialNames[materialIndex]];
			loader.load(baseUrl + info.diffuseMapFileName, info.opacityMapFileName == null ? null : baseUrl + info.opacityMapFileName, loaderContext);
		}
		
		/**
		 * Ретранслирует событие начала загрузки текстуры.
		 */
		private function onTextureLoadingStart(e:Event):void {
			dispatchEvent(e);
		}
		
		/**
		 * Ретранслирует событие окончания загрузки текстуры.
		 */
		private function onTextureLoadingComplete(e:Event):void {
			dispatchEvent(e);
			currFileIndex++;
		}

		/**
		 * Рассылает событие прогресса загрузки файлов.
		 */
		private function onProgress(e:ProgressEvent):void {
			dispatchEvent(new LoaderProgressEvent(LoaderProgressEvent.LOADING_PROGRESS, LoadingStage.TEXTURE, totalFiles, currFileIndex, e.bytesLoaded, e.bytesTotal));
		}

		/**
		 * Обрабатывает завершение загрузки текстуры материала.
		 */
		private function onMaterialTexturesLoadingComplete(e:Event):void {
			// В зависимости от полученного события устанавливается загруженное изображение или битмап-заглушка
			if (e is IOErrorEvent) {
				_textures.add(materialNames[materialIndex], getStubBitmapData());
				dispatchEvent(e);
			} else {
				_textures.add(materialNames[materialIndex], loader.bitmapData);
			}
			if ((++materialIndex) == materialNames.length) {
				// Загружены текстуры для всех материалов, отправляется сообщение о завершении
				clean(); 
				dispatchEvent(new Event(Event.COMPLETE));
			} else {
				loadNextTextureFile();
			}
		}
		
	}
}