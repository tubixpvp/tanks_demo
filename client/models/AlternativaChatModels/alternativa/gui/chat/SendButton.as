package alternativa.gui.chat {
	import alternativa.gui.chat.skin.SendButtonSkin;
	import alternativa.gui.widget.button.ImageButton;
	
	import flash.display.BitmapData;
	
	
	public class SendButton	extends ImageButton {
		
		private var skin:SendButtonSkin;
		
		public function SendButton(normal:BitmapData = null, over:BitmapData = null, press:BitmapData = null, lock:BitmapData = null) {
			super(0, 0, normal, over, press, lock);
		}
		
		override public function updateSkin():void {
			skin = SendButtonSkin(skinManager.getSkin(SendButton));
			super.updateSkin();
		}
		
		/**
		 * Фокусировка
		 */		
		override protected function focus():void {}
		/**
		 * Расфокусировка
		 */		
		override protected function unfocus():void {}
		
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
			} else if (focused) {
				bitmap.bitmapData = _overBitmap;
				bitmap.transform.colorTransform = skin.colorFocus;
				bitmap.y = yNormal;
			}  else if (over) {
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