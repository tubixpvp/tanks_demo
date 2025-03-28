package alternativa.gui.widget.button {
	import alternativa.gui.skin.widget.button.ImageButtonSkin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * 
	 * Кнопка, состоящая из одной картинки
	 * 
	 */	
	public class ImageButton extends BaseButton {
		
		// Настройки смещения картинки при нажатии
		protected var yNormal:int;
		protected var yPress:int;

		// Битмап
		protected var bitmap:Bitmap;
		
		// Состояния кнопки
		protected var _normalBitmap:BitmapData;
		protected var _overBitmap:BitmapData;
		protected var _pressBitmap:BitmapData;
		protected var _lockBitmap:BitmapData;
		
		// Шкурка
		private var skin:ImageButtonSkin;
		
		// Активная область
		private var _hitArea:Shape;
		
		/**
		 * 
		 * @param yNormal - смещение картинки по y в нормальном состоянии
		 * @param yPress - смещение картинки по y при нажатии
		 * @param normal - изображение нормального состояния
		 * @param over - изображение при наведении
		 * @param press - изображение при нажатии
		 * @param lock - изображение заблокированной кнопки
		 * 
		 */		
		public function ImageButton(yNormal:int, yPress:int,normal:BitmapData = null, over:BitmapData = null, press:BitmapData = null, lock:BitmapData = null) {
			super();
			// Сохраняем настройки
			this.yNormal = yNormal;
			this.yPress = yPress;
			
			stretchableH = false;
			stretchableV = false;
			
			// Сохраняем состояния
			_normalBitmap = normal;
			_overBitmap = (over != null) ? over : normal;
			_pressBitmap = (press != null) ? press : normal;
			_lockBitmap = (lock != null) ? lock : normal;
			
			// Создаем активную область
			_hitArea = new Shape();
			addChild(_hitArea);
			if (_normalBitmap != null) {
				// Создание активной области
				drawHitArea(new Rectangle(0, 0, _normalBitmap.width, _normalBitmap.height));
				// Установка минимальных размеров
				minSize.x = _normalBitmap.width;
				minSize.y = _normalBitmap.height;
			}
			// Создаём битмап
			bitmap = new Bitmap();			
			addChild(bitmap);
		}
		
		// Отрисовка активной области
		private function drawHitArea(rect:Rectangle):void {
			with (_hitArea.graphics) {
				clear();
				beginFill(0xff0000, 0);
				drawRect(rect.x, rect.y, rect.width, rect.height);
			}
		}		
		
		/**
		 * Обновить скин 
		 */	
		override public function updateSkin():void {
			skin = ImageButtonSkin(skinManager.getSkin(ImageButton));
			super.updateSkin();
		}
		/**
		 * Расчет предпочтительных размеров
		 * @param size
		 * @return размеры изображения кнопки в нормальном состоянии
		 * 
		 */	
		override public function computeSize(size:Point):Point {
			var newSize:Point = (_normalBitmap != null) ? new Point(_normalBitmap.width, _normalBitmap.height) : new Point();
			return newSize;
		}
		
		// Перерисовка графики состояний
		public function set normalBitmap(value:BitmapData):void {
			_normalBitmap = value;
			// Создание активной области
			drawHitArea(new Rectangle(0, 0, _normalBitmap.width, _normalBitmap.height));
			// Установка минимальных размеров
			minSize.x = _normalBitmap.width;
			minSize.y = _normalBitmap.height;
			if (isSkined)
				switchState();
		}
		public function set overBitmap(value:BitmapData):void {
			_overBitmap = value;
			if (isSkined)
				switchState();
		}
		public function set pressBitmap(value:BitmapData):void {
			_pressBitmap = value;
			if (isSkined)
				switchState();
		}
		public function set lockBitmap(value:BitmapData):void {
			_lockBitmap = value;
			if (isSkined)
				switchState();
		}
		
		public function get normalBitmap():BitmapData {
			return _normalBitmap;
		}
		public function get overBitmap():BitmapData {
			return _overBitmap;
		}
		public function get pressBitmap():BitmapData {
			return _pressBitmap;
		}
		public function get lockBitmap():BitmapData {
			return _lockBitmap;
		}
		
		/**
		 * Смена визуального представления состояния 
		 * 
		 */
		override protected function switchState():void {
			if (locked) {
				bitmap.bitmapData = _lockBitmap;
				bitmap.transform.colorTransform = skin.colorLock;
				bitmap.y = yNormal;
			} else if (pressed) {
				bitmap.bitmapData = _pressBitmap;
				bitmap.transform.colorTransform = skin.colorPress;
				bitmap.y = yPress;
			} else if (over) {
				bitmap.bitmapData = _overBitmap;
				bitmap.transform.colorTransform = skin.colorOver;
				bitmap.y = yNormal;
			} else {
				bitmap.bitmapData = _normalBitmap;
				bitmap.transform.colorTransform = skin.colorNormal;
				bitmap.y = yNormal;	
			}
		}
		
	}
}