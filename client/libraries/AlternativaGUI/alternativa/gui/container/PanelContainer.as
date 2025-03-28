package alternativa.gui.container {
	import alternativa.gui.window.WindowBase;
	import alternativa.gui.window.WindowEvent;
	import alternativa.gui.window.panel.ResizeablePanelBase;
	
	
	public class PanelContainer extends Container {
		
		public function PanelContainer(marginLeft:int = 0, marginTop:int = 0, marginRight:int = 0, marginBottom:int = 0) {
			super(marginLeft, marginTop, marginRight, marginBottom);
		}
		
		/*override public function computeMinSize():Point {
			var newMinSize:Point = super.computeMinSize();
			if (_objects.length > 0) trace("PanelContainer computeMinSize: " + newMinSize);
			return newMinSize;
		}*/
		
		/*override public function computeSize(_size:Point):Point {
			if (_objects.length > 0) trace("PanelContainer computeSize size: " + _size);
			var size:Point = new Point();
			// проверка на минимум
			size.x = isStretchable(Direction.HORIZONTAL) ? Math.max(_size.x, _minSize.x) : _minSize.x;
			size.y = isStretchable(Direction.VERTICAL) ? Math.max(_size.y, _minSize.y) : _minSize.y;
			
			// проверка на максимум
			/*if (_stretchableH) {
				if (size.y > Container(_parentContainer).currentSize.y*0.5 && Container(_parentContainer).currentSize.y != 0) {
					size.y = Math.floor(Container(_parentContainer).currentSize.y*0.5);
				}
			} else {
				if (size.x > Container(_parentContainer).currentSize.x*0.5 && Container(_parentContainer).currentSize.x != 0) {
					size.x = Math.floor(Container(_parentContainer).currentSize.x*0.5);
				}
			}*/
			
			// Определяем размер контента
			/*var contentSize:Point = layoutManager.computeSize(this, size.clone().subtract(new Point(_marginLeft + _marginRight, _marginTop + _marginBottom)));
			
			// Определяем размер контейнера с отступами
			var newSize:Point = new Point(contentSize.x + _marginLeft + _marginRight, contentSize.y + _marginTop + _marginBottom);
			
			// Пытаемся принять предлагаемый размер (не меньше размера с учетом контента)
			newSize.x = Math.max(size.x, newSize.x);
			newSize.y = Math.max(size.y, newSize.y);
			if (_objects.length > 0) trace("PanelContainer computeSize newSize: " + newSize);
			return newSize;
		}*/
		
		/*override public function draw(size:Point):void {
			trace("PanelContainer draw");
			super.draw(size);
		}*/
		
		// Добавление панели
		public function addPanel(p:ResizeablePanelBase):void {
			addObject(p);
			p.addEventListener(WindowEvent.SELECT, onPanelSelect);
		}
		public function removePanel(p:ResizeablePanelBase):void {
			p.removeEventListener(WindowEvent.SELECT, onPanelSelect);
			removeObject(p);
		}
		
		// Включение табуляции при установке фокуса
		protected function onPanelSelect(e:WindowEvent):void {
			var w:WindowBase;
			for (var i:int = 0; i < objects.length; i++) {
				w = WindowBase(objects[i]);
				if (w != e.window) {
					w.tabChildren = false;
				} else {
					w.tabChildren = true;
				}
			}
		}
		
		override public function set minSizeChanged(value:Boolean):void {
			_minSizeChanged = value;
			if (_minSizeChanged && _parentContainer != null && !_parentContainer.minSizeChanged) {
				_parentContainer.minSizeChanged = true;
			}
		}
		
	}
}