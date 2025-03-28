package alternativa.engine3d.loaders {
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.core.Vertex;
	import alternativa.types.Point3D;
	
	import flash.geom.Point;
	
	use namespace alternativa3d;
	
	/**
	 * Класс позволяет разобрать данные в формате OBJ. После обработки данных контейнер с трёхмерными объектами становится доступным через свойство <code>content</code>, а свойство
	 * <code>materialFileNames</code> содержит список имён файлов библиотек материалов. Каждый созданный объект содержит поверхности, идентификаторы которых совпадают с именами
	 * назначенных материалов, но сами материалы поверхностей не создаются, т.к. они будут известны только после загрузки библиотек материалов.
	 * <p>
	 * При разборе данных распознаются следующие ключевые слова формата OBJ:
	 * </p>
	 * <p>
	 * <table border="1" style="border-collapse: collapse">
	 * <tr>
	 *   <th width="30%">Ключевое слово</th>
	 *   <th>Описание</th>
	 *   <th>Действие парсера</th></tr>
	 * <tr>
	 *   <td>o object_name</td>
	 *   <td>Объявление нового объекта с именем object_name</td>
	 *   <td>Если для текущего объекта были определены грани, то команда создаёт новый текущий объект с указанным именем,
	 *       иначе у текущего объекта просто меняется имя на указанное.</td>
	 * </tr>
	 * <tr>
	 *   <td>v x y z</td>
	 *   <td>Объявление вершины с координатами x y z</td>
	 *   <td>Вершина помещается в общий список вершин сцены для дальнейшего использования</td>
	 * </tr>
	 * <tr>
	 *   <td>vt u [v]</td>
	 *   <td>Объявление текстурной вершины с координатами u v</td>
	 *   <td>Вершина помещается в общий список текстурных вершин сцены для дальнейшего использования</td>
	 * </tr>
	 * <tr>
	 *   <td>f v0[/vt0] v1[/vt1] ... vN[/vtN]</td>
	 *   <td>Объявление грани, состоящей из указанных вершин и опционально имеющую заданные текстурные координаты для вершин.</td>
	 *   <td>Грань добавляется к текущему активному объекту. Если есть активный материал, то грань также добавляется в поверхность
	 *       текущего объекта, соответствующую текущему материалу.</td>
	 * </tr>
	 * <tr>
	 *   <td>usemtl material_name</td>
	 *   <td>Установка текущего материала с именем material_name</td>
	 *   <td>С момента установки текущего материала все грани, создаваемые в текущем объекте будут помещаться в поверхность,
	 *       соотвествующую этому материалу и имеющую идентификатор, совпадающий с его именем.</td>
	 * </tr>
	 * <tr>
	 *   <td>mtllib file1 file2 ...</td>
	 *   <td>Объявление файлов, содержащих определения материалов</td>
	 *   <td>Имена файлов добавляются в список.</td>
	 * </tr>
	 * </table></p>
	 */
	public class ParserOBJ {
		
		private static const COMMENT_CHAR:String = "#";
		
		private static const CMD_OBJECT_NAME:String = "o";
		private static const CMD_GROUP_NAME:String = "g";
		private static const CMD_VERTEX:String = "v";
		private static const CMD_TEXTURE_VERTEX:String = "vt";
		private static const CMD_FACE:String = "f";
		private static const CMD_MATERIAL_LIB:String = "mtllib";
		private static const CMD_USE_MATERIAL:String = "usemtl";

		private static const REGEXP_TRIM:RegExp = /^\s*(.*?)\s*$/;
		private static const REGEXP_SPLIT_FILE:RegExp = /\r*\n/;
		private static const REGEXP_SPLIT_LINE:RegExp = /\s+/;

		private var objectKey:String = CMD_OBJECT_NAME;

		// Контейнер, содержащий все определённые в OBJ-файле объекты
		private var _content:Object3D;
		// Текущий конструируемый объект
		private var currentObject:Mesh;
		// Стартовый индекс вершины в глобальном массиве вершин для текущего объекта
		private var vIndexStart:int = 0;
		// Стартовый индекс текстурной вершины в глобальном массиве текстурных вершин для текущего объекта
		private var vtIndexStart:int = 0;
		// Глобальный массив вершин, определённых во входном файле
		private var globalVertices:Array;
		// Глобальный массив текстурных вершин, определённых во входном файле
		private var globalTextureVertices:Array;
		// Имя текущего активного материала. Если значение равно null, то активного материала нет. 
		private var currentMaterialName:String;
		// Массив граней текущего объекта, которым назначен текущий материал
		private var materialFaces:Array;
		// Массив имён файлов, содержащих определения материалов
		private var _materialFileNames:Array;
		// Мобильность объектов
		private var _mobility:int;
		// Коэффициент пересчёта единиц измерения сцены. Размеры создаваемых объектов будут умножены на заданное значение.
		private var _scale:Number = 1;
		// Флаг поворота объектов на 90 градусов по оси X
		private var _rotateModel:Boolean;
		
		/**
		 * Создаёт новый экземпляр класса.
		 */
		public function ParserOBJ() {
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
		 * При установленном значении <code>true</code> объекты будут определяться не ключевым словом "o", а словом "g". Это может быть полезно, т.к. некоторые OBJ-експортёры могут
		 * использовать слово "g" для определения объектов в OBJ-файле.
		 * 
		 * @default false 
		 */
		public function get objectsAsGroups():Boolean {
			return objectKey == CMD_GROUP_NAME;
		}

		/**
		 * @private
		 */
		public function set objectsAsGroups(value:Boolean):void {
			objectKey = value ? CMD_GROUP_NAME : CMD_OBJECT_NAME;
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
		 * При установленном значении <code>true</code> выполняется преобразование координат геометрических вершин посредством
		 * поворота на 90 градусов относительно оси X. Смысл флага в преобразовании системы координат, в которой направление вверх определяется осью <code>Y</code>,
		 * в систему координат, использующуюся в Alternativa3D (вверх направлена ось <code>Z</code>).
		 * 
		 * @default false 
		 */		
		public function get rotateModel():Boolean {
			return _rotateModel;
		}
		
		/**
		 * @private
		 */
		public function set rotateModel(value:Boolean):void {
			_rotateModel = value;
		}
		
		/**
		 * Контейнер, содержащий все определённые в OBJ-файле объекты.
		 */
		public function get content():Object3D {
			return _content;
		}
		
		/**
		 * Массив имён файлов, содержащих библиотеки материалов.
		 */
		public function get materialFileNames():Array {
			return _materialFileNames;
		}
		
		/**
		 * Разбирает содержимое OBJ-файла и формирует объекты.
		 * 
		 * @param data данные OBJ-файла
		 */
		public function parse(data:String):void {
			globalVertices = new Array();
			globalTextureVertices = new Array();
			_materialFileNames = new Array();

			_content = new Object3D();
			createNewObject("");
			
			var lines:Array = data.split(REGEXP_SPLIT_FILE);
			lines.forEach(parseLine);
			moveFacesToSurface();
		}
		
		/**
		 * 
		 */
		private function createNewObject(objectName:String):void {
			currentObject = new Mesh(objectName);
			currentObject.mobility = _mobility;
			_content.addChild(currentObject);
		}

		/**
		 * Разбирает строку входного файла.
		 */
		private function parseLine(line:String, index:int, lines:Array):void {
			line = line.replace(REGEXP_TRIM,"$1");
			if (line.length == 0 || line.charAt(0) == COMMENT_CHAR) {
				return;
			}
			var parts:Array = line.split(REGEXP_SPLIT_LINE);
			switch (parts[0]) {
				// Объявление нового объекта
				case objectKey:
					defineObject(parts[1]);
					break;
				// Объявление вершины
				case CMD_VERTEX:
					globalVertices.push(new Point3D(Number(parts[1])*_scale, Number(parts[2])*_scale, Number(parts[3])*_scale));
					break;
				// Объявление текстурной вершины
				case CMD_TEXTURE_VERTEX:
					globalTextureVertices.push(new Point3D(Number(parts[1]), Number(parts[2]), Number(parts[3])));
					break;
				// Объявление грани
				case CMD_FACE:
					createFace(parts);
					break;
				case CMD_MATERIAL_LIB:
					storeMaterialFileNames(parts);
					break;
				case CMD_USE_MATERIAL:
					setNewMaterial(parts);
					break;
			}
		}
		
		/**
		 * Определяет новый объект.
		 * 
		 * @param objectName имя объекта
		 */
		private function defineObject(objectName:String):void {
			if (currentObject._faces.length == 0) {
				// Если у текущего объекта нет граней, то он остаётся текущим, но меняется имя
				currentObject.name = objectName;
			} else {
				// Если у текущего объекта есть грани, то обявление нового имени создаёт новый объект
				moveFacesToSurface();
				createNewObject(objectName);
			}
			vIndexStart = globalVertices.length;
			vtIndexStart = globalTextureVertices.length;
		}
		
		/**
		 * Создаёт грани в текущем объекте.
		 * 
		 * @param parts массив, содержащий индексы вершин грани, начиная с элемента с индексом 1 
		 */		
		private function createFace(parts:Array):void {
			// Стартовый индекс вершины в объекте для добавляемой грани
			var startVertexIndex:int = currentObject._vertices.length;
			// Создание вершин в объекте
			var faceVertexCount:int = parts.length - 1;
			var vtIndices:Array = new Array(3);
			// Массив идентификаторов вершин грани
			var faceVertices:Array = new Array(faceVertexCount);
			for (var i:int = 0; i < faceVertexCount; i++) {
				var indices:Array = parts[i + 1].split("/");
				// Создание вершины
				var vIdx:int = int(indices[0]);
				// Если индекс положительный, то его значение уменьшается на единицу, т.к. в obj формате индексация начинается с 1.
				// Если индекс отрицательный, то выполняется смещение на его значение назад от стартового глобального индекса вершин для текущего объекта.
				var actualIndex:int = vIdx > 0 ? vIdx - 1 : (vIndexStart + vIdx);
				
				var vertex:Vertex = currentObject._vertices[actualIndex];
				// Если вершины нет в объекте, она добавляется
				if (vertex == null) {
					var p:Point3D = globalVertices[actualIndex];
					if (_rotateModel) {
						// В формате obj направление "вверх" совпадает с осью Y, поэтому выполняется поворот объекта на 90 градусов по оси X 
						vertex = currentObject.createVertex(p.x, -p.z, p.y, actualIndex);
					} else {
						vertex = currentObject.createVertex(p.x, p.y, p.z, actualIndex);
					}
				}
				faceVertices[i] = vertex;
				
				// Запись индекса текстурной вершины
				if (i < 3) {
					vtIndices[i] = int(indices[1]);
				}
			}
			// Создание грани
			var face:Face = currentObject.createFace(faceVertices, currentObject._faces.length);
			// Установка uv координат
			if (vtIndices[0] != 0) {
				p = globalTextureVertices[vtIndices[0] - 1];
				face.aUV = new Point(p.x, p.y);
				p = globalTextureVertices[vtIndices[1] - 1];
				face.bUV = new Point(p.x, p.y);
				p = globalTextureVertices[vtIndices[2] - 1];
				face.cUV = new Point(p.x, p.y);
			}
			// Если есть активный материал, то грань заносится в массив для последующего формирования поверхности в объекте
			if (currentMaterialName != null) {
				materialFaces.push(face);
			}
		}
		
		/**
		 * Сохраняет имена библиотек материалов.
		 * 
		 * @param parts массив, содержащий имена файлов материалов, начиная с элемента с индексом 1
		 */
		private function storeMaterialFileNames(parts:Array):void {
			for (var i:int = 1; i < parts.length; i++) {
				_materialFileNames.push(parts[i]);
			}
		}

		/**
		 * Устанавливает новый текущий материал.
		 * 
		 * @param parts массив, во втором элементе которого содержится имя материала
		 */
		private function setNewMaterial(parts:Array):void {
			// Все сохранённые грани добавляются в соответствующую поверхность текущего объекта
			moveFacesToSurface();
			// Установка нового текущего материала
			currentMaterialName = parts[1];
		}
		
		/**
		 * Добавляет все грани с текущим материалом в поверхность с идентификатором, совпадающим с именем материала. 
		 */
		private function moveFacesToSurface():void {
			if (currentMaterialName != null && materialFaces.length > 0) {
				if (currentObject.hasSurface(currentMaterialName)) {
					// При наличии поверхности с таким идентификатором, грани добавляются в неё
					var surface:Surface = currentObject.getSurfaceById(currentMaterialName);
					for each (var face:* in materialFaces) {
						surface.addFace(face);
					}
				} else {
					// При отсутствии поверхности с таким идентификатором, создатся новая поверхность
					currentObject.createSurface(materialFaces, currentMaterialName);
				}
			}
			if (materialFaces == null) {
				materialFaces = new Array();
			} else {
				materialFaces.length = 0;
			}
		}

	}
}