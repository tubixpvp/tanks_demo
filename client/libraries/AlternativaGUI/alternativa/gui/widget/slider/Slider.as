package alternativa.gui.widget.slider {
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.skin.widget.slider.SliderSkin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Базовый горизонтальный слайдер с возможностью скинования (тянется по горизонтали)
	 */	
	public class Slider extends BitmapSlider {
		
		// Шкурка
		private var skin:SliderSkin;
		
		// Графика трэка
		private var trackLeft:Bitmap;
		private var trackCenter:Bitmap;
		private var trackRight:Bitmap;
		
		// Минимальная ширина ячейки
		private var divisionMinLength:int;
		
		// Включение отображения рисок
		private var showTicks:Boolean;
		
		/**
		 * @param posNum - количество позиций
		 * @param currentPos - текущая позиция
		 * @param divisionMinLength - минимальная ширина ячейки
		 * @param runnerAlign - выравнивание бегунка в ячейке каждой позиции
		 * 
		 */		
		public function Slider(direction:Boolean,
							   posNum:int,
							   currentPos:int,
							   divisionMinLength:int,
							   showTicks:Boolean) {
			
			super(direction, null, null, posNum, currentPos, 0, false, true);
			
			this.divisionMinLength = divisionMinLength;
			this.showTicks = showTicks;
		}
		
		// Создание трэка
		override protected function createTrack():void {
			track = new Sprite();
			track.tabEnabled = false;
			track.tabChildren = false;
			addChild(track);
			
			trackLeft = new Bitmap();
			trackCenter = new Bitmap();
			trackRight = new Bitmap();
			track.addChild(trackLeft);
			track.addChild(trackCenter);
			track.addChild(trackRight);
		}
		
		/**
		 * Обновить скин 
		 */
		override public function updateSkin():void {
			skin = SliderSkin(skinManager.getSkin(getSkinType()));
			super.updateSkin();
			
			if (_direction == Direction.HORIZONTAL) {
				// ГОРИЗОНТАЛЬНЫЙ
				setTrackParts(skin.horizTrackLeft, skin.horizTrackCenter, skin.horizTrackRight);
				_runnerBitmap = skin.horizRunner;
				_tickBitmap = skin.horizTick;
			} else {
				// ВЕРТИКАЛЬНЫЙ
				setTrackParts(skin.vertTrackTop, skin.vertTrackMiddle, skin.vertTrackBottom);
				_runnerBitmap = skin.vertRunner;
				_tickBitmap = skin.vertTick;
			}
			setRunnerStates(_runnerBitmap, _runnerBitmap, _runnerBitmap, _runnerBitmap);
			
			_borderThickness = skin.borderThickness;
			_tickMargin = skin.tickMargin;
			
			arrangeGraphics();
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */
		protected function getSkinType():Class {
			return Slider;
		}
		
		// Загрузка битмап трэка
		private function setTrackParts(left:BitmapData, center:BitmapData, right:BitmapData):void {
			trackLeft.bitmapData = left;
			trackCenter.bitmapData = center;
			trackRight.bitmapData = right;
		}
		
		// Загрузка битмап бегунка
		private function setRunnerStates(normal:BitmapData, over:BitmapData, press:BitmapData, lock:BitmapData):void {
			runner.normalBitmap = normal;
			runner.overBitmap = over;
			runner.pressBitmap = press;
			runner.lockBitmap = lock;
		}
		
		// Расстановка битмап, сохранение размеров
		override protected function arrangeGraphics():void {
			if (_direction == Direction.HORIZONTAL) {
				// ГОРИЗОНТАЛЬНЫЙ
				if (trackCenter.height > _runnerBitmap.height) {
					runner.y = Math.round((trackCenter.height - _runnerBitmap.height)/2);
				} else {
					track.y = Math.round((_runnerBitmap.height - trackCenter.height)/2);
				}
				runnerWidth = _runnerBitmap.width;
				
				if (segmentAligned) {
					// Отступ рисок от края
					offset = 0;
					// Установка ширины
					_minSize.x = 2*skin.borderThickness + divisionMinLength*posNum;
				} else {
					var tickWidth:int = (_tickBitmap != null && showTicks) ? _tickBitmap.width : 1;
					offset = (runnerWidth > tickWidth) ? Math.floor((runnerWidth-tickWidth)*0.5) : 0;
					_minSize.x = 2*skin.borderThickness + offset*2 + divisionMinLength*(posNum-1) + tickWidth;
				}
				// Ширина отрезков
				divisionLength = divisionMinLength;
				
				// Отрисовка рисок
				if (_tickBitmap != null && showTicks) {
					drawTicks();
					ticks.x = _borderThickness;
					ticks.y = track.y + skin.horizTrackCenter.height + _tickMargin;
					// Установка высоты
					if (skin.horizTrackCenter.height > _runnerBitmap.height) {
						_minSize.y = skin.horizTrackCenter.height + _tickMargin + _tickBitmap.height;
					} else {
						_minSize.y = track.y + skin.horizTrackCenter.height + _tickMargin + _tickBitmap.height;
					}
				} else {
					// Установка высоты
					_minSize.y = Math.max(_runnerBitmap.height, skin.horizTrackCenter.height);
				}
			} else {
				// ВЕРТИКАЛЬНЫЙ
				runnerHeight = _runnerBitmap.height;
				
				if (segmentAligned) {
					// Отступ рисок от края
					offset = 0;
					// Установка высоты
					_minSize.y = 2*skin.borderThickness + divisionMinLength*posNum;
				} else {
					var tickHeight:int = (_tickBitmap != null && showTicks) ? _tickBitmap.height : 1;
					offset = (runnerHeight > tickHeight) ? Math.floor((runnerHeight-tickHeight)*0.5) : 0;
					_minSize.y = 2*skin.borderThickness + offset*2 + divisionMinLength*(posNum-1) + tickHeight;
				}
				// Ширина отрезков
				divisionLength = divisionMinLength;
				
				// Отрисовка рисок
				if (_tickBitmap != null && showTicks) {
					drawTicks();
					ticks.y = _borderThickness;
					// Расстановка трэка и бегунка
					var trackWidth:int = trackCenter.width;
					if (trackWidth > _runnerBitmap.width) {
						track.x = _tickBitmap.width + _tickMargin;
						runner.x = track.x + Math.round((trackWidth - _runnerBitmap.width)/2);
					} else {
						var d:int = Math.round((_runnerBitmap.width - trackWidth)/2);
						if ((_tickBitmap.width + _tickMargin) < d) {
							track.x = d;
							ticks.x = track.x - (_tickBitmap.width + _tickMargin);
						} else {
							track.x = _tickBitmap.width + _tickMargin;
							runner.x = track.x - d;
						}
					}
					// Установка ширины
					if (trackWidth > _runnerBitmap.width) {
						_minSize.x = trackWidth + _tickMargin + _tickBitmap.width;
					} else {
						_minSize.x = runner.x + _runnerBitmap.width;
					}
				} else {
					// Расстановка трэка и бегунка
					if (trackCenter.width > _runnerBitmap.width) {
						runner.x = Math.round((trackCenter.width - _runnerBitmap.width)/2);
					} else {
						track.x = Math.round((_runnerBitmap.width - trackCenter.width)/2);
					}
					// Установка ширины
					_minSize.x = Math.max(_runnerBitmap.width, skin.vertTrackMiddle.width);
				}
				
			}
			// Добавление области срабатывания
			addHitArea();
		}
		
		// Добавление области срабатывания
		override protected function addHitArea():void {
			var addition:int = 3;
			track.graphics.clear();
			track.graphics.beginFill(0, 0);
			
			if (_direction == Direction.HORIZONTAL) {
				// ГОРИЗОНТАЛЬНЫЙ
				var y0:int = -addition;
				var h:int = (_tickBitmap != null && showTicks) ? (addition + skin.horizTrackCenter.height + _tickBitmap.height + _tickMargin) : (2*addition + skin.horizTrackCenter.height);
				
				track.graphics.drawRect(0, y0, _currentSize.x, h);
			} else {
				// ВЕРТИКАЛЬНЫЙ
				if (_tickBitmap != null && showTicks) {
					var x0:int = -(_tickBitmap.width + _tickMargin);
					var w:int = addition + skin.vertTrackMiddle.width + _tickBitmap.width + _tickMargin;
				} else {
					var x0:int = -addition;
					var w:int = 2*addition + skin.vertTrackMiddle.width;
				}
				track.graphics.drawRect(x0, 0, w, _currentSize.y);
			}
		}
		
		/**
		 * Расчет предпочтительных размеров
		 * @param size
		 * @return 
		 * 
		 */	
		override public function computeSize(size:Point):Point {
			var newSize:Point = _minSize.clone();
			if (size != null) {
				if (_direction == Direction.HORIZONTAL) {
					newSize.x = isStretchable(Direction.HORIZONTAL) ? Math.max(size.x, _minSize.x) : _minSize.x;
					newSize.y = _minSize.y;
				} else {
					newSize.y = isStretchable(Direction.HORIZONTAL) ? Math.max(size.y, _minSize.y) : _minSize.y;
					newSize.x = _minSize.x;
				}				
			} 
			return newSize;
		}
		/**
		 * Отрисовка
		 * @param size
		 */	
		override public function draw(size:Point):void {
			_currentSize = size.clone();
			
			if (_direction == Direction.HORIZONTAL) {
				
				// ГОРИЗОНТАЛЬНЫЙ
				// Резина трэка
				trackCenter.x = trackLeft.width;
				trackRight.x = size.x - trackRight.width;
				trackCenter.width = trackRight.x - trackCenter.x;
				// Пересчет ширины деления
				var tickWidth:int = (_tickBitmap != null && showTicks) ? _tickBitmap.width : 1;
				divisionLength = (size.x - offset*2 - _borderThickness*2 - tickWidth)/(posNum-1);
			} else {
				
				// ВЕРТИКАЛЬНЫЙ
				// Резина трэка
				trackCenter.y = trackLeft.height;
				trackRight.y = size.y - trackRight.height;
				trackCenter.height = trackRight.y - trackCenter.y;
				// Пересчет ширины деления
				var tickHeight:int = (_tickBitmap != null && showTicks) ?  _tickBitmap.height : 1;
				divisionLength = (size.y - offset*2 - _borderThickness*2 - tickHeight)/(posNum-1);
			}
			// Построение рисок
			if (_tickBitmap != null && showTicks) 
				drawTicks();
			// Установка бегунка
			this.currentPos = currentPos;
			
			// Добавление области срабатывания
			addHitArea();
		}
		
		// Фокусировка
		override protected function focus():void {
			var rect:Rectangle = new Rectangle(0, 0, _currentSize.x, _currentSize.y);
			if (showTicks)
				rect.height += 2;
			drawFocusFrame(rect);
			addChild(focusFrame);
		}
		
	}
}