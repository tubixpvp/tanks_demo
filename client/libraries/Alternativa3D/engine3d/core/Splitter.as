package alternativa.engine3d.core {

	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.errors.SplitterNeedMoreVerticesError;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;

	use namespace alternativa3d;

	/**
	 * Сплиттеры применяются для управления видимостью отдельных частей сцены. Сплиттеры находятся ближе к корню BSP-дерева, чем обычные полигоны.
	 * Таким образом, они образуют систему ветвей, каждая из которых может быть скрыта от своего соседа.
	 * 
	 * <p>Например, пусть в сцене задан единственный сплиттер, а камера находится в левой ветке. При открытом сплиттере камера будет
	 * иметь возможность видеть содержимое правой ветки. Если же сплиттер закрыт, то содержимое правой ветки дерева не будет отображаться совсем.</p> 
	 * 
	 * <p>Глубина сплиттеров в сцене определяется порядком их расположения в массиве при задании свойства <code>Scene3D.splitters</code>. Каждый
	 * последующий сплиттер разделяет на части пространства, образованные предыдущими сплиттерами. При этом он, как и обычный полигон, может быть
	 * поделён на несколько частей в процессе встраивания в BSP-дерево.</p>
	 *
	 * <p>Для управления видимостью ветвей дерева, образованных системой сплиттеров, дополнительно могут быть использованы объекты класса 
	 * <code>Sector</code>.</p>
	 *
	 * @see Scene3D#splitters
	 * @see Sector
	 */
	public class Splitter {

		// Счетчик имен объекта
		private static var counter:uint = 0;

		/**
		 * Создает сплиттер из грани. Если объект, которому принадлежит грань, находится на сцене,
		 * используются глобальные координаты вершин в сцене, иначе используются локальные координаты вершин грани.
		 *
		 * @param face грань, которая будет использована для создания сплиттера
		 * @param name имя нового экземпляра сплиттера. Если указано значение <code>null</code>, имя будет выбрано автоматически.
		 */
		public static function createFromFace(face:Face, name:String = null):Splitter {
			var src:Array = face._vertices;
			var dest:Array = new Array();
			var i:int;
			if (face._mesh != null && face._mesh._scene != null) {
				var m:Matrix3D = Object3D.matrix2; 
				face._mesh.getTransformation(m);
				for (i = 0; i < face._verticesCount; i++) {
					var p:Point3D = Vertex(src[i])._coords.clone();
					p.transform(m);
					dest[i] = p;
				}
			} else {
				for (i = 0; i < face._verticesCount; i++) {
					dest[i] = Vertex(src[i])._coords;
				}
			}
			return new Splitter(dest, name);
		}

		/**
		 * @private
		 * Изменение состояния сплиттера в БСП дереве.
		 */		
		alternativa3d var changeStateOperation:Operation = new Operation("changeSplitterState", this, changeState, Operation.SPLITTER_CHANGE_STATE);
		/**
		 * @private
		 * Обновление примитива в сцене.
		 */
		alternativa3d var updatePrimitiveOperation:Operation = new Operation("updateSplitter", this, updatePrimitive, Operation.SPLITTER_UPDATE);

		/**
		 * @private
		 * Состояние
		 */
		alternativa3d var _open:Boolean = true;

		/**
		 * @private
		 * Примитив  
		 */
		alternativa3d var primitive:SplitterPrimitive;

		/**
		 * @private
		 * Нормаль 
		 */
		alternativa3d var normal:Point3D = new Point3D();

		/**
		 * @private
		 * Оффсет 
		 */
		alternativa3d var offset:Number;

		/**
		 * @private
		 * Сцена 
		 */
		alternativa3d var _scene:Scene3D;

		/**
		 * Имя объекта. 
		 */
		public var name:String;

		/**
		 * Создает экземпляр сплиттера.
		 *
		 * @param vertices массив координат вершин сплиттера. Плоскость, в которой расположены вершины,
		 * будет использована в качестве плоскости сплиттера.
		 * 
		 * @param name имя объекта. Если указано значение <code>null</code>, имя будет выбрано автоматически.
		 * 
		 * @throws alternativa.engine3d.errors.SplitterNeedMoreVerticesError для создания сплиттера было передано менее трех точек.
		 */
		public function Splitter(vertices:Array, name:String = null) {
			var count:int = vertices.length;
			if (count < 3) {
				throw new SplitterNeedMoreVerticesError(count);
			}
			primitive = SplitterPrimitive.create();
			primitive.mobility = int.MIN_VALUE;
			primitive.splitter = this;
			for (var i:int = 0; i < count; i++) {
				primitive.points[i] = Point3D(vertices[i]).clone();
			}
			primitive.num = count;
			calculatePlane();

			this.name = (name != null) ? name : "splitter" + ++counter;
		}

		/**
		 * Список вершин сплиттера. Элементами являются объекты класса <code>Point3D</code>.
		 */
		public function get vertices():Array {
			var res:Array = new Array().concat(primitive.points);
			for (var i:int = 0; i < primitive.num; i++) {
				res[i] = Point3D(res[i]).clone();
			}
			return res;
		}

		/**
		 * Состояние сплиттера. При закрытом состоянии сплиттера в камере не рисуются части сцены,
		 * расположенные в соседней ветке относительно данного сплиттера.
		 */
		public function get open():Boolean {
			return _open;
		}

		/**
		 * @private
		 */
		public function set open(value:Boolean):void {
			if (_open != value) {
				_open = value;
				if (_scene != null) {
					_scene.addOperation(changeStateOperation);
				}
			}
		}

		/**
		 * Создаёт строковое представление объекта.
		 * 
		 * @return строковое представление объекта
		 */
		public function toString():String {
			return "[Splitter " + name + ((_open) ? " open]" : " closed]");
		}

		/**
		 * @private
		 * Добавление на сцену 
		 */
		alternativa3d function addToScene(scene:Scene3D):void {
			_scene = scene

			// Изменение состояния вызывает перерисовку
			changeStateOperation.addSequel(_scene.changePrimitivesOperation);
			// Обновление сплиттеров в сцене вызывает перевставку
			_scene.updateBSPOperation.addSequel(updatePrimitiveOperation);
		}

		/**
		 * @private
		 * Удаление из сцены
		 */
		alternativa3d function removeFromScene(scene:Scene3D):void {
			changeStateOperation.removeSequel(scene.changePrimitivesOperation);
			scene.updateBSPOperation.removeSequel(updatePrimitiveOperation);

			scene.removeOperation(changeStateOperation);

			// Удаляем примитив сплиттера из сцены
			removePrimitive(primitive);

			_scene = null
		}

		/**
		 * @private
		 * Расчет нормали и оффсета плоскости. 
		 */
		private function calculatePlane():void {
			// Вектор AB
			var av:Point3D = primitive.points[0];
			var bv:Point3D = primitive.points[1];
			var abx:Number = bv.x - av.x;
			var aby:Number = bv.y - av.y;
			var abz:Number = bv.z - av.z;
			// Вектор AC
			var cv:Point3D = primitive.points[2];
			var acx:Number = cv.x - av.x;
			var acy:Number = cv.y - av.y;
			var acz:Number = cv.z - av.z;
			// Перпендикуляр к плоскости
			normal.x = acz*aby - acy*abz;
			normal.y = acx*abz - acz*abx;
			normal.z = acy*abx - acx*aby;
			// Нормализация перпендикуляра
			normal.normalize();
			offset = av.x*normal.x + av.y*normal.y + av.z*normal.z;
		}

		/**
		 * @private
		 * Помечает конечные примитивы на удаление.
		 */
		private function updatePrimitive():void {
			removePrimitive(primitive);
		}

		/**
		 * @private
		 * Отправляет на перерисовку примитивы сплиттеровой ноды.
		 */
		private function changeState():void {
			changePrimitiveNode(primitive);
		}

		/**
		 * @private
		 * Отправляет на перерисовку ноды сплиттера. 
		 */
		private function changePrimitiveNode(primitive:PolyPrimitive):void {
			if (primitive.backFragment == null) {
				// Базовый примитив
				changePrimitivesInNode(primitive.node.back);
				changePrimitivesInNode(primitive.node.front);
			} else {
				// Примитив попилился на куски
				changePrimitiveNode(primitive.backFragment);
				changePrimitiveNode(primitive.frontFragment);
			}
		}

		/**
		 * @private
		 * Отправляет на перерисовку ветку бсп дерева.
		 */
		private function changePrimitivesInNode(node:BSPNode):void {
			if (node != null) {
				if (node.primitive != null) {
					_scene.changedPrimitives[node.primitive] = true;
				} else {
					var primitive:*;
					for (primitive in node.frontPrimitives) {
						_scene.changedPrimitives[primitive] = true;
					}
					for (primitive in node.backPrimitives) {
						_scene.changedPrimitives[primitive] = true;
					}
				}
				changePrimitivesInNode(node.back);
				changePrimitivesInNode(node.front);
			}
		}

		/**
		 * @private
		 * Рекурсивно проходит по фрагментам примитива и отправляет конечные фрагменты на удаление из сцены 
		 */
		private function removePrimitive(primitive:PolyPrimitive):void {
			if (primitive.backFragment != null) {
				// Удаляем куски примитива
				removePrimitive(primitive.backFragment);
				removePrimitive(primitive.frontFragment);
				primitive.backFragment = null;
				primitive.frontFragment = null;
			} else {
				// Если примитив в BSP-дереве
				if (primitive.node != null) {
					primitive.node.splitter = null;
					// Удаление примитива
					_scene.removeBSPPrimitive(primitive);
				}
			}
			if (primitive != this.primitive) {
				primitive.parent = null;
				primitive.sibling = null;
				SplitterPrimitive.destroy(primitive as SplitterPrimitive);
			}
		}

	}
}
