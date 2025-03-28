package alternativa.gui.container {
	import alternativa.gui.layout.snap.ISnapable;
	import alternativa.gui.layout.snap.Snap;
	import alternativa.gui.layout.snap.SnapRect;
	import alternativa.gui.window.WindowBase;
	import alternativa.gui.window.WindowEvent;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Оконный контейнер 
	 */	
	public class WindowContainer extends Container implements IWindowContainer, ISnapable {
		
		/**
		 * Выбранное окно 
		 */		
		private var selectedWindow:WindowBase;
		/**
		 * @private
		 * Флаг включения снапинга 
		 */
		private var _snapEnabled:Boolean;
		/**
		 * @private
		 * Конфигурация снапинга сторон объекта
		 */
		private var _snapConfig:int;
		/**
		 * @private
		 * Снап область
		 */
		private var _snapRect:Rectangle;
		
		
		public function WindowContainer() {
			super();
			
			_stretchableH = true;
			_stretchableV = true;
			
			_snapEnabled = true;
			_snapConfig = Snap.INTERNAL;
			_snapRect = new SnapRect();
		}
		
		/**
		 * Добавление окна
		 * @param window окно
		 */
		public function addWindow(window:WindowBase):void {
			addObject(window);
			window.addEventListener(WindowEvent.SELECT, onWindowSelect);
			window.addEventListener(WindowEvent.UNSELECT, onWindowUnselect);
			window.parentWindowContainer = this;
		}
		
		/**
		 * Удаление окна  
		 * @param window окно
		 */		
		public function removeWindow(window:WindowBase):void {
			window.parentWindowContainer = null;
			window.removeEventListener(WindowEvent.SELECT, onWindowSelect);
			window.removeEventListener(WindowEvent.UNSELECT, onWindowUnselect);
			removeObject(window);
		}
		
		/**
		 * @private
		 * Включение табуляции при установке фокуса
		 */		
		protected function onWindowSelect(e:WindowEvent):void {
			if (selectedWindow == null) {
				for (var i:int = 0; i < _objects.length; i++) {
					WindowBase(_objects[i]).tabChildren = false;
				}
			}			
			selectedWindow = e.window;
			
			var w:WindowBase = selectedWindow;
			w.tabChildren = true;
		}
		
		/**
		 * @private
		 * Выключение табуляции при потере фокуса
		 */		
		protected function onWindowUnselect(e:WindowEvent):void {
			var w:WindowBase = e.window;
			w.tabChildren = false;
		}
		
		/**
		 * Отрисовка контейнера в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			super.draw(size);
			// Установка габаритов для снапинга
			if (_snapRect.width == 0 && _snapRect.height == 0) {
				snapRect = new SnapRect(0, 0, size.x, size.y);
			}
		}
		
		/**
		 * Флаг снапинга
		 */
		public function get snapEnabled():Boolean {
			return _snapEnabled;
		}
		public function set snapEnabled(value:Boolean):void {
			_snapEnabled = value;
		}
		/**
		 * Побитовая конфигурация снапинга сторон
		 */
		public function get snapConfig():int {
			return _snapConfig;
		}
		public function set snapConfig(value:int):void {
			_snapConfig = value;
		}
		/**
		 * Габаритный контейнер для снапинга (в локальных коодинатах)
		 */
		public function get snapRect():Rectangle {
			return _snapRect;
		}
		public function set snapRect(rect:Rectangle):void {
			_snapRect = rect;
		}
		
		override public function set minSizeChanged(value:Boolean):void {
			//trace("WindowContainer minSizeChanged: " + value);
			super.minSizeChanged = value;
		}
		
		/**
		 * Отрисовка с пересчетом в заданных размерах
		 * @param size размеры
		 */		
		override public function repaint(size:Point):void {
			//trace("WindowContainer repaint");
			if (_minSizeChanged) {
				computeMinSize();
			}
			var newSize:Point = computeSize(size);
			if (!_minSizeChanged) {
				draw(newSize);
			}
		}
		
	}
}