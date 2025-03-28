package alternativa.gui.widget.joystick {
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.widget.slider.BitmapSlider;
	import alternativa.utils.MouseUtils;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class LinearJoystick extends BitmapSlider {
		
		/**
		 * Значение приращения 
		 */		
		private var _value:Number;
		/**
		 * Среднее положение 
		 */		
		private var centerPos:int;
		
		
		/**
		 * @param direction
		 * @param trackBitmap
		 * @param runnerBitmap
		 * @param borderThickness
		 * @param posNum
		 * @param step
		 */		
		public function LinearJoystick(direction:Boolean, 
									   trackBitmap:BitmapData,
									   runnerBitmap:BitmapData,
									   borderThickness:int,
									   posNum:int,
									   step:Number) {
			super(direction,
				  trackBitmap,
				  runnerBitmap,
				  2*posNum + 1,
				  posNum + 1,
				  borderThickness,
				  false,
				  true);
			
			_value = 0;
			centerPos = posNum + 1;
		}
		
		/**
		 * Создание бегунка
		 */		
		override protected function createRunner():void {
			if (_direction == Direction.HORIZONTAL) {
				runner = new LinearJoystickRunnerButton(_runnerBitmap);
			} else { 
				runner = new LinearJoystickRunnerButton(_runnerBitmap);
			}
			addChild(runner);
			runner.slider = this;
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
		 * Флаг наведения
		 */
		override public function set over(value:Boolean):void {
			_over = value;
			switchState();
		}
		
		/**
		 * Флаг нажатия
		 */
		override public function set pressed(value:Boolean):void {
			_pressed = value;
			switchState();
			
			if (_pressed) {
				var halfRunnerWidth:int = Math.floor(runner.currentSize.x*0.5);
				var halfRunnerHeight:int = Math.floor(runner.currentSize.y*0.5);
				var p:Point = MouseUtils.localCoords(this);
				if (Direction.HORIZONTAL) {
					runner.x = p.x - halfRunnerWidth;
				} else {
					runner.y = p.y - halfRunnerHeight;
				}
				runner.pressed = value;
				mouseMove(MouseUtils.globalCoords());
			} else {
				runner.pressed = value;
			}
		}
		
		/**
		 * Установка бегунка в нужную позицию
		 * @param posNum - номер позиции (1..posNum)
		 */		
		override public function set currentPos(num:int):void {
			// Рассчет приращения
			_value = num - centerPos;
			if (num == centerPos && !runner.dragON) {
				_currentPos = num;
			}
			super.currentPos = num;
			//trace("joystick value: " + _value);
		}
		
		public function get value():Number {
			return _value;
		}

	}
}