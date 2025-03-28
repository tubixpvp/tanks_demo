package alternativa.gui.widget.joystick {
	import alternativa.gui.base.GUIObject;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ShapeButton;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	
	public class CrossJoystick extends GUIObject {
		
		private var area:Bitmap;
		
		/**
		 * Центр 
		 */		
		private var center:Point;
		
		private var leftButton:ShapeButton;
		private var topButton:ShapeButton;
		private var rightButton:ShapeButton;
		private var bottomButton:ShapeButton;
		
		private var leftButtonGfx:Bitmap;
		private var topButtonGfx:Bitmap;
		private var rightButtonGfx:Bitmap;
		private var bottomButtonGfx:Bitmap;
		
		
		public function CrossJoystick(areaBitmap:BitmapData, areaDiametr:int, leftButtonBitmap:BitmapData = null, topButtonBitmap:BitmapData = null, rightButtonBitmap:BitmapData = null, bottomButtonBitmap:BitmapData = null) {
			area = new Bitmap(areaBitmap);
			addChild(area);
			
			center = new Point(Math.floor(area.width*0.5), Math.floor(area.height*0.5));
			
			// Создание кнопок
			var r:Number = areaDiametr*0.5;
			var d:Number = r/Math.sqrt(2);
			
			leftButton = new ShapeButton();
			leftButton.graphics.beginFill(0x00ff00, 0);
			leftButton.graphics.lineTo(-d, -d);
			leftButton.graphics.lineTo(-r, 0);
			leftButton.graphics.lineTo(-d, d);
			leftButton.graphics.endFill();
			
			topButton = new ShapeButton();
			topButton.graphics.beginFill(0xff0000, 0);
			topButton.graphics.lineTo(d, -d);
			topButton.graphics.lineTo(0, -r);
			topButton.graphics.lineTo(-d, -d);
			topButton.graphics.endFill();
			
			rightButton = new ShapeButton();
			rightButton.graphics.beginFill(0x0000ff, 0);
			rightButton.graphics.lineTo(d, -d);
			rightButton.graphics.lineTo(r, 0);
			rightButton.graphics.lineTo(d, d);
			rightButton.graphics.endFill();
		
			bottomButton = new ShapeButton();
			bottomButton.graphics.beginFill(0xffffff, 0);
			bottomButton.graphics.lineTo(d, d);
			bottomButton.graphics.lineTo(0, r);
			bottomButton.graphics.lineTo(-d, d);
			bottomButton.graphics.endFill();
			
			addChild(leftButton);
			addChild(topButton);
			addChild(rightButton);
			addChild(bottomButton);
			leftButton.x = center.x;
			leftButton.y = center.y;
			topButton.x = center.x;
			topButton.y = center.y;
			rightButton.x = center.x;
			rightButton.y = center.y;
			bottomButton.x = center.x;
			bottomButton.y = center.y;
			
			// Графика кнопок
			/*topButtonGfx = new Bitmap(topButtonBitmap);
			addChild(topButtonGfx);
			topButtonGfx.x = center.x - Math.floor(topButtonGfx.width*0.5);
			topButtonGfx.y = center.y - Math.floor(topButtonGfx.height);*/
			
			// Подписка обработчиков
			leftButton.addEventListener(ButtonEvent.PRESS, left);
			topButton.addEventListener(ButtonEvent.PRESS, top);
			rightButton.addEventListener(ButtonEvent.PRESS, right);
			bottomButton.addEventListener(ButtonEvent.PRESS, bottom);
			
			// Подключение повторителей
			
		}
		
		private function left(e:ButtonEvent):void {
			//trace("left");
			dispatchEvent(new CrossJoystickEvent(CrossJoystickEvent.LEFT));
		}
		private function top(e:ButtonEvent):void {
			//trace("top");
			dispatchEvent(new CrossJoystickEvent(CrossJoystickEvent.TOP));
		}
		private function right(e:ButtonEvent):void {
			//trace("right");
			dispatchEvent(new CrossJoystickEvent(CrossJoystickEvent.RIGHT));
		}
		private function bottom(e:ButtonEvent):void {
			//trace("bottom");
			dispatchEvent(new CrossJoystickEvent(CrossJoystickEvent.BOTTOM));
		}
		
		/**
		 * Расчет минимальных размеров объекта
		 * @return минимальные размеры
		 */		 		
		override public function computeMinSize():Point {
			_minSize = new Point(area.width, area.height);
			_minSizeChanged = false;
			return _minSize;
		}
		
		/**
		 * Расчет предпочтительных размеров с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */				
		override public function computeSize(size:Point):Point {
			return _minSize;
		}

	}
}