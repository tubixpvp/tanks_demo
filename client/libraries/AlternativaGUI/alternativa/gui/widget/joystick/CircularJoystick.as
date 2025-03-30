package alternativa.gui.widget.joystick {
	import alternativa.gui.base.ActiveObject;
	import alternativa.iointerfaces.mouse.IMouseCoordListener;
	import alternativa.gui.skin.widget.button.ImageButtonSkin;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.utils.MouseUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class CircularJoystick extends ActiveObject implements IMouseCoordListener {
		
		private var area:Bitmap;
		private var hat:CircularJoystickHat;
		
		private var areaDiametr:int;
		private var hatDiametr:int;
		
		/**
		 * Скин кнопки 
		 */		
		private var imageButtonSkin:ImageButtonSkin;
		
		/**
		 * Центр 
		 */		
		private var center:Point;
		
		/**
		 * Смещения по осям  
		 */		
		private var _offsetValue:Point;
		/**
		 * Угол отклонения (в радианах)
		 */	
		private var _angleValue:Number;
		/**
		 * Приведенная длина радиус-вектора (0..1) 
		 */		
		private var _radiusValue:Number;
		
		/**
		 * Максимальное удаление центра hat от центра area
		 */		
		private var maxShiftRadius:Number;
		
		
		public function CircularJoystick(areaBitmap:BitmapData, hatBitmap:BitmapData, areaDiametr:int, hatDiametr:int) {
			area = new Bitmap(areaBitmap);
			hat = new CircularJoystickHat(hatBitmap);
			hat.joystick = this;
			addChild(area);
			addChild(hat);
			
			this.areaDiametr = areaDiametr;
			this.hatDiametr = hatDiametr;
			
			center = new Point(Math.floor(area.width*0.5), Math.floor(area.height*0.5));
			//trace("CircularJoystick center: " + center);
			maxShiftRadius = Math.floor((areaDiametr - hatDiametr)*0.5);
			//trace("CircularJoystick maxShiftRadius: " + maxShiftRadius);
			
			centerHat();
			
			_offsetValue = new Point();
		}
		
		/**
		 * Обновление скина 
		 */		
		override public function updateSkin():void {
			imageButtonSkin = ImageButtonSkin(skinManager.getSkin(ImageButton));
			super.updateSkin();
		}
		
		/**
		 * Расчет минимальных размеров объекта
		 * @return минимальные размеры
		 */		 		
		override public function computeMinSize():Point {
			_minSize = new Point(area.width, area.height);
			_minSizeChanged = false;
			
			hat.computeMinSize();
			
			return _minSize;
		}
		
		/**
		 * Расчет предпочтительных размеров с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */				
		override public function computeSize(size:Point):Point {
			hat.computeSize(hat.minSize);
			
			return _minSize;
		}
		
		/**
		 * Отрисовка в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			super.draw(size);
			
			hat.draw(hat.minSize);
		}
		
		internal function centerHat():void {
			hat.x = center.x - Math.floor(hat.width*0.5);
			hat.y = center.y - Math.floor(hat.height*0.5);
		}
		
		private function drawDirection():void {
			
		}
		
		/**
		 * Рассылка изменения координат мыши 
		 * @param mouseCoord координаты мыши
		 */		
		public function mouseMove(mouseCoord:Point):void {
			var mouseCoords:Point = MouseUtils.localCoords(this);
			var newHatCenterCoords:Point = new Point(mouseCoords.x - hat.dragPoint.x + Math.floor(hat.width*0.5), mouseCoords.y - hat.dragPoint.y + Math.floor(hat.height*0.5));
			var dx:int = newHatCenterCoords.x - center.x;
			var dy:int = center.y - newHatCenterCoords.y;
			
			var outOfArea:Boolean;
			if (dx != 0 || dy != 0) {
				var r:Number = Math.sqrt(dx*dx + dy*dy);
				if (r > maxShiftRadius) {
					outOfArea = true;
					_radiusValue = 1;
				} else {
					_radiusValue = r/maxShiftRadius;
				}
			} else {
				_radiusValue = 0;
			}
			//trace("radiusValue: " + _radiusValue);
			
			var angle:Number;
			if (dx > 0) {
				if (dy > 0) {
					// I-я четверть
					angle = Math.atan(dy/dx);
					if (outOfArea) {
						dx = maxShiftRadius * Math.cos(angle);
						dy = maxShiftRadius * Math.sin(angle);
					}
				} else if (dy < 0) {
					// IV-я четверть
					angle = Math.PI*2 - Math.atan(-dy/dx);
					if (outOfArea) {
						dx = maxShiftRadius * Math.cos(Math.PI*2 - angle);
						dy = -maxShiftRadius * Math.sin(Math.PI*2 - angle);
					}
				} else {
					// 0
					angle = 0;
					if (outOfArea) {
						dx = maxShiftRadius;
						dy = 0;
					}
				}
			} else if (dx < 0) {
				if (dy > 0) {
					// II-я четверть
					angle = Math.PI - Math.atan(-dy/dx);
					if (outOfArea) {
						dx = -maxShiftRadius * Math.cos(Math.PI - angle);
						dy = maxShiftRadius * Math.sin(Math.PI - angle);
					}
				} else if (dy < 0) {
					// III-я четверть
					angle = Math.PI + Math.atan(dy/dx);
					if (outOfArea) {
						dx = -maxShiftRadius * Math.cos(angle - Math.PI);
						dy = -maxShiftRadius * Math.sin(angle - Math.PI);
					}
				} else {
					// 180
					angle = Math.PI;
					if (outOfArea) {
						dx = -maxShiftRadius;
						dy = 0;
					}
				}
			} else {
				if (dy > 0) {
					// 90
					angle = Math.PI*0.5;
					if (outOfArea) {
						dx = 0;
						dy = maxShiftRadius;
					}
				} else if (dy < 0) {
					// 270
					angle = Math.PI*1.5;
					if (outOfArea) {
						dx = 0;
						dy = -maxShiftRadius;
					}
				} else {
					// 0
					angle = 0;
				}
			}
			//trace("angle: " + (180*angle)/Math.PI);
			_angleValue = angle;
			_offsetValue.x = dx/maxShiftRadius;
			_offsetValue.y = dy/maxShiftRadius;
			//trace("offsetValue: " + _offsetValue);
						
			if (outOfArea) {
				newHatCenterCoords.x = center.x + dx;
				newHatCenterCoords.y = center.y - dy;
			}
			hat.x = newHatCenterCoords.x - Math.floor(hat.width*0.5);
			hat.y = newHatCenterCoords.y - Math.floor(hat.height*0.5);
			
			dispatchEvent(new CircularJoystickEvent(CircularJoystickEvent.CHANGE_POS, _offsetValue, _angleValue, _radiusValue));
		}
		
		
		/**
		 * Смена визуального представления состояния 
		 */
		internal function switchState():void {
			if (hat.dragON) {
				area.transform.colorTransform = imageButtonSkin.colorPress;
			} else {
				if (pressed) {
					area.transform.colorTransform = imageButtonSkin.colorPress;
				} else if (over) {
					area.transform.colorTransform = imageButtonSkin.colorOver;
				} else {
					area.transform.colorTransform = imageButtonSkin.colorNormal;
				}
			}
		}
		
		override public function set over(value:Boolean):void {
			trace("Joystick over: " + value);
			super.over = value;
			switchState();
		}
		/**
		 * Флаг нажатия
		 */	
		override public function set pressed(value:Boolean):void {
			trace("Joystick pressed: " + value);
			super.pressed = value;
			switchState();
			
			if (_pressed) {
				var halfHatWidth:int = Math.round(hat.currentSize.x*0.5);
				var halfHatHeight:int = Math.round(hat.currentSize.y*0.5);
				var p:Point = MouseUtils.localCoords(this);
				hat.x = p.x - halfHatWidth;
				hat.y = p.y - halfHatHeight;
				hat.pressed = value;
				mouseMove(MouseUtils.globalCoords());
			} else {
				hat.pressed = value;
			}		
		}
		
		/**
		 * Текст всплывающей подсказки
		 */
		override public function set hint(value:String):void {
			super.hint = value;
			hat.hint = value;
		}
		
		/**
		 * Смещения по осям  
		 */
		public function get offsetValue():Point {
			return _offsetValue;
		}
		/**
		 * Угол отклонения (в радианах)
		 */
		public function get angleValue():Number {
			return _angleValue;
		}
		/**
		 * Приведенная длина радиус-вектора (0..1) 
		 */
		public function get radiusValue():Number {
			return _radiusValue;
		}

	}
}