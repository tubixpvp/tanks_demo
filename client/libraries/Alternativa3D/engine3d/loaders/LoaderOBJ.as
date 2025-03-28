package alternativa.engine3d.loaders {
	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.loaders.events.LoaderEvent;
	import alternativa.engine3d.loaders.events.LoaderProgressEvent;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.TextureMaterialPrecision;
	import alternativa.types.Map;
	import alternativa.types.Texture;
	
	import flash.display.BlendMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	use namespace alternativa3d;

	/**
	 * Загрузчик моделей из файла в формате OBJ. Загрузчик использует класс <code>ParserOBJ</code> для создания объектов из OBJ-файла, после чего выполняет загрузку
	 * библиотек материалов, создаёт материалы и назначает их объектам.
	 * <p>
	 * При загрузке текстурных материалов учитывается наличие карт прозрачности.
	 * </p>
	 *
	 * @see alternativa.engine3d.loaders.ParserOBJ
	 */
	public class LoaderOBJ extends Loader3D {
		
		/**
		 * Если указано значение <code>false</code>, то материалы загружаться не будут.
		 * 
		 * @default true
		 */
		public var loadMaterials:Boolean = true;

		/**
		 * Значение свойства <code>smooth</code> для текстурных материалов.
		 * 
		 * @default false
		 * @see alternativa.engine3d.materials.TextureMaterial#smooth
		 */		
		public var smooth:Boolean = false;
		
		/**
		 * Значение свойства <code>blendMode</code> для текстурных материалов.
		 * 
		 * @default BlendMode.NORMAL
		 * @see alternativa.engine3d.materials.Material#blendMode
		 */
		public var blendMode:String = BlendMode.NORMAL;
		
		/**
		 * Значение свойства <code>precision</code> для текстурных материалов.
		 * 
		 * @default TextureMaterialPrecision.MEDIUM
		 * @see alternativa.engine3d.materials.TextureMaterial#precision
		 * @see alternativa.engine3d.materials.TextureMaterialPrecision
		 */		
		public var precision:Number = TextureMaterialPrecision.MEDIUM;
		
		private static const STATE_LOADING_LIBRARY:int = 3;
		
		private var mtlLoader:LoaderMTL;
		private var materialsLibrary:Map;
		private var uv:Point = new Point();
		private var parser:ParserOBJ;
		
		private var currentMaterialFileIndex:int;
		private var numMaterialFiles:int;
		private var textureMaterials:Map;
		
		private var bitmapsLoader:TextureMapsBatchLoader;

		/**
		 * Создаёт новый экземпляр класса.
		 */
		public function LoaderOBJ() {
			super();
			parser = new ParserOBJ();
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
		 * При установленном значении <code>true</code> объекты будут определяться не ключевым словом "o", а словом "g". Это может быть полезно, т.к. некоторые OBJ-експортёры могут
		 * использовать слово "g" для определения объектов в OBJ-файле.
		 * 
		 * @default false 
		 */
		public function get objectsAsGroups():Boolean {
			return parser.objectsAsGroups;
		}

		/**
		 * @private
		 */
		public function set objectsAsGroups(value:Boolean):void {
			parser.objectsAsGroups = value;
		}

		/**
		 * При установленном значении <code>true</code> выполняется преобразование координат геометрических вершин посредством
		 * поворота на 90 градусов относительно оси X. Смысл флага в преобразовании системы координат, в которой направление вверх определяется осью <code>Y</code>,
		 * в систему координат, использующуюся в Alternativa3D (вверх направлена ось <code>Z</code>).
		 *  
		 * @default false 
		 */
		public function get rotateModel():Boolean {
			return parser.rotateModel;
		}

		/**
		 * @private
		 */		
		public function set rotateModel(value:Boolean):void {
			parser.rotateModel = value;
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
		 * @inheritDoc
		 */
		override protected function closeInternal():void {
			super.closeInternal();
			if (loaderState == Loader3DState.LOADING_LIBRARY) {
				mtlLoader.close();
			}
		}
		
		/**
		 * Метод очищает внутренние ссылки на загруженные данные, чтобы сборщик мусора мог освободить занимаемую ими память. Метод не работает
		 * во время загрузки.
		 */
		override protected function unloadInternal():void {
			if (mtlLoader != null) {
				mtlLoader.unload();
			}
			if (bitmapsLoader != null) {
				bitmapsLoader.unload();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function clean():void {
			super.clean();
			loaderContext = null;
			textureMaterials = null;
		}
		
		/**
		 * Метод выполняет разбор данных, полученных из OBJ-файла.
		 * 
		 * @param s содержимое OBJ-файла 
		 * @param materialLibrary библиотека материалов
		 * @return объект, содержащий все трёхмерные объекты, определённые в OBJ-файле
		 */
		override protected function parse(data:ByteArray):void {
			parser.parse(data.toString());
			// После разбора файла имеем дерево 3д-объектов и массив с именами файлов библиотек материалов
			_content = parser.content;
			// Загружаем библиотеки материалов или заканчиваем работу, если материалов нет
			numMaterialFiles = parser.materialFileNames.length;
			if (loadMaterials && numMaterialFiles > 0) {
				loadMaterialsLibrary();
			} else {
				complete();
			}
		}
		
		/**
 		 * Загружает библиотеки материалов.
 		 * 
		 * @param materialFileNames массив с именами файлов библиотек материалов
		 */
		private function loadMaterialsLibrary():void {
			loaderState = Loader3DState.LOADING_LIBRARY;
			if (mtlLoader == null) {
				mtlLoader = new LoaderMTL();
				mtlLoader.addEventListener(Event.OPEN, onMaterialLibLoadingStart);
				mtlLoader.addEventListener(ProgressEvent.PROGRESS, onMaterialLibLoadingProgress);
				mtlLoader.addEventListener(Event.COMPLETE, onMaterialLibLoadingComplete);
				mtlLoader.addEventListener(IOErrorEvent.IO_ERROR, onMaterialLibLoadingError);
				mtlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onMaterialLibLoadingError);
			}
			materialsLibrary = new Map();
			
			currentMaterialFileIndex = -1;
			loadNextMaterialFile();
		}
		
		/**
		 * Обрабатывает ошибки при загрузке библиотеки материалов.
		 */
		private function onMaterialLibLoadingError(e:ErrorEvent):void {
			close();
			dispatchEvent(e);
		}
		
		/**
		 * 
		 */
		private function onMaterialLibLoadingStart(e:Event):void {
			dispatchEvent(new LoaderEvent(LoaderEvent.LOADING_START, LoadingStage.MATERIAL_LIBRARY));
		}

		/**
		 * 
		 */
		private function onMaterialLibLoadingProgress(e:ProgressEvent):void {
			dispatchEvent(new LoaderProgressEvent(LoaderProgressEvent.LOADING_PROGRESS, LoadingStage.MATERIAL_LIBRARY, numMaterialFiles, currentMaterialFileIndex, e.bytesLoaded, e.bytesTotal));
		}
		
		/**
		 * Обработка успешной загрузки библиотеки материалов.
		 */
		private function onMaterialLibLoadingComplete(e:Event):void {
			dispatchEvent(new LoaderEvent(LoaderEvent.LOADING_COMPLETE, LoadingStage.MATERIAL_LIBRARY));
			// Слияние загруженной библиотеки с уже имеющейся
			materialsLibrary.concat(mtlLoader.library);
			// Загрузка следующего файла материалов
			loadNextMaterialFile();
		}
		
		/**
		 * Загрузка и разбор очередного файла материалов.
		 */
		private function loadNextMaterialFile():void {
			currentMaterialFileIndex++;
			if (currentMaterialFileIndex == numMaterialFiles) {
				// Все материалы загружены, проверяется наличие текстурных материалов и выполняется их загрузка
				checkMaterials();
			} else {
				mtlLoader.load(baseURL + parser.materialFileNames[currentMaterialFileIndex]);
			}
		}
		
		/**
		 * 
		 */
		private function checkMaterials():void {
			collectTextureMaterialNames();
			if (textureMaterials != null) {
				loadTextures();
			} else {
				setMaterials();
				complete();
			}
		}

		/**
		 * Запускает процесс загрузки текстур.
		 */
		private function loadTextures():void {
			if (bitmapsLoader == null) {
				bitmapsLoader = new TextureMapsBatchLoader();
				bitmapsLoader.addEventListener(LoaderEvent.LOADING_START, onTextureLoadingStart);
				bitmapsLoader.addEventListener(LoaderEvent.LOADING_COMPLETE, onTextureLoadingComplete);
				bitmapsLoader.addEventListener(LoaderProgressEvent.LOADING_PROGRESS, onTextureLoadingProgress);
				bitmapsLoader.addEventListener(Event.COMPLETE, onTextureMaterialsLoadingComplete);
				bitmapsLoader.addEventListener(IOErrorEvent.IO_ERROR, onTextureLoadingError);
			}
			setState(Loader3DState.LOADING_TEXTURE);
			bitmapsLoader.load(baseURL, textureMaterials, loaderContext);
		}
		
		/**
		 * Обрабатывает неудачную загрузку текстуры.
		 */
		private function onTextureLoadingError(e:IOErrorEvent):void {
			dispatchEvent(e);
		}
		
		/**
		 * Обрабатывает начало загрузки очередного файла текстуры.
		 */
		private function onTextureLoadingStart(e:Event):void {
			dispatchEvent(e);
		}

		/**
		 * Обрабатывает окончание загрузки очередного файла текстуры.
		 */
		private function onTextureLoadingComplete(e:Event):void {
			dispatchEvent(e);
		}
		
		/**
		 * Рассылает событие прогресса загрузки файла текстуры.
		 */
		private function onTextureLoadingProgress(e:LoaderProgressEvent):void {
			dispatchEvent(e);
		}
		
		/**
		 * Обрабатывает завершение загрузки текстур материала.
		 */
		private function onTextureMaterialsLoadingComplete(e:Event):void {
			setMaterials();
			complete();
		}
		
		/**
		 * 
		 */
		private function collectTextureMaterialNames():void {
			for (var materialName:String in materialsLibrary) {
				var info:MTLMaterialInfo = materialsLibrary[materialName];
				if (info.diffuseMapInfo != null) {
					if (textureMaterials == null) {
						textureMaterials = new Map();
					}
					var textureMapsInfo:TextureMapsInfo = new TextureMapsInfo();
					textureMapsInfo.diffuseMapFileName = info.diffuseMapInfo.fileName;
					if (info.dissolveMapInfo != null) {
						textureMapsInfo.opacityMapFileName = info.dissolveMapInfo.fileName;
					}
					textureMaterials.add(materialName, textureMapsInfo);
				}
			}
		}
		
		/**
		 * Устанавливает материалы.
		 */
		private function setMaterials():void {
			if (materialsLibrary != null) {
				for (var objectKey:* in _content.children) {
					var object:Mesh = objectKey;
					for (var surfaceKey:* in object._surfaces) {
						var surface:Surface = object._surfaces[surfaceKey];
						// Поверхности имеют идентификаторы, соответствующие именам материалов
						var materialInfo:MTLMaterialInfo = materialsLibrary[surfaceKey];
						if (materialInfo != null) {
							if (materialInfo.diffuseMapInfo == null) {
								surface.material = new FillMaterial(materialInfo.color, materialInfo.alpha, blendMode);
							} else {
								var texture:Texture = new Texture(bitmapsLoader.textures[surfaceKey], materialInfo.diffuseMapInfo.fileName);
								surface.material = new TextureMaterial(texture, materialInfo.alpha, materialInfo.diffuseMapInfo.repeat, smooth, blendMode, -1, 0, precision);
								transformUVs(surface, new Point(materialInfo.diffuseMapInfo.offsetU, materialInfo.diffuseMapInfo.offsetV), new Point(materialInfo.diffuseMapInfo.sizeU, materialInfo.diffuseMapInfo.sizeV));
							}
						}
					}
				}
			}
		}
		
		/**
		 * Метод выполняет преобразование UV-координат текстурированных граней. В связи с тем, что в формате MTL предусмотрено
		 * масштабирование и смещение текстурной карты в UV-пространстве, а в движке такой фунциональности нет, необходимо
		 * эмулировать преобразования текстуры преобразованием UV-координат граней. Преобразования выполняются исходя из предположения,
		 * что текстурное пространство сначала масштабируется относительно центра, а затем сдвигается на указанную величину
		 * смещения.
		 * 
		 * @param surface поверхность, грани которой обрабатываюся
		 * @param mapOffset смещение текстурной карты. Значение mapOffset.x указывает смещение по U, значение mapOffset.y
		 * 		указывает смещение по V.
		 * @param mapSize коэффициенты масштабирования текстурной карты. Значение mapSize.x указывает коэффициент масштабирования
		 * 		по оси U, значение mapSize.y указывает коэффициент масштабирования по оси V. 
		 */
		private function transformUVs(surface:Surface, mapOffset:Point, mapSize:Point):void {
			for (var key:* in surface._faces) {
				var face:Face = key;
				if (face._aUV) {
					uv.x = face._aUV.x;
					uv.y = face._aUV.y;
					uv.x = 0.5 + (uv.x - 0.5 - mapOffset.x)*mapSize.x;
					uv.y = 0.5 + (uv.y - 0.5 - mapOffset.y)*mapSize.y;
					face.aUV = uv;
					
					uv.x = face._bUV.x;
					uv.y = face._bUV.y;
					uv.x = 0.5 + (uv.x - 0.5 - mapOffset.x)*mapSize.x;
					uv.y = 0.5 + (uv.y - 0.5 - mapOffset.y)*mapSize.y;
					face.bUV = uv;
					
					uv.x = face._cUV.x;
					uv.y = face._cUV.y;
					uv.x = 0.5 + (uv.x - 0.5 - mapOffset.x)*mapSize.x;
					uv.y = 0.5 + (uv.y - 0.5 - mapOffset.y)*mapSize.y;
					face.cUV = uv;
				}
			}
		}
		
	}
}