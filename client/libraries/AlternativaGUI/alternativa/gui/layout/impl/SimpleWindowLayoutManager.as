package alternativa.gui.layout.impl {
	import alternativa.gui.base.IGUIObject;
	import alternativa.gui.base.IHelper;
	import alternativa.gui.container.IContainer;
	import alternativa.gui.layout.IWindowLayoutManager;
	import alternativa.gui.window.WindowBase;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	public class SimpleWindowLayoutManager extends LayoutManagerBase implements IWindowLayoutManager {
		
		private var windowRestoreCoord:Dictionary;
		private var windowRestoreSize:Dictionary;
		
		public function SimpleWindowLayoutManager() {
			super();
			windowRestoreCoord = new Dictionary(false);
			windowRestoreSize = new Dictionary(false);
		}
		
		/**
		 * Перерасчет размера контента контейнера
		 * @param container - контейнер
		 * @param size - заданный размер
		 * @return рассчитанный размер
		 */		
		override public function computeSize(size:Point):Point {
			var newSize:Point = size.clone();
			// Если есть объекты
			if (objectsNum > 0) {
				var influences:Array = new Array();
				for(var i:int = 0; i < objectsNum; i++) {
					var object:IGUIObject = IGUIObject(objects[i]);
					// Пересчет размеров
					if (!WindowBase(object).maximized) {
						// Пересчет минимальных размеров
						if (object.minSizeChanged) {
							objectsMinSize[i] = object.computeMinSize();
						}
						
						if (object.currentSize != null) {
							objectsSize[i] = object.computeSize(object.currentSize);
						} else {
							objectsSize[i] = object.computeSize(objectsMinSize[i]);
						}
					} else {
						objectsSize[i] = object.computeSize(size);
					}
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
		 * Свернуть окно 
		 * @param window окно
		 */		
		public function minimizeWindow(window:WindowBase):void {
			
		}		
		
		/**
		 * Развернуть окно
		 * @param window окно
		 */
		public function maximizeWindow(window:WindowBase):void {
			// Сохранение размеров и координат
			windowRestoreCoord[window] = new Point(window.x, window.y);
			windowRestoreSize[window] = new Point(window.currentSize.x, window.currentSize.y);
			
			// Перерисовка
			window.draw(window.computeSize(IGUIObject(_container).currentSize));
			
			// Установка координат
			window.x = 0;
			window.y = 0;
		}
		
		/**
		 * Вернуть окну прежний размер (каким он был до разворачивания)
		 * @param window окно
		 */
		public function restoreWindow(window:WindowBase):void {
			// Перерисовка
			window.draw(window.computeSize(windowRestoreSize[window]));
			
			// Установка координат
			var coord:Point = Point(windowRestoreCoord[window]);
			window.x = coord.x;
			window.y = coord.y;
		}
		
	}
}