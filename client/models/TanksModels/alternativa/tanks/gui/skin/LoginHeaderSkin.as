package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	public class LoginHeaderSkin extends LabelSkin	{
		
		private static const tfNormal:TextFormat = new TextFormat("Stamper", 18, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Stamper", 18, 0x898972);
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		public function LoginHeaderSkin() {
			super(LoginHeaderSkin.tfNormal,
			 	  LoginHeaderSkin.tfLocked,
			 	  new Array(),
			 	  new Array(),
			 	  LoginHeaderSkin.thickness,
			 	  LoginHeaderSkin.sharpness);
		}

	}
}