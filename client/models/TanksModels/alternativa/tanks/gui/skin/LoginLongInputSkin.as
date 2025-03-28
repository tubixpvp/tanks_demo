package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.InputSkin;
	
	import flash.display.BitmapData;
	import flash.text.TextFormat;
	
	
	public class LoginLongInputSkin	extends InputSkin {
		
		[Embed(source="../../resources/login-long-input_nl.png")] private static const bitmapNL:Class;
		[Embed(source="../../resources/login-long-input_nc.png")] private static const bitmapNC:Class;
		[Embed(source="../../resources/login-long-input_nr.png")] private static const bitmapNR:Class;
		/*[Embed(source="../resources/input_ol.png")] private static const bitmapOL:Class;
		[Embed(source="../resources/input_oc.png")] private static const bitmapOC:Class;
		[Embed(source="../resources/input_or.png")] private static const bitmapOR:Class;
		[Embed(source="../resources/input_ll.png")] private static const bitmapLL:Class;
		[Embed(source="../resources/input_lc.png")] private static const bitmapLC:Class;
		[Embed(source="../resources/input_lr.png")] private static const bitmapLR:Class;
		[Embed(source="../resources/input_fl.png")] private static const bitmapFL:Class;
		[Embed(source="../resources/input_fc.png")] private static const bitmapFC:Class;
		[Embed(source="../resources/input_fr.png")] private static const bitmapFR:Class;
		[Embed(source="../resources/input_wl.png")] private static const bitmapWL:Class;
		[Embed(source="../resources/input_wc.png")] private static const bitmapWC:Class;
		[Embed(source="../resources/input_wr.png")] private static const bitmapWR:Class;
		[Embed(source="../resources/input_wol.png")] private static const bitmapWOL:Class;
		[Embed(source="../resources/input_woc.png")] private static const bitmapWOC:Class;
		[Embed(source="../resources/input_wor.png")] private static const bitmapWOR:Class;*/

		private static const bmpNL:BitmapData = new bitmapNL().bitmapData;
		private static const bmpNC:BitmapData = new bitmapNC().bitmapData;
		private static const bmpNR:BitmapData = new bitmapNR().bitmapData;
		/*private static const bmpOL:BitmapData = new bitmapOL().bitmapData;
		private static const bmpOC:BitmapData = new bitmapOC().bitmapData;
		private static const bmpOR:BitmapData = new bitmapOR().bitmapData;
		private static const bmpLL:BitmapData = new bitmapLL().bitmapData;
		private static const bmpLC:BitmapData = new bitmapLC().bitmapData;
		private static const bmpLR:BitmapData = new bitmapLR().bitmapData;
		private static const bmpFL:BitmapData = new bitmapFL().bitmapData;
		private static const bmpFC:BitmapData = new bitmapFC().bitmapData;
		private static const bmpFR:BitmapData = new bitmapFR().bitmapData;
		private static const bmpWL:BitmapData = new bitmapWL().bitmapData;
		private static const bmpWC:BitmapData = new bitmapWC().bitmapData;
		private static const bmpWR:BitmapData = new bitmapWR().bitmapData;
		private static const bmpWOL:BitmapData = new bitmapWOL().bitmapData;
		private static const bmpWOC:BitmapData = new bitmapWOC().bitmapData;
		private static const bmpWOR:BitmapData = new bitmapWOR().bitmapData;*/
		
		private static const borderThickness:int = 0;
		
		private static const leftMargin:int = 5;
		private static const rightMargin:int = 5;
		private static const topMargin:int = 0;	
		
		private static const thickness:Number = 50;
		private static const sharpness:Number = -50;
		
		private static const tfNormal:TextFormat = new TextFormat("Alternativa", 18, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Alternativa", 18, 0x999999);

		public function LoginLongInputSkin() {
			super(
					LoginLongInputSkin.bmpNL,
					LoginLongInputSkin.bmpNC,
					LoginLongInputSkin.bmpNR,
					LoginLongInputSkin.bmpNL,
					LoginLongInputSkin.bmpNC,
					LoginLongInputSkin.bmpNR,
					LoginLongInputSkin.bmpNL,
					LoginLongInputSkin.bmpNC,
					LoginLongInputSkin.bmpNR,
					LoginLongInputSkin.bmpNL,
					LoginLongInputSkin.bmpNC,
					LoginLongInputSkin.bmpNR,
					LoginLongInputSkin.bmpNL,
					LoginLongInputSkin.bmpNC,
					LoginLongInputSkin.bmpNR,
					LoginLongInputSkin.bmpNL,
					LoginLongInputSkin.bmpNC,
					LoginLongInputSkin.bmpNR,
					LoginLongInputSkin.borderThickness,
					LoginLongInputSkin.topMargin,
					LoginLongInputSkin.leftMargin,
					LoginLongInputSkin.rightMargin,
					LoginLongInputSkin.thickness,
					LoginLongInputSkin.sharpness,
					LoginLongInputSkin.tfNormal,
					LoginLongInputSkin.tfLocked);		
		}

	}
}