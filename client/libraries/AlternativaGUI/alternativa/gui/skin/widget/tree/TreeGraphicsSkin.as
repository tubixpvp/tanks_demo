package alternativa.gui.skin.widget.tree {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;

	public class TreeGraphicsSkin implements ISkin {
		
		public var bitmapConnectLine:BitmapData;		
		public var bitmapConnectTri:BitmapData;
		public var bitmapConnectTop:BitmapData;
		public var bitmapConnectBottom:BitmapData;
		
		public function TreeGraphicsSkin(bitmapConnectLine:BitmapData, bitmapConnectTri:BitmapData, bitmapConnectTop:BitmapData, bitmapConnectBottom:BitmapData) {
			this.bitmapConnectLine = bitmapConnectLine;
			this.bitmapConnectTri = bitmapConnectTri;
			this.bitmapConnectTop = bitmapConnectTop;
			this.bitmapConnectBottom =  bitmapConnectBottom;
		}
		
		
		
	}
}