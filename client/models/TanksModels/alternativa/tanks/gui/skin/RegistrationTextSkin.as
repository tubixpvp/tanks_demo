package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.TextSkin;
	
	import flash.text.TextFormat;
	
	public class RegistrationTextSkin extends TextSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Stamper", 14, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Stamper", 14, 0x898972);
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		public function RegistrationTextSkin() {
			super(RegistrationTextSkin.tfNormal,
				  RegistrationTextSkin.tfLocked,
				  RegistrationTextSkin.thickness,
				  RegistrationTextSkin.sharpness);
			
		}

	}
}