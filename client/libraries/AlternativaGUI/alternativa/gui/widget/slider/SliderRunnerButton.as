package alternativa.gui.widget.slider {
	import alternativa.gui.init.GUI;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.utils.MouseUtils;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	 
	
	public class SliderRunnerButton extends ImageButton {
		
		protected var _slider:BitmapSlider;
		
		protected var _dragON:Boolean = false;
		
		// Точка хватания мышью
		protected var _dragPoint:Point;
		
		
		public function SliderRunnerButton(yNormal:int, yPress:int, normal:BitmapData = null, over:BitmapData = null, press:BitmapData = null, lock:BitmapData = null) {
			super(yNormal, yPress, normal, over, press, lock);
			
			// Инициализация фокуса
			tabEnabled = false;
		}
		
		/**
		 *  Установка флага наведенности
		 */
		override public function set over(value:Boolean):void {
			if (!_dragON) {
				super.over = value;
				switchState();			
				draw(currentSize);
			}	
		}
		
		/**
		 *  Установка флага нажатия
		 */
		override public function set pressed(value:Boolean):void {
			super.pressed = value;
			if (_pressed) {
				_dragON = true;
				// Сохранение точки захвата бегунка
				_dragPoint = MouseUtils.localCoords(this);
				
				GUI.mouseManager.addMouseCoordListener(_slider);
				
				// Генерация события
				_slider.dispatchEvent(new SliderEvent(SliderEvent.START_DRAG, _slider.currentPos));
			} else {
				GUI.mouseManager.removeMouseCoordListener(_slider);
				
				_dragON = false;
				_dragPoint = null;
				
				// Генерация события
				_slider.dispatchEvent(new SliderEvent(SliderEvent.STOP_DRAG, _slider.currentPos));
			}
		}
		
		public function set slider(s:BitmapSlider):void {
			_slider = s;
		}
		
		public function get dragON():Boolean {
			return _dragON;
		}
		
		public function get dragPoint():Point {
			return _dragPoint;
		}
		
	}
}