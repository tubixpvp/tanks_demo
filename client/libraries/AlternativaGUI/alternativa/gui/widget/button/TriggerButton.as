package alternativa.gui.widget.button {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.skin.widget.button.TriggerButtonSkin;
	import alternativa.gui.widget.Label;
	
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TriggerButton extends BaseButton implements ITriggerButton {
		
		// Флаг выбранности
		protected var _selected:Boolean;
		
		// Битмап
		protected var bitmap:Bitmap;
		
		// Текстовое поле
		protected var tf:Label;
		
		// Шкурка
		protected var skin:TriggerButtonSkin;
		
		// Отступ текстового поля
		//private const g:Number = 1.5;//1.618;
		
		
		public function TriggerButton(text:String = "", textColor:int = -1) {
			super();
			_selected = false;
			
			// Создаём битмап
			bitmap = new Bitmap();			
			addChild(bitmap);
			
			// Создаем текстовое поле
			tf = new Label(text, Align.LEFT, textColor);
			tf.cursorActive = true;
			tf.addCursorListener(this);
			addChild(tf);
			
			//var pressFilter:FocusKeyFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array(13, 32)));
			//_availableKeys = new Array(pressFilter);
			
		}
		
		// Установка битмап
		override public function updateSkin():void {
			skin = TriggerButtonSkin(skinManager.getSkin(getSkinType()));
			
			// Установка минимальных размеров
			setMinSize();
			
			// Установка текстового поля
			setLabelPos();
			
			// Установка состояния
			super.updateSkin();
			
			// Заполнение промежутка между кнопкой и текстом
			 fillSpace();
		}
		
		// Установка минимальных размеров
		protected function setMinSize():void {
			if (tf.text != null && tf.text != "") {
				_minSize.x = Math.max(_minSize.x, skin.unselected.width + skin.space + tf.computeSize(new Point()).x);
			} else {
				_minSize.x = skin.unselected.width;
			}
			_minSize.y = Math.max(skin.unselected.height, tf.minSize.y);
		}
		
		// Установка текстового поля
		protected function setLabelPos():void {
			tf.x = skin.unselected.width + skin.space;
			tf.y = Math.round((skin.unselected.height - tf.minSize.y)/2);
		}
		
		// Заполнение промежутка между кнопкой и текстом
		protected function fillSpace():void {
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(bitmap.width, 0, skin.space, bitmap.height);
		}
		
		// Определение класса для скинования
		protected function getSkinType():Class {
			return null;
		}
		
		
		/**
		 * Вычислить минимальные размеры элемента
		 * @param size исходные размеры от менеджера компоновки
		 * @return минимальные размеры
		 * 
		 */	
		override public function computeMinSize():Point {
			if (tf.text != null && tf.text != "") {
				_minSize.x = Math.max(_minSize.x, skin.unselected.width + skin.space + tf.computeSize(new Point()).x);
			} else {
				_minSize.x = skin.unselected.width;
			}
			_minSize.y = Math.max(skin.unselected.height, tf.minSize.y);
			
			minSizeChanged = false;
			return _minSize;
		}
		
		/**
		 * Расчет предпочтительных размеров с учетом stretchable флагов и минимальных размеров.
		 * @param size
		 * @return 
		 * 
		 */	
		override public function computeSize(size:Point):Point {
			// Установка минимальных размеров
			/*if (tf.text != null && tf.text != "") {
				_minSize.x = Math.max(_minSize.x, Math.round(skin.unselected.width*g) + tf.computeSize(new Point()).x);
			} else {
				_minSize.x = skin.unselected.width;
			}
			_minSize.y = Math.max(skin.unselected.height, tf.minSize.y);*/
			
			var newSize:Point = _minSize.clone();
			
			if (size != null) {
				if (_stretchableH)
					newSize.x = Math.max(size.x, _minSize.x);
				
				newSize.y = _minSize.y;
			} 
			
			return newSize;
		}
		
		// Отрисовка
		override public function draw(size:Point):void {
			super.draw(size);
			if (tf.text != null && tf.text != "") {
				var tfSize:Point = new Point();
				tfSize.x = size.x - (skin.unselected.width + skin.space);
				tfSize.y = tf.minSize.y;
				
				tf.draw(tfSize);
				
				tf.y = Math.round((skin.unselected.height - tf.minSize.y)/2);
			} 
		}
		
		/**
		 * Смена визуального представления состояния 
		 * 
		 */
		override protected function switchState():void {
			if (_selected) {	
				if (_locked) {
					bitmap.bitmapData = skin.lockedSelected;
				} else {
					bitmap.bitmapData = skin.selected;
				}
			} else {
				if (_locked) {
					bitmap.bitmapData = skin.lockedUnselected;
				} else {
					bitmap.bitmapData = skin.unselected;
				}
			}
		}
		
		
		// Фокусировка
		override protected function focus():void {
			drawFocusFrame(new Rectangle(0, 0, skin.unselected.width, skin.unselected.height));
			addChild(focusFrame);
		}
		
		
		// блокировка
		override public function set locked(value:Boolean):void {
			super.locked = value;
			tf.locked = value;
		}
		
		// Флаг выбранности
		public function set selected(value:Boolean):void {
			_selected = value;
			if (isSkined) {
				switchState();	
				draw(currentSize);
			}
		}
		// Цвет текста
		public function set textColor(color:int):void {
			tf.textColor = color;
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		public function get textColor():int {
			return tf.textColor;
		}
		
	}
}