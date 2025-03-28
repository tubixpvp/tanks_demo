package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.TextSkin;
	
	import flash.text.TextFormat;
	
	public class LoginTextSkin extends TextSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Alternativa", 12, 0x000000);
		private static const tfLocked:TextFormat = new TextFormat("Alternativa", 12, 0x666666);
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		public function LoginTextSkin() {
			super(LoginTextSkin.tfNormal,
				  LoginTextSkin.tfLocked,
				  LoginTextSkin.thickness,
				  LoginTextSkin.sharpness);
			
		}

	}
}