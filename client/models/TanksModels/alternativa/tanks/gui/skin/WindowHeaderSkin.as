package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	
	public class WindowHeaderSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Stamper", 24, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Stamper", 24, 0x898972);
		
		private static const thickness:Number = 50;
		private static const sharpness:Number = -50;
		
		public function WindowHeaderSkin() {
			super(WindowHeaderSkin.tfNormal,
			 	  WindowHeaderSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  WindowHeaderSkin.thickness,
			 	  WindowHeaderSkin.sharpness);
		}

	}
}