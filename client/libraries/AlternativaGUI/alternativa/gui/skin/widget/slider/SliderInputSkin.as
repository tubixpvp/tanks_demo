package alternativa.gui.skin.widget.slider {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class SliderInputSkin implements ISkin {
		
		public var sliderButtonNormal:BitmapData;
		public var sliderButtonOver:BitmapData;
		public var sliderButtonPress:BitmapData;
		public var sliderButtonLock:BitmapData;
		
		public function SliderInputSkin(sliderButtonNormal:BitmapData,
										sliderButtonOver:BitmapData,
										sliderButtonPress:BitmapData,
										sliderButtonLock:BitmapData) {
			
			this.sliderButtonNormal = sliderButtonNormal;
			this.sliderButtonOver = sliderButtonOver;
			this.sliderButtonPress = sliderButtonPress;
			this.sliderButtonLock = sliderButtonLock;
		}
		
	}
}