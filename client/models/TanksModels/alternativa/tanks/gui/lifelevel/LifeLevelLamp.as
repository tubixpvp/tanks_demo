package alternativa.tanks.gui.lifelevel {
	import alternativa.gui.widget.Image;
	
	import flash.display.BitmapData;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	
	public class LifeLevelLamp extends Image {
		
		[Embed(source="../../resources/lifelevel_lamp_grey.png")] private static const bitmapGrey:Class;
		private static const greyBd:BitmapData = new bitmapGrey().bitmapData;
		
		[Embed(source="../../resources/lifelevel_lamp_green_blink.png")] private static const bitmapGreenBlink:Class;
		private static const greenBlinkBd:BitmapData = new bitmapGreenBlink().bitmapData;
		[Embed(source="../../resources/lifelevel_lamp_yellow_blink.png")] private static const bitmapYellowBlink:Class;
		private static const yellowBlinkBd:BitmapData = new bitmapYellowBlink().bitmapData;
		[Embed(source="../../resources/lifelevel_lamp_red_blink.png")] private static const bitmapRedBlink:Class;
		private static const redBlinkBd:BitmapData = new bitmapRedBlink().bitmapData;
		
		public static const COLOR_RED:String = "LifeLevelLampColorRed";
		public static const COLOR_YELLOW:String = "LifeLevelLampColorYellow";
		public static const COLOR_GREEN:String = "LifeLevelLampColorGreen";
		
		// Горит лампочка или нет
		private var _power:Boolean;
		// Полпериода мигания в милисекундах
		private var _blink:int;
		// Цвет ламочки
		private var _color:String;
		private var colorBd:BitmapData;
		
		// id таймера мигания
		private var blinkInt:int;
		private var blinkState:Boolean;
		
		
		public function LifeLevelLamp() {
			super(greyBd);
			_color = COLOR_GREEN;
			colorBd = greenBlinkBd;
			_blink = 0;
			_power = false;
			blinkInt = -1;
			blinkState = false;
		}
		
		public function set color(value:String):void {
			_color = value;
			switch (value) {
				case COLOR_RED:
					colorBd = redBlinkBd;
					break;
				case COLOR_YELLOW:
					colorBd = yellowBlinkBd;
					break;
				case COLOR_GREEN:
					colorBd = greenBlinkBd;
					break;
			}
			if (_power) {
				bitmap.bitmapData = colorBd;
			}
		}
		
		public function set power(value:Boolean):void {
			_power = value;
			if (_power) {
				bitmap.bitmapData = colorBd;
				if (_blink) {
					blinkState = true;
					blinkInt = setInterval(blinking, _blink);
				}
			} else {
				bitmap.bitmapData = greyBd;
				if (_blink) {
					blinkState = false;
					clearInterval(blinkInt);
				}
			}
		}
		
		public function set blink(value:int):void {
			_blink = value;
			if (_power) {
				if (value > 0) {
					blinkState = true;
					blinkInt = setInterval(blinking, _blink);
				} else {
					clearInterval(blinkInt);
				}
			}
		}
		
		// Мигание
		private function blinking():void {
			if (blinkState) {
				blinkState = false;
				bitmap.bitmapData = greyBd;
			} else {
				blinkState = true;
				bitmap.bitmapData = colorBd;
			}
		}
		
	}
}