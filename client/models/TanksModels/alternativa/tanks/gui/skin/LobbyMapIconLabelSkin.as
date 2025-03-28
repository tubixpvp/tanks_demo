package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	public class LobbyMapIconLabelSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Stamper", 11, 0x000000);
		private static const tfLocked:TextFormat = new TextFormat("Stamper", 11, 0x000000);
		
		private static const thickness:Number = 50;
		private static const sharpness:Number = -50;
		
		public function LobbyMapIconLabelSkin() {
			super(LobbyMapIconLabelSkin.tfNormal,
			 	  LobbyMapIconLabelSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  LobbyMapIconLabelSkin.thickness,
			 	  LobbyMapIconLabelSkin.sharpness);
		}
		
	}
}