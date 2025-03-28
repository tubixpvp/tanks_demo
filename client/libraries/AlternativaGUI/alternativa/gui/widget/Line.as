package alternativa.gui.widget {
	import alternativa.gui.base.GUIShapeObject;
	import alternativa.gui.base.IRotateable;
	import alternativa.gui.layout.enums.AvailableAngle;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.skin.widget.LineSkin;
	
	import flash.geom.Point;

	public class Line extends GUIShapeObject implements IRotateable {
		
		// Направление
		private var _direction:Boolean;
		
		// шкурка
		private var skin:LineSkin;
		
		// Угол поворота графики
		private var _rotationAngle:Number = -1;
		
		

		public function Line(direction:Boolean) {			
			super();
			// Сохранение параметров
			this._direction = direction;
			stretchableV = (_direction == Direction.VERTICAL);
			stretchableH = (_direction == Direction.HORIZONTAL);
		}
		
		override public function updateSkin():void {
			skin = LineSkin(skinManager.getSkin(Line));
			super.updateSkin();
			// Определяем мин.размеры
			if (_direction == Direction.VERTICAL) {
				minSize.x = skin.bmpVM.width;
				minSize.y = skin.bmpVT.height + skin.bmpVB.height;
			} else {
				minSize.x = skin.bmpHL.width + skin.bmpHR.width;
				minSize.y = skin.bmpHC.height;
			}
		}
		
		// Отрисовка
		override public function draw(size:Point):void {
			super.draw(size);
			graphics.clear();
			// Размещаем части
			if (_direction == Direction.VERTICAL) {
				graphics.beginBitmapFill(skin.bmpVT, null, false, false);
				graphics.drawRect(0, 0, minSize.x, skin.bmpVT.height);
				graphics.endFill();
				
				graphics.beginBitmapFill(skin.bmpVM, null, false, false);
				graphics.drawRect(0, skin.bmpVT.height, minSize.x, size.y - minSize.y);
				graphics.endFill();
				
				graphics.beginBitmapFill(skin.bmpVB, null, false, false);
				graphics.drawRect(0, size.y - skin.bmpVB.height, minSize.x, skin.bmpVB.height);
				graphics.endFill();
			} else {
				graphics.beginBitmapFill(skin.bmpHL, null, false, false);
				graphics.drawRect(0, 0, skin.bmpHL.width, minSize.y);
				graphics.endFill();
				
				graphics.beginBitmapFill(skin.bmpHC, null, false, false);
				graphics.drawRect(skin.bmpHL.width, 0, size.x - minSize.x, minSize.y);
				graphics.endFill();
				
				graphics.beginBitmapFill(skin.bmpHR, null, false, false);
				graphics.drawRect(size.x - skin.bmpHR.width, 0, skin.bmpHR.width, minSize.y);
				graphics.endFill();
			}
		}
		
		/**
		 * Задать начальный угол поворота (без поворота графики)
		 * @param value - угол, кратный 90 градусам, заданный в радианах
		 */		
		public function initAngle(value:Number):void {
			_rotationAngle = value;
		}
		
		
		/**
		 * Повернуть графику объекта на один из доступных углов
		 * @param value - угол, кратный 90 градусам, заданный в радианах
		 */		 
		public function set angle(value:Number):void {
			if (_rotationAngle != value) {
				if (((_rotationAngle == AvailableAngle.DEGREES_0 || _rotationAngle == AvailableAngle.DEGREES_180) && (value == AvailableAngle.DEGREES_90 || value == AvailableAngle.DEGREES_270))
				 || ((_rotationAngle == AvailableAngle.DEGREES_90 || _rotationAngle == AvailableAngle.DEGREES_270) && (value == AvailableAngle.DEGREES_0 || value == AvailableAngle.DEGREES_180)) 
					) {
					_direction = !_direction;
					if (_direction == Direction.VERTICAL) {
						stretchableV = true;
						stretchableH = false;
						minSize.x = skin.bmpVM.width;
						minSize.y = skin.bmpVT.height + skin.bmpVB.height;
					} else {
						stretchableV = false;
						stretchableH = true;
						minSize.x = skin.bmpHL.width + skin.bmpHR.width;
						minSize.y = skin.bmpHC.height;
					}
					minSizeChanged = true;
				} 
				_rotationAngle = value;
				
			}
		}
		
		/**
		 * Получить угол поворота графики объекта
		 * @return - угол поворота
		 */			
		public function get angle():Number {
			return _rotationAngle;
		}
		
	}
}