package alternativa.gui.widget.slider {
	import alternativa.gui.init.GUI;
	import alternativa.gui.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.gui.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.mouse.IMouseCoordListener;
	import alternativa.gui.mouse.IMouseWheelListener;
	import alternativa.gui.skin.widget.button.ImageButtonSkin;
	import alternativa.gui.widget.Widget;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.utils.MouseUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * Многопозиционный переключатель из произвольной графики (не резиновый)
	 */	
	public class BitmapSlider extends Widget implements IMouseCoordListener, IMouseWheelListener {
		
		// Направление
		protected var _direction:Boolean;
		
		// Полоска для бегунка
		protected var track:Sprite;
		
		// Бегунок
		protected var runner:SliderRunnerButton;
		
		// Графика трэка, бегунка и рисок
		protected var _trackBitmap:BitmapData;
		protected var _runnerBitmap:BitmapData;
		protected var _tickBitmap:BitmapData;
		
		/**
		 * Скин кнопки 
		 */		
		protected var imageButtonSkin:ImageButtonSkin;
		
		// Количество позиций
		private var _posNum:int;
		
		// Текущая позиция
		protected var _currentPos:int;
		
		// Толщина обводки
		protected var _borderThickness:int;
		
		// Длина деления
		protected var divisionLength:Number;
		
		// Ширина бегунка
		protected var runnerWidth:int;
		
		// Высота бегунка
		protected var runnerHeight:int;
		
		// Выравнивание бегунка относительно центра позиции
		protected var runnerAlign:uint;
		
		// Риски позиций
		protected var ticks:Shape;
		
		// Отступ рисок от трэка
		protected var _tickMargin:int;
		
		// Флаг расстановки рисок по центрам отрезков
		protected var segmentAligned:Boolean;
		
		// Отступ рисок от краев справа и слева
		protected var offset:int;
		
		// Названия действий
		public static const KEY_ACTION_PREV:String = "SliderPrev";
		public static const KEY_ACTION_NEXT:String = "SliderNext";
		
		
		/**
		 * @param trackBitmap - область перемещения бегунка
		 * @param runnerBitmap - бегунок
		 * @param posNum - количество позиций
		 * @param currentPos - текущая позиция
		 * @param segmentAligned - true:расстановка рисок по центрам отрезков, false:расстановка на всю ширину трэка
		 * @param borderThickness - толщина обводки
		 * @param tickBitmap - риска
		 * @param tickMargin - отступ рисок от трэка
		 */		
		public function BitmapSlider(direction:Boolean, 
									 trackBitmap:BitmapData,
									 runnerBitmap:BitmapData,
									 posNum:int,
									 currentPos:int,
									 borderThickness:int,
									 segmentAligned:Boolean,
									 sideMarginsEnabled:Boolean,
									 tickBitmap:BitmapData = null,
									 tickMargin:int = 1) {
			super();
			
			// Сохранение параметров
			_direction = direction;
			_trackBitmap = trackBitmap;
			_runnerBitmap = runnerBitmap;
			_posNum = posNum;
			_borderThickness = borderThickness;
			this.segmentAligned = segmentAligned;
			this.runnerAlign = Align.CENTER;
			_tickBitmap = tickBitmap;
			_tickMargin = tickMargin;
			
			stretchableH = false;
			stretchableV = false;
			
			// Создаём трэк
			createTrack();
			
			// Создаем риски
			ticks = new Shape();
			addChild(ticks);
			
			// Создаем бегунок
			createRunner();
			
			// Расстановка графики
			if (trackBitmap != null && runnerBitmap != null) {
				arrangeGraphics();
				// Установка текущей позиции
				this.currentPos = currentPos;
			} else {
				_currentPos = currentPos;
			}
			
			var prevCode:int;
			var nextCode:int;
			if (_direction == Direction.HORIZONTAL) {
				prevCode = 37;
				nextCode = 39;
			} else {
				prevCode = 40;
				nextCode = 38;
			}
			var prevFilter:FocusKeyFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array([prevCode])));
			var nextFilter:FocusKeyFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array([nextCode])));
			keyFiltersConfig.addKeyDownFilter(prevFilter, KEY_ACTION_PREV);
			keyFiltersConfig.addKeyDownFilter(nextFilter, KEY_ACTION_NEXT);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_PREV, this, decCurrentPos);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_NEXT, this, incCurrentPos);
		}
		
		// Создание трэка
		protected function createTrack():void {
			track = new Sprite();
			track.mouseEnabled = false;
			track.mouseChildren = false;
			track.tabEnabled = false;
			track.tabChildren = false;
			addChild(track);
			if (_trackBitmap != null) {
				var bmp:Bitmap = new Bitmap(_trackBitmap);
				track.addChild(bmp);
			}
		}
		
		// Создание бегунка
		protected function createRunner():void {
			if (_direction == Direction.HORIZONTAL) {
				runner = new SliderRunnerButton(0, 0, _runnerBitmap);
			} else { 
				runner = new SliderRunnerButton(0, 0, _runnerBitmap);
			}
			addChild(runner);
			runner.slider = this;
		}
		
		// Расстановка битмап, сохранение размеров
		protected function arrangeGraphics():void {
			if (_direction == Direction.HORIZONTAL) {

				
				// ГОРИЗОНТАЛЬНЫЙ
				// Расстановка трэка и бегунка
				if (_trackBitmap.height > _runnerBitmap.height) {
					runner.y = Math.round((_trackBitmap.height - _runnerBitmap.height)/2);
				} else {
					track.y = Math.round((_runnerBitmap.height - _trackBitmap.height)/2);
				}
				runnerWidth = _runnerBitmap.width;
				
				if (segmentAligned) {
					// Отступ рисок от края
					offset = 0;
					// Ширина отрезков
					divisionLength = (_trackBitmap.width - _borderThickness*2)/posNum;
				} else {
					var tickWidth:int = (_tickBitmap != null) ? _tickBitmap.width : 1;
					offset = (runnerWidth > tickWidth) ? Math.floor((runnerWidth-tickWidth)*0.5) : 0;
					divisionLength = (_trackBitmap.width - offset*2 - _borderThickness*2 - tickWidth)/(posNum-1);
				}
				// Отрисовка рисок
				if (_tickBitmap != null) {
					drawTicks();
					ticks.x = _borderThickness;
					ticks.y = track.y + _trackBitmap.height + _tickMargin;
					// Установка высоты
					if (_trackBitmap.height > _runnerBitmap.height) {
						_minSize.y = _trackBitmap.height + _tickMargin + _tickBitmap.height;
					} else {
						_minSize.y = track.y + _trackBitmap.height + _tickMargin + _tickBitmap.height;
					}
				} else {
					// Установка высоты
					_minSize.y = Math.max(_runnerBitmap.height, _trackBitmap.height);
				}
				// Добавление области срабатывания
				addHitArea();
				
				// Установка ширины
				_minSize.x = _trackBitmap.width;
				
				_currentSize = _minSize.clone();
			} else {
				
				
				// ВЕРТИКАЛЬНЫЙ
				runnerHeight = _runnerBitmap.height;
				
				if (segmentAligned) {
					// Отступ рисок от края
					offset = 0;
					// Ширина отрезков
					divisionLength = (_trackBitmap.height - _borderThickness*2)/posNum;
				} else {
					var tickHeight:int = (_tickBitmap != null) ? _tickBitmap.height : 1;
					offset = (runnerHeight > tickHeight) ? Math.floor((runnerHeight-tickHeight)*0.5) : 0;
					divisionLength = (_trackBitmap.height - offset*2 - _borderThickness*2 - tickHeight)/(posNum-1);
				}
				// Отрисовка рисок
				if (_tickBitmap != null) {
					drawTicks();
					ticks.y = _borderThickness;
					// Расстановка трэка и бегунка
					if (_trackBitmap.width > _runnerBitmap.width) {
						track.x = _tickBitmap.width + _tickMargin;
						runner.x = track.x + Math.round((_trackBitmap.width - _runnerBitmap.width)/2);
					} else {
						var d:int = Math.round((_runnerBitmap.width - _trackBitmap.width)/2);
						if ((_tickBitmap.width + _tickMargin) < d) {
							track.x = d;
							ticks.x = track.x - (_tickBitmap.width + _tickMargin);
						} else {
							track.x = _tickBitmap.width + _tickMargin;
							runner.x = track.x - d;
						}
					}
					// Установка ширины
					if (_trackBitmap.width > _runnerBitmap.width) {
						_minSize.x = _trackBitmap.width + _tickMargin + _tickBitmap.width;
					} else {
						_minSize.x = runner.x + _runnerBitmap.width;
					}
				} else {
					// Расстановка трэка и бегунка
					if (_trackBitmap.width > _runnerBitmap.width) {
						runner.x = Math.round((_trackBitmap.width - _runnerBitmap.width)/2);
					} else {
						track.x = Math.round((_runnerBitmap.width - _trackBitmap.width)/2);
					}
					// Установка ширины
					_minSize.x = Math.max(_runnerBitmap.width, _trackBitmap.width);
				}
				// Добавление области срабатывания
				addHitArea();
				
				// Установка высоты
				_minSize.y = _trackBitmap.height;
				
				_currentSize = _minSize.clone();
			}
		}
		
		// Расстановка рисок
		protected function drawTicks():void {
			ticks.graphics.clear();
			if (_direction == Direction.HORIZONTAL) {
				// ГОРИЗОНТАЛЬНЫЙ
				for (var i:int = 0; i < posNum; i++) {
					var fillMatrix:Matrix = new Matrix();
					var sx:int;
					if (segmentAligned) {
						// центровка по отрезкам
						sx = Math.floor((divisionLength - _tickBitmap.width)*0.5) + Math.floor(i*divisionLength);
					} else {
						// расстановка на всю ширину
						sx = offset + Math.floor(i*divisionLength);
					}
					Matrix(fillMatrix).createBox(1, 1, 0, sx, 0);
					ticks.graphics.beginBitmapFill(_tickBitmap, fillMatrix, false, false);
					ticks.graphics.drawRect(sx, 0, _tickBitmap.width, _tickBitmap.height);
					ticks.graphics.endFill();
				}
			} else {
				// ВЕРТИКАЛЬНЫЙ
				for (var i:int = 0; i < posNum; i++) {
					var fillMatrix:Matrix = new Matrix();
					var sy:int;
					if (segmentAligned) {
						// центровка по отрезкам
						sy = Math.floor((divisionLength - _tickBitmap.height)*0.5) + Math.floor(i*divisionLength);
					} else {
						// расстановка на всю ширину
						sy = offset + Math.floor(i*divisionLength);
					}
					Matrix(fillMatrix).createBox(1, 1, 0, 0, sy);
					ticks.graphics.beginBitmapFill(_tickBitmap, fillMatrix, false, false);
					ticks.graphics.drawRect(0, sy, _tickBitmap.width, _tickBitmap.height);
					ticks.graphics.endFill();
				}
			}
		}
		
		// Добавление области срабатывания
		protected function addHitArea():void {
			var addition:int = 3;
			track.graphics.clear();
			track.graphics.beginFill(0, 0);
			
			if (_direction == Direction.HORIZONTAL) {
				// ГОРИЗОНТАЛЬНЫЙ
				var y0:int = -addition;
				var h:int = (_tickBitmap != null) ? (addition + _trackBitmap.height + _tickBitmap.height + _tickMargin) : (2*addition + _trackBitmap.height);
				
				track.graphics.drawRect(0, y0, _trackBitmap.width, h);
			} else {
				// ВЕРТИКАЛЬНЫЙ
				if (_tickBitmap != null) {
					var x0:int = -(_tickBitmap.width + _tickMargin);
					var w:int = addition + _trackBitmap.width + _tickBitmap.width + _tickMargin;
				} else {
					var x0:int = -addition;
					var w:int = 2*addition + _trackBitmap.width;
				}
				track.graphics.drawRect(x0, 0, w, _trackBitmap.height);
			}
		}
		
		/**
		 * Обновление скина 
		 */		
		override public function updateSkin():void {
			imageButtonSkin = ImageButtonSkin(skinManager.getSkin(ImageButton));
			super.updateSkin();
		}
		
		/**
		 * Расчет предпочтительных размеров
		 * @param size
		 * @return всегда минимальный размер
		 * 
		 */	
		override public function computeSize(size:Point):Point {
			return _minSize;
		}
		
		/**
		 * Отрисовка не нужна (currentSize сохраняется в конструкторе)
		 * @param size
		 * 
		 */	
		override public function draw(size:Point):void {}
		
		/**
		 * Перейти на предыдующую позицию 
		 */		
		public function decCurrentPos():void {
			currentPos = _currentPos - 1;
		}
		/**
		 * Перейти на следующую позицию 
		 */		
		public function incCurrentPos():void {
			currentPos = _currentPos + 1;
		}
		
		/**
		 * Рассылка изменения координат мыши 
		 * @param mouseCoord координаты мыши
		 */		
		public function mouseMove(mouseCoord:Point):void {
			var mouseCoords:Point = MouseUtils.localCoords(this);
			var length:int;
			if (_direction == Direction.HORIZONTAL) {
				// ГОРИЗОНТАЛЬНЫЙ
				length = track.width;
				var arrowCoord:int = Math.floor(mouseCoords.x - runner.dragPoint.x + runnerWidth/2);
				// Определение позиции
				var n:int;
				if (segmentAligned)
					n = Math.floor((arrowCoord - _borderThickness)/divisionLength)+1;
				else
					n = Math.floor((arrowCoord - _borderThickness - offset + divisionLength*0.5)/divisionLength)+1;
			} else {
				// ВЕРТИКАЛЬНЫЙ
				length = track.height;
				var arrowCoord:int = Math.floor(mouseCoords.y - runner.dragPoint.y + runnerHeight/2);
				// Определение позиции
				var n:int;
				if (segmentAligned)
					n = Math.floor(((_currentSize.y - arrowCoord) - _borderThickness)/divisionLength)+1;
				else
					n = Math.floor(((_currentSize.y - arrowCoord) - _borderThickness - offset + divisionLength*0.5)/divisionLength)+1;
			}
			// Краевые ограничения
			if (n < 1) n = 1;
			if (n > posNum) n = _posNum;
			// Установка бегунка
			if (n != currentPos) currentPos = n;
		}
		
		/**
		 * Рассылка прокрутки колесика мыши 
		 * @param delta поворот
		 */		
		public function mouseWheel(delta:int):void {
			var posDelta:int = (delta > 0) ? 1 : -1;
			currentPos = _currentPos + posDelta;
		}
		
		/**
		 * Смена визуального представления состояния 
		 */
		protected function switchState():void {
			if (pressed) {
				track.transform.colorTransform = imageButtonSkin.colorPress;
			} else if (over) {
				track.transform.colorTransform = imageButtonSkin.colorOver;
			} else {
				track.transform.colorTransform = imageButtonSkin.colorNormal;
			}
		}
		
		/**
		 * Флаг наведения
		 */
		override public function set over(value:Boolean):void {
			super.over = value;
			switchState();
			
			if (_over) {
				GUI.mouseManager.addMouseWheelListener(this);
			} else {
				GUI.mouseManager.removeMouseWheelListener(this);
			}
		}
		
		/**
		 * Флаг нажатия
		 */
		override public function set pressed(value:Boolean):void {
			super.pressed = value;
			switchState();
			
			if (_pressed) {
				var mouseCoords:Point = MouseUtils.localCoords(this);
				// Определение позиции
				if (_direction == Direction.HORIZONTAL) {
					// ГОРИЗОНТАЛЬНЫЙ
					if (segmentAligned) {
						currentPos = Math.floor((mouseCoords.x - _borderThickness)/divisionLength)+1;
					} else {
						currentPos = Math.floor((mouseCoords.x - _borderThickness - offset + divisionLength*0.5)/divisionLength)+1;
					}
				} else {
					// ВЕРТИКАЛЬНЫЙ
					if (segmentAligned) {
						currentPos = Math.floor((_currentSize.y - mouseCoords.y - _borderThickness)/divisionLength)+1;
					} else {
						currentPos = Math.floor((_currentSize.y - mouseCoords.y - _borderThickness - offset + divisionLength*0.5)/divisionLength)+1;
					}
				}
			}
		}
		
		/**
		 * Установка бегунка в нужную позицию
		 * @param posNum - номер позиции (1..posNum)
		 */		
		public function set currentPos(num:int):void {
			//trace("set currentPos: " + num);
			if (num < 1) num = 1;
			if (num > posNum) num = posNum;
				
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
					runner.x = _borderThickness + offset + Math.floor((num - 1)*divisionLength + Math.floor((tickWidth - runnerWidth)*0.5));
				}
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
			
			if (_currentPos != num) {
				// Сохранение позиции
				_currentPos = num;
				// Генерация события
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE_POS, _currentPos));
			}
		}
		/**
		 * Установка изображения полоски трэка
		 * @param bitmap
		 * 
		 */		
		public function set trackBitmap(bitmap:BitmapData):void {
			_trackBitmap = bitmap;
			var bmp:Bitmap = new Bitmap(_trackBitmap);
			track.addChild(bmp);
			if (_runnerBitmap != null)
				arrangeGraphics();
		}
		/**
		 * Установка изображения бегунка
		 * @param bitmap
		 * 
		 */		
		public function set runnerBitmap(bitmap:BitmapData):void {
			_runnerBitmap = bitmap;
			runner.normalBitmap = bitmap;
			if (_trackBitmap != null)
				arrangeGraphics();
		}
		/**
		 * Установка изображения риски
		 * @param bitmap
		 * 
		 */		
		public function set tickBitmap(bitmap:BitmapData):void {
			_tickBitmap = bitmap;
			drawTicks();
		}		
		/**
		 * Установка толщины обводки
		 * @param value
		 * 
		 */		
		public function set borderThickness(value:int):void {
			if (_trackBitmap != null && _runnerBitmap != null && value != _borderThickness) {
				_borderThickness = value;
				arrangeGraphics();
			} else {
				_borderThickness = value;
			}
		}
		
		/**
		 * Установка подсказки
		 * @param value - строка подсказки
		 * 
		 */		
		override public function set hint(value:String):void {
			super.hint = value;
			//track.hint = value;
			runner.hint = value;
		}
		
		/**
		 * Установка отступа рисок от трэка
		 * @param value
		 * 
		 */		
		/*public function set tickMargin(value:int):void {
			_tickMargin = value;
			ticks.y = track.y + track.height + value;
		}*/
			
		/**
		 * @return текущая позиция
		 */		
		public function get currentPos():int {
			return _currentPos;
		}
		/**
		 * @return количество позиций 
		 */		
		public function get posNum():int {
			return _posNum;
		}
		
		/**
		 * Кнопка бегунка 
		 */		
		public function get runnerButton():SliderRunnerButton {
			return runner;
		}
		
	}
}