package alternativa.gui.skin.widget.button {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class SwitchSkin implements ISkin {
		
		public var cornerTL:BitmapData;
		public var cornerTR:BitmapData;
		public var cornerBL:BitmapData;
		public var cornerBR:BitmapData;
		public var edgeTC:BitmapData;
		public var edgeML:BitmapData;
		public var edgeMR:BitmapData;
		public var edgeBC:BitmapData;
		public var bgMC:BitmapData;
		
		public var arrow:BitmapData;
		
		public var borderThickness:int;
		
		public function SwitchSkin(cornerTL:BitmapData,
								   cornerTR:BitmapData,
								   cornerBL:BitmapData,
								   cornerBR:BitmapData, 
								   edgeTC:BitmapData,
								   edgeML:BitmapData,
								   edgeMR:BitmapData,
								   edgeBC:BitmapData,
								   bgMC:BitmapData,
								   arrow:BitmapData,
								   borderThickness:int) {
								   	
			this.cornerTL = cornerTL;
			this.cornerTR = cornerTR;
			this.cornerBL = cornerBL;
			this.cornerBR = cornerBR;
			this.edgeTC = edgeTC;
			this.edgeML = edgeML;
			this.edgeMR = edgeMR;
			this.edgeBC = edgeBC;
			this.bgMC = bgMC;
			this.arrow = arrow;
			this.borderThickness = borderThickness;
		}
		
	}
}