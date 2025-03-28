package alternativa.gui.widget {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.skin.widget.TextSkin;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Mouse;

	/**
	 * Текстовое поле с возможностью редактирования
	 */
	public class Text extends Label {
		
		/**
		 * Режим автоматического переноса строк
		 */		
		private var _wordWrap:Boolean;
		/**
		 * Режим редактирования
		 */		
		private var _editable:Boolean;
		/**
		 * Скин 
		 */		
		private var skin:TextSkin; 

		/**
		 * @param minWidth минимальная ширина
		 * @param text текст
		 * @param align выравнивание
		 * @param wordWrap автоматический перенос строк
		 * @param editable редактируемость
		 * @param maxChars максимальное количество символов
		 * @param color цвет, перекрывающий цвет их скина
		 */		
		public function Text(minWidth:int, text:String = "", align:uint = 0, wordWrap:Boolean = false, editable:Boolean = false, maxChars:uint = 255, color:int = -1) {
			super(text, align, color);
			
			/*switch (align) {
				case Align.LEFT:
					tf.autoSize = TextFieldAutoSize.LEFT;
					break;	
				case Align.CENTER:
					tf.autoSize = TextFieldAutoSize.CENTER;
					break;	
				case Align.RIGHT:
					tf.autoSize = TextFieldAutoSize.RIGHT;
					break;
			}*/
			//tf.autoSize = TextFieldAutoSize.NONE;
			// Начальные установки
			_wordWrap = wordWrap;
			tf.wordWrap = wordWrap;
			tf.multiline = true;
			tf.maxChars = maxChars;
			
			tf.width = _minSize.x = minWidth;
			
			tf.text = text;
			
			// Редактируемость
			_editable = editable;
			
			cursorActive = editable;
			tabEnabled = editable;
			mouseChildren = editable;
			tabChildren = editable;
			
			tf.mouseEnabled = editable;
			tf.cursorActive = editable;
			tf.tabEnabled = editable;
			tf.selectable = editable;
			tf.type = (!_editable) ? TextFieldType.DYNAMIC : TextFieldType.INPUT;
			
			// Настройка ретрансляции
			tf.addEventListener(Event.CHANGE, onChange);
			
			/*tf.addEventListener(MouseEvent.MOUSE_OVER, onTfMouseOver);
			tf.addEventListener(MouseEvent.MOUSE_OUT, onTfMouseOut);
			tf.addEventListener(MouseEvent.MOUSE_DOWN, onTfMouseDown);*/
			
			
			_sidesCorrelated = true;
		}
		
		private function onTfMouseOver(e:MouseEvent):void {
			//trace("onTfMouseOver");
			//IOInterfaces.mouseManager.changeCursor(IOInterfaces.mouseManager.cursorTypes.NONE);
		}
		private function onTfMouseOut(e:MouseEvent):void {
			//trace("onTfMouseOut");
			Mouse.hide();
		}
		private function onTfMouseDown(e:MouseEvent):void {
			//trace("onTfMouseDown");
			//tabEnabled = false;
			//stage.focus = tf;
		}
		
		/*override public function set over(value:Boolean):void {
			//trace("text over: " + value);
			super.over = value;
			if (_over) {
				
			}
		}*/
		
		/**
		 * Обновить скин 
		 */
		override public function updateSkin():void {
			skin = TextSkin(skinManager.getSkin(getSkinType()));
			super.updateSkin();
			tf.cacheAsBitmap = false;
			
			//tf.autoSize = TextFieldAutoSize.RIGHT;
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */
		override protected function getSkinType():Class {
			return Text;
		}
		
		/**
		 * Расчет минимальных размеров элемента
		 * @param size исходные размеры от менеджера компоновки
		 * @return минимальные размеры
		 */
		override public function computeMinSize():Point {
			if (visible) {
				var newSize:Point = _minSize.clone();
				if (_text != "" && _text != null) {
					tf.autoSize = TextFieldAutoSize.NONE;
					tf.width = _minSize.x;
					tf.autoSize = TextFieldAutoSize.LEFT;
					_minSize.y = Math.round(tf.height) - 6;// Вынужденное шаманство на 6px из-за странности текстовых полей
				}
				//trace("Text computeMinSize: " + newSize);
				return newSize;
			} else {
				return new Point();
			}
		}
		
		/**
		 * Расчет предпочтительных размеров с учетом stretchable флагов и минимальных размеров.
		 * @param size исходные размеры от менеджера компоновки
		 * @return предпочтительные размеры
		 */
		override public function computeSize(size:Point):Point {
			//trace("Text computeSize size: " + size);
			if (_wordWrap) {
				var newSize:Point = _minSize.clone();
				if (size != null) {
					if (_stretchableH) {
						newSize.x = Math.max(size.x, _minSize.x);
					} else {
						newSize.x = Math.max(_minSize.x);
					}
					tf.autoSize = TextFieldAutoSize.NONE;
					//trace("Text computeSize autoSize: " + tf.autoSize);
					_textWidth = newSize.x;
					tf.width = _textWidth;
					tf.autoSize = TextFieldAutoSize.LEFT;
					/*switch (align) {
						case Align.LEFT:
							tf.autoSize = TextFieldAutoSize.LEFT;
							break;	
						case Align.CENTER:
							tf.autoSize = TextFieldAutoSize.CENTER;
							break;	
						case Align.RIGHT:
							tf.autoSize = TextFieldAutoSize.RIGHT;
							break;
					}*/
					newSize.y = Math.round(tf.height) - 6;// Вынужденное шаманство на 6px из-за странности текстовых полей
				} 
				//trace("Text computeSize newSize: " + newSize);
				return newSize;				
			} else {
				if (visible) {
				
					var newSize:Point = _minSize.clone();
					if (size != null) {
						if (_stretchableH) {
							newSize.x = Math.max(size.x, _minSize.x, _textWidth);
						} else {
							newSize.x = Math.max(_minSize.x, _textWidth);
						}
						_textWidth = newSize.x;
						//tf.autoSize = TextFieldAutoSize.NONE;
						tf.width = _textWidth;
						newSize.y = Math.round(tf.height) - 6;// Вынужденное шаманство на 6px из-за странности текстовых полей
						//tf.autoSize = TextFieldAutoSize.LEFT;
					} 
					return newSize;
				} else {
					return new Point();
				}
			}
		}
		
		/**
		 * Отрисовка в заданном размере
		 * @param size заданный размер
		 */
		override public function draw(size:Point):void {
			//trace("Text draw size: " + size);
			//super.draw(size);
			
			_currentSize = size.clone();
			
//			this.graphics.clear();
//			this.graphics.lineStyle(1, 0x0000ff, 1);
//			this.graphics.drawRect(0, 0, size.x, size.y);

			//trace("Text draw autoSize: " + tf.autoSize);
			//drawTextField();
		}
		
		/**
		 *  Отрисовка надписи
		 */
		override protected function drawTextField():void {
			/*switch (align) {
				case Align.LEFT: 
					tf.x = 0;
					break;
				case Align.CENTER:
					tf.x = (_currentSize.x - _textWidth) >> 1;
					break;
				case Align.RIGHT:
					tf.x = _currentSize.x - _textWidth;
					break;
			}
			tf.x -= 2;// Вынужденное шаманство из-за разницы в 3px с настоящей шириной текстового поля*/
		}
		
		/**
		 * Изменили текст 
		 * @param e событие изменения
		 */		
		protected function onChange(e:Event):void {
			minSizeChanged = true;
			
			_text = tf.text;
			if (isSkined) {
				// пересчет ширины
				//var oldTextWidth:int = _textWidth;				
				calcTextWidth();
				//var d:int = _textWidth - oldTextWidth;
				// перерисовка
				//draw(new Point(_currentSize.x + d, _minSize.y));
			}
			//_text = tf.text;
			//calcTextWidth();
			//repaint(currentSize);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Смена состояния
		 */
		/*override protected function switchState():void {
			if (isSkined) {			
				var format:TextFormat = (_locked) ? skin.tfLocked : skin.tfNormal;
				tf.setTextFormat(format);
				tf.defaultTextFormat = format;
			}
		}*/
		
		/**
		 * Выделить весь текст
		 */		
		/*public function selectAll():void {
			tf.setSelection(0, tf.text.length);
		}*/
		
		/*override public function set pressed(value:Boolean):void {
			trace("set pressed: " + value);
			super.pressed = value;
			if (_pressed) {
				
			} else {
				
			}
		}*/

		/**
		 * Установка режима редактирования 
		 * @param value редактируемый или нет 
		 */						
		/*public function set editable(value:Boolean):void {
			_editable = value;
			mouseEnabled = _editable;
			tabEnabled = _editable;
			tf.mouseEnabled = _editable;
			tf.tabEnabled = _editable;
			tf.selectable = _editable;
			tf.type = (!_editable) ? TextFieldType.DYNAMIC : TextFieldType.INPUT;
		}*/
		
		// Фокусировка
		/*override public function set tabIndex(index:int):void {
			if (_editable) {
				tf.tabIndex = index;
			} else {
				tabIndex = index;
			}
		}*/
		
		/**
		 * Установка режима автоматического переноса строк
		 * @param value переносить или нет
		 */
		/*public function set wordWrap(value:Boolean):void {
				_wordWrap = value;
				tf.wordWrap = value;
				
				if (isSkined) repaintCurrentSize();
		}*/
		 
		/**
		 * Установка максимального количества символов 
		 * @param value максимальное количество символов 
		 */		
		/*public function set maxChars(value:uint):void {
			tf.maxChars = value;
		}*/

		/**
		 * Установить флаг блокировки
		 * @param value значение флага блокировки
		 */	
		/*override public function set locked(value:Boolean):void {
				_locked = value;
				//tf.tabEnabled = !value && _editable;
				//tf.mouseEnabled = !value && _editable;
				//mouseEnabled = !value && _editable;
				//tabEnabled = !value && _editable;
				
				// Если залочиваем
				if (_locked) {
					// Если объект фокусирован, снять с него фокус
					if (stage != null && stage.focus == this) {
						stage.focus = null;
					}
					// Отправляем отведение
					//dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
				}
				
				if (isSkined) switchState();				
		}*/

		/**
		 * Тип курсора 
		 */	
		/*override public function get cursorOverType():uint {
			var cursorType:uint;
			if (_editable) {
				cursorType = IOInterfaces.mouseManager.cursorTypes.EDIT_TEXT;
			} else {
				cursorType = IOInterfaces.mouseManager.cursorTypes.NORMAL;
			}			
			return cursorType;
		}*/
		/*override public function get cursorPressedType():uint {
			var cursorType:uint;
			if (_editable) {
				cursorType = IOInterfaces.mouseManager.cursorTypes.EDIT_TEXT;
			} else {
				cursorType = IOInterfaces.mouseManager.cursorTypes.NORMAL;
			}			
			return cursorType;
		}*/
		
	}
}