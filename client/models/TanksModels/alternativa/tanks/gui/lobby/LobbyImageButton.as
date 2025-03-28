package alternativa.tanks.gui.lobby {
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.tanks.gui.skin.LobbyImageButtonSkin;
	
	import flash.display.BitmapData;
	
	public class LobbyImageButton extends ImageButton {
		
		private var skin:LobbyImageButtonSkin;
		
		public function LobbyImageButton(normal:BitmapData = null, over:BitmapData = null, press:BitmapData = null, lock:BitmapData = null) {
			super(0, 0, normal, over, press, lock);
		}
		
		override public function updateSkin():void {
			skin = LobbyImageButtonSkin(skinManager.getSkin(LobbyImageButton));
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
				//bitmap.y = yNormal;
			} else if (pressed) {
				bitmap.bitmapData = _pressBitmap;
				bitmap.transform.colorTransform = skin.colorPress;
				//bitmap.y = yPress;
			} else if (focused) {
				bitmap.bitmapData = _overBitmap;
				bitmap.transform.colorTransform = skin.colorFocus;
				//bitmap.y = yNormal;
			}  else if (over) {
				bitmap.bitmapData = _overBitmap;
				bitmap.transform.colorTransform = skin.colorOver;
				//bitmap.y = yNormal;
			} else {
				bitmap.bitmapData = _normalBitmap;
				bitmap.transform.colorTransform = skin.colorNormal;
				//bitmap.y = yNormal;	
			}
		}

	}
}