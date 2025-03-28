package alternativa.gui.widget.button {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.skin.widget.button.ButtonSkin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * Кнопка 
	 */
	public class Button extends BaseButton {
		
		/**
		 * Левая часть кнопки 
		 */		
		private var left:Bitmap;
		/**
		 * Центральная часть кнопки 
		 */		
		private var center:Bitmap;
		/**
		 * Правая часть кнопки 
		 */
		private var right:Bitmap;
		
		/**
		 * Надпись на кнопке
		 */		
		private var tf:TextField;
		/**
		 * Картинка на кнопке
		 */		
		private var gfx:Bitmap;
		
		/**
		 * Смещение иконки и текста при нажатии
		 */		
		private var yShift:int = 0;
		
		/**
		 * @private
		 * Скин 
		 */		
		protected var skin:ButtonSkin;
		
		/**
		 * Текст надписи
		 */		
		private var _text:String;
		
		/**
		 * Выравнивание
		 */		
		private var _align:uint;
		
		/**
		 * Минимальная ширина (зависит от скина, текста, иконки)
		 */		
		private var minWidth:int;
		
		
		/**
		 * @param text текст
		 * @param image иконка
		 * @param align выравнивание
		 */		
		public function Button(text:String = null, image:BitmapData = null, align:uint = 1) {
			super();
			
			// Создаём части кнопки
			left = new Bitmap();
			center = new Bitmap();
			right = new Bitmap();
			
			// Создаём картинку
			gfx = new Bitmap();
			
			// Создаём надпись
			tf = new TextField();
			with (tf) {
				autoSize = TextFieldAutoSize.LEFT;
				antiAliasType = AntiAliasType.ADVANCED;
				embedFonts = true;
				selectable = false;
				mouseEnabled = false;
				tabEnabled = false;
				cacheAsBitmap = true;
			}
			
			addChild(left);
			addChild(center);
			addChild(right);
			addChild(gfx);
			addChild(tf);
			
			// Устанавливаем параметры
			setText(text);
			setAlign(align);
			setImage(image);
		}
		
		/**
		 * Обновление скина 
		 */
		override public function updateSkin():void {
			skin = ButtonSkin(skinManager.getSkin(Button));
			
			// Сохранение высоты
			_minSize.y = skin.nc.height;
			
			// Настройка антиалиаса текста
			tf.thickness = skin.textThickness;
			tf.sharpness = skin.textSharpness;
			
			// Обновить состояние
			super.updateSkin();
			
			// Расчет ширины
			calcMinWidth();
		}		
		
		/**
		 * Расчет минимальных размеров объекта
		 * @return минимальные размеры
		 */	
		override public function computeMinSize():Point {
			calcMinWidth();
			minSizeChanged = false;
			return new Point(Math.max(_minSize.x, minWidth), minSize.y);
		}
		
		/**
		 * Расчет предпочтительных размеров с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */				
		override public function computeSize(size:Point):Point {
			var newSize:Point = new Point(Math.max(_minSize.x, minWidth), minSize.y);
			if (size != null) {
				if (_stretchableH) newSize.x = Math.max(size.x, newSize.x);
				if (_stretchableV) newSize.y = Math.max(size.y, newSize.y);
			} 
			
			return newSize;
		}
		
		/**
		 * Отрисовка в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */		
		override public function draw(size:Point):void {
			// Сохраняем размеры
			super.draw(size);
			// Расставляем части кнопки
			drawButton();
			// Расставляем надпись и картинку
			drawTextAndImage();
		}
		
		/**
		 * Размещение частей кнопки
		 */
		private function drawButton():void {
			center.x = left.width;
			center.width = currentSize.x - left.width - right.width;
			right.x = currentSize.x - right.width;
		}

		/**
		 * Размещение надписи и картинки
		 */
		private function drawTextAndImage():void {
			var x:int;
			var s:int = ((image != null) && (_text != null && _text != "")) ? skin.space : 0;//space
			var w:int = gfx.width + s + ((_text != null && _text != "") ? (tf.width - 3) : 0);//ширина image + space + textField (Вынужденное шаманство на 3px из-за странности текстовых полей)
			
			switch (align) {
				case Align.LEFT: 
					x = skin.margin;
					break;
				case Align.CENTER:
					x = Math.round((currentSize.x - w)/2);
					break;
				case Align.RIGHT:
					x = currentSize.x - w - skin.margin;
					break;
			}
			gfx.x = x;
			tf.x = x + gfx.width + s - 2;// Вынужденное шаманство из-за разницы в 3px с настоящей шириной текстового поля
			
			// Центровка картинки и текста по вертикали
			if (image != null)
				gfx.y = Math.round((_minSize.y - image.height)/2) + yShift;
			if (_text != null && _text != "")
				tf.y = Math.round((_minSize.y - (tf.height-6))/2) - 4 + yShift;// Вынужденное шаманство на 4px и 6px из-за странности текстовых полей
		}
		
		/**
		 * Расчёт минимальной ширины
		 */
		private function calcMinWidth():void {
			minWidth = skin.margin*2;
			if (_text != null && _text != "") {
				minWidth += Math.round(tf.width - 3);// Вынужденное шаманство на 3px из-за странности текстовых полей
			}
			if (image != null) {
				minWidth += Math.round(gfx.width) + ((_text != null && _text != "") ? skin.space : 0);
			}
		}
		
		/**
		 * Смена визуального состояния 
		 */
		override protected function switchState():void {		
			if (_locked) {
				state(skin.ll, skin.lc, skin.lr, 0, skin.tfLocked, skin.colorLocked);
			} else 
			if (_pressed) {
				state(skin.pl, skin.pc, skin.pr, skin.yPressShift, skin.tfPressed, skin.colorPressed);	
			} else 
			if (_over) {
				state(skin.ol, skin.oc, skin.or, 0, skin.tfOver, skin.colorOver); 
			} else 
			if (_focused) {
				state(skin.fl, skin.fc, skin.fr, 0, skin.tfNormal, skin.colorNormal);
			} else {
				state(skin.nl, skin.nc, skin.nr, 0, skin.tfNormal, skin.colorNormal);
			}
		}
		
		/**
		 * Перегрузка битмап и формата текста при смене состояния
		 */
		protected function state(_left:BitmapData,_center:BitmapData,_right:BitmapData, _yShift:int, format:TextFormat, color:ColorTransform):void {
			left.bitmapData = _left;
			center.bitmapData = _center;
			right.bitmapData = _right;
			yShift = _yShift;
			tf.setTextFormat(format);
			tf.defaultTextFormat = format;
			gfx.transform.colorTransform = color;
		}
		
		/**
		 * Фокусировка
		 */		
		override protected function focus():void {
			switchState();
			repaintCurrentSize();
			var dx:int = Math.round(skin.margin*0.5);
			var dy:int = Math.round(skin.margin*0.25);
			drawFocusFrame(new Rectangle(dx, dy, _currentSize.x - 2*dx, _currentSize.y - 2*dy));
			addChild(focusFrame);
		}
		/**
		 * Расфокусировка
		 */
		override protected function unfocus():void {
			removeChild(focusFrame);
			switchState();
			repaintCurrentSize();
		}
		
		/**
		 * Выравнивание
		 */
		public function get align():uint {
			return _align;
		}
		public function set align(value:uint):void {
			setAlign(value);			
			
			if (skin==null) return;			
			
			// Расставляем надпись и картинку
			drawTextAndImage();			
		}
		
		/**
		 * Установить текст
		 * @param value текст
		 */		
		public function set text(value:String):void {
			setText(value);			
			
			if (isSkined) {
				calcMinWidth();
				minSizeChanged = true;
			}
		}
		
		/**
		 * Иконка
		 */
		public function get image():BitmapData {
			return gfx.bitmapData;
		}
		public function set image(value:BitmapData):void {
			setImage(value);			
		
			if (skin==null) return;
			
			calcMinWidth();
			drawTextAndImage();
		}
		
		/**
		 * @private
		 * Заглушка на растяжку по вертикали 
		 */		
		override public function set stretchableV(value:Boolean):void {}
		
		/**
		 * Установить текст, без перерисовки 
		 * @param value текст
		 */		
		public function setText(value:String):void {
				_text = value;
				if (value != null) {
					tf.text = value;
					tf.visible = true;
				} else {
					tf.text = "";
					tf.visible = false;
				}
		}
		
		/**
		 * Установить иконку, без перерисовки 
		 * @param value иконка
		 */		
		private function setImage(value:BitmapData):void {				
			gfx.bitmapData = value;		
		}
		
		/**
		 * Установить выравнивание, без перерисовки 
		 * @param value выравнивание
		 */		
		private function setAlign(value:int):void {				
			_align = value;		
		}
		
	}
}