package alternativa.engine3d.loaders {
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.core.Vertex;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.TextureMaterialPrecision;
	import alternativa.engine3d.materials.WireMaterial;
	import alternativa.types.Map;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	import alternativa.utils.ColorUtils;
	import alternativa.utils.MathUtils;
	
	import flash.display.BlendMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	use namespace alternativa3d;
	
	/**
	 * Класс позволяет разобрать бинарные данные в формате 3DS. После разбора данных получается дерево трёхмерных объектов и список используемых текстур.
	 * <p>
	 * В процессе построения дерева объектов неподдерживаемые объекты заменяются экземплярами <code>Object3D</code>.
	 * </p>
	 * <p>
	 * Материалы, для которых указан файл диффузной текстуры, представляются в виде <code>TextureMaterial</code> с пустой текстурой, которая должна быть установлена позднее.
	 * Информация о файлах диффузной карты и карты прозрачности добавляется в список <code>textureMaterials</code>. При этом имена файлов переводятся в нижний регистр.
	 * </p>
	 * <p>
	 * Материалы, для которых файл диффузной текстуры не указан, представляются экземпляром <code>FillMaterial</code> с указанным цветом.
	 * </p>
	 * <p>
	 * При формировании каждого объекта, имеющие одинаковый материал грани объединяются в поверхности. Идентификаторы поверхностей совпадают
	 * с названием соответствующего материала. Если для объекта не задан ни один материал, то все грани помещаются в одну поверхность, для которой
	 * устанавливается материал <code>WireMaterial</code> с линиями серого цвета.
	 * </p>
	 * <p>
	 * Класс имеет ряд свойств, влияющих на создаваемые текстурные материалы.
	 * </p>
	 */
	public class Parser3DS {
		private static const CHUNK_MAIN:uint = 0x4D4D;
		private static const CHUNK_VERSION:uint = 0x0002;
		private static const CHUNK_SCENE:uint = 0x3D3D;
		private static const CHUNK_ANIMATION:uint = 0xB000;
		private static const CHUNK_OBJECT:uint = 0x4000;
		private static const CHUNK_TRIMESH:uint = 0x4100;
		private static const CHUNK_VERTICES:uint = 0x4110;
		private static const CHUNK_FACES:uint = 0x4120;
		private static const CHUNK_FACESMATERIAL:uint = 0x4130;
		private static const CHUNK_MAPPINGCOORDS:uint = 0x4140;
		private static const CHUNK_OBJECTCOLOR:uint = 0x4165;
		private static const CHUNK_TRANSFORMATION:uint = 0x4160;
		private static const CHUNK_MESHANIMATION:uint = 0xB002;
		private static const CHUNK_MATERIAL:uint = 0xAFFF;
		
		private var data:ByteArray;
		// Контейнер с объектами сцены
		private var _content:Object3D;
		// Мапа, хранящая имена файлов текстур. Ключи -- имена материалов, значения -- объекты типа TextureMapsInfo.
		private var _textureMaterials:Map;
		// Флаг повтора текстуры для создаваемых текстурных материалов.
		private var _repeat:Boolean = true;
		// Флаг сглаживания текстур для создаваемых текстурных материалов.
		private var _smooth:Boolean = false;
		// Режим наложения цвета для создаваемых текстурных материалов.
		private var _blendMode:String = BlendMode.NORMAL;
		// Точность перспективной коррекции для создаваемых текстурных материалов.
		private var _precision:Number = TextureMaterialPrecision.MEDIUM;
		// Коэффициент пересчёта единиц измерения сцены. Размеры создаваемых объектов будут умножены на заданное значение.
		private var _scale:Number = 1;
		// Уровень мобильности для загруженных объектов.
		private var _mobility:int = 0;

		// Внутренние переменные для хранения промежуточных данных при разборе
		private var version:uint;
		private var objectDatas:Map;
		private var animationDatas:Array;
		private var materialDatas:Map;
		
		/**
		 * Объект-контейнер, содержащий все загруженные объекты. 
		 */
		public function get content():Object3D {
			return _content;
		}
		
		/**
		 * Флаг повтора текстуры для создаваемых текстурных материалов.
		 * 
		 * @default true
		 * @see alternativa.engine3d.materials.TextureMaterial#repeat
		 */
		public function get repeat():Boolean {
			return _repeat;
		}
		
		/**
		 * @private
		 */
		public function set repeat(value:Boolean):void {
			_repeat = value;
		}
		
		/**
		 * Флаг сглаживания текстур для создаваемых текстурных материалов.
		 * 
		 * @default false
		 * @see alternativa.engine3d.materials.TextureMaterial#smooth
		 */		
		public function get smooth():Boolean {
			return _smooth;
		}
		
		/**
		 * @private
		 */
		public function set smooth(value:Boolean):void {
			_smooth = value;
		}
		
		/**
		 * Режим наложения цвета для создаваемых текстурных материалов.
		 * 
		 * @default BlendMode.NORMAL
		 * @see alternativa.engine3d.materials.Material#blendMode
		 */
		public function get blendMode():String {
			return _blendMode;
		}
		
		/**
		 * @private
		 */
		public function set blendMode(value:String):void {
			_blendMode = value;
		}
		
		/**
		 * Точность перспективной коррекции для создаваемых текстурных материалов.
		 * 
		 * @default TextureMaterialPrecision.MEDIUM
		 * @see alternativa.engine3d.materials.TextureMaterial#precision
		 * @see alternativa.engine3d.materials.TextureMaterialPrecision
		 */		
		public function get precision():Number {
			return _precision;
		}
		
		/**
		 * @private
		 */
		public function set precision(value:Number):void {
			_precision = value;
		}
		
		/**
		 * Коэффициент пересчёта единиц измерения сцены. Размеры создаваемых объектов будут умножены на заданное значение.
		 * @default 1
		 */
		public function get scale():Number {
			return _scale;
		}
		
		/**
		 * @private
		 */
		public function set scale(value:Number):void {
			_scale = value;
		}
		
		/**
		 * Уровень мобильности для загруженных объектов.
		 * @default 0
		 * @see alternativa.engine3d.core.Object3D#mobility
		 */		
		public function get mobility():int {
			return _mobility;
		}
		
		/**
		 * @private
		 */
		public function set mobility(value:int):void {
			_mobility = value;
		}
		
		/**
		 * Список файлов текстур. Ключами являются имена материалов, значениями &mdash; объекты класса <code>TextureMapsInfo</code>, содержащие
		 * имена файлов диффузной текстуры и карты прозрачности.
		 * 
		 * @see alternativa.engine3d.loaders.TextureMapsInfo
		 */
		public function get textureMaterials():Map {
			return _textureMaterials;
		}
		
		/**
		 * Разбирает 3DS-данные и формирует дерево трёхмерных объектов. Чтение данных начинается с текущей позиции в массиве. После успешного окончания работы метода
		 * контейнер с объектами становится доступным через свойство <code>content</code>. Свойство <code>textureMaterials</code> будет содержать имена файлов текстур для каждого
		 * текстурного материала, либо будет равно <code>null</code>, если в сцене нет текстурных материалов.
		 * 
		 * @param data массив с данными в формате 3DS
		 * @return <code>true</code> в случае успешного разбора данных, иначе <code>false</code>
		 * 
		 * @see #content
		 * @see #textureMaterials
		 */
		public function parse(data:ByteArray):Boolean {
			unload();

			if (data.bytesAvailable < 6) {
				return false;
			}
			this.data = data;
			data.endian = Endian.LITTLE_ENDIAN;
			
			try {
				parse3DSChunk(data.position, data.bytesAvailable);
				buildContent();
			} catch (e:Error) {
				unload();
				throw e;
			} finally {
				clean();
			}

			return true;
		}
		
		/**
		 * Удаляет внутренние ссылки на сформированные данные.
		 */
		public function unload():void {
			_content = null;
			_textureMaterials = null;
		}

		/**
		 * Удаляет ссылки на временные данные.
		 */
		private function clean():void {
			version = 0;
			objectDatas = null;
			animationDatas = null;
			materialDatas = null;
		}

		/**
		 * Читает заголовок блока и возвращает его описание.
		 * 
		 * @param dataPosition
		 * @param bytesAvailable
		 * @return 
		 */
		private function readChunkInfo(dataPosition:uint, bytesAvailable:uint):ChunkInfo {
			if (bytesAvailable < 6) {
				return null;
			}
			data.position = dataPosition;
			var chunkInfo:ChunkInfo = new ChunkInfo();
			chunkInfo.id = data.readUnsignedShort();
			chunkInfo.size = data.readUnsignedInt();
			chunkInfo.dataSize = chunkInfo.size - 6;
			chunkInfo.dataPosition = data.position;
			chunkInfo.nextChunkPosition = dataPosition + chunkInfo.size;
			return chunkInfo;
		}

		/**
		 * 
		 */
		private function parse3DSChunk(dataPosition:uint, bytesAvailable:uint):void {
			var chunkInfo:ChunkInfo = readChunkInfo(dataPosition, bytesAvailable);
			if (chunkInfo == null) {
				return;
			}

			data.position = dataPosition;
			
			switch (chunkInfo.id) {
				// Главный
				case CHUNK_MAIN:
					parseMainChunk(chunkInfo.dataPosition, chunkInfo.dataSize);
					break;
			}
			
			parse3DSChunk(chunkInfo.nextChunkPosition, bytesAvailable - chunkInfo.size);
		}

		/**
		 * 
		 */
		private function parseMainChunk(dataPosition:uint, bytesAvailable:uint):void {
			var chunkInfo:ChunkInfo = readChunkInfo(dataPosition, bytesAvailable);
			if (chunkInfo == null) {
				return;
			}
			
			switch (chunkInfo.id) {
				// Версия
				case CHUNK_VERSION:
					version = data.readUnsignedInt();
					break;
				// 3D-сцена
				case CHUNK_SCENE:
					parse3DChunk(chunkInfo.dataPosition, chunkInfo.dataSize);
					break;
				// Анимация
				case CHUNK_ANIMATION:
					parseAnimationChunk(chunkInfo.dataPosition, chunkInfo.dataSize);
					break;
			}
				
			parseMainChunk(chunkInfo.nextChunkPosition, bytesAvailable - chunkInfo.size);
		}

		/**
		 * 
		 */
		private function parse3DChunk(dataPosition:uint, bytesAvailable:uint):void {
			var chunkInfo:ChunkInfo = readChunkInfo(dataPosition, bytesAvailable);
			if (chunkInfo == null) {
				return;
			}

			switch (chunkInfo.id) {
				// Материал
				case CHUNK_MATERIAL:
					// Парсим материал
					var material:MaterialData = new MaterialData();
					parseMaterialChunk(material, chunkInfo.dataPosition, chunkInfo.dataSize);
					break;
				// Объект
				case CHUNK_OBJECT:
					parseObject(chunkInfo);
					break;
			}
				
			parse3DChunk(chunkInfo.nextChunkPosition, bytesAvailable - chunkInfo.size);
		}

		/**
		 * 
		 */
		private function parseObject(chunkInfo:ChunkInfo):void {
			// Создаём список объектов, если надо
			if (objectDatas == null) {
				objectDatas = new Map();
			}
			// Создаём данные объекта
			var object:ObjectData = new ObjectData();
			// Получаем название объекта
			object.name = getString(chunkInfo.dataPosition);
			// Помещаем данные объекта в список
			objectDatas[object.name] = object;
			// Парсим объект
			var offset:int = object.name.length + 1;
			parseObjectChunk(object, chunkInfo.dataPosition + offset, chunkInfo.dataSize - offset);
		}

		/**
		 * 
		 */
		private function parseObjectChunk(object:ObjectData, dataPosition:uint, bytesAvailable:uint):void {
			var chunkInfo:ChunkInfo = readChunkInfo(dataPosition, bytesAvailable);
			if (chunkInfo == null) {
				return;
			}
			
			switch (chunkInfo.id) {
				// Меш
				case CHUNK_TRIMESH:
					parseMeshChunk(object, chunkInfo.dataPosition, chunkInfo.dataSize);
					break;
				// Источник света
				case 0x4600:
					break;
				// Камера
				case 0x4700:
					break;
			}
				
			parseObjectChunk(object, chunkInfo.nextChunkPosition, bytesAvailable - chunkInfo.size);
		}

		/**
		 * 
		 */
		private function parseMeshChunk(object:ObjectData, dataPosition:uint, bytesAvailable:uint):void {
			var chunkInfo:ChunkInfo = readChunkInfo(dataPosition, bytesAvailable);
			if (chunkInfo == null) {
				return;
			}
				
			switch (chunkInfo.id) {
				// Вершины
				case CHUNK_VERTICES:
					parseVertices(object);
					break;
				// UV
				case CHUNK_MAPPINGCOORDS:
					parseUVs(object);
					break;
				// Трансформация
				case CHUNK_TRANSFORMATION:
					parseMatrix(object);
					break;
				// Грани
				case CHUNK_FACES:
					parseFaces(object, chunkInfo);
					break;
			}
				
			parseMeshChunk(object, chunkInfo.nextChunkPosition, bytesAvailable - chunkInfo.size);
		}

		/**
		 * 
		 */
		private function parseVertices(object:ObjectData):void {
			var num:uint = data.readUnsignedShort();
			object.vertices = new Array();
			for (var i:uint = 0; i < num; i++) {
				object.vertices.push(new Point3D(data.readFloat(), data.readFloat(), data.readFloat()));
			}
		}
		
		/**
		 * 
		 */
		private function parseUVs(object:ObjectData):void {
			var num:uint = data.readUnsignedShort();
			object.uvs = new Array();
			for (var i:uint = 0; i < num; i++) {
				object.uvs.push(new Point(data.readFloat(), data.readFloat()));
			}
		}
		
		/**
		 * 
		 */
		private function parseMatrix(object:ObjectData):void {
			object.matrix = new Matrix3D();
			object.matrix.a = data.readFloat();
			object.matrix.e = data.readFloat();
			object.matrix.i = data.readFloat();
			object.matrix.b = data.readFloat();
			object.matrix.f = data.readFloat();
			object.matrix.j = data.readFloat();
			object.matrix.c = data.readFloat();
			object.matrix.g = data.readFloat();
			object.matrix.k = data.readFloat();
			object.matrix.d = data.readFloat();
			object.matrix.h = data.readFloat();
			object.matrix.l = data.readFloat();
		}
		
		/**
		 * 
		 */
		private function parseFaces(object:ObjectData, chunkInfo:ChunkInfo):void {
			var num:uint = data.readUnsignedShort();
			object.faces = new Array();
			for (var i:uint = 0; i < num; i++) {
				var face:FaceData = new FaceData();
				face.a = data.readUnsignedShort();
				face.b = data.readUnsignedShort();
				face.c = data.readUnsignedShort();
				object.faces.push(face);
				data.position += 2; // Пропускаем флаг отрисовки рёбер
			}
			var offset:uint = 2 + 8*num;
			parseFacesChunk(object, chunkInfo.dataPosition + offset, chunkInfo.dataSize - offset);
		}
		
		/**
		 * 
		 */
		private function parseFacesChunk(object:ObjectData, dataPosition:uint, bytesAvailable:uint):void {
			var chunkInfo:ChunkInfo = readChunkInfo(dataPosition, bytesAvailable);
			if (chunkInfo == null) {
				return;
			}
				
			switch (chunkInfo.id) {
				// Поверхности
				case CHUNK_FACESMATERIAL:
					parseSurface(object);
					break;
			}
				
			parseFacesChunk(object, chunkInfo.nextChunkPosition, bytesAvailable - chunkInfo.size);
		}
		
		/**
		 * 
		 */
		private function parseSurface(object:ObjectData):void {
			// Создаём список поверхностей, если надо
			if (object.surfaces == null) {
				object.surfaces = new Map();
			}
			// Создаём данные поверхности
			var surface:SurfaceData = new SurfaceData();
			// Получаем название материала
			surface.materialName = getString(data.position);
			// Помещаем данные поверхности в список
			object.surfaces[surface.materialName] = surface;
			// Получаем грани поверхности
			var num:uint = data.readUnsignedShort();
			surface.faces = new Array(num);
			for (var i:uint = 0; i < num; i++) {
				surface.faces[i] = data.readUnsignedShort();
			}
		}
		
		/**
		 * 
		 */
		private function parseAnimationChunk(dataPosition:uint, bytesAvailable:uint):void {
			var chunkInfo:ChunkInfo = readChunkInfo(dataPosition, bytesAvailable);
			if (chunkInfo == null) {
				return;
			}
			
			switch (chunkInfo.id) {
				// Анимация объекта
				case 0xB001:
				case 0xB002:
				case 0xB003:
				case 0xB004:
				case 0xB005:
				case 0xB006:
				case 0xB007:
					if (animationDatas == null) {
						animationDatas = new Array();
					}
					var animation:AnimationData = new AnimationData();
					animationDatas.push(animation);
					parseObjectAnimationChunk(animation, chunkInfo.dataPosition, chunkInfo.dataSize);
					break;
				// Таймлайн
				case 0xB008:
					break;
			}
			
			parseAnimationChunk(chunkInfo.nextChunkPosition, bytesAvailable - chunkInfo.size);
		}

		/**
		 * 
		 */
		private function parseObjectAnimationChunk(animation:AnimationData, dataPosition:uint, bytesAvailable:uint):void {
			var chunkInfo:ChunkInfo = readChunkInfo(dataPosition, bytesAvailable);
			if (chunkInfo == null) {
				return;
			}

			switch (chunkInfo.id) {
				// Идентификация объекта и его связь
				case 0xB010:
					// Имя объекта
					animation.objectName = getString(data.position);
					data.position += 4;
					// Индекс родительского объекта в линейном списке объектов сцены
					animation.parentIndex = data.readUnsignedShort();
					break;
				// Имя dummy объекта
				case 0xB011:
					animation.objectName = getString(data.position);
					break;
				// Точка привязки объекта (pivot)
				case 0xB013:
					animation.pivot = new Point3D(data.readFloat(), data.readFloat(), data.readFloat());
					break;
				// Смещение объекта относительно родителя
				case 0xB020:
					data.position += 20;
					animation.position = new Point3D(data.readFloat(), data.readFloat(), data.readFloat());
					break;
				// Поворот объекта относительно родителя (angle-axis)
				case 0xB021:
					data.position += 20;
					animation.rotation = getRotationFrom3DSAngleAxis(data.readFloat(), data.readFloat(), data.readFloat(), data.readFloat());
					break;
				// Масштабирование объекта относительно родителя
				case 0xB022:
					data.position += 20;
					animation.scale = new Point3D(data.readFloat(), data.readFloat(), data.readFloat());
					break;
			}
			
			parseObjectAnimationChunk(animation, chunkInfo.nextChunkPosition, bytesAvailable - chunkInfo.size);
		}

		/**
		 * 
		 */
		private function parseMaterialChunk(material:MaterialData, dataPosition:uint, bytesAvailable:uint):void {
			var chunkInfo:ChunkInfo = readChunkInfo(dataPosition, bytesAvailable);
			if (chunkInfo == null) {
				return;
			}

			var textureMapsInfo:TextureMapsInfo;
			switch (chunkInfo.id) {
				// Имя материала
				case 0xA000:
					parseMaterialName(material);
					break;
				// Ambient color
				case 0xA010:
					break;
				// Diffuse color
				case 0xA020:
					data.position = chunkInfo.dataPosition + 6;
					material.color = ColorUtils.rgb(data.readUnsignedByte(), data.readUnsignedByte(), data.readUnsignedByte());
					break;
				// Specular color
				case 0xA030:
					break;
				// Shininess percent
				case 0xA040:
					data.position = chunkInfo.dataPosition + 6;
					material.glossiness = data.readUnsignedShort();
					break;
				// Shininess strength percent
				case 0xA041:
					data.position = chunkInfo.dataPosition + 6;
					material.specular = data.readUnsignedShort();
					break;
				// Transperensy
				case 0xA050:
					data.position = chunkInfo.dataPosition + 6;
					material.transparency = data.readUnsignedShort();
					break;
				// Texture map 1
				case 0xA200:
					material.diffuseMap = new MapData();
					parseMapChunk(material.name, material.diffuseMap, chunkInfo.dataPosition, chunkInfo.dataSize);
					textureMapsInfo = getTextureMapsInfo(material.name);
					textureMapsInfo.diffuseMapFileName = material.diffuseMap.filename;
					break;
				// Texture map 2
				case 0xA33A:
					break;
				// Opacity map
				case 0xA210:
					material.opacityMap = new MapData();
					parseMapChunk(material.name, material.opacityMap, chunkInfo.dataPosition, chunkInfo.dataSize);
					textureMapsInfo = getTextureMapsInfo(material.name);
					textureMapsInfo.opacityMapFileName = material.opacityMap.filename;
					break;
				// Bump map
				case 0xA230:
					//material.normalMap = new MapData();
					//parseMapChunk(material.normalMap, dataIndex, dataLength);
					break;
				// Shininess map
				case 0xA33C:
					break;
				// Specular map
				case 0xA204:
					break;
				// Self-illumination map
				case 0xA33D:
					break;
				// Reflection map
				case 0xA220:
					break;
			}
				
			parseMaterialChunk(material, chunkInfo.nextChunkPosition, bytesAvailable - chunkInfo.size);
		}
		
		/**
		 * 
		 */
		private function getTextureMapsInfo(materialName:String):TextureMapsInfo {
			if (_textureMaterials == null) {
				_textureMaterials = new Map();
			}
			var info:TextureMapsInfo = _textureMaterials[materialName];
			if (info == null) {
				info = new TextureMapsInfo();
				_textureMaterials[materialName] = info;
			}
			return info;
		}

		/**
		 * 
		 */
		private function parseMaterialName(material:MaterialData):void {
			// Создаём список материалов, если надо
			if (materialDatas == null) {
				materialDatas = new Map();
			}
			// Получаем название материала
			material.name = getString(data.position);
			// Помещаем данные материала в список
			materialDatas[material.name] = material;
		}
		
		/**
		 * 
		 */
		private function parseMapChunk(materialName:String, map:MapData, dataPosition:uint, bytesAvailable:uint):void {
			var chunkInfo:ChunkInfo = readChunkInfo(dataPosition, bytesAvailable);
			if (chunkInfo == null) {
				return;
			}

			switch (chunkInfo.id) {
				// Имя файла
				case 0xA300:
					map.filename = getString(chunkInfo.dataPosition).toLowerCase();
					break;
				case 0xA351:
					// Параметры текстурирования
//					trace("MAP OPTIONS", data.readShort().toString(2));
					break;
				// Масштаб по U
				case 0xA354:
					map.scaleU = data.readFloat();
					break;
				// Масштаб по V
				case 0xA356:
					map.scaleV = data.readFloat();
					break;
				// Смещение по U
				case 0xA358:
					map.offsetU = data.readFloat();
					break;
				// Смещение по V
				case 0xA35A:
					map.offsetV = data.readFloat();
					break;
				// Угол поворота
				case 0xA35C:
					map.rotation = data.readFloat();
					break;
			}
			
			parseMapChunk(materialName, map, chunkInfo.nextChunkPosition, bytesAvailable - chunkInfo.size);
		}

		/**
		 * 
		 */
		private function buildContent():void {
			// Формируем связи объектов
			_content = new Object3D("container_3ds");
			
			// Расчёт матриц текстурных материалов
			buildMaterialMatrices();
			
			var i:uint;
			var length:uint;
			var objectName:String;
			var objectData:ObjectData;
			var mesh:Mesh;
			// В сцене есть иерархически связанные оьъекты и (или) указаны данные о трансформации объектов.
			if (animationDatas != null) {
				if (objectDatas != null) {
					length = animationDatas.length;
					for (i = 0; i < length; i++) {
						var animationData:AnimationData = animationDatas[i];
						objectName = animationData.objectName;
						objectData = objectDatas[objectName];
						// Для проверки, не представлен ли один объект в нескольких экземплярах, каждый раз проходим до конца списка секций анимации,
						// проверяя совпадение очередного имени объекта с текущим именем. Если обнаруживается совпадение, в список объектных данных
						// добавляется новая запись. Имя нового объекта формируется из имени оригинального объекта с добавлением значения счётчика.
						if (objectData != null) {
							var nameCounter:uint = 2;
							for (var j:uint = i + 1; j < length; j++) {
								var animationData2:AnimationData = animationDatas[j];
								if (objectName == animationData2.objectName) {
									// Найдено совпадение имени объекта в проверяемой секции анимации. Создаём описание нового экземпляра объекта.
									var newName:String = objectName + nameCounter;
									animationData2.objectName = newName;
									var newObjectData:ObjectData = new ObjectData();
									newObjectData.name = newName;
									if (objectData.vertices != null) {
										newObjectData.vertices = new Array().concat(objectData.vertices);
									}
									if (objectData.uvs != null) {
										newObjectData.uvs = new Array().concat(objectData.uvs);
									}
									if (objectData.matrix != null) {
										newObjectData.matrix = objectData.matrix.clone();
									}
									if (objectData.faces != null) {
										newObjectData.faces = new Array().concat(objectData.faces);
									}
									if (objectData.surfaces != null) {
										newObjectData.surfaces = objectData.surfaces.clone();
									}
									objectDatas[newName] = newObjectData;
									nameCounter++;
								}
							}
						}
						
						if (objectData != null && objectData.vertices != null) {
							// Создание полигонального объекта
							mesh = new Mesh(objectName);
							animationData.object = mesh;
							setBasicObjectProperties(animationData);
							buildMesh(mesh, objectData, animationData);
						} else {
							// Создание пустого 3д-объекта
							var object:Object3D = new Object3D(objectName);
							animationData.object = object;
							setBasicObjectProperties(animationData);
						}
					}
					// Создание дерева объектов
					buildHierarchy();
				}
			} else {
				// В сцене нет иерархически связанных объектов и не заданы трансформации для объектов. В контейнер добавляются только полигональные объекты.
				for (objectName in objectDatas) {
					objectData = objectDatas[objectName];
					if (objectData.vertices != null) {
						// Меш
						mesh = new Mesh(objectName);
						buildMesh(mesh, objectData, null);
						_content.addChild(mesh);
					}
				}
			}
		}

		/**
		 * Расчитывает матрицы преобразования UV-координат для всех текстурных материалов.
		 */
		private function buildMaterialMatrices():void {
			var materialData:MaterialData;
			for (var materialName:String in materialDatas) {
				materialData = materialDatas[materialName];
				var materialMatrix:Matrix = new Matrix();
				var mapData:MapData = materialData.diffuseMap;
				if (mapData != null) {
					var rot:Number = MathUtils.toRadian(mapData.rotation);
					var rotSin:Number = Math.sin(rot);
					var rotCos:Number = Math.cos(rot);
					materialMatrix.translate(-mapData.offsetU, mapData.offsetV);
					materialMatrix.translate(-0.5, -0.5);
					materialMatrix.rotate(-rot);
					materialMatrix.scale(mapData.scaleU, mapData.scaleV);
					materialMatrix.translate(0.5, 0.5);
				}
				materialData.matrix = materialMatrix;
			}
		}
		
		/**
		 * Устанавливает базовые свойства трёхмерных объектов.
		 * 
		 * @param animationData
		 */
		private function setBasicObjectProperties(animationData:AnimationData):void {
			var object:Object3D = animationData.object;
			if (animationData.position != null) {
				object.x = animationData.position.x*_scale;
				object.y = animationData.position.y*_scale;
				object.z = animationData.position.z*_scale;
			}
			if (animationData.rotation != null) {
				object.rotationX = animationData.rotation.x;
				object.rotationY = animationData.rotation.y;
				object.rotationZ = animationData.rotation.z;
			}
			if (animationData.scale != null) {
				object.scaleX = animationData.scale.x;
				object.scaleY = animationData.scale.y;
				object.scaleZ = animationData.scale.z;
			}
			object.mobility = _mobility;
		}
		
		/**
		 * Создаёт геометрию, поверхности и материалы объекта.
		 * 
		 * @param mesh
		 * @param objectData
		 * @param animationData
		 */
		private function buildMesh(mesh:Mesh, objectData:ObjectData, animationData:AnimationData):void {
			// Добавляем вершины
			var i:int;
			var key:*;
			var vertex:Vertex;
			var face:Face;
			var length:int = objectData.vertices.length;
			for (i = 0; i < length; i++) {
				var vertexData:Point3D = objectData.vertices[i];
				objectData.vertices[i] = mesh.createVertex(vertexData.x, vertexData.y, vertexData.z, i);
			}
			// Коррекция вершин
			if (animationData != null) {
				// Инвертируем матрицу
				objectData.matrix.invert();
				// Вычитаем точку привязки из смещения матрицы
				if (animationData.pivot != null) {
					objectData.matrix.d -= animationData.pivot.x;
					objectData.matrix.h -= animationData.pivot.y;
					objectData.matrix.l -= animationData.pivot.z;
				}
				// Трансформируем вершины
				for (key in mesh._vertices) {
					vertex = mesh._vertices[key];
					vertex._coords.transform(objectData.matrix);
				}
			}
			// Преобразование единиц измерения
			for (key in mesh._vertices) {
				vertex = mesh._vertices[key];
				vertex._coords.multiply(_scale);
			}
			// Добавляем грани
			length = (objectData.faces == null) ? 0 : objectData.faces.length;
			for (i = 0; i < length; i++) {
				var faceData:FaceData = objectData.faces[i];
				face = mesh.createFace([objectData.vertices[faceData.a], objectData.vertices[faceData.b], objectData.vertices[faceData.c]], i);
				if (objectData.uvs != null) {
					face.aUV = objectData.uvs[faceData.a];
					face.bUV = objectData.uvs[faceData.b];
					face.cUV = objectData.uvs[faceData.c];
				}
			}
			// Добавляем поверхности
			if (objectData.surfaces != null) {
				for (var surfaceId:String in objectData.surfaces) {
					var materialData:MaterialData = materialDatas[surfaceId];
					var surfaceData:SurfaceData = objectData.surfaces[surfaceId];
					var surface:Surface = mesh.createSurface(surfaceData.faces, surfaceId);
					if (materialData.diffuseMap != null) {
						// Текстурный материал
						length = surfaceData.faces.length;
						for (i = 0; i < length; i++) {
							face = mesh.getFaceById(surfaceData.faces[i]);
							if (face._aUV != null && face._bUV != null && face._cUV != null) {
								var m:Matrix = materialData.matrix;
								var x:Number = face.aUV.x;
								var y:Number = face.aUV.y;
								face._aUV.x = m.a*x + m.b*y + m.tx; 
								face._aUV.y = m.c*x + m.d*y + m.ty; 
								x = face._bUV.x;
								y = face._bUV.y;
								face._bUV.x = m.a*x + m.b*y + m.tx; 
								face._bUV.y = m.c*x + m.d*y + m.ty; 
								x = face._cUV.x;
								y = face._cUV.y;
								face._cUV.x = m.a*x + m.b*y + m.tx; 
								face._cUV.y = m.c*x + m.d*y + m.ty; 
							}
						}
						// Материал создаётся с нулевой текстурой, которая в дальнейшем должна быть установлена внешними средствами
						surface.material = new TextureMaterial(null, 1 - materialData.transparency/100, _repeat, _smooth, _blendMode, -1, 0, _precision);
					} else {
						surface.material = new FillMaterial(materialDatas[surfaceId].color, 1 - materialData.transparency/100);
					}
				}
			} else {
				// Поверхность по умолчанию
				var defaultSurface:Surface = mesh.createSurface();
				// Добавляем грани
				for (var faceId:String in mesh._faces) {
					defaultSurface.addFace(mesh._faces[faceId]);
				}
				defaultSurface.material = new WireMaterial(0, 0x7F7F7F);
			}
		}
		
		/**
		 * Создаёт дерево объектов сцены.
		 */
		private function buildHierarchy():void {
			var len:Number = animationDatas.length;
			for (var i:int = 0; i < len; i++) {
				var animData:AnimationData = animationDatas[i];
				if (animData.parentIndex == 0xFFFF) {
					_content.addChild(animData.object);
				} else {
					AnimationData(animationDatas[animData.parentIndex]).object.addChild(animData.object);
				}
			}
		}

		/**
		 * Считывает строку, заканчивающуюся на нулевой байт.
		 * 
		 * @param index
		 * @return 
		 */
		private function getString(index:uint):String {
			data.position = index;
			var charCode:uint;
			var res:String = "";
			while ((charCode = data.readByte()) != 0) {
				res += String.fromCharCode(charCode);
			}
			return res;
		}
		
		/**
		 * 
		 * @param angle
		 * @param x
		 * @param z
		 * @param y
		 * @return 
		 */
		private function getRotationFrom3DSAngleAxis(angle:Number, x:Number, z:Number, y:Number):Point3D {
			var res:Point3D = new Point3D();
			var s:Number = Math.sin(angle);
			var c:Number = Math.cos(angle);
			var t:Number = 1 - c;
			var k:Number = x*y*t + z*s;
			var half:Number;
			if (k >= 1) {
				half = angle/2;
				res.z = -2*Math.atan2(x*Math.sin(half), Math.cos(half));
				res.y = -Math.PI/2;
				res.x = 0;
				return res;
			}
			if (k <= -1) {
				half = angle/2;
				res.z = 2*Math.atan2(x*Math.sin(half), Math.cos(half));
				res.y = Math.PI/2;
				res.x = 0;
				return res;
			}
			res.z = -Math.atan2(y*s - x*z*t, 1 - (y*y + z*z)*t);
			res.y = -Math.asin(x*y*t + z*s);
			res.x = -Math.atan2(x*s - y*z*t, 1 - (x*x + z*z)*t);			
			return res;
		}
		
	}
}

