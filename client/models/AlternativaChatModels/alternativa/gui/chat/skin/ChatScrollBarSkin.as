package alternativa.gui.chat.skin {
	import alternativa.gui.skin.container.scrollBox.ScrollBarSkin;
	
	import flash.display.BitmapData;
	
	
	public class ChatScrollBarSkin extends ScrollBarSkin {
		
		[Embed(source="resources/emptyBitmap.png")] private static const emptyBitmap:Class;
		private static const bmp:BitmapData = new emptyBitmap().bitmapData;
		
		public function ChatScrollBarSkin()	{
			super(ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp,
				  ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp,	ChatScrollBarSkin.bmp, 
				  ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp, 
				  ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp,
				  ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp,
				  ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp, ChatScrollBarSkin.bmp,	ChatScrollBarSkin.bmp,
				  0, 0);
		}

	}
}