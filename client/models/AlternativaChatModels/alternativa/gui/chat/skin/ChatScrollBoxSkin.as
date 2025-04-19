package alternativa.gui.chat.skin {	
	import alternativa.gui.skin.container.scrollBox.ScrollBoxSkin;
	
	import flash.display.BitmapData;
	
	public class ChatScrollBoxSkin extends ScrollBoxSkin {
		
		[Embed(source="resources/box_ntl.png")] private static const bitmapNTL:Class;
		[Embed(source="resources/box_ntc.png")] private static const bitmapNTC:Class;
		[Embed(source="resources/box_ntr.png")] private static const bitmapNTR:Class;
		[Embed(source="resources/box_nml.png")] private static const bitmapNML:Class;
		[Embed(source="resources/box_nmc.png")] private static const bitmapNMC:Class;
		[Embed(source="resources/box_nmr.png")] private static const bitmapNMR:Class;
		[Embed(source="resources/box_nbl.png")] private static const bitmapNBL:Class;
		[Embed(source="resources/box_nbc.png")] private static const bitmapNBC:Class;
		[Embed(source="resources/box_nbr.png")] private static const bitmapNBR:Class;

		[Embed(source="resources/box_ntl.png")] private static const bitmapOTL:Class;
		[Embed(source="resources/box_ntc.png")] private static const bitmapOTC:Class;
		[Embed(source="resources/box_ntr.png")] private static const bitmapOTR:Class;
		[Embed(source="resources/box_nml.png")] private static const bitmapOML:Class;
		[Embed(source="resources/box_nmc.png")] private static const bitmapOMC:Class;
		[Embed(source="resources/box_nmr.png")] private static const bitmapOMR:Class;
		[Embed(source="resources/box_nbl.png")] private static const bitmapOBL:Class;
		[Embed(source="resources/box_nbc.png")] private static const bitmapOBC:Class;
		[Embed(source="resources/box_nbr.png")] private static const bitmapOBR:Class;

		[Embed(source="resources/box_ntl.png")] private static const bitmapLTL:Class;
		[Embed(source="resources/box_ntc.png")] private static const bitmapLTC:Class;
		[Embed(source="resources/box_ntr.png")] private static const bitmapLTR:Class;
		[Embed(source="resources/box_nml.png")] private static const bitmapLML:Class;
		[Embed(source="resources/box_nmc.png")] private static const bitmapLMC:Class;
		[Embed(source="resources/box_nmr.png")] private static const bitmapLMR:Class;
		[Embed(source="resources/box_nbl.png")] private static const bitmapLBL:Class;
		[Embed(source="resources/box_nbc.png")] private static const bitmapLBC:Class;
		[Embed(source="resources/box_nbr.png")] private static const bitmapLBR:Class;
		
		[Embed(source="resources/emptyBitmap.png")] private static const bitmapCorner:Class;
		
		private static const bmpNTL:BitmapData = new bitmapNTL().bitmapData;
		private static const bmpNTC:BitmapData = new bitmapNTC().bitmapData;
		private static const bmpNTR:BitmapData = new bitmapNTR().bitmapData;
		private static const bmpNML:BitmapData = new bitmapNML().bitmapData;
		private static const bmpNMC:BitmapData = new bitmapNMC().bitmapData;
		private static const bmpNMR:BitmapData = new bitmapNMR().bitmapData;
		private static const bmpNBL:BitmapData = new bitmapNBL().bitmapData;
		private static const bmpNBC:BitmapData = new bitmapNBC().bitmapData;
		private static const bmpNBR:BitmapData = new bitmapNBR().bitmapData;
		
		private static const bmpOTL:BitmapData = new bitmapOTL().bitmapData;
		private static const bmpOTC:BitmapData = new bitmapOTC().bitmapData;
		private static const bmpOTR:BitmapData = new bitmapOTR().bitmapData;
		private static const bmpOML:BitmapData = new bitmapOML().bitmapData;
		private static const bmpOMC:BitmapData = new bitmapOMC().bitmapData;
		private static const bmpOMR:BitmapData = new bitmapOMR().bitmapData;
		private static const bmpOBL:BitmapData = new bitmapOBL().bitmapData;
		private static const bmpOBC:BitmapData = new bitmapOBC().bitmapData;
		private static const bmpOBR:BitmapData = new bitmapOBR().bitmapData;

		private static const bmpLTL:BitmapData = new bitmapLTL().bitmapData;
		private static const bmpLTC:BitmapData = new bitmapLTC().bitmapData;
		private static const bmpLTR:BitmapData = new bitmapLTR().bitmapData;
		private static const bmpLML:BitmapData = new bitmapLML().bitmapData;
		private static const bmpLMC:BitmapData = new bitmapLMC().bitmapData;
		private static const bmpLMR:BitmapData = new bitmapLMR().bitmapData;
		private static const bmpLBL:BitmapData = new bitmapLBL().bitmapData;
		private static const bmpLBC:BitmapData = new bitmapLBC().bitmapData;
		private static const bmpLBR:BitmapData = new bitmapLBR().bitmapData;
		
		private static const bmpCorner:BitmapData = new bitmapCorner().bitmapData;
		
		private static const borderThickness:int = 0;
		
		public function ChatScrollBoxSkin() {
			super(ChatScrollBoxSkin.bmpNTL,
				  ChatScrollBoxSkin.bmpNTC,
				  ChatScrollBoxSkin.bmpNTR,
				  ChatScrollBoxSkin.bmpNML,
				  ChatScrollBoxSkin.bmpNMC,
				  ChatScrollBoxSkin.bmpNMR,
				  ChatScrollBoxSkin.bmpNBL,
				  ChatScrollBoxSkin.bmpNBC,
				  ChatScrollBoxSkin.bmpNBR,
				  ChatScrollBoxSkin.bmpOTL,
				  ChatScrollBoxSkin.bmpOTC,
				  ChatScrollBoxSkin.bmpOTR,
				  ChatScrollBoxSkin.bmpOML,
				  ChatScrollBoxSkin.bmpOMC,
				  ChatScrollBoxSkin.bmpOMR,
				  ChatScrollBoxSkin.bmpOBL,
				  ChatScrollBoxSkin.bmpOBC,
				  ChatScrollBoxSkin.bmpOBR,
				  ChatScrollBoxSkin.bmpLTL,
				  ChatScrollBoxSkin.bmpLTC,
				  ChatScrollBoxSkin.bmpLTR,
				  ChatScrollBoxSkin.bmpLML,
				  ChatScrollBoxSkin.bmpLMC,
				  ChatScrollBoxSkin.bmpLMR,
				  ChatScrollBoxSkin.bmpLBL,
				  ChatScrollBoxSkin.bmpLBC,
				  ChatScrollBoxSkin.bmpLBR,
				  ChatScrollBoxSkin.bmpCorner,
				  ChatScrollBoxSkin.borderThickness);
		}
	}
}