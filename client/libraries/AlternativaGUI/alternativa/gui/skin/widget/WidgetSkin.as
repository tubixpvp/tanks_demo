package alternativa.gui.skin.widget {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class WidgetSkin	implements ISkin {
		
		public var focusFramePattern:BitmapData;
		
		public function WidgetSkin(focusFramePattern:BitmapData) {
			this.focusFramePattern = focusFramePattern;
		}
		
	}
}