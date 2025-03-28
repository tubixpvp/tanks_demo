package alternativa.gui.container {
	import alternativa.gui.base.IGUIObject;
	import alternativa.gui.focus.IFocus;
	import alternativa.gui.init.GUI;
	import alternativa.gui.layout.ILayoutManager;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.LayoutManagerBase;
	import alternativa.gui.skin.widget.WidgetSkin;
	import alternativa.gui.widget.Widget;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * Контейнер с поддержкой курсора и клавиатуры
	 */	
	public class WidgetContainer extends Widget implements IContainer {
		
		/**
		 * @private
		 * Графический контейнер объектов 
		 */
		protected var canvas:Sprite;
		/**
		 * @private
		 * Список объектов 
		 */
		protected var _objects:Array;
		/**
		 * Список слушателей изменения количества объектов 
		 */
		private var objectsNumListeners:Array;
		/**
		 * @private
		 * Компоновщик
		 */
		protected var _layoutManager:ILayoutManager;
		/**
		 * @private
		 * Отступ слева
		 */
		protected var _marginLeft:int;
		/**
		 * @private
		 * Отступ сверху
		 */
		protected var _marginTop:int;
		/**
		 * @private
		 * Отступ справа
		 */
		protected var _marginRight:int;
		/**
		 * @private
		 * Отступ снизу
		 */
		protected var _marginBottom:int;
		/**
		 * Скин 
		 */		
		private var skin:WidgetSkin;
		
		/**
		 * @param marginLeft отступ слева
		 * @param marginTop отступ сверху
		 * @param marginRight отступ справа
		 * @param marginBottom отступ снизу
		 */		
		public function WidgetContainer(marginLeft:int = 0, marginTop:int = 0, marginRight:int = 0, marginBottom:int = 0) {
			super();
			
			tabChildren = true;
			mouseChildren = true;
			
			_objects = new Array();
			objectsNumListeners = new Array();
			
			// Создание области для добавления объектов
			canvas = new Sprite();
			canvas.mouseEnabled = false;
			canvas.tabEnabled = false;
			canvas.mouseChildren = true;
			canvas.tabChildren = true;
			addChild(canvas);
			
			// Сохранение отступов
			_marginLeft = marginLeft;
			_marginTop = marginTop;
			_marginRight = marginRight;
			_marginBottom = marginBottom;
			
			// Установка мэнеджера компоновки по умолчанию
			layoutManager = new LayoutManagerBase();
		}
		
		/**
		 * Обновление скина 
		 */		
		override public function updateSkin():void {
			super.updateSkin();
			skin = WidgetSkin(skinManager.getSkin(Widget));
		}
		
		/**
		 * Расчет минимальных размеров контейнера
		 * @return минимальные размеры
		 */	
		override public function computeMinSize():Point {
			// Определяем размер контейнера с отступами
			var newSize:Point = Point(layoutManager.computeMinSize()).add(new Point(_marginLeft + _marginRight, _marginTop + _marginBottom));
			
			newSize.x = Math.max(newSize.x, _minSize.x);
			newSize.y = Math.max(newSize.y, _minSize.y);
			
			minSizeChanged = false;
			
			return newSize;
		}
		
		/**
		 * Расчет предпочтительных размеров контейнера с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */	
		override public function computeSize(_size:Point):Point {
			var size:Point = new Point();
			// Проверка на минимум
			size.x = isStretchable(Direction.HORIZONTAL) ? Math.max(_size.x, _minSize.x, layoutManager.minSize.x) : Math.max(_minSize.x, layoutManager.minSize.x);
			size.y = isStretchable(Direction.VERTICAL) ? Math.max(_size.y, _minSize.y, layoutManager.minSize.y) : Math.max(_minSize.y, layoutManager.minSize.y);
			
			// Определяем размер контента
			var contentSize:Point = layoutManager.computeSize(size.clone().subtract(new Point(_marginLeft + _marginRight, _marginTop + _marginBottom)));
			
			// Определяем размер контейнера с отступами
			var newSize:Point = new Point(contentSize.x + _marginLeft + _marginRight, contentSize.y + _marginTop + _marginBottom);
			
			// Пытаемся принять предлагаемый размер (не меньше размера с учетом контента)
			newSize.x = Math.max(size.x, newSize.x);
			newSize.y = Math.max(size.y, newSize.y);
			
			return newSize;
		}
		
		/**
		 * Отрисовка контейнера в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			// Сохранение текущего размера
			super.draw(size);
			
			var newSize:Point = size.clone();
			// Установка отступов
			if (canvas.x != _marginLeft) canvas.x = _marginLeft;
			if (canvas.y != _marginTop) canvas.y = _marginTop;
			// Отрисовка контента
			var contentSize:Point = layoutManager.draw(new Point(newSize.x - _marginLeft - _marginRight, newSize.y - _marginTop - _marginBottom));
		}
		
		/**
		 * Добавить слушателя изменений количества объектов
		 * @param listener слушатель
		 */		
		public function addObjectsNumListener(listener:IContainerObjectsNumListener):void {
			objectsNumListeners.push(listener);
		}
		/**
		 * Удалить слушателя изменений количества объектов
		 * @param listener слушатель
		 */		
		public function removeObjectsNumListener(listener:IContainerObjectsNumListener):void {
			objectsNumListeners.splice(objectsNumListeners.indexOf(listener), 1);
		}
		
		/**
		 * Рассылка события добавления объектов
		 * @param addedObjects добавленные объекты
		 */		
		private function dispatchObjectsAddedEvent(addedObjects:Array):void {
			for (var i:int = 0; i < objectsNumListeners.length; i++) {
				IContainerObjectsNumListener(objectsNumListeners[i]).objectsAdded(addedObjects);
			}
		}
		/**
		 * Рассылка события удаления объектов 
		 * @param removedObjects удаленные объекты
		 */
		private function dispatchObjectsRemovedEvent(removedObjects:Array):void {
			for (var i:int = 0; i < objectsNumListeners.length; i++) {
				IContainerObjectsNumListener(objectsNumListeners[i]).objectsRemoved(removedObjects);
			}
		}
		
		/**
		 * Добавить объект в контейнер
		 * @param object GUI объект
		 */
		public function addObject(object:IGUIObject):void {			
			_objects.push(object);
			canvas.addChild(DisplayObject(object));
			// Установка скин-менеджера						
			addSkinnableObject(DisplayObject(object));
			// Установка корневого объекта
			if (this.rootObject != null)
				object.rootObject = this.rootObject;
			// Установка родительского контейнера
			object.parentContainer = this;
			
			if (!minSizeChanged) {
				minSizeChanged = true;
			}			
			// Рассылка события
			dispatchObjectsAddedEvent(new Array(object));
		}
		

		// Добавить объект перед существующим объектом
		/*public function addObjectBefore(object:IGUIObject, before:IGUIObject):void {
			_objects.splice(_objects.indexOf(before), 0, object);
			canvas.addChild(DisplayObject(object));
			//установка скин-менеджера
			addSkinnableObject(DisplayObject(object));
			// установка корневого объекта
			if (this.rootObject != null)
				object.rootObject = this.rootObject;
			// установка родительского контейнера
			object.parentContainer = this;
			
			// рассылка события
			//dispatchEvent(new ContainerEvent(ContainerEvent.OBJECTS_NUM_CHANGED, this));
		}

		// Добавить объект после существующего объекта
		public function addObjectAfter(object:IGUIObject, after:IGUIObject):void {
			_objects.splice(_objects.indexOf(after)+1, 0, object);
			canvas.addChild(DisplayObject(object));
			//установка скин-менеджера
			addSkinnableObject(DisplayObject(object));
			// установка корневого объекта
			if (this.rootObject != null)
				object.rootObject = this.rootObject;
			// установка родительского контейнера
			object.parentContainer = this;
			
			// рассылка события
			//dispatchEvent(new ContainerEvent(ContainerEvent.OBJECTS_NUM_CHANGED, this));
		}*/

		/**
		 * Добавить объект в заданную позицию
		 * @param object объект
		 * @param index позиция
		 */		
		public function addObjectAt(object:IGUIObject, index:int):void {
			_objects.splice(index, 0, object);
			canvas.addChild(DisplayObject(object));
			
			// Установка скин-менеджера
			addSkinnableObject(DisplayObject(object));
			// Установка корневого объекта
			if (this.rootObject != null) {
				object.rootObject = this.rootObject;
			}
			// Установка родительского контейнера
			object.parentContainer = this;
			
			if (!minSizeChanged) {
				minSizeChanged = true;
			}
			// Рассылка события
			dispatchObjectsAddedEvent(new Array(object));
		}

		/**
		 * Удалить объект из контейнера
		 * @param object GUI объект
		 */
		public function removeObject(object:IGUIObject):void {			
			_objects.splice(_objects.indexOf(object), 1);
			canvas.removeChild(DisplayObject(object));
			removeSkinnableObject(DisplayObject(object));
			if (!minSizeChanged) {
				minSizeChanged = true;
			}
			// Смена фокуса
			if (object is IFocus) {
				if (IFocus(object).focused) {
					GUI.focusManager.focus = null;
				}
			}
			// Рассылка события
			dispatchObjectsRemovedEvent(new Array(object));
		}

		/**
		 * Удалить объект из определённой позиции
		 * @param index позиция
		 */		
		public function removeObjectAt(index:int):void {
			var object:DisplayObject = _objects[index]; 
			_objects.splice(index, 1);
			canvas.removeChild(DisplayObject(object));
			removeSkinnableObject(DisplayObject(object));
			if (!minSizeChanged) {
				minSizeChanged = true;
			}
			// Смена фокуса
			if (object is IFocus) {
				if (IFocus(object).focused) {
					GUI.focusManager.focus = null;
				}
			}
			// Рассылка события
			dispatchObjectsRemovedEvent(new Array(object));
		}

		// Удалить все объекты
		/*public function removeObjects():void {
			for each (var object:DisplayObject in _objects) {
				canvas.removeChild(object);
				removeSkinnableObject(object);
			}
			_objects = new Array();
			
			// рассылка события
			//dispatchEvent(new ContainerEvent(ContainerEvent.OBJECTS_NUM_CHANGED, this));
		}*/
		
		// Получить объект из определённой позиции
		public function getObjectAt(index:int):IGUIObject {
			return _objects[index];
		}
		
		//Получить индекс заданного объекта
		public function getObjectIndex(object:IGUIObject):int {
			var index:int = _objects.indexOf(object);
			return index;
		}
		
		// Вставить объект в определённую позицию
		/*public function setObjectIndex(object:IGUIObject, index:int):void {
			_objects.splice(_objects.indexOf(object), 1);
			_objects.splice(index, 0, object);
		}

		// Поменять объекты местами
		public function swapObjects(object1:IGUIObject, object2:IGUIObject):void {
			_objects[_objects.indexOf(object1)] = object2;
			_objects[_objects.indexOf(object2)] = object1;
		}

		// Поменять объекты местами
		public function swapObjectsAt(index1:int, index2:int):void {
			var object:IGUIObject = _objects[index1];
			_objects[index1] = _objects[index2];
			_objects[index2] = object;
		}*/

		/**
		 * Наличие объекта в контейнере
		 * @param object объект
		 * @return наличие объекта
		 */
		public function hasObject(object:IGUIObject):Boolean {
			return _objects.indexOf(object) >= 0;
		}
		
		/**
		 * Менеджер компоновки объектов 
		 */
		public function get layoutManager():ILayoutManager {
			return _layoutManager;
		}
		public function set layoutManager(manager:ILayoutManager):void {
			_layoutManager = manager;
			manager.container = this;
		}
		
		/**
		 * Список объектов контейнера 
		 */
		public function get objects():Array {
			return _objects;
		}
		
		/**
		 * Фокусировка
		 */
		override protected function focus():void {}
		/**
		 * Расфокусировка
		 */
		override protected function unfocus():void {}
		
		/**
		 * Наличие дочернего графического объекта
		 * @param child графический объект
		 * @return наличие объекта
		 */		
		override public function contains(child:DisplayObject):Boolean {
			return canvas.contains(child);
		} 
		
		override public function set rootObject(object:IGUIObject):void {
			_rootObject = object;
			for each (var obj:IGUIObject in _objects) {				
				IGUIObject(obj).rootObject = object;		
			}
		}
		
		public function set marginLeft(value:int):void {
			_marginLeft = value;
		}
		/**
		 * Отступ слева
		 */
		public function get marginLeft():int {
			return _marginLeft;
		}
		
		public function set marginTop(value:int):void {
			_marginTop = value;
		}
		/**
		 * Отступ сверху
		 */
		public function get marginTop():int {
			return _marginTop;
		}
		
		public function set marginRight(value:int):void {
			_marginRight = value;
		}
		/**
		 * Отступ справа
		 */
		public function get marginRight():int {
			return _marginRight;
		}
		
		public function set marginBottom(value:int):void {
			_marginBottom = value;
		}
		/**
		 * Отступ снизу
		 */
		public function get marginBottom():int {
			return _marginBottom;
		}
	
	}
}