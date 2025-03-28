package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	
	public class LobbyMapInfoLabelSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Sign", 12, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Sign", 12, 0x898972);
		
		private static const thickness:Number = -50;
		private static const sharpness:Number = 50;
		
		public function LobbyMapInfoLabelSkin() {
			
			//LobbyMapInfoLabelSkin.tfNormal.letterSpacing = 1;
			//LobbyMapInfoLabelSkin.tfLocked.letterSpacing = 1;
			
			LobbyMapInfoLabelSkin.tfNormal.bold = true;
			LobbyMapInfoLabelSkin.tfLocked.bold = true;
			
			super(LobbyMapInfoLabelSkin.tfNormal,
			 	  LobbyMapInfoLabelSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  LobbyMapInfoLabelSkin.thickness,
			 	  LobbyMapInfoLabelSkin.sharpness);
		}

	}
}