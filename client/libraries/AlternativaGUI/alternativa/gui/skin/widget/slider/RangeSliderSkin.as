package alternativa.gui.skin.widget.slider {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class RangeSliderSkin extends SliderSkin implements ISkin {
		
		public var horizRunner2:BitmapData;
		public var vertRunner2:BitmapData;
		public var horizRangeFill:BitmapData;
		public var vertRangeFill:BitmapData;
		public var rangeFillColor:uint;
		public var rangeFillColorAlpha:Number;
		public var bitmapRangeFillMode:Boolean;
		
		
		public function RangeSliderSkin(horizTrackLeft:BitmapData,
								   		horizTrackCenter:BitmapData,
								   		horizTrackRight:BitmapData,
								   		horizRunner1:BitmapData,
								   		horizRunner2:BitmapData,
								   		horizTick:BitmapData,
								   		horizRangeFill:BitmapData,
								   		vertTrackTop:BitmapData,
								   		vertTrackMiddle:BitmapData,
								   		vertTrackBottom:BitmapData,
								   		vertRunner1:BitmapData,
								   		vertRunner2:BitmapData,
								   		vertTick:BitmapData,
								   		vertRangeFill:BitmapData,
								   		borderThickness:int,
								   		tickMargin:int,
								   		rangeFillColor:uint,
								   		rangeFillColorAlpha:Number,
								   		bitmapRangeFillMode:Boolean) {
								   			
			super(horizTrackLeft,
				  horizTrackCenter,
				  horizTrackRight,
				  horizRunner1,
				  horizTick,
				  vertTrackTop,
				  vertTrackMiddle,
				  vertTrackBottom,
				  vertRunner1,
				  vertTick,
				  borderThickness,
				  tickMargin);
				  
			this.horizRunner2 = horizRunner2;
			this.vertRunner2 = vertRunner2;
			this.horizRangeFill = horizRangeFill;
			this.vertRangeFill = vertRangeFill;
			this.rangeFillColor = rangeFillColor;
			this.rangeFillColorAlpha = rangeFillColorAlpha;
			this.bitmapRangeFillMode = bitmapRangeFillMode;
		}

	}
}