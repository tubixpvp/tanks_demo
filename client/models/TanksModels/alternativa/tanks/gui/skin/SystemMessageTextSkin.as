package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.TextSkin;
	
	import flash.text.TextFormat;
	
	
	public class SystemMessageTextSkin extends TextSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Stamper", 14, 0x000000);
		private static const tfLocked:TextFormat = new TextFormat("Stamper", 14, 0x666666);
		
		private static const thickness:Number = 50;
		private static const sharpness:Number = -50;
		
		public function SystemMessageTextSkin() {
			
			SystemMessageTextSkin.tfNormal.leading = 18;
			SystemMessageTextSkin.tfLocked.leading = 18;
			
			super(SystemMessageTextSkin.tfNormal,
				  SystemMessageTextSkin.tfLocked,
				  SystemMessageTextSkin.thickness,
				  SystemMessageTextSkin.sharpness);
			
		}

	}
}