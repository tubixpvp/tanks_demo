package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	
	public class ScoresLabelSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Chicago", 14, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Chicago", 14, 0x666666);
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		public function ScoresLabelSkin() {
			
			ScoresLabelSkin.tfNormal.letterSpacing = 4;
			ScoresLabelSkin.tfLocked.letterSpacing = 4;
			
			super(ScoresLabelSkin.tfNormal,
			 	  ScoresLabelSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  ScoresLabelSkin.thickness,
			 	  ScoresLabelSkin.sharpness);
		}

	}
}