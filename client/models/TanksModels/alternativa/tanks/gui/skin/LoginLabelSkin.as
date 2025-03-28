package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	
	public class LoginLabelSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Stamper", 14, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Stamper", 14, 0x898972);
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		public function LoginLabelSkin() {
			super(LoginLabelSkin.tfNormal,
			 	  LoginLabelSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  LoginLabelSkin.thickness,
			 	  LoginLabelSkin.sharpness);
		}

	}
}