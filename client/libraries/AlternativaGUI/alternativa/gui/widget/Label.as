package alternativa.gui.widget {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * Текстовая метка
	 */	
	public class Label extends Widget {
		
		/**
		 * Текстовое поле 
		 */		
		public var tf:ActiveTextField;
		/**
		 * Текущий размер текстового поля
		 */		
		protected var _textWidth:int;
		/**
		 * Текст
		 */		
		protected var _text:String;
		/**
		 * Выравнивание
		 */		
		protected var _align:uint;
		/**
		 * Скин 
		 */				
		private var skin:LabelSkin;
		/**
		 * Заданный цвет текста (перекрывает цвет скина, если не равен -1)
		 */		
		private var color:int;
		
		/**
		 * @param text текст
		 * @param align выравнивание
		 * @param color цвет, перекрывающий цвет их скина
		 */		
		public function Label(text:String = "", align:uint = Align.LEFT, color:int = -1) {
			super();
			// Отключение событий курсора
			cursorActive = false;
			tabEnabled = false;
			
			// Создание текстового поля
			tf = new ActiveTextField();			
			addChild(tf);
			tf.cursorActive = false;
			tf.tabEnabled = false;
			
			with (tf) {
				autoSize = TextFieldAutoSize.LEFT;
				antiAliasType = AntiAliasType.ADVANCED;
				embedFonts = true;
				selectable = false;
				multiline = false;
				mouseEnabled = false;
				tabEnabled = false;
				cursorActive = false;
				y = -3;
			}
			// Установки параметров
			_align = align;
			this.color = color;
			_text = text;
			tf.text = text;
		}
		
		/**
		 * Обновить скин 
		 */	
		override public function updateSkin():void {
			skin = LabelSkin(skinManager.getSkin(getSkinType()));
			super.updateSkin();
			// Параметры отображения
			tf.thickness = skin.thickness;
			tf.sharpness = skin.sharpness;
			// Обновляем формат текста			
			switchState();
			// Пересчитываем ширину и высоту
			calcTextWidth();
			// Вынужденное шаманство из-за странности текстовых полей
			if (tf.textHeight > 0) {
				_minSize.y = Math.round(tf.textHeight - 3);
			}
			// Минимальная ширина задается только извне
			
			tf.cacheAsBitmap = true;
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */		
		protected function getSkinType():Class {
			return Label;
		}
		
		/**
		 * Расчёт ширины текста
		 */
		protected function calcTextWidth():void {
			_textWidth = Math.round(tf.textWidth);
		}
		
		/**
		 * Расчет минимальных размеров элемента
		 * @param size исходные размеры от менеджера компоновки
		 * @return минимальные размеры
		 */
		override public function computeMinSize():Point {
			if (visible) {
				var newSize:Point = _minSize.clone();
				if (_text != "" && _text != null)
					newSize.x = Math.max(_minSize.x, _textWidth);
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
			if (visible) {
				var newSize:Point = _minSize.clone();
				if (size != null) {
					if (_stretchableH)
						newSize.x = Math.max(size.x, _minSize.x, _textWidth);
					else
						newSize.x = Math.max(_minSize.x, _textWidth);
				} 
				return newSize;
			} else {
				return new Point();
			}
		}
		
		/**
		 * Проверить является ли объект растягиваемым 
		 * @param direction направление растягивания
		 * @return растягиваемость по данному направлению
		 */
		override public function isStretchable(direction:Boolean):Boolean {
			return (direction == Direction.HORIZONTAL) ? _stretchableH : false;
		}
		
		/**
		 * Отрисовка в заданном размере
		 * @param size заданный размер
		 */	
		override public function draw(size:Point):void {
			//trace("Label draw size: " + size);
			//trace("Label text: " + text);
			/*this.graphics.clear();
			this.graphics.lineStyle(1, 0x0000ff, 1);
			this.graphics.drawRect(0, 0, size.x, size.y);*/
			
			super.draw(size);
			if (align == Align.CENTER || align == Align.RIGHT) {
				drawTextField();
			} else {
				// Вынужденное шаманство из-за разницы в 3px с настоящей шириной текстового поля
				tf.x = -2;
			}
		}
		
		/**
		 * Отрисовка текстового поля
		 */
		protected function drawTextField():void {
			switch (align) {
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
			// Вынужденное шаманство из-за разницы в 3px с настоящей шириной текстового поля
			tf.x -= 2;
		}
		
		/**
		 * Смена визуального состояния
		 */		
		protected function switchState():void {
			var format:TextFormat = _locked ? skin.tfLocked : skin.tfNormal;
			var filters:Array = _locked ? skin.filtersLocked : skin.filtersNormal;
			state(format, filters);
		}
		
		/**
		 * Установка визуального состояния
		 * @param format формат текста
		 */		
		protected function state(format:TextFormat, filters:Array):void {
			tf.setTextFormat(format);
			tf.defaultTextFormat = format;
			if (color != -1) {
				if (!_locked) 
					tf.textColor = color;
				else 
					tf.textColor = int(format.color);
			}
			if (filters.length > 0) {
				tf.filters = filters;
			}
		}
		
		/**
		 * Установить флаг блокировки
		 * @param value значение флага блокировки
		 */		
		override public function set locked(value:Boolean):void {
			super.locked = value;
			// Перерисовка
			if (isSkined) {
				// Сохранение старой ширины
				var oldTextWidth:int = _textWidth;	
				// Смена формата
				switchState();
				// Пересчет ширины
				calcTextWidth();
				var d:int = _textWidth - oldTextWidth;
				// Пересчет высоты
				_minSize.y = Math.round(tf.textHeight - 3);// Вынужденное шаманство из-за странности текстовых полей
				// Перерисовка
				draw(new Point(_currentSize.x + d, _minSize.y));
			}
		}
		
		/**
		 * Установить выравнивание текста 
		 */		
		public function set align(value:uint):void {
			_align = value;
			if (isSkined)
				drawTextField();
		}
		
		/**
		 * Задать текст
		 * @param value текст
		 */		
		public function set text(value:String):void {
			minSizeChanged = true;
			
			if (value != null) {
				_text = value;
				tf.text = value;				
				if (isSkined) {
					// Пересчет ширины
					var oldTextWidth:int = _textWidth;				
					calcTextWidth();
					var d:int = _textWidth - oldTextWidth;
					// Пересчет высоты
					if (tf.textHeight > 0) {
						_minSize.y = Math.round(tf.textHeight - 3);
					}
					// Перерисовка
					draw(new Point(_currentSize.x + d, _minSize.y));
				}
			} else {
				_text = "";
				tf.text = _text;
			}
		}
		
		/**
		 * Установить цвет текста
		 * @param color цвет
		 */		
		public function set textColor(color:int):void {
			this.color = color;
			tf.setTextFormat(tf.defaultTextFormat);
			tf.textColor = color;
		}
		
		/**
		 * Получить выравнивание 
		 * @return выравнивание
		 */		
		public function get align():uint {
			return _align;
		}
		/**
		 * Получить текст
		 * @return текст
		 */		
		public function get text():String {
			return tf.text;
		}
		/**
		 * Получить цвет текста
		 * @return цвет текста
		 */		
		public function get textColor():int {
			return color;
		}
		
	}
}