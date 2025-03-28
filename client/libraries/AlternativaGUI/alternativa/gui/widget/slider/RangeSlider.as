package alternativa.gui.widget.slider {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.skin.widget.slider.RangeSliderSkin;
	import alternativa.utils.MouseUtils;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	
	
	public class RangeSlider extends Slider {
		
		/**
		 * Скин 
		 */
		private var skin:RangeSliderSkin;
		/**
		 * 2-й бегунок (окончание диапазона) 
		 */		
		protected var runner2:SliderRunnerButton;
		/**
		 * Графика 2-го бегунка
		 */		
		protected var _runner2Bitmap:BitmapData;
		/**
		 * Текущая позиция 2-го бегунка
		 */		
		private var _currentPos2:int;
		/**
		 * Точка хватания мышью 2-го бегунка
		 */		
		private var dragPoint2:Point;
		
		/**
		 * Заливка диапазона 
		 */		
		private var rangeFill:Shape;
		
		
		public function RangeSlider(direction:Boolean,
							 	    posNum:int,
							   		runner1Pos:int,
							   		runner2Pos:int,
							   		divisionMinLength:int,
							   		showTicks:Boolean) {
			
			super(direction, posNum, runner1Pos, divisionMinLength, showTicks);
			
			_currentPos2 = runner2Pos;
			
			// Создаем заливку диапазона
			rangeFill = new Shape();
			addChild(rangeFill);
			rangeFill.y = runner.y;
			
			// Создаем 2-й бегунок
			if (_direction == Direction.HORIZONTAL) {
				runner2 = new SliderRunnerButton(0, 1, null);
			} else { 
				runner2 = new SliderRunnerButton(0, 0, null);
			}
			addChild(runner2);
			runner2.slider = this;
		}
		
		/**
		 * Обновить скин 
		 */
		override public function updateSkin():void {
			skin = RangeSliderSkin(skinManager.getSkin(getSkinType()));
			if (_direction == Direction.HORIZONTAL) {
				// ГОРИЗОНТАЛЬНЫЙ
				_runner2Bitmap = skin.horizRunner2;
			} else {
				// ВЕРТИКАЛЬНЫЙ
				_runner2Bitmap = skin.vertRunner2;
			}
			setRunner2States(_runner2Bitmap, _runner2Bitmap, _runner2Bitmap, _runner2Bitmap);
			super.updateSkin();
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */
		override protected function getSkinType():Class {
			return RangeSlider;
		}
		
		/**
		 * Загрузка битмап 2-го бегунка
		 */		
		private function setRunner2States(normal:BitmapData, over:BitmapData, press:BitmapData, lock:BitmapData):void {
			runner2.normalBitmap = normal;
			runner2.overBitmap = over;
			runner2.pressBitmap = press;
			runner2.lockBitmap = lock;
		}
		
		/**
		 * Отрисовка
		 * @param size
		 */	
		override public function draw(size:Point):void {
			super.draw(size);
			currentPos2 = _currentPos2;
		}
		
		/**
		 * Рассылка изменения координат мыши 
		 * @param mouseCoord координаты мыши
		 */		
		override public function mouseMove(mouseCoord:Point):void {
			if (runner.dragON) {
				super.mouseMove(mouseCoord);
			} else {
				onRunner2Drag(mouseCoord);
			}
		}
		
		/**
		 * Смена 2-й позиции при перетаскивании 2-го бегунка 
		 * @param mouseCoord координаты мыши
		 */		
		private function onRunner2Drag(mouseCoord:Point):void {
			if (dragPoint2 == null) {
				// Сохранение точки захвата бегунка
				dragPoint2 = MouseUtils.localCoords(runner2);
			}
			
			var mouseCoords:Point = MouseUtils.localCoords(this);
			var length:int;
			if (_direction == Direction.HORIZONTAL) {
				// ГОРИЗОНТАЛЬНЫЙ
				length = track.width;
				var arrowCoord:int = Math.floor(mouseCoords.x - dragPoint2.x + runnerWidth/2);
				// Определение позиции
				var n:int;
				if (segmentAligned)
					n = Math.floor((arrowCoord - _borderThickness)/divisionLength)+1;
				else
					n = Math.floor((arrowCoord - _borderThickness - offset + divisionLength*0.5)/divisionLength)+1;
			} else {
				// ВЕРТИКАЛЬНЫЙ
				length = track.height;
				var arrowCoord:int = Math.floor(mouseCoords.y - dragPoint2.y + runnerHeight/2);
				// Определение позиции
				var n:int;
				if (segmentAligned)
					n = Math.floor(((_currentSize.y - arrowCoord) - _borderThickness)/divisionLength)+1;
				else
					n = Math.floor(((_currentSize.y - arrowCoord) - _borderThickness - offset + divisionLength*0.5)/divisionLength)+1;
			}
			// Краевые ограничения
			if (n < 1) n = 1;
			if (n > posNum) n = posNum;
			// Установка бегунка
			if (n != currentPos2) currentPos2 = n;
		}
		
		private function drawRangeFill():void {
			var w:int;
			var h:int;
			if (_direction == Direction.HORIZONTAL) {
				// ГОРИЗОНТАЛЬНЫЙ
				w = runner2.x - runner.x - runnerWidth;
				h = runner.height;
				rangeFill.graphics.clear();
				if (skin.bitmapRangeFillMode) {
					rangeFill.graphics.beginBitmapFill(skin.horizRangeFill);
				} else {
					rangeFill.graphics.beginFill(skin.rangeFillColor, 0.5);
				}
				rangeFill.graphics.drawRect(0, 0, w, h);
			} else {
				// ВЕРТИКАЛЬНЫЙ
				w = runner.width;
				h = runner.y - runner2.y - runnerHeight;
				rangeFill.graphics.clear();
				if (skin.bitmapRangeFillMode) {
					rangeFill.graphics.beginBitmapFill(skin.vertRangeFill);
				} else {
					rangeFill.graphics.beginFill(skin.rangeFillColor, 0.5);
				}
				rangeFill.graphics.drawRect(0, 0, w, h);
			}	
			
		}
		
		/**
		 * Установка бегунка в нужную позицию
		 * @param posNum - номер позиции (1..posNum)
		 */		
		override public function set currentPos(num:int):void {
			if (num < 1) num = 1;
			if (num > _currentPos2) num = _currentPos2;
			//trace("pos1: " + num);
				
			// Установка бегунка
			if (_direction == Direction.HORIZONTAL) {
				
				// ГОРИЗОНТАЛЬНЫЙ
				if (segmentAligned) {
					runner.x = _borderThickness + Math.floor((num - 1)*divisionLength - Math.floor(runnerWidth/2));
					if (runnerAlign == Align.CENTER) {
						runner.x += Math.floor(divisionLength/2);
					} else if (runnerAlign == Align.RIGHT) {
						runner.x += divisionLength;
					}
				} else {
					var tickWidth:int = (_tickBitmap != null) ? _tickBitmap.width : 1;
					runner.x = _borderThickness + offset + Math.floor((num - 1)*divisionLength) - runnerWidth;// + Math.floor((tickWidth - runnerWidth)*0.5));
				}
				rangeFill.x = runner.x + runnerWidth;
			} else {
				
				// ВЕРТИКАЛЬНЫЙ
				if (segmentAligned) {
					runner.y = _borderThickness + Math.floor((posNum - (num))*divisionLength - Math.floor(runnerHeight/2));
					if (runnerAlign == Align.MIDDLE) {
						runner.y += Math.floor(divisionLength/2);
					} else if (runnerAlign == Align.BOTTOM) {
						runner.y += divisionLength;
					}
				} else {
					var tickHeight:int = (_tickBitmap != null) ?  _tickBitmap.height : 1;
					runner.y = _borderThickness + offset + Math.floor((posNum - (num))*divisionLength + Math.floor((tickHeight - runnerHeight)*0.5));
				}
			}
			drawRangeFill();
			
			if (_currentPos != num) {
				// Сохранение позиции
				_currentPos = num;
				// Генерация события
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE_POS, _currentPos));
			}
		}
		
		/**
		 * Установка 2-го бегунка в нужную позицию
		 * @param posNum - номер позиции (1..posNum)
		 */		
		public function set currentPos2(num:int):void {
			if (num < currentPos) num = currentPos;
			if (num > posNum) num = posNum;
			//trace("pos2: " + num);
			
			// Установка бегунка
			if (_direction == Direction.HORIZONTAL) {
				
				// ГОРИЗОНТАЛЬНЫЙ
				if (segmentAligned) {
					runner2.x = _borderThickness + Math.floor((num - 1)*divisionLength - Math.floor(runnerWidth/2));
					if (runnerAlign == Align.CENTER) {
						runner2.x += Math.floor(divisionLength/2);
					} else if (runnerAlign == Align.RIGHT) {
						runner2.x += divisionLength;
					}
				} else {
					var tickWidth:int = (_tickBitmap != null) ? _tickBitmap.width : 1;
					runner2.x = _borderThickness + offset + Math.floor((num - 1)*divisionLength);// + Math.floor((tickWidth - runnerWidth)*0.5));
				}
			} else {
				
				// ВЕРТИКАЛЬНЫЙ
				if (segmentAligned) {
					runner2.y = _borderThickness + Math.floor((posNum - (num))*divisionLength - Math.floor(runnerHeight/2));
					if (runnerAlign == Align.MIDDLE) {
						runner2.y += Math.floor(divisionLength/2);
					} else if (runnerAlign == Align.BOTTOM) {
						runner2.y += divisionLength;
					}
				} else {
					var tickHeight:int = (_tickBitmap != null) ?  _tickBitmap.height : 1;
					runner2.y = _borderThickness + offset + Math.floor((posNum - (num))*divisionLength + Math.floor((tickHeight - runnerHeight)*0.5));
				}
				rangeFill.y = runner2.y + runnerHeight;
			}
			drawRangeFill();
			
			if (_currentPos2 != num) {
				// Сохранение позиции
				_currentPos2 = num;
				// Генерация события
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE_POS, _currentPos2));
			}
		}
		/**
		 * @return текущая позиция 2-го бегунка
		 */		
		public function get currentPos2():int {
			return _currentPos2;
		}

	}
}