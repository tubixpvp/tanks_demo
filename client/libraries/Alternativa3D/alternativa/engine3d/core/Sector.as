package alternativa.engine3d.core {

	import alternativa.engine3d.alternativa3d;
	import alternativa.types.Point3D;
	import alternativa.types.Set;

	use namespace alternativa3d;

	/**
	 * Cектор предоставляет механизм управления видимостью частей сцены, который дополняет систему сплиттеров. Каждый сектор находится в какой-то
	 * из ветвей BSP-дерева, образованных сплиттерами. Также каждый сектор хранит множество других видимых из него секторов.
	 * 
	 * <p>Если камера находится в дочерней ветке узла, образованного сплиттером, то видимость соседней относительно сплиттера ветки определяется
	 * следующим образом:
	 * <ul>
	 * <li>Если в ветке, в которой находится камера, не задан сектор, то видимость соседней ветки определяется состоянием сплиттера.</li>
	 * <li>Если в ветке, в которой находится камера, задан сектор, а в соседней ветке сектор не задан, то видимость соседней ветки определяется
	 * состоянием сплиттера.</li>
	 * <li>Если в обоих ветках заданы сектора, то видимость соседней ветки определяется состоянием сплиттера и взаимной видимостью секторов.
	 * То есть если сектора невидимы друг для друга, то даже при открытом сплиттере соседняя ветка дерева будет невидима для камеры.</li>
	 * </ul>
	 * </p>
	 * 
	 * <p>Сектора задаются в свойстве <code>Scene.sectors</code>.</p>
	 * 
	 * @see Scene3D#sectors
	 * @see Splitter
	 */
	public class Sector {

		// Счетчик имен объекта
		private static var counter:uint = 0;

		/**
		 * @private
		 * Убрать из бсп дерева перед перестроением сплиттеров.
		 */
		alternativa3d var updateOperation:Operation = new Operation("removeSector", this, removeFromBSP, Operation.SECTOR_UPDATE);
		/**
		 * @private
		 * Поиск сплиттеровой ноды в БСП дереве.
		 */
		alternativa3d var findNodeOperation:Operation = new Operation("addSector", this, addToBSP, Operation.SECTOR_FIND_NODE);
		/**
		 * @private
		 * Изименение видимости.
		 */
		alternativa3d var changeVisibleOperation:Operation = new Operation("changeSectorVisibility", this, changeVisible, Operation.SECTOR_CHANGE_VISIBLE);

		/**
		 * @private
		 * Список видимых секторов. 
		 */
		alternativa3d var _visible:Set = new Set();

		/**
		 * @private
		 * Координата x сектора. 
		 */
		private var x:Number;
		/**
		 * @private
		 * Координата y сектора. 
		 */
		private var y:Number;
		/**
		 * @private
		 * Координата z сектора. 
		 */
		private var z:Number;

		/**
		 * @private
		 */
		alternativa3d var _scene:Scene3D;

		// Сплиттеровая нода
		private var _node:BSPNode;

		/**
		 * Имя сектора. 
		 */
		public var name:String;

		/**
		 * Создаёт новый экземпляр сектора. По координатам сектора определяется та дочерняя ветка сплиттера, для которой сектор задает видимость.
		 *
		 * @param x координата по оси X
		 * @param y координата по оси Y
		 * @param z координата по оси Z
		 * @param name имя сектора. При указании <code>null</code> используется автоматически сгенерированное имя.
		 */
		public function Sector(x:Number = 0, y:Number = 0, z:Number = 0, name:String = null) {
			this.name = (name != null) ? name : "sector" + ++counter;
			this.x = x;
			this.y = y;
			this.z = z;
			_visible[this] = true;
			// Обновление в дереве требует перевставки
			updateOperation.addSequel(findNodeOperation);
			// Обновление в дереве требует перерисовки
			findNodeOperation.addSequel(changeVisibleOperation);
		}

		/**
		 * Добавляет сектора в список видимых. Видимость секторов взаимная, поэтому текущий сектор автоматически добавляется
		 * в список видимых для каждого из указанных секторов.
		 * 
		 * @param sector сектор, добавляемый в список видимых
		 * @param sectors дополнительные сектора, добавляемые в список видимых
		 * 
		 * @see #removeVisible() 
		 */
		public function addVisible(sector:Sector, ...sectors):void {
			sector._visible[this] = true;
			_visible[sector] = true;
			sector.markToChange();
			var count:int = sectors.length;
			for (var i:int = 0; i < count; i++) {
				var sc:Sector = sectors[i];
				sc._visible[this] = true;
				_visible[sc] = true;
				sc.markToChange();
			}
			markToChange();
		}

		/**
		 * Удаляет сектора из списка видимых. Видимость секторов взаимная, поэтому текущий сектор автоматически удаляется из списка видимости указанных секторов.
		 * 
		 * @param sector сектор, удаляемый из списка видимости
		 * @param sectors дополнительные сектора, удаляемые из списка видимых
		 * 
		 * @see #addVisible() 
		 */
		public function removeVisible(sector:Sector, ...sectors):void {
			if (_visible[sector] && sector != this) {
				delete sector._visible[this];
				sector.markToChange();
				delete _visible[sector];
				markToChange();
			}
			var count:int = sectors.length;
			for (var i:int = 0; i < count; i++) {
				var sc:Sector = sectors[i];
				if (_visible[sc] && sc != this) {
					delete sc._visible[this];
					sc.markToChange();
					delete _visible[sc];
					markToChange();
				}
			}
		}

		/**
		 * Определяет потенциальную видимость заданного сектора.
		 * 
		 * @param sector сектор, видимость которого проверяется
		 * @return <code>true</code>, если указанный сектор находится в списке видимости текущего, иначе <code>false</code>
		 */
		public function isVisible(sector:Sector):Boolean {
			return _visible[sector];
		}

		/**
		 * Создаёт строковое представление объекта.
		 * 
		 * @return строковое представление объекта
		 */
		public function toString():String {
			var s:String = "[Sector " + name + " X:" + x.toFixed(3) + " Y:" + y.toFixed(3) + " Z:" + z.toFixed(3);
			var sector:Sector;
			var v:String = "";
			for (var sc:* in _visible) {
				if (sc != this) {
					if (sector == null) {
						sector = sc;
						v = sector.name;
					} else {
						sector = sc;
						v += " " + sector.name;
					}
				}
			}
			return (sector == null) ? s + "]" : s + " visible:[" + v + "]]";
		}

		/**
		 * @private
		 */
		alternativa3d function addToScene(scene:Scene3D):void {
			_scene = scene;

			// Перестройка сплиттеров перевставляет сектор
			scene.updateSplittersOperation.addSequel(updateOperation);
			// Изменение видимости вызывает перерисовку
			changeVisibleOperation.addSequel(scene.changePrimitivesOperation);
			// Поиск ноды
			scene.addOperation(findNodeOperation);
		}

		/**
		 * @private 
		 */
		alternativa3d function removeFromScene(scene:Scene3D):void {
			scene.updateSplittersOperation.removeSequel(updateOperation);
			changeVisibleOperation.removeSequel(scene.changePrimitivesOperation);

			scene.removeOperation(findNodeOperation);
			scene.removeOperation(changeVisibleOperation);

			// Убираем сектор из бсп дерева
			removeFromBSP();

			_scene = null;
		}

		/**
		 * @private
		 * Установка приоритета сектора. Используется для сохранения последовательности добавления в дерево.
		 */
		alternativa3d function setLevel(level:int):void {
			findNodeOperation.priority = (findNodeOperation.priority & 0xFF000000) | level;
		}

		/**
		 * @private
		 * Послать операцию обновления видимости на сцену 
		 */
		alternativa3d function markToChange():void {
			if (_scene != null) {
				_scene.addOperation(changeVisibleOperation);
			}
		}

		/**
		 * Убирает сектор из БСП дерева. 
		 */
		private function removeFromBSP():void {
			if (_node != null) {
				if (_node.frontSector == this) {
					_node.frontSector = null;
				} else {
					_node.backSector = null;
				}
				_node = null;
			}
		}

		/**
		 * Поиск сплиттеровой ноды для этого сектора. 
		 */
		private function addToBSP():void {
			findSectorNode(_scene.bsp);
		}

		/**
		 * Рекурсивный поиск ноды сектора.
		 */
		private function findSectorNode(node:BSPNode):void {
			if (node != null && node.splitter != null) {
				var normal:Point3D = node.normal;
				if (x*normal.x + y*normal.y + z*normal.z - node.offset >= 0) {
					if (node.front == null || node.front.splitter == null) {
						if (node.frontSector == null) {
							node.frontSector = this;
							_node = node;
						}
					} else {
						findSectorNode(node.front);
					}
				} else {
					if (node.back == null || node.back.splitter == null) {
						if (node.backSector == null) {
							node.backSector = this;
							_node = node;
						}
					} else {
						findSectorNode(node.back);
					}
				}
			}
		}

		/**
		 * Отправляет примитивы текущего сектора на перерисовку. 
		 */
		private function changeVisible():void {
			if (_node != null) {
				var primitive:*;
				if (_node.frontSector == this) {
					changeNode(_node.front);
				} else {
					changeNode(_node.back);
				}
			}
		}

		/**
		 * Отправляет на перерисовку ветку бсп дерева. 
		 */
		private function changeNode(node:BSPNode):void {
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
				changeNode(node.back);
				changeNode(node.front);
			}
		}

	}
}
