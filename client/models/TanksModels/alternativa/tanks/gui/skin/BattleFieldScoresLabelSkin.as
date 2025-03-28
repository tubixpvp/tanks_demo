package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	
	public class BattleFieldScoresLabelSkin	extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Chicago", 10, 0xcccccc);
		private static const tfLocked:TextFormat = new TextFormat("Chicago", 10, 0x666666);
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		public function BattleFieldScoresLabelSkin() {
			
			BattleFieldScoresLabelSkin.tfNormal.letterSpacing = 2;
			BattleFieldScoresLabelSkin.tfLocked.letterSpacing = 2;
			
			super(BattleFieldScoresLabelSkin.tfNormal,
			 	  BattleFieldScoresLabelSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  BattleFieldScoresLabelSkin.thickness,
			 	  BattleFieldScoresLabelSkin.sharpness);
		}

	}
}