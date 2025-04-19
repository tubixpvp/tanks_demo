package alternativa.gui.chat.skin {
	import alternativa.gui.skin.container.scrollBox.ScrollerSkin;
	
	import flash.display.BitmapData;
	
	
	public class ChatScrollerSkin extends ScrollerSkin {
		
		[Embed(source="resources/emptyBitmap.png")] private static const emptyBitmap:Class;
		private static const bmp:BitmapData = new emptyBitmap().bitmapData;
		
		public function ChatScrollerSkin() {
			super(ChatScrollerSkin.bmp, ChatScrollerSkin.bmp, ChatScrollerSkin.bmp,
				  ChatScrollerSkin.bmp, ChatScrollerSkin.bmp, ChatScrollerSkin.bmp,
				  ChatScrollerSkin.bmp, ChatScrollerSkin.bmp, ChatScrollerSkin.bmp,
				  ChatScrollerSkin.bmp, ChatScrollerSkin.bmp, ChatScrollerSkin.bmp,
				  ChatScrollerSkin.bmp, ChatScrollerSkin.bmp, ChatScrollerSkin.bmp,
				  ChatScrollerSkin.bmp, ChatScrollerSkin.bmp, ChatScrollerSkin.bmp,
				  1);
		}

	}
}