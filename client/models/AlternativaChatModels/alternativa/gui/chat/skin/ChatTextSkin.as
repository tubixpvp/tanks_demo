package alternativa.gui.chat.skin {
	
	import alternativa.gui.skin.widget.TextSkin;
	import flash.text.TextFormat;

	public class ChatTextSkin extends TextSkin	{
		
		private static const tfNormal:TextFormat = new TextFormat("Alternativa", 12, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Alternativa", 12, 0x898972);
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		public function ChatTextSkin() {
			super(ChatTextSkin.tfNormal,
				  ChatTextSkin.tfLocked,
				  ChatTextSkin.thickness,
				  ChatTextSkin.sharpness);
			
		}
	}
}