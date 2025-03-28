package alternativa.gui.mouse {
	import flash.display.BitmapData;
	
	public class CursorState {
		
		public var bitmap:BitmapData;
		public var xOffset:int;
		public var yOffset:int;
		
		public function CursorState(bitmap:BitmapData,
									xOffset:int,
									yOffset:int) {
			this.bitmap = bitmap;
			this.xOffset = xOffset;
			this.yOffset = yOffset;
		}
		
	}
}