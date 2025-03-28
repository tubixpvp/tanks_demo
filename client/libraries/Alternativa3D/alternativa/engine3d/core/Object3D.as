package alternativa.engine3d.core {

	import alternativa.engine3d.*;
	import alternativa.engine3d.errors.Object3DHierarchyError;
	import alternativa.engine3d.errors.Object3DNotFoundError;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	import alternativa.types.Set;
	import alternativa.utils.ObjectUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	use namespace alternativa3d;

	/**
 	 * Событие рассылается когда пользователь последовательно нажимает и отпускает левую кнопку мыши над одним и тем же объектом.
 	 * Между нажатием и отпусканием кнопки могут происходить любые другие события.
	 * 
	 * @eventType alternativa.engine3d.events.MouseEvent3D.CLICK
	 */
	[Event (name="click", type="alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь нажимает левую кнопку мыши над объектом.
	 * 
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_DOWN
	 */		
	[Event (name="mouseDown", type="alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь отпускает левую кнопку мыши над объектом.
	 * 
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_UP
	 */		
	[Event (name="mouseUp", type="alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь наводит курсор мыши на объект.
	 * 
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_OVER
	 */		
	[Event (name="mouseOver", type="alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь уводит курсор мыши с объекта.
	 * 
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_OUT
	 */
	[Event (name="mouseOut", type="alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь перемещает курсор мыши над объектом.
	 * 
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_MOVE
	 */
	[Event (name="mouseMove", type="alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь вращает колесо мыши над объектом.
	 * 
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_WHEEL
	 */
	[Event (name="mouseWheel", type="alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Базовый класс для объектов, находящихся в сцене. Класс реализует иерархию объектов сцены, а также содержит сведения
	 * о трансформации объекта как единого целого.
	 * 
	 * <p> Масштабирование, ориентация и положение объекта задаются в родительской системе координат. Результирующая
	 * локальная трансформация является композицией операций масштабирования, поворотов объекта относительно осей
	 * <code>X</code>, <code>Y</code>, <code>Z</code> и параллельного переноса центра объекта из начала координат.
	 * Операции применяются в порядке их перечисления.</p>
	 * 
	 * <p> Глобальная трансформация (в системе координат корневого объекта сцены) является композицией трансформаций
	 * самого объекта и всех его предков по иерархии объектов сцены.</p>
	 * 
	 * <p> Класс реализует интерфейс <code>flash.events.IEventDispatcher</code> и может рассылать мышиные события, содержащие информацию
	 * о точке в трёхмерном пространстве, в которой произошло событие. На данный момент не реализованы capture и bubbling фазы рассылки
	 * событий.</p>
	 */
	public class Object3D implements IEventDispatcher {
		/**
		 * @private
		 * Вспомогательная матрица
		 */
		alternativa3d static var matrix1:Matrix3D = new Matrix3D();
		/**
		 * @private
		 * Вспомогательная матрица
		 */
		alternativa3d static var matrix2:Matrix3D = new Matrix3D();

		/**
		 * @private
		 * Поворот или масштабирование
		 */		
		alternativa3d var changeRotationOrScaleOperation:Operation = new Operation("changeRotationOrScale", this);
		/**
		 * @private
		 * Перемещение
		 */		
		alternativa3d var changeCoordsOperation:Operation = new Operation("changeCoords", this);
		/**
		 * @private
		 * Расчёт матрицы трансформации
		 */		
		alternativa3d var calculateTransformationOperation:Operation = new Operation("calculateTransformation", this, calculateTransformation, Operation.OBJECT_CALCULATE_TRANSFORMATION);  
		/**
		 * @private
		 * Изменение уровеня мобильности
		 */		
		alternativa3d var calculateMobilityOperation:Operation = new Operation("calculateMobility", this, calculateMobility, Operation.OBJECT_CALCULATE_MOBILITY);

		// Инкремент количества объектов
		private static var counter:uint = 0;

		/**
		 * @private
		 * Наименование
		 */		
		alternativa3d var _name:String;
		/**
		 * @private
		 * Сцена
		 */		
		alternativa3d var _scene:Scene3D;
		/**
		 * @private
		 * Родительский объект
		 */		
		alternativa3d var _parent:Object3D;
		/**
		 * @private
		 * Дочерние объекты
		 */		
		alternativa3d var _children:Set = new Set();
		/**
		 * @private
		 * Уровень мобильности
		 */		
		alternativa3d var _mobility:int = 0;
		/**
		 * @private
		 */
		alternativa3d var inheritedMobility:int;
		/**
		 * @private
		 * Координаты объекта относительно родителя
		 */		
		alternativa3d var _coords:Point3D = new Point3D();
		/**
		 * @private
		 * Поворот объекта по оси X относительно родителя. Угол измеряется в радианах.
		 */		
		alternativa3d var _rotationX:Number = 0;
		/**
		 * @private
		 * Поворот объекта по оси Y относительно родителя. Угол измеряется в радианах.
		 */		
		alternativa3d var _rotationY:Number = 0;
		/**
		 * @private
		 * Поворот объекта по оси Z относительно родителя. Угол измеряется в радианах.
		 */		
		alternativa3d var _rotationZ:Number = 0;
		/**
		 * @private
		 * Мастшаб объекта по оси X относительно родителя
		 */		
		alternativa3d var _scaleX:Number = 1;
		/**
		 * @private
		 * Мастшаб объекта по оси Y относительно родителя
		 */		
		alternativa3d var _scaleY:Number = 1;
		/**
		 * @private
		 * Мастшаб объекта по оси Z относительно родителя
		 */		
		alternativa3d var _scaleZ:Number = 1;
		/**
		 * @private
		 * Полная матрица трансформации, переводящая координаты из локальной системы координат объекта в систему координат сцены
		 */		
		alternativa3d var _transformation:Matrix3D = new Matrix3D();
		/**
		 * @private
		 * Координаты в сцене
		 */		
		alternativa3d var globalCoords:Point3D = new Point3D();

		/**
		 * Флаг указывает, будет ли объект принимать мышиные события.
		 */
		public var mouseEnabled:Boolean = true;
		/**
		 * Диспетчер событий.
		 */
		private var dispatcher:EventDispatcher;

		/**
		 * Создание экземпляра класса.
		 * 
		 * @param name имя экземпляра
		 */
		public function Object3D(name:String = null) {
			// Имя по-умолчанию
			_name = (name != null) ? name : defaultName();
			
			// Последствия операций
			changeRotationOrScaleOperation.addSequel(calculateTransformationOperation);
			changeCoordsOperation.addSequel(calculateTransformationOperation);
		}

		/**
		 * @private
		 * Расчёт трансформации
		 */
		alternativa3d function calculateTransformation():void {
			if (changeRotationOrScaleOperation.queued) {
				// Если полная трансформация
				_transformation.toTransform(_coords.x, _coords.y, _coords.z, _rotationX, _rotationY, _rotationZ, _scaleX, _scaleY, _scaleZ);
				if (_parent != null) {
					_transformation.combine(_parent._transformation);
				}
				// Сохраняем глобальные координаты объекта
				globalCoords.x = _transformation.d;
				globalCoords.y = _transformation.h;
				globalCoords.z = _transformation.l;
			} else {
				// Если только перемещение
				globalCoords.copy(_coords);
				if (_parent != null) {
					globalCoords.transform(_parent._transformation);
				}
				_transformation.offset(globalCoords.x, globalCoords.y, globalCoords.z);
			}
		}

		/**
		 * @private
		 * Расчёт общей мобильности
		 */
		private function calculateMobility():void {
			inheritedMobility = ((_parent != null) ? _parent.inheritedMobility : 0) + _mobility;
		}

		/**
		 * Добавляет дочерний объект. Добавляемый объект удаляется из списка детей предыдущего родителя.
		 * Новой сценой дочернего объекта становится сцена родителя.
		 * 
		 * @param child добавляемый объект
		 * 
		 * @return добавленный объект
		 * 
		 * @throws alternativa.engine3d.errors.Object3DHierarchyError нарушение иерархии объектов сцены
		 */
		public function addChild(child:Object3D):Object3D {

			// Проверка на null
			if (child == null) {
				throw new Object3DHierarchyError(null, this);
			}

			// Проверка на наличие
			if (child._parent == this) {
				return child;
			}

			// Проверка на добавление к самому себе
			if (child == this) {
				throw new Object3DHierarchyError(this, this);
			}

			// Проверка на добавление родительского объекта
			if (child._scene == _scene) {
				// Если объект был в той же сцене, либо оба не были в сцене
				var parentObject:Object3D = _parent;
				while (parentObject != null) {
					if (child == parentObject) {
						throw new Object3DHierarchyError(child, this);
						return null;
					}
					parentObject = parentObject._parent;
				}
			}

			// Если объект был в другом объекте
			if (child._parent != null) {
				// Удалить его оттуда
				child._parent._children.remove(child);
			} else {
				// Если объект был корневым в сцене
				if (child._scene != null && child._scene._root == child) {
					child._scene.root = null;
				}
			}

			// Добавляем в список
			_children.add(child);
			// Указываем себя как родителя
			child.setParent(this);
			// Устанавливаем уровни
			child.setLevel((calculateTransformationOperation.priority & 0xFFFFFF) + 1);
			// Указываем сцену
			child.setScene(_scene);

			return child;
		}

		/**
		 * Удаляет указанный объект из списка детей.
		 * 
		 * @param child удаляемый дочерний объект
		 * 
		 * @return удаленный объект
		 *  
		 * @throws alternativa.engine3d.errors.Object3DNotFoundError указанный объект не содержится в списке детей текущего объекта
		 */
		public function removeChild(child:Object3D):Object3D {
			// Проверка на null
			if (child == null) {
				throw new Object3DNotFoundError(null, this);
			}
			// Проверка на наличие
			if (child._parent != this) {
				throw new Object3DNotFoundError(child, this);
			}
			// Убираем из списка
			_children.remove(child);
			// Удаляем ссылку на родителя
			child.setParent(null);
			// Удаляем ссылку на сцену
			child.setScene(null);

			return child;
		}
		
		/**
		 * @private
		 * Установка родительского объекта.
		 * 
		 * @param value родительский объект
		 */
		alternativa3d function setParent(value:Object3D):void {
			// Отписываемся от сигналов старого родителя
			if (_parent != null) {
				removeParentSequels();
			}
			// Сохранить родителя
			_parent = value;
			// Если устанавливаем родителя
			if (value != null) {
				// Подписка на сигналы родителя
				addParentSequels();
			}
		}

		/**
		 * @private
		 * Установка новой сцены для объекта.
		 * 
		 * @param value сцена
		 */
		alternativa3d function setScene(value:Scene3D):void {
			if (_scene != value) {
				// Если была сцена
				if (_scene != null) {
					// Удалиться из сцены
					removeFromScene(_scene);
				}
				// Если новая сцена
				if (value != null) {
					// Добавиться на сцену
					addToScene(value);
				}
				// Сохранить сцену
				_scene = value;
			} else {
				// Посылаем операцию трансформации
				addOperationToScene(changeRotationOrScaleOperation);
				// Посылаем операцию пересчёта мобильности
				addOperationToScene(calculateMobilityOperation);
			}
			// Установить эту сцену у дочерних объектов
			for (var key:* in _children) {
				var object:Object3D = key;
				object.setScene(_scene);
			}
		}
		
		/**
		 * @private
		 * Установка уровня операции трансформации.
		 *  
		 * @param value уровень операции трансформации
		 */
		alternativa3d function setLevel(value:uint):void {
			// Установить уровень операции трансформации и расчёта мобильности
			calculateTransformationOperation.priority = (calculateTransformationOperation.priority & 0xFF000000) | value;
			calculateMobilityOperation.priority = (calculateMobilityOperation.priority & 0xFF000000) | value;
			// Установить уровни у дочерних объектов
			for (var key:* in _children) {
				var object:Object3D = key;
				object.setLevel(value + 1);
			}
		}
		
		/**
		 * @private
		 * Подписка на сигналы родителя.
		 */
		private function addParentSequels():void {
			_parent.changeCoordsOperation.addSequel(changeCoordsOperation);
			_parent.changeRotationOrScaleOperation.addSequel(changeRotationOrScaleOperation);
			_parent.calculateMobilityOperation.addSequel(calculateMobilityOperation);
		}
		
		/**
		 * @private
		 * Удаление подписки на сигналы родителя.
		 */
		private function removeParentSequels():void {
			_parent.changeCoordsOperation.removeSequel(changeCoordsOperation);
			_parent.changeRotationOrScaleOperation.removeSequel(changeRotationOrScaleOperation);
			_parent.calculateMobilityOperation.removeSequel(calculateMobilityOperation);
		}
		
		/**
		 * Метод вызывается при добавлении объекта на сцену. Наследники могут переопределять метод для выполнения
		 * специфических действий.
		 * 
		 * @param scene сцена, в которую добавляется объект
		 */
		protected function addToScene(scene:Scene3D):void {
			// При добавлении на сцену полная трансформация и расчёт мобильности
			scene.addOperation(changeRotationOrScaleOperation);
			scene.addOperation(calculateMobilityOperation);
		}

		/**
		 * Метод вызывается при удалении объекта со сцены. Наследники могут переопределять метод для выполнения
		 * специфических действий.
		 * 
		 * @param scene сцена, из которой удаляется объект
		 */
		protected function removeFromScene(scene:Scene3D):void {
			// Удаляем все операции из очереди
			scene.removeOperation(changeRotationOrScaleOperation);
			scene.removeOperation(changeCoordsOperation);
			scene.removeOperation(calculateMobilityOperation);
		}

		/**
		 * Имя объекта. 
		 */
		public function get name():String {
			return _name;
		}

		/**
		 * @private
		 */
		public function set name(value:String):void {
			_name = value;
		}

		/**
		 * Сцена, которой принадлежит объект.
		 */
		public function get scene():Scene3D {
			return _scene;
		}

		/**
		 * Родительский объект.
		 */
		public function get parent():Object3D {
			return _parent;
		}
		
		/**
		 * Набор дочерних объектов.
		 */
		public function get children():Set {
			return _children.clone();
		}
		
		/**
		 * Уровень мобильности. Результирующая мобильность объекта является суммой мобильностей объекта и всех его предков
		 * по иерархии объектов в сцене. Результирующая мобильность влияет на положение объекта в BSP-дереве. Менее мобильные
		 * объекты находятся ближе к корню дерева, чем более мобильные.
		 */
		public function get mobility():int {
			return _mobility;
		}
		
		/**
		 * @private
		 */
		public function set mobility(value:int):void {
			if (_mobility != value) {
				_mobility = value;
				addOperationToScene(calculateMobilityOperation);
			}
		}

		/**
		 * Координата X.
		 */
		public function get x():Number {
			return _coords.x;
		}

		/**
		 * Координата Y.
		 */
		public function get y():Number {
			return _coords.y;
		}

		/**
		 * Координата Z.
		 */
		public function get z():Number {
			return _coords.z;
		}

		/**
		 * @private
		 */
		public function set x(value:Number):void {
			if (_coords.x != value) {
				_coords.x = value;
				addOperationToScene(changeCoordsOperation);
			}
		}

		/**
		 * @private
		 */
		public function set y(value:Number):void {
			if (_coords.y != value) {
				_coords.y = value;
				addOperationToScene(changeCoordsOperation);
			}
		}

		/**
		 * @private
		 */
		public function set z(value:Number):void {
			if (_coords.z != value) {
				_coords.z = value;
				addOperationToScene(changeCoordsOperation);
			}
		}

		/**
		 * Координаты объекта.
		 */
		public function get coords():Point3D {
			return _coords.clone();
		}
		
		/**
		 * @private
		 */
		public function set coords(value:Point3D):void {
			if (!_coords.equals(value)) {
				_coords.copy(value);
				addOperationToScene(changeCoordsOperation);
			}
		}
		
		/**
		 * Угол поворота вокруг оси X, заданный в радианах.
		 */
		public function get rotationX():Number {
			return _rotationX;
		}

		/**
		 * Угол поворота вокруг оси Y, заданный в радианах.
		 */
		public function get rotationY():Number {
			return _rotationY;
		}

		/**
		 * Угол поворота вокруг оси Z, заданный в радианах.
		 */
		public function get rotationZ():Number {
			return _rotationZ;
		}

		/**
		 * @private
		 */
		public function set rotationX(value:Number):void {
			if (_rotationX != value) {
				_rotationX = value;
				addOperationToScene(changeRotationOrScaleOperation);
			}
		}		

		/**
		 * @private
		 */
		public function set rotationY(value:Number):void {
			if (_rotationY != value) {
				_rotationY = value;
				addOperationToScene(changeRotationOrScaleOperation);
			}
		}		

		/**
		 * @private
		 */
		public function set rotationZ(value:Number):void {
			if (_rotationZ != value) {
				_rotationZ = value;
				addOperationToScene(changeRotationOrScaleOperation);
			}
		}
		
		/**
		 * Коэффициент масштабирования вдоль оси X.
		 */
		public function get scaleX():Number {
			return _scaleX;
		}

		/**
		 * Коэффициент масштабирования вдоль оси Y.
		 */
		public function get scaleY():Number {
			return _scaleY;
		}

		/**
		 * Коэффициент масштабирования вдоль оси Z.
		 */
		public function get scaleZ():Number {
			return _scaleZ;
		}

		/**
		 * @private
		 */
		public function set scaleX(value:Number):void {
			if (_scaleX != value) {
				_scaleX = value;
				addOperationToScene(changeRotationOrScaleOperation);
			}
		}

		/**
		 * @private
		 */
		public function set scaleY(value:Number):void {
			if (_scaleY != value) {
				_scaleY = value;
				addOperationToScene(changeRotationOrScaleOperation);
			}
		}

		/**
		 * @private
		 */
		public function set scaleZ(value:Number):void {
			if (_scaleZ != value) {
				_scaleZ = value;
				addOperationToScene(changeRotationOrScaleOperation);
			}
		}

		/**
		 * Строковое представление объекта.
		 * 
		 * @return строковое представление объекта
		 */
		public function toString():String {
			return "[" + ObjectUtils.getClassName(this) + " " + _name + "]";
		}

		/**
		 * Имя объекта по умолчанию.
		 * 
		 * @return имя объекта по умолчанию
		 */		
		protected function defaultName():String {
			return "object" + ++counter;
		}

		/**
		 * @private
		 * Добавление операции в очередь.
		 * 
		 * @param operation добавляемая операция
		 */
		alternativa3d function addOperationToScene(operation:Operation):void {
			if (_scene != null) {
				_scene.addOperation(operation);
			}
		}

		/**
		 * @private
		 * Удаление операции из очереди.
		 * 
		 * @param operation удаляемая операция
		 */
		alternativa3d function removeOperationFromScene(operation:Operation):void {
			if (_scene != null) {
				_scene.removeOperation(operation);
			}
		}

		/**
		 * Создаёт пустой объект без какой-либо внутренней структуры. Например, если некоторый геометрический примитив при
		 * своём создании формирует набор вершин, граней и поверхностей, то этот метод не должен создавать вершины, грани и
		 * поверхности. Данный метод используется в методе clone() и должен быть переопределён в потомках для получения
		 * правильного объекта.
		 * 
		 * @return новый пустой объект
		 */
		protected function createEmptyObject():Object3D {
			return new Object3D();
		}

		/**
		 * Копирует свойства объекта-источника. Данный метод используется в методе clone() и должен быть переопределён в
		 * потомках для получения правильного объекта. Каждый потомок должен в переопределённом методе копировать только те
		 * свойства, которые добавлены к базовому классу именно в нём. Копирование унаследованных свойств выполняется
		 * вызовом super.clonePropertiesFrom(source).
		 * 
		 * @param source объект, свойства которого копируются
		 */
		protected function clonePropertiesFrom(source:Object3D):void {
			_name = source._name;
			_mobility = source._mobility;
			_coords.x = source._coords.x;
			_coords.y = source._coords.y;
			_coords.z = source._coords.z;
			_rotationX = source._rotationX;
			_rotationY = source._rotationY;
			_rotationZ = source._rotationZ;
			_scaleX = source._scaleX;
			_scaleY = source._scaleY;
			_scaleZ = source._scaleZ;
		}

		/**
		 * Клонирует объект. Для реализации собственного клонирования наследники должны переопределять методы
		 * <code>createEmptyObject()</code> и <code>clonePropertiesFrom()</code>.
		 * 
		 * @return клонированный экземпляр объекта
		 * 
		 * @see #createEmptyObject()
		 * @see #clonePropertiesFrom()
		 */
		public function clone():Object3D {
			var copy:Object3D = createEmptyObject();
			copy.clonePropertiesFrom(this);
			
			// Клонирование детей
			for (var key:* in _children) {
				var child:Object3D = key;
				copy.addChild(child.clone());
			}
			
			return copy;
		}

		/**
		 * Получает дочерний объект с заданным именем.
		 * 
		 * @param name имя дочернего объекта
		 * @param deep флаг углублённого поиска. Если задано значение <code>false</code>, поиск будет осуществляться только среди непосредственных
		 * дочерних объектов, иначе поиск будет выполняться по всему дереву дочерних объектов. 
		 * 
		 * @return любой дочерний объект с заданным именем или <code>null</code> в случае отсутствия таких объектов
		 */
		public function getChildByName(name:String, deep:Boolean = false):Object3D {
			var key:*;
			var child:Object3D;
			for (key in _children) {
				child = key;
				if (child._name == name) {
					return child;
				}
			}
			if (deep) {
				for (key in _children) {
					child = key;
					child = child.getChildByName(name, true);
					if (child != null) {
						return child;
					}
				}
			}
			return null;
		}

		/**
		 * Трансформирует точку из локальной системы координат объекта в систему координат сцены. Матрица трансформации корневого объекта сцены
		 * не учитывается, т.к. его система координат является системой координат сцены.
		 *
		 * @param point локальные координаты точки
		 * @param result в этот параметр будут записаны трансформированные координаты. Если передано значение <code>null</code>, то будет создан
		 *   новый экземпляр класса <code>Point3D</code>.
		 *
		 * @return координаты точки в сцене или <code>null</code> в случае, если объект не находится в сцене
		*/
		public function localToGlobal(point:Point3D, result:Point3D = null):Point3D {
			if (_scene == null) {
				return null;
			}
			if (result == null) {
				result = point.clone();
			}

			if (_parent == null) {
				// Для корневого объекта трансформация единичная вне зависимости от матрицы
				return result;
			}

			getTransformation(matrix2);
			result.transform(matrix2);

			return result;
		}

		/**
		 * Трансформирует точку из глобальной системы координат в локальную.
		 * 
		 * @param point точка, заданная в глобальной системе координат.
		 * @param result в этот параметр будут записаны трансформированные координаты. Если передано значение <code>null</code>, то будет создан
		 *   новый экземпляр класса <code>Point3D</code>.
		 * 
		 * @return точка, трансформированная в локальную систему координат объекта или <code>null</code> в случае, если объект не находится в сцене.
		 */
		public function globalToLocal(point:Point3D, result:Point3D = null):Point3D {
			if (_scene == null) {
				return null;
			}
			if (result == null) {
				result = point.clone();
			}
			
			if (_parent == null) {
				// Для корневого объекта трансформация единичная вне зависимости от матрицы
				return result;
			}
			
			getTransformation(matrix2);
			matrix2.invert();
			result.transform(matrix2);
			return result;
		}

		/**
		 * Получает матрицу полной трансформации объекта.
		 * 
		 * @return матрица полной трансформации, переводящая координаты из локальной системы объекта в систему координат сцены или <code>null</code> в случае,
		 * если объект не находится в сцене
		 */
		public function get transformation():Matrix3D {
			if (_scene == null) {
				return null;
			}
			var result:Matrix3D = new Matrix3D();
			getTransformation(result);
			return result;
		}

		/**
		 * Добавляет обработчик события.
		 * 
		 * @param type тип события
		 * @param listener обработчик события
		 * @param useCapture не используется,
		 * @param priority приоритет обработчика. Обработчики с большим приоритетом выполняются раньше. Обработчики с одинаковым приоритетом
		 *   выполняются в порядке их добавления.
		 * @param useWeakReference флаг использования слабой ссылки для обработчика
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			if (dispatcher == null) {
				dispatcher = new EventDispatcher(this);
			}
			useCapture = false;
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		/**
		 * Рассылает событие.
		 * 
		 * @param event посылаемое событие
		 * @return false
		 */
		public function dispatchEvent(event:Event):Boolean {
			if (dispatcher != null) {
				dispatcher.dispatchEvent(event);
			}
			return false;
		}

		/**
		 * Проверяет наличие зарегистрированных обработчиков события указанного типа.
		 * 
		 * @param type тип события
		 * @return <code>true</code> если есть обработчики события указанного типа, иначе <code>false</code>
		 */
		public function hasEventListener(type:String):Boolean {
			if (dispatcher != null) {
				return dispatcher.hasEventListener(type);
			}
			return false;
		}

		/**
		 * Удаляет обработчик события.
		 * 
		 * @param type тип события
		 * @param listener обработчик события
		 * @param useCapture не используется
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			if (dispatcher != null) {
				useCapture = false;
				dispatcher.removeEventListener(type, listener, useCapture);
			}
		}

		/**
		 * 
		 */
		public function willTrigger(type:String):Boolean {
			if (dispatcher != null) {
				return dispatcher.willTrigger(type);
			}
			return false;
		}

		/**
		 * @private
		 * Получение матрицы трансформации объекта. Перед расчётом выполняется проверка необходимости пересчёта матрицы.
		 * 
		 * @param matrix матрица, в которую записывается результат
		 * 
		 * @return <code>true</code>, если был произведён пересчёт матрицы трансформации, <code>false</code>, если пересчёт не понадобился
		 */
		alternativa3d function getTransformation(matrix:Matrix3D):Boolean {
			var rootObject:Object3D = _scene._root;
			var topNonTransformedObject:Object3D;
			var currentObject:Object3D = this;

			// Поиск первого нетрансформированного объекта в дереве объектов
			do {
				if (currentObject.changeCoordsOperation.queued || currentObject.changeRotationOrScaleOperation.queued) {
					topNonTransformedObject = currentObject._parent;
				}
			} while ((currentObject = currentObject._parent) != rootObject);

			if (topNonTransformedObject != null) {
				// Расчёт матрицы трансформации
				matrix.toTransform(_coords.x, _coords.y, _coords.z, _rotationX, _rotationY, _rotationZ, _scaleX, _scaleY, _scaleZ);
				currentObject = this;
				while ((currentObject = currentObject._parent) != topNonTransformedObject) {
					matrix1.toTransform(currentObject._coords.x, currentObject._coords.y, currentObject._coords.z, currentObject._rotationX, currentObject._rotationY, currentObject._rotationZ, currentObject._scaleX, currentObject._scaleY, currentObject._scaleZ);
					matrix.combine(matrix1);
				}
				if (topNonTransformedObject != rootObject) {
					matrix.combine(topNonTransformedObject._transformation);
				}
				return true;
			}
			matrix.copy(_transformation);
			return false;
		}

		/**
		 * Вызывает заданную функцию для объекта и всех его детей, передавая текущий объект в качестве параметра.
		 * 
		 * @param func функция вида Function(object:Object3D):void
		 */
		public function forEach(func:Function):void {
			func.call(this, this);
			for (var child:* in _children) {
				Object3D(child).forEach(func);
			}
		}

	}
}