import alternativa.engine3d.core.Object3D;
import alternativa.types.Matrix3D;
import alternativa.types.Point3D;

import flash.geom.Matrix;
import alternativa.types.Map;
import flash.utils.ByteArray;

class MaterialData {
	public var name:String;
	public var color:uint;
	public var specular:uint;
	public var glossiness:uint;
	public var transparency:uint;
	public var diffuseMap:MapData;
	public var opacityMap:MapData;
	//public var normalMap:MapData;
	public var matrix:Matrix;
}

class MapData {
	public var filename:String;
	public var scaleU:Number = 1;
	public var scaleV:Number = 1;
	public var offsetU:Number = 0;
	public var offsetV:Number = 0;
	public var rotation:Number = 0;
}

class ObjectData {
	public var name:String;
	public var vertices:Array;
	public var uvs:Array;
	public var matrix:Matrix3D;
	public var faces:Array; 
	public var surfaces:Map; 
}

class FaceData {
	public var a:uint;
	public var b:uint;
	public var c:uint;
}

class SurfaceData {
	public var materialName:String;
	public var faces:Array;
}

class AnimationData {
	public var objectName:String;
	public var object:Object3D;
	public var parentIndex:uint;
	public var pivot:Point3D;
	public var position:Point3D;
	public var rotation:Point3D;
	public var scale:Point3D;
}

/**
 * 
 */
class ChunkInfo {
	public var id:uint;
	public var size:uint;
	public var dataSize:uint;
	public var dataPosition:uint;
	public var nextChunkPosition:uint;
}
