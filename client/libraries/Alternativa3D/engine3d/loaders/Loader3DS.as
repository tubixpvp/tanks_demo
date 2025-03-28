package alternativa.engine3d.loaders {
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.loaders.events.LoaderEvent;
	import alternativa.engine3d.loaders.events.LoaderProgressEvent;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.types.Texture;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	
	use namespace alternativa3d;

	/**
	 * Загрузчик сцен в формате 3DS.
	 * <p>
	 * Класс предоставляет возможность загрузить 3DS-данные из сети или из бинарного массива. Полученные данные разбираются с помощью класса
	 * <code>Parser3DS</code>, после чего автоматически загружаются текстуры, используемые в сцене, которые затем назначаются текстурным материалам.
	 * Если при загрузке текстуры происходит ошибка (например, файл отсутствует), то текстура заменяется текстурой-заглушкой и рассылается
	 * сообщение <code>IOErrorEvent</code>.
	 * </p>
	 * <p>
	 * Перед загрузкой данных можно установить ряд свойств, влияющих на создаваемые текстурные материалы.
	 * </p>
	 * 
	 * @see alternativa.engine3d.loaders.Parser3DS
	 */
	public class Loader3DS extends Loader3D {
		
		/**
		 * Если указано значение <code>false</code>, то материалы загружаться не будут.
		 * 
		 * @default true
		 */
		public var loadMaterials:Boolean = true;
		
		private var bitmapLoader:TextureMapsBatchLoader;
		private var parser:Parser3DS;
		
		/**
		 * Создаёт новый экземпляр класса.
		 */
		public function Loader3DS() {
			super();
			parser = new Parser3DS();
		}
		
		/**
		 * Значение свойства <code>repeat</code> для текстурных материалов.
		 * 
		 * @default true
		 * @see alternativa.engine3d.materials.TextureMaterial
		 */
		public function get repeat():Boolean {
			return parser.repeat;
		}
		
		/**
		 * @private
		 */
		public function set repeat(value:Boolean):void {
			parser.repeat = value;
		}
		
		/**
		 * Значение свойства <code>smooth</code> для текстурных материалов.
		 * 
		 * @default false
		 * @see alternativa.engine3d.materials.TextureMaterial#smooth
		 */		
		public function get smooth():Boolean {
			return parser.smooth;
		}
		
		/**
		 * @private
		 */
		public function set smooth(value:Boolean):void {
			parser.smooth = value;
		}
		
		/**
		 * Значение свойства <code>blendMode</code> для текстурных материалов.
		 * 
		 * @default BlendMode.NORMAL
		 * @see alternativa.engine3d.materials.Material#blendMode
		 */
		public function get blendMode():String {
			return parser.blendMode;
		}
		
		/**
		 * @private
		 */
		public function set blendMode(value:String):void {
			parser.blendMode = value;
		}
		
		/**
		 * Значение свойства <code>precision</code> для текстурных материалов.
		 * 
		 * @default TextureMaterialPrecision.MEDIUM
		 * @see alternativa.engine3d.materials.TextureMaterial#precision
		 * @see alternativa.engine3d.materials.TextureMaterialPrecision
		 */		
		public function get precision():Number {
			return parser.precision;
		}
		
		/**
		 * @private
		 */
		public function set precision(value:Number):void {
			parser.precision = value;
		}
		
		/**
		 * Коэффициент пересчёта единиц измерения сцены. Размеры создаваемых объектов будут умножены на заданное значение.
		 * @default 1
		 */
		public function get scale():Number {
			return parser.scale;
		}
		
		/**
		 * @private
		 */
		public function set scale(value:Number):void {
			parser.scale = value;
		}
		
		/**
		 * Уровень мобильности для загруженных объектов.
		 * @default 0
		 * @see alternativa.engine3d.core.Object3D#mobility
		 */		
		public function get mobility():int {
			return parser.mobility;
		}
		
		/**
		 * @private
		 */
		public function set mobility(value:int):void {
			parser.mobility = value;
		}
		
		/**
		 * Выполняет действия для прекращения текущей загрузки.
		 */
		override protected function closeInternal():void {
			super.closeInternal();
			if (loaderState == Loader3DState.LOADING_TEXTURE) {
				bitmapLoader.close();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function unloadInternal():void {
			if (bitmapLoader != null) {
				bitmapLoader.unload();
			}
		}
		
		/**
		 * Разбирает загруженные данные.
		 * 
		 * @param data данные в формате 3DS
		 */
		override protected function parse(data:ByteArray):void {
			parser.parse(data);
			_content = parser.content;
			
			if (loadMaterials && parser.textureMaterials != null) {
				loadTextures();
			} else {
				complete();
			}
		}

		/**
		 * Запускает процесс загрузки текстур.
		 */
		private function loadTextures():void {
			if (bitmapLoader == null) {
				bitmapLoader = new TextureMapsBatchLoader();
				bitmapLoader.addEventListener(LoaderEvent.LOADING_START, onTextureLoadingStart);
				bitmapLoader.addEventListener(LoaderEvent.LOADING_COMPLETE, onTextureLoadingComplete);
				bitmapLoader.addEventListener(LoaderProgressEvent.LOADING_PROGRESS, onTextureLoadingProgress);
				bitmapLoader.addEventListener(Event.COMPLETE, onTextureMaterialsLoadingComplete);
				bitmapLoader.addEventListener(IOErrorEvent.IO_ERROR, onTextureLoadingError);
			}
			setState(Loader3DState.LOADING_TEXTURE);
			bitmapLoader.load(baseURL, parser.textureMaterials, loaderContext);
		}
		
		/**
		 * Обрабатывает сообщение об ошибке загрузки текстуры.
		 */
		private function onTextureLoadingError(e:IOErrorEvent):void {
			dispatchEvent(e);
		}
		
		/**
		 * Обрабатывает сообщение о начале загрузки очередной текстуры.
		 */
		private function onTextureLoadingStart(e:LoaderEvent):void {
			if (hasEventListener(e.type)) {
				dispatchEvent(e);
			}
		}

		/**
		 * Обрабатывает сообщение об окончании загрузки очередного файла текстуры.
		 */
		private function onTextureLoadingComplete(e:LoaderEvent):void {
			if (hasEventListener(e.type)) {
				dispatchEvent(e);
			}
		}
		
		/**
		 * Рассылает событие прогресса загрузки очередного файла текстуры.
		 */
		private function onTextureLoadingProgress(e:LoaderProgressEvent):void {
			if (hasEventListener(e.type)) {
				dispatchEvent(e);
			}
		}
		
		/**
		 * Устанавливает текстуры для материалов после завершения загрузки всех текстур.
		 */
		private function onTextureMaterialsLoadingComplete(e:Event):void {
			parser.content.forEach(setTextures);
			complete();
		}
		
		/**
		 * Устанавливает текстуры для текстурных материалов объекта.
		 */
		private function setTextures(object:Object3D):void {
			var mesh:Mesh = object as Mesh;
			if (mesh != null) {
				for (var key:String in mesh._surfaces) {
					var textureMapsInfo:TextureMapsInfo = parser.textureMaterials[key];
					if (textureMapsInfo != null) {
						var texture:Texture = new Texture(bitmapLoader.textures[key], textureMapsInfo.diffuseMapFileName);
						var s:Surface = mesh._surfaces[key];
						TextureMaterial(s.material).texture = texture;
					}
				}
			}
		}
		
	}
}