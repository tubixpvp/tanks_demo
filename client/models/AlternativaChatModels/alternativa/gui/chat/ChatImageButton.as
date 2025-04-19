package alternativa.gui.chat {
	import alternativa.gui.widget.button.ImageButton;
	
	import flash.display.BitmapData;
	
	
	public class ChatImageButton extends ImageButton {
		
		public function ChatImageButton(yNormal:int, yPress:int, normal:BitmapData = null, over:BitmapData = null, press:BitmapData = null, lock:BitmapData = null) {
			super(yNormal, yPress, normal, over, press, lock);
		}
		
		/**
		 * Фокусировка
		 */		
		override protected function focus():void {}
		/**
		 * Расфокусировка
		 */		
		override protected function unfocus():void {}

	}
}