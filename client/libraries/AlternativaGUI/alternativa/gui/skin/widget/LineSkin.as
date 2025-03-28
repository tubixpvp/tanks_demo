package alternativa.gui.skin.widget {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class LineSkin implements ISkin {
		
		public var bmpVT:BitmapData;
		public var bmpVM:BitmapData;
		public var bmpVB:BitmapData;
		public var bmpHL:BitmapData;
		public var bmpHC:BitmapData;
		public var bmpHR:BitmapData;
		
		public function LineSkin(
				bmpVT:BitmapData,
				bmpVM:BitmapData,
				bmpVB:BitmapData,
				bmpHL:BitmapData,
				bmpHC:BitmapData,
				bmpHR:BitmapData) {
				
			this.bmpVT = bmpVT;
			this.bmpVM = bmpVM;
			this.bmpVB = bmpVB;
			
			this.bmpHL = bmpHL;
			this.bmpHC = bmpHC;
			this.bmpHR = bmpHR;
		}
		
	}
}