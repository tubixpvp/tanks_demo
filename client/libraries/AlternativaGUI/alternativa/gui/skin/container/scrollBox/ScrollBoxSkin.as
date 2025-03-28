package alternativa.gui.skin.container.scrollBox {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class ScrollBoxSkin implements ISkin {
		
		/* Кодировка графики посимвольно: 
		 		1  n - normal, o - over, l - locked 
				2  t - top, m - middle, b - bottom
				3  l - left, c - center, r - right
		*/
		public var ntl:BitmapData;
		public var ntc:BitmapData;
		public var ntr:BitmapData;
    	public var nml:BitmapData;
    	public var nmc:BitmapData;
    	public var nmr:BitmapData;
    	public var nbl:BitmapData;
    	public var nbc:BitmapData;
    	public var nbr:BitmapData;
    	public var otl:BitmapData;
    	public var otc:BitmapData;
    	public var otr:BitmapData;
		public var oml:BitmapData;
		public var omc:BitmapData;
		public var omr:BitmapData;
		public var obl:BitmapData;
		public var obc:BitmapData;
		public var obr:BitmapData;
		public var ltl:BitmapData;
		public var ltc:BitmapData;
		public var ltr:BitmapData;
		public var lml:BitmapData;
		public var lmc:BitmapData;
		public var lmr:BitmapData;
		public var lbl:BitmapData;
		public var lbc:BitmapData;
		public var lbr:BitmapData;
		
		public var corner:BitmapData;
		
		public var borderThickness:int;
		
		public function ScrollBoxSkin(ntl:BitmapData, ntc:BitmapData, ntr:BitmapData,
									  nml:BitmapData, nmc:BitmapData, nmr:BitmapData,
									  nbl:BitmapData, nbc:BitmapData, nbr:BitmapData,
									  otl:BitmapData, otc:BitmapData, otr:BitmapData,
									  oml:BitmapData, omc:BitmapData, omr:BitmapData,
									  obl:BitmapData, obc:BitmapData, obr:BitmapData,
									  ltl:BitmapData, ltc:BitmapData, ltr:BitmapData,
									  lml:BitmapData, lmc:BitmapData, lmr:BitmapData,
									  lbl:BitmapData, lbc:BitmapData, lbr:BitmapData,
									  corner:BitmapData, borderThickness:int) {
			this.ntl = ntl;
			this.ntc = ntc;
			this.ntr = ntr;
    		this.nml = nml;
   		 	this.nmc = nmc;
   		 	this.nmr = nmr;
   		 	this.nbl = nbl;
   	 		this.nbc = nbc;
    		this.nbr = nbr;
    		this.otl = otl;
    		this.otc = otc;
    		this.otr = otr;
			this.oml = oml; 
			this.omc = omc;
			this.omr = omr;
			this.obl = obl;
			this.obc = obc;
			this.obr = obr;
			this.ltl = ltl;
			this.ltc = ltc;
			this.ltr = ltr;
			this.lml = lml;
			this.lmc = lmc;
			this.lmr = lmr;
			this.lbl = lbl;
			this.lbc = lbc;
			this.lbr = lbr;
			this.corner = corner;
			this.borderThickness = borderThickness;
		}
		
	}
}