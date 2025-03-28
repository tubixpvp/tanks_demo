package alternativa.gui.widget.joystick {
	import alternativa.gui.widget.slider.SliderEvent;
	import alternativa.gui.widget.slider.SliderRunnerButton;
	
	import flash.display.BitmapData;
	
	
	public class LinearJoystickRunnerButton extends SliderRunnerButton {
		
		
		public function LinearJoystickRunnerButton(normal:BitmapData = null, over:BitmapData = null, press:BitmapData = null, lock:BitmapData = null) {
			super(0, 0, normal, over, press, lock);
		}
		
		/**
		 *  Установка флага нажатия
		 */
		override public function set pressed(value:Boolean):void {
			super.pressed = value;
			if (!_pressed) {
				_slider.currentPos = Math.floor(_slider.posNum*0.5) + 1;
			}
		}
		
	}
}