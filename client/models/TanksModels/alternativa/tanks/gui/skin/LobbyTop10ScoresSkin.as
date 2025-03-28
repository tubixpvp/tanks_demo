package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	
	public class LobbyTop10ScoresSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Digital", 10, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Digital", 10, 0x898972);
		
		private static const thickness:Number = 0;
		private static const sharpness:Number = 0;
		
		public function LobbyTop10ScoresSkin() {
			
			super(LobbyTop10ScoresSkin.tfNormal,
			 	  LobbyTop10ScoresSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  LobbyTop10ScoresSkin.thickness,
			 	  LobbyTop10ScoresSkin.sharpness);
		}

	}
}