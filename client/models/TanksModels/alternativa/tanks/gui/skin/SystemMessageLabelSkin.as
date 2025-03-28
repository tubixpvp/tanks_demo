package alternativa.tanks.gui.skin {
	
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	public class SystemMessageLabelSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Stamper", 14, 0x000000);
		private static const tfLocked:TextFormat = new TextFormat("Stamper", 14, 0x666666);
		
		private static const thickness:Number = 50;
		private static const sharpness:Number = -50;
		
		public function SystemMessageLabelSkin() {
			
			super(SystemMessageLabelSkin.tfNormal,
			 	  SystemMessageLabelSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  SystemMessageLabelSkin.thickness,
			 	  SystemMessageLabelSkin.sharpness);
		}

	}
}