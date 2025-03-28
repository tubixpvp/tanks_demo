package alternativa.gui.skin.widget {
	import alternativa.skin.ISkin;
	
	import flash.text.TextFormat;
	
	public class LabelSkin implements ISkin {
		
		public var tfNormal:TextFormat;
		public var tfLocked:TextFormat;
		
		public var filtersNormal:Array;
		public var filtersLocked:Array;
		
		public var thickness:Number;
		public var sharpness:Number;
		
		public function LabelSkin(tfNormal:TextFormat, tfLocked:TextFormat, filtersNormal:Array, filtersLocked:Array, thickness:Number, sharpness:Number) {
			
			this.tfNormal = tfNormal;
			this.tfLocked = tfLocked;
			
			this.thickness = thickness;
			this.sharpness = sharpness;
			
			this.filtersNormal = filtersNormal;
			this.filtersLocked = filtersLocked;
		}
		
	}
}