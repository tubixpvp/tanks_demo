package alternativa.gui.widget {
	import alternativa.gui.init.GUI;
	import alternativa.gui.skin.widget.ImageSkin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Image extends Widget {

		// Битмап
		protected var bitmap:Bitmap;

		// Шкурка
		private var skin:ImageSkin;
		
		// Маска
		private var maskRect:Rectangle;
		
		public function Image(bitmapData:BitmapData = null) {
			super();
			
			// Инициализация фокуса и мыши
			tabEnabled = false;
			mouseEnabled = false;
			
			// Создаём битмап
			bitmap = new Bitmap();
			addChild(bitmap);
			
			if (bitmapData!=null)
				this.bitmapData = bitmapData;
			
			// маска
			//maskRect = new Rectangle(0,0,1,1);
			
			cacheAsBitmap = true;
		}
		
		override public function updateSkin():void {
			skin = ImageSkin(skinManager.getSkin(Image));
			super.updateSkin();	
			this.locked = locked;
		}
		
		override public function get cursorOverType():uint {
			return GUI.mouseManager.cursorTypes.NORMAL;
		}
		override public function get cursorPressedType():uint {
			return GUI.mouseManager.cursorTypes.NORMAL;
		}
		
		override public function draw(size:Point):void {
			super.draw(size);
			// маска
			//maskRect.width = size.x;
			//maskRect.height = size.y;
			//bitmap.scrollRect = maskRect;
		}
		
		override public function set locked(value:Boolean):void {
			super.locked = value;
			mouseEnabled = !value;
			if (isSkined)
				bitmap.transform.colorTransform = value ? skin.colorLocked : skin.colorNormal;
		}
		
		public function set bitmapData(value:BitmapData):void {
			bitmap.bitmapData = value;
			bitmap.width = value.width;
			bitmap.height = value.height;
			minSize.x = value.width;
			minSize.y = value.height;
		}
		
		public function get bitmapData():BitmapData {
			return bitmap.bitmapData;
		}
		
		// Фокусировка
		override protected function focus():void {
			//drawFocusFrame(new Rectangle(0, 0, _currentSize.x, _currentSize.y));
			//addChild(focusFrame);
		}
		// Расфокусировка
		override protected function unfocus():void {
			//removeChild(focusFrame);
		}
		
	}
}