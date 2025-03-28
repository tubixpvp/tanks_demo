package alternativa.gui.widget {
	import alternativa.gui.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.gui.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.skin.widget.InputSkin;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * Текстовое поле ввода 
	 */	
	public class Input extends Text {

		// Части фона
		private var left:Bitmap;
		private var center:Bitmap;
		private var right:Bitmap;
		/**
		 * Скин 
		 */
		private var skin:InputSkin;
		
		/**
		* Флаг правильности введенных данных
		*/
		private var _wrong:Boolean = false;
		/**
		 * @private
		 * Действие "ВВОД"
		 */
		private const KEY_ACTION_ENTER:String = "InputEnter";
		
//		var tfBorder:Shape = new Shape();
		
		/**
		 * @param text текст
		 * @param maxChars максимальное количество символов
		 * @param align выравнивание
		 */		
		public function Input(text:String = "", maxChars:uint = 0) {			
			super(0, text, Align.LEFT, false, true, maxChars);
			
			tf.multiline = false;
			
			// Создаём части фона
			left = new Bitmap();
			center = new Bitmap();
			right = new Bitmap();
			addChildAt(left,0);
			addChildAt(center,1);
			addChildAt(right,2);
			
			// Фильтры горячих клавиш
			var pressFilter:FocusKeyFilter = new FocusKeyFilter(tf, new SimpleKeyFilter(new Array([13])));
			keyFiltersConfig.addKeyDownFilter(pressFilter, KEY_ACTION_ENTER);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_ENTER, this, onEnter);
			
//			tfBorder = new Shape();
//			addChild(tfBorder);
		}
		
		private function onEnter():void {
			dispatchEvent(new Event(Event.COMPLETE, true, true));
		}
		
		/**
		 * Обновить скин 
		 */	
		public override function updateSkin():void {
			skin = InputSkin(skinManager.getSkin(getSkinType()));
			super.updateSkin();
			_minSize.x = Math.max(_minSize.x, skin.leftMargin + skin.rightMargin + tf.width);
			_minSize.y = skin.bmpNC.height;
			
			tf.x = skin.leftMargin;
			tf.y = skin.topMargin;	
			
			tf.autoSize = TextFieldAutoSize.NONE;
			tf.height = _minSize.y;
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */
		override protected function getSkinType():Class {
			return Input;
		}
		
		override public function computeMinSize():Point {
			if (visible) {
				return _minSize.clone();
			} else {
				return new Point();
			}
		}
		
		override public function computeSize(size:Point):Point {
			var newSize:Point = _minSize.clone();
			
			if (size != null) {
				if (_stretchableH)
					newSize.x = Math.max(size.x, _minSize.x);
			} 
			
			return newSize;
		}
		
		/**
		 * Отрисовка в заданном размере
		 * @param size заданный размер
		 */
		override public function draw(size:Point):void {
			_currentSize = size.clone();
			drawInput();
		}
		
		/**
		 * Отрисовка поля ввода
		 */
		private function drawInput():void {
			tf.width = currentSize.x - skin.leftMargin - skin.rightMargin;
			
			/*tfBorder.graphics.clear();
			tfBorder.graphics.lineStyle(1, 0x0000ff, 1);
			tfBorder.graphics.drawRect(0, 0, currentSize.x, currentSize.y);*/
			
			center.x = left.width;
			center.width = currentSize.x - left.width - right.width;
			right.x = currentSize.x - right.width;
		}

		//override protected function calcTextWidth():void {
			//trace("Input calcTextWidth");
			//_textWidth = Math.round(tf.width) - 3;// Вынужденное шаманство на 3px из-за странности текстовых полей
			//_minSize.x = Math.max(_minSize.x, skin.leftMargin + skin.rightMargin + _textWidth);
			//_minSize.y = skin.bmpNC.height;
		//}
		
		//override protected function onChange(e:Event):void {
			//trace("Input onChange");
			//_text = tf.text;
			//calcTextWidth();
			//repaint(currentSize);
			//dispatchEvent(new Event(Event.CHANGE));
		//}
		
		/**
		 * Смена визуального состояния
		 */		
		override protected function switchState():void {
			super.switchState();
			
			if (!_wrong) {
				if (_locked) {
					left.bitmapData = skin.bmpLL;
					center.bitmapData = skin.bmpLC;
					right.bitmapData = skin.bmpLR;	
				} else if (_over) {
					left.bitmapData = skin.bmpOL;
					center.bitmapData = skin.bmpOC;
					right.bitmapData = skin.bmpOR;	
				} else if (_focused) {
					left.bitmapData = skin.bmpFL;
					center.bitmapData = skin.bmpFC;
					right.bitmapData = skin.bmpFR;		
				} else {
					left.bitmapData = skin.bmpNL;
					center.bitmapData = skin.bmpNC;
					right.bitmapData = skin.bmpNR;
				}
			} else {
				if (_locked) {
					left.bitmapData = skin.bmpLL;
					center.bitmapData = skin.bmpLC;
					right.bitmapData = skin.bmpLR;	
				} else if (_over) {
					left.bitmapData = skin.bmpWOL;
					center.bitmapData = skin.bmpWOC;
					right.bitmapData = skin.bmpWOR;	
				} else {
					left.bitmapData = skin.bmpWL;
					center.bitmapData = skin.bmpWC;
					right.bitmapData = skin.bmpWR;		
				}
			}
		}
		
		/**
		 * Установка индекса для табуляции 
		 * @param index индекса для табуляции
		 */		
		override public function set tabIndex(index:int):void {
			tf.tabIndex = index;
		}
		
		/*override protected function focus():void {
			trace("Input focus");
			switchState();
			drawInput();
			var dx:int = skin.borderThickness;
			var dy:int = skin.borderThickness;
			drawFocusFrame(new Rectangle(dx, dy, _currentSize.x - 2*dx, _currentSize.y - 2*dy));
			addChild(focusFrame);
		}
		
		override protected function unfocus():void {
			removeChild(focusFrame);
			switchState();
			drawInput();
		}*/
		
		/**
		 * Задать текст
		 * @param value - текст
		 * 
		 */		
		override public function set text(value:String):void {
			if (value != null) {
				_text = value;
				tf.text = value;				
				tf.visible = true;
				if (isSkined) {
					// пересчет ширины
					calcTextWidth();
					// перерисовка
					repaintCurrentSize();
				}
			} else {
				_text = "";
				tf.text = _text;
				tf.visible = true;
			}
		}
		
		/**
		 * Установка флага наведенности
		 */
		override public function set over(value:Boolean):void {
			super.over = value;
			switchState();
			drawInput();
		}
		
		/**
		 * Установка флага блокировки
		 */
		override public function set locked(value:Boolean):void {
			super.locked = value;
			cursorActive = !value;
			tabEnabled = !value;
			tf.locked = value;
			if (isSkined) {
				switchState();
				drawInput();
			}
		}
		
		/**
		 * Установить отграничение на ввод символов 
		 * @param simbols допустимые для ввода символы
		 */		
		public function restrict(simbols:String):void {
			tf.restrict = simbols;
		}
		
		/**
		 * Флаг режима ввода текста как пароля 
		 * @param value значение флага режима пароля
		 */		
		public function set passwordMode(value:Boolean):void {
			tf.displayAsPassword = value;
		}
		
		public function set wrongData(value:Boolean):void {
			_wrong = value;
			switchState();
			drawInput();
		}
		public function get wrongData():Boolean {
			return _wrong;
		}
		
	}
}