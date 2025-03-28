package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.text.TextFormat;
	
	
	public class RadarLabelSkin extends LabelSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Pixel", 6, 0x336633);
		private static const tfLocked:TextFormat = new TextFormat("Pixel", 6, 0x333333);
		
		private static const thickness:Number = 50;
		private static const sharpness:Number = -50;
		
		public function RadarLabelSkin() {
			super(RadarLabelSkin.tfNormal,
				  RadarLabelSkin.tfLocked,
				  new Array(),
				  new Array(),
				  RadarLabelSkin.thickness,
				  RadarLabelSkin.sharpness);
		}

	}
}