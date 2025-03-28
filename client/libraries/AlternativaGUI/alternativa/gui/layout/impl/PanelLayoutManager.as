package alternativa.gui.layout.impl {
	import alternativa.gui.base.IGUIObject;
	import alternativa.gui.container.Container;
	import alternativa.gui.container.IContainer;
	import alternativa.gui.layout.ILayoutManager;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.WindowAlign;
	import alternativa.gui.window.panel.ResizeablePanelBase;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class PanelLayoutManager implements ILayoutManager {
		
		/**
		 * @private
		 * Контейнер, с которым работаем
		 */		
		protected var _container:IContainer;
		// Направление
		private var _direction:Boolean;
		// размещаемые объекты
		private var objects:Array;
		// количество объектов
		private var objectsNum:uint;
		// посчитанные размеры объектов
		private var objectsSize:Array;
		// посчитанные минимальные размеры объектов
		private var objectsMinSize:Array;
		// посчитанные относительные координаты объектов
		private var objectsCoord:Dictionary;
		// посчитанные минимальные размеры
		private var _minSize:Point;
		
		private var TOP_MASK:int;
		private var MIDDLE_MASK:int;
		private var BOTTOM_MASK:int;

		private var LEFT_MASK:int;
		private var CENTER_MASK:int;
		private var RIGHT_MASK:int;
	
		
		public function PanelLayoutManager(direction:Boolean = Direction.HORIZONTAL) {
			
			// Сохранение параметров
			_direction = direction;
			
			objectsSize = new Array();
			objectsCoord = new Dictionary(false);
			objectsMinSize = new Array();
			
			// сохранение масок выравнивания
			TOP_MASK = WindowAlign.TOP_MASK;
			MIDDLE_MASK = WindowAlign.MIDDLE_MASK;
			BOTTOM_MASK = WindowAlign.BOTTOM_MASK;
			
			LEFT_MASK = WindowAlign.LEFT_MASK;
			CENTER_MASK = WindowAlign.CENTER_MASK;
			RIGHT_MASK = WindowAlign.RIGHT_MASK;
		}
		
		/**
		 * Вычислить минимальные размеры контента контейнера
		 * @return минимальные размеры
		 */	
		public function computeMinSize():Point {
			objects = _container.objects;
			objectsNum = objects.length;
			
			_minSize = new Point();
			
			// если есть объекты
			if (objectsNum > 0) {
				for(var i:int = 0; i < objectsNum; i++) {
					var object:IGUIObject = IGUIObject(objects[i]);
					
					// пересчет минимальных размеров
					objectsMinSize[i] = object.computeMinSize();
					
					if (Point(objectsMinSize[i]).x > _minSize.x)
						_minSize.x = Point(objectsMinSize[i]).x;
					if (Point(objectsMinSize[i]).y > _minSize.y)
						_minSize.y = Point(objectsMinSize[i]).y;
					
					if (object.currentSize.x > _minSize.x)
						_minSize.x = object.currentSize.x;
					if (object.currentSize.y > _minSize.y)
						_minSize.y = object.currentSize.y;
				}
				//trace("PanelLayoutManager computeMinSize: " + _minSize);
			}
			return _minSize;
		}
		
		/**
		 * Получить минимальный размер контента без пересчета 
		 * @return минимальный размер контента
		 */		
		public function get minSize():Point {
			return _minSize;
		}
		
		/**
		 * Подсчитать размер контента контейнера
		 * @param container контейнер
		 * @param size заданный размер
		 * @return рассчитанный размер
		 * 
		 */		
		public function computeSize(_size:Point):Point {
			
			//if (_size == null) 
				var size:Point = new Point();
			//else 
				//size = _size.clone();
			if (_direction == Direction.HORIZONTAL) {
				size.x = _size.x;
			} else {
				size.y = _size.y;
			}
				
			objects = _container.objects;			
			objectsNum = objects.length;
			
			// если есть объекты
			if (objectsNum > 0) {
				//trace("PanelLayoutManager computeSize size: " + _size);
				for(var i:int = 0; i < objectsNum; i++) {
					// пересчет размеров
					var object:ResizeablePanelBase = ResizeablePanelBase(objects[i]);
					var objectCurrentSize:Point = (object.currentSize != null) ? object.currentSize : new Point();
					//var align:int = object.align;
					//trace("PanelLayoutManager computeSize objectCurrentSize: " + object.currentSize);
					if (object.direction == Direction.VERTICAL) {
						objectsSize[i] = object.computeSize(new Point(objectCurrentSize.x, _size.y));
						if (Point(objectsSize[i]).x > size.x) size.x = Point(objectsSize[i]).x;
					} else {
						objectsSize[i] = object.computeSize(new Point(_size.x, objectCurrentSize.y));
						if (Point(objectsSize[i]).y > size.y) size.y = Point(objectsSize[i]).y;
					}
				}
				//trace("PanelLayoutManager computeSize newSize: " + size);
			}
			return size;
		}
		
		// Отрисовать и расположить
		public function draw(size:Point):Point {
			if (objectsNum > 0) {
				//trace("PanelLayoutManager draw size: " + size);
				for (var i:int = 0; i < objectsNum; i++) {
					var object:ResizeablePanelBase = ResizeablePanelBase(objects[i]);
					var objectSize:Point = Point(objectsSize[i]);
					var align:int = object.align;
					// отрисовка
					//if (objectSize.x != object.currentSize.x || objectSize.y != object.currentSize.y || object is IContainer) {
						//trace("PanelLayoutManager draw objectSize: " + objectSize);
						object.draw(objectSize);
					//}
					// расстановка
					if (object.direction == Direction.HORIZONTAL) {
						object.y = 0;
						if (align & LEFT_MASK) {
							object.x = 0;
						} else if (align & CENTER_MASK) {
							object.x = Math.floor((size.x - objectSize.x)*0.5);
						} else {
							object.x = size.x - objectSize.x;
						}						
					} else {
						object.x = 0;
						if (align & TOP_MASK) {
							object.y = 0;
						} else if (align & MIDDLE_MASK) {
							object.y = Math.floor((size.y - objectSize.y)*0.5);
						} else {
							object.y = size.y - objectSize.y;
						}	
					}
				}
			}
			
			return size;
		}
		
		/**
		 * Контейнер, с которым работаем 
		 */		
		public function set container(c:IContainer):void {
			_container = c;
		}

	}
}