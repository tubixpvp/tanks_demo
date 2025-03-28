package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	
	public class LobbyLabelSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Stamper", 11, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Stamper", 11, 0x898972);
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		public function LobbyLabelSkin() {
			super(LobbyLabelSkin.tfNormal,
			 	  LobbyLabelSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  LobbyLabelSkin.thickness,
			 	  LobbyLabelSkin.sharpness);
		}

	}
}