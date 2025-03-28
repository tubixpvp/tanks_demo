package alternativa.gui.skin.widget {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class NumberInputSkin implements ISkin {
		
		public var incButtonNormal:BitmapData;
		public var incButtonOver:BitmapData;
		public var incButtonPress:BitmapData;
		public var incButtonLock:BitmapData;

		public var decButtonNormal:BitmapData;
		public var decButtonOver:BitmapData;
		public var decButtonPress:BitmapData;
		public var decButtonLock:BitmapData;
		
		public function NumberInputSkin(incButtonNormal:BitmapData,
										incButtonOver:BitmapData,
										incButtonPress:BitmapData,
										incButtonLock:BitmapData,
										decButtonNormal:BitmapData,
										decButtonOver:BitmapData,
										decButtonPress:BitmapData,
										decButtonLock:BitmapData) {
			
			this.incButtonNormal = incButtonNormal;
			this.incButtonOver = incButtonOver;
			this.incButtonPress = incButtonPress;
			this.incButtonLock = incButtonLock;
			
			this.decButtonNormal = decButtonNormal;
			this.decButtonOver = decButtonOver;
			this.decButtonPress = decButtonPress;
			this.decButtonLock = decButtonLock;
		}
		
	}
}