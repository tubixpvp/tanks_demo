package alternativa.gui.widget.joystick {
	import alternativa.gui.init.GUI;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.utils.MouseUtils;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	
	public class CircularJoystickHat extends ImageButton {
		
		protected var _joystick:CircularJoystick;
		
		protected var _dragON:Boolean = false;
		
		// Точка хватания мышью
		protected var _dragPoint:Point;
		
		
		public function CircularJoystickHat(normal:BitmapData = null, over:BitmapData = null, press:BitmapData = null, lock:BitmapData = null) {
			super(0, 0, normal, over, press, lock);
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
				
				GUI.mouseManager.addMouseCoordListener(_joystick);
				
				// Генерация события
				_joystick.dispatchEvent(new CircularJoystickEvent(CircularJoystickEvent.START_DRAG, _joystick.offsetValue, _joystick.angleValue, _joystick.radiusValue));
			} else {
				GUI.mouseManager.removeMouseCoordListener(_joystick);
				
				_dragON = false;
				_dragPoint = null;
				
				_joystick.centerHat();
				// Генерация события
				_joystick.dispatchEvent(new CircularJoystickEvent(CircularJoystickEvent.STOP_DRAG, _joystick.offsetValue, _joystick.angleValue, _joystick.radiusValue));
			}
			_joystick.switchState();
		}
		
		public function set joystick(j:CircularJoystick):void {
			_joystick = j;
		}
		
		public function get dragON():Boolean {
			return _dragON;
		}
		
		public function set dragPoint(p:Point):void {
			_dragPoint = p;
		}
		public function get dragPoint():Point {
			return _dragPoint;
		}

	}
}