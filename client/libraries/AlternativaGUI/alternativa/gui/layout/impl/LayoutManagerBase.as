package alternativa.gui.layout.impl {
	import alternativa.gui.base.IGUIObject;
	import alternativa.gui.base.IHelper;
	import alternativa.gui.base.IManager;
	import alternativa.gui.base.ResizeableBase;
	import alternativa.gui.container.Container;
	import alternativa.gui.container.IContainer;
	import alternativa.gui.container.IContainerObjectsNumListener;
	import alternativa.gui.layout.ILayoutManager;
	import alternativa.gui.layout.snap.ISnapHelper;
	import alternativa.gui.layout.snap.ISnapable;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Компоновщик объектов, устанавливаемый для контейнеров по умолчанию 
	 */	
	public class LayoutManagerBase implements IManager, ILayoutManager, IContainerObjectsNumListener {
		
		/**
		 * @private
		 * Контейнер, с которым работаем
		 */		
		protected var _container:IContainer;
		/**
		 * @private
		 * Размещаемые объекты
		 */		
		protected var objects:Array;
		/**
		 * @private
		 * Количество размещаемых объектов
		 */		
		protected var objectsNum:uint;
		/**
		 * @private
		 * Посчитанные размеры объектов
		 */		
		protected var objectsSize:Array;
		/**
		 * @private
		 * Посчитанные минимальные размеры объектов
		 */		
		protected var objectsMinSize:Array;
		/**
		 * @private
		 * Посчитанные минимальные размеры контейнера
		 */		
		protected var _minSize:Point;
		/**
		 * @private
		 * Нулевой размер для определения минимального
		 */		
		protected const nullSize:Point = new Point();
		/**
		 * @private
		 * Список хэлперов
		 */		
		protected var _helperList:Array;
		
		
		public function LayoutManagerBase()	{
			objects = new Array();
			objectsSize = new Array();
			objectsMinSize = new Array();
			_helperList = new Array();
		}
		
		//----- IManager
		/**
		 * Обработать воздействия на объекты
		 * @param objects список объектов
		 * @param influences список воздействий
		 */
		public function handleInfluences(objects:Array, influences:Array):void {
			// Корректировка хелперами
			for (var n:int = 0; n < _helperList.length; n++) {
				var helper:IHelper = IHelper(_helperList[n]);
				influences = helper.correctInfluence(objects, influences);
			}
			for (var i:int = 0; i < objects.length; i++) {
				if (objects[i] is IGUIObject) {
					var object:IGUIObject = IGUIObject(objects[i]);
					
					if (influences[i] is Point) {
						// MOVE
						var offset:Point = Point(influences[i]);
						// Краевые ограничения
						if (IGUIObject(_container).currentSize.x > 0 && IGUIObject(_container).currentSize.y > 0) {
							if (object.x + offset.x < 0) {
								offset.x = -object.x;
							}
							if (object.x + offset.x + object.currentSize.x > IGUIObject(_container).currentSize.x) {
								offset.x = IGUIObject(_container).currentSize.x - object.currentSize.x - object.x;
							}
							if (object.y + offset.y < 0) {
								offset.y = -object.y;     
							}
							if (object.y + offset.y + object.currentSize.y > IGUIObject(_container).currentSize.y) {
								offset.y = IGUIObject(_container).currentSize.y - object.currentSize.y - object.y;
							}
						}
						object.x += offset.x;
						object.y += offset.y;
					} else if (influences[i] is Rectangle) {
						// RESIZE
						var delta:Rectangle = Rectangle(influences[i]);
						// Новый размер
						var newSize:Point = object.currentSize.clone();
						newSize.x += delta.width;
						newSize.y += delta.height;
						// Пересчет минимальных размеров, если необходимо
						if (object.minSizeChanged) {
							objectsMinSize[i] = object.computeMinSize();
						}
						
						// Расчет предпочтительных размеров
						var computedNewSize:Point = object.computeSize(newSize);
						// Масштабирование возможно
						if (computedNewSize.x != object.currentSize.x || computedNewSize.y != object.currentSize.y) {
							
							// Надо пересчитать дельту на случай, 
							// Если computedNewSize не равен newSize (неполное масштабирование)
							if (computedNewSize.x != newSize.x) {
								var dx:int = computedNewSize.x - newSize.x;
								delta.width += dx;
								if (delta.x != 0)
									delta.x -= dx;
								newSize.x = computedNewSize.x;
							}
							if (computedNewSize.y != newSize.y) {
								var dy:int = computedNewSize.y - newSize.y;
								delta.height += dy;
								if (delta.y != 0)
									delta.y -= dy;
								newSize.y = computedNewSize.y;
							}
							
							// Применение масштабирования
							if (newSize.x != object.currentSize.x) {
								if (delta.x != 0)
									object.x += delta.x;
								else
									ResizeableBase(object).pivot.x += delta.width;
							}
							if (newSize.y != object.currentSize.y) {	
								if (delta.y != 0)
									object.y += delta.y;
								else
									ResizeableBase(object).pivot.y += delta.height;
							}
							
							// Перерисовка
							object.draw(newSize);
							
						} else {
							influences[i] = new Rectangle();
						}
					}
				}
			}
			// Сохранение воздействий в хэлперах
			for (n = 0; n < _helperList.length; n++) {
				helper = IHelper(_helperList[n]);
				helper.saveInfluence(objects, influences);
			}
		}
		
		/**
		 * Добавить хэлпер для корректировки воздействий 
		 * @param helper хэлпер
		 */		
		public function addHelper(helper:IHelper):void {
			_helperList.push(helper);
			// Добавление объектов на корректировку
			for (var i:int = 0; i < this.objects.length; i++) {
				helper.addObject(Object(this.objects[i]));
			}
			if (helper is ISnapHelper && _container != null) {
				helper.addObject(_container);
			}
		}
		
		//----- IContainerObjectsNumListener
		/**
		 * В контейнер добавили объекты 
		 * @param objects добавленные объекты
		 */		
		public function objectsAdded(objects:Array):void {
			for (var i:int = 0; i < objects.length; i++) {
				for (var j:int = 0; j < _helperList.length; j++) {
					var helper:IHelper = IHelper(_helperList[j]);
					helper.addObject(Object(objects[i]));
				}
			}
		}
		/**
		 * Из контейнера удалили объекты 
		 * @param objects удаленные объекты
		 */		
		public function objectsRemoved(objects:Array):void {
			for (var i:int = 0; i < objects.length; i++) {
				for (var j:int = 0; j < _helperList.length; j++) {
					var helper:IHelper = IHelper(_helperList[j]);
					helper.removeObject(Object(objects[i]));
				}
			}
		}
		
		//----- ILayoutManager
		/**
		 * Вычислить минимальный размер контента контейнера
		 *  @param container контейнер
		 *  @return минимальный размер
		 */
		public function computeMinSize():Point {
			objects = container.objects;
			objectsNum = objects.length;
			_minSize = new Point();
			
			// Если есть объекты
			if (objectsNum > 0) {
				var influences:Array = new Array();
				for(var i:int = 0; i < objectsNum; i++) {
					var object:IGUIObject = IGUIObject(objects[i]);
					
					// Пересчет минимальных размеров
					objectsMinSize[i] = object.computeMinSize();
					
					// Сохранение воздействия для хелперов
					var p:Point;
					if (object.currentSize.x == 0 && object.currentSize.y == 0) {
						p = objectsMinSize[i];
					} else {
						p = new Point();
					}
					influences.push(new Rectangle(0, 0, p.x, p.y));
					
					if (Point(objectsMinSize[i]).x > _minSize.x)
						_minSize.x = Point(objectsMinSize[i]).x;
					if (Point(objectsMinSize[i]).y > _minSize.y)
						_minSize.y = Point(objectsMinSize[i]).y;
				}
				// Сохранение воздействий в хэлперы
				for (var n:int = 0; n < _helperList.length; n++) {
					var helper:IHelper = IHelper(_helperList[n]);
					helper.saveInfluence(objects, influences);
						
					var c:Array = new Array();
					c.push(_container);
					var s:Array = new Array();
					s.push(new Point(_minSize.x, _minSize.y));
					helper.saveInfluence(c, s);
				}
				
			}	
			return _minSize;
		}
		
		/**
		 * Перерасчет размера контента контейнера
		 * @param container контейнер
		 * @param size заданный размер
		 * @return рассчитанный размер
		 */		
		public function computeSize(size:Point):Point {
			var newSize:Point = size.clone();
			// Если есть объекты
			if (objectsNum > 0) {
				var influences:Array = new Array();
				for(var i:int = 0; i < objectsNum; i++) {
					var object:IGUIObject = IGUIObject(objects[i]);
					// Пересчет минимальных размеров, если необходимо
					if (object.minSizeChanged) {
						objectsMinSize[i] = object.computeMinSize();
					}
					// Пересчет размеров
					if (object.currentSize != null && object.currentSize.x != 0 && object.currentSize.y != 0)
						objectsSize[i] = object.computeSize(object.currentSize);
					else
						objectsSize[i] = object.computeSize(objectsMinSize[i]);
						
					// Сохранение воздействия для хелперов
					var p:Point = new Point();
					if (Point(objectsSize[i]).x != object.currentSize.x || Point(objectsSize[i]).y != object.currentSize.y) {
						if (object.currentSize.x == 0 && object.currentSize.y == 0) {
							p = Point(objectsSize[i]).subtract(objectsMinSize[i]);
						} else {
							p = Point(objectsSize[i]).subtract(object.currentSize);
						}
					}
					influences.push(new Rectangle(0, 0, p.x, p.y));
				}
				// Сохранение воздействий в хэлперы
				for (var n:int = 0; n < _helperList.length; n++) {
					var helper:IHelper = IHelper(_helperList[n]);
					helper.saveInfluence(objects, influences);
					
					var c:Array = new Array();
					c.push(_container);
					var s:Array = new Array();
					s.push(new Point(size.x - _minSize.x, size.y - _minSize.y));
					helper.saveInfluence(c, s);
				}
				
			}
			return newSize;
		}
		
		/**
		 * Отрисовать и расположить объекты контейнера
		 * @param container контейнер
		 * @param size заданный размер
		 * @return итоговый размер
		 */		
		public function draw(size:Point):Point {
			if (objectsNum > 0) {
				for (var i:int = 0; i < objectsNum; i++) {
					var object:IGUIObject = IGUIObject(objects[i]);
					var objectSize:Point = Point(objectsSize[i]);
					// Отрисовка
					object.draw(objectSize);
					// Расстановка
					
				}
			}
			return size;
		}
		
		/**
		 * Минимальный размер контента контейнера (получаемый без пересчета) 
		 */		
		public function get minSize():Point {
			return _minSize;
		}
		
		/**
		 * Контейнер, с которым работаем 
		 */		 
		 public function get container():IContainer {
			return _container;
		}
		public function set container(c:IContainer):void {
			_container = c;
			// Подписка на изменение количества объектов в контейнере
			_container.addObjectsNumListener(this);
		}

	}
}