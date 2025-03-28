package alternativa.gui.skin.widget.progressBar {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class ProgressBarSkin implements ISkin {
		
		public var left:BitmapData;
		public var center:BitmapData;
		public var right:BitmapData;
		public var fill:BitmapData;
		
		public var borderThickness:int;
		
		
		public function ProgressBarSkin(left:BitmapData,
										center:BitmapData,
										right:BitmapData,
										fill:BitmapData,
										borderThickness:int) {
			this.left = left;
			this.center = center;
			this.right = right;
			this.fill = fill;
			this.borderThickness = borderThickness;
		}

	}
}