package alternativa.gui.chat.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	
	public class ChatLabelSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Alternativa", 11, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Alternativa", 11, 0x898972);
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		public function ChatLabelSkin()	{
			super(ChatLabelSkin.tfNormal,
			 	  ChatLabelSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  ChatLabelSkin.thickness,
			 	  ChatLabelSkin.sharpness);
		}

	}
}