package alternativa.gui.skin.widget {
	import flash.text.TextFormat;
	
	public class TextSkin extends LabelSkin {
		
		public function TextSkin(tfNormal:TextFormat, tfLocked:TextFormat, thickness:Number, sharpness:Number) {
			super(tfNormal, tfLocked, new Array(), new Array(), thickness, sharpness);
		}
		
	}
}