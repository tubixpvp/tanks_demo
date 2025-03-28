package alternativa.gui.skin.widget.slider {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class SliderSkin implements ISkin {
		
		public var horizTrackLeft:BitmapData;
		public var horizTrackCenter:BitmapData;
		public var horizTrackRight:BitmapData;
		public var horizRunner:BitmapData;
		public var horizTick:BitmapData;

		public var vertTrackTop:BitmapData;
		public var vertTrackMiddle:BitmapData;
		public var vertTrackBottom:BitmapData;
		public var vertRunner:BitmapData;
		public var vertTick:BitmapData;
		
		public var borderThickness:int;
		public var tickMargin:int;
		
		public function SliderSkin(horizTrackLeft:BitmapData,
								   horizTrackCenter:BitmapData,
								   horizTrackRight:BitmapData,
								   horizRunner:BitmapData,
								   horizTick:BitmapData,
								   vertTrackTop:BitmapData,
								   vertTrackMiddle:BitmapData,
								   vertTrackBottom:BitmapData,
								   vertRunner:BitmapData,
								   vertTick:BitmapData,
								   borderThickness:int,
								   tickMargin:int) {
								   	
			this.horizTrackLeft = horizTrackLeft;
			this.horizTrackCenter = horizTrackCenter;
			this.horizTrackRight = horizTrackRight;
			this.horizRunner = horizRunner;
			this.horizTick = horizTick;

			this.vertTrackTop = vertTrackTop;
			this.vertTrackMiddle = vertTrackMiddle;
			this.vertTrackBottom = vertTrackBottom;
			this.vertRunner = vertRunner;
			this.vertTick = vertTick;
			
			this.borderThickness = borderThickness;
			this.tickMargin = tickMargin;
		}
		
	}
}