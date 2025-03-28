package alternativa.gui.skin.widget.comboBox {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class ComboBoxSkin implements ISkin {
		
		public var nl:BitmapData;
		public var nc:BitmapData;
		public var nr:BitmapData;
		
		public var ll:BitmapData;
		public var lc:BitmapData;
		public var lr:BitmapData;
		
		public var buttonNormal:BitmapData;
		public var buttonOver:BitmapData;
		public var buttonPress:BitmapData;
		public var buttonLock:BitmapData;
		
		public var borderThickness:int;
		
		public function ComboBoxSkin(nl:BitmapData,
								 	 nc:BitmapData,
								   	 nr:BitmapData,
								   	 ll:BitmapData,
								 	 lc:BitmapData,
								   	 lr:BitmapData,
								   	 buttonNormal:BitmapData,
								   	 buttonOver:BitmapData,
								   	 buttonPress:BitmapData,
								   	 buttonLock:BitmapData,
								   	 borderThickness:int) {
			this.nl = nl;							   	
			this.nc = nc;							   	
			this.nr = nr;			
			
			this.ll = ll;							   	
			this.lc = lc;							   	
			this.lr = lr;
			
			this.buttonNormal = buttonNormal;
			this.buttonOver = buttonOver;
			this.buttonPress = buttonPress;
			this.buttonLock = buttonLock;
			
			this.borderThickness = borderThickness;				
		}
		
	}
}