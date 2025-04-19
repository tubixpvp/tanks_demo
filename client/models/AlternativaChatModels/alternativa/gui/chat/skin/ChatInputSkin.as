package alternativa.gui.chat.skin {
	import alternativa.gui.skin.widget.InputSkin;
	
	import flash.display.BitmapData;
	import flash.text.TextFormat;
	
	
	public class ChatInputSkin extends InputSkin {
		
		[Embed(source="resources/input_nl.png")] private static const bitmapNL:Class;
		[Embed(source="resources/input_nc.png")] private static const bitmapNC:Class;
		[Embed(source="resources/input_nr.png")] private static const bitmapNR:Class;
		private static const bmpNL:BitmapData = new bitmapNL().bitmapData;
		private static const bmpNC:BitmapData = new bitmapNC().bitmapData;
		private static const bmpNR:BitmapData = new bitmapNR().bitmapData;
		
		private static const borderThickness:int = 0;
		
		private static const leftMargin:int = 5;
		private static const rightMargin:int = 5;
		private static const topMargin:int = 5;	
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		private static const tfNormal:TextFormat = new TextFormat("Alternativa", 14, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Alternativa", 14, 0x898972);
		
		public function ChatInputSkin()	{
			super(ChatInputSkin.bmpNL, ChatInputSkin.bmpNC, ChatInputSkin.bmpNR,
				  ChatInputSkin.bmpNL, ChatInputSkin.bmpNC, ChatInputSkin.bmpNR,
				  ChatInputSkin.bmpNL, ChatInputSkin.bmpNC, ChatInputSkin.bmpNR,
				  ChatInputSkin.bmpNL, ChatInputSkin.bmpNC, ChatInputSkin.bmpNR,
				  ChatInputSkin.bmpNL, ChatInputSkin.bmpNC, ChatInputSkin.bmpNR,
				  ChatInputSkin.bmpNL, ChatInputSkin.bmpNC, ChatInputSkin.bmpNR,
				  ChatInputSkin.borderThickness,
				  ChatInputSkin.topMargin,
				  ChatInputSkin.leftMargin,
				  ChatInputSkin.rightMargin,
				  ChatInputSkin.thickness,
				  ChatInputSkin.sharpness,
				  ChatInputSkin.tfNormal,
				  ChatInputSkin.tfLocked);
		}

	}
}