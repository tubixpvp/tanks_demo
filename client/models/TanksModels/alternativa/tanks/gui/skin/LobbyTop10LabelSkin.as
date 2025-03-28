package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	
	public class LobbyTop10LabelSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Sign", 12, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Sign", 12, 0x898972);
		
		private static const thickness:Number = -50;
		private static const sharpness:Number = 50;
		
		public function LobbyTop10LabelSkin() {
			
			//LobbyTop10LabelSkin.tfNormal.letterSpacing = 1;
			//LobbyTop10LabelSkin.tfLocked.letterSpacing = 1;
			LobbyTop10LabelSkin.tfNormal.bold = true;
			LobbyTop10LabelSkin.tfLocked.bold = true;
			
			super(LobbyTop10LabelSkin.tfNormal,
			 	  LobbyTop10LabelSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  LobbyTop10LabelSkin.thickness,
			 	  LobbyTop10LabelSkin.sharpness);
		}

	}
}