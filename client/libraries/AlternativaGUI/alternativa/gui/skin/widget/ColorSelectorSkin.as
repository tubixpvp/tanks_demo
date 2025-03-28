package alternativa.gui.skin.widget {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class ColorSelectorSkin implements ISkin {
		
		public var sliderHorizRunner:BitmapData;
		public var sliderVertRunner:BitmapData;
		
		public var sliderThickness:int;
		public var sliderBorderThickness:int;
		public var sliderLength:int;
		
		public var mixedColorSideSize:int;
		
		public function ColorSelectorSkin(sliderRunner:BitmapData,
										  sliderVertRunner:BitmapData,
										  sliderThickness:int,
										  sliderBorderThickness:int,
										  sliderLength:int,
										  mixedColorSideSize:int) {
										  	
			this.sliderHorizRunner = sliderHorizRunner;
			this.sliderVertRunner = sliderVertRunner;
			
			this.sliderThickness = sliderThickness;
			this.sliderBorderThickness = sliderBorderThickness;
			this.sliderLength = sliderLength;
			
			this.mixedColorSideSize = mixedColorSideSize;
		}
		
	}
}