package alternativa.gui.skin.container.scrollBox {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class ScrollerSkin implements ISkin {
		
		/**		Кодировка графики посимвольно: 
		 * 		вертикально 	1  n - normal, o - over, p - pressed 
		 * 		 				2  t - top, m - middle, b - bottom
		 * 
		 *		горизонтально	1  n - normal, o - over, p - locked 		 
		 * 						2  l - left, c - center, p - pressed	*/
		
		public var nt:BitmapData;
		public var nm:BitmapData;
		public var nb:BitmapData;
		public var ot:BitmapData;
		public var om:BitmapData;
		public var ob:BitmapData;
		public var pt:BitmapData;
		public var pm:BitmapData;
		public var pb:BitmapData;
		
		public var nl:BitmapData;
		public var nc:BitmapData;
		public var nr:BitmapData;
		public var ol:BitmapData;
		public var oc:BitmapData;
		public var or:BitmapData;
		public var pl:BitmapData;
		public var pc:BitmapData;
		public var pr:BitmapData;
		
		public var minLength:int;
		
		public function ScrollerSkin(nt:BitmapData, nm:BitmapData, nb:BitmapData,
									 ot:BitmapData, om:BitmapData, ob:BitmapData,
									 pt:BitmapData, pm:BitmapData, pb:BitmapData,
									 nl:BitmapData, nc:BitmapData, nr:BitmapData,
									 ol:BitmapData, oc:BitmapData, or:BitmapData,
									 pl:BitmapData, pc:BitmapData, pr:BitmapData,
									 minLength:int) {
			this.nt = nt;
			this.nm = nm;
			this.nb = nb;
			this.ot = ot;
			this.om = om;
			this.ob = ob;
			this.pt = pt;
			this.pm = pm;
			this.pb = pb;
			
			this.nl = nl;
			this.nc = nc;
			this.nr = nr;
			this.ol = ol;
			this.oc = oc;
			this.or = or;
			this.pl = pl;
			this.pc = pc;
			this.pr = pr;
			
			this.minLength = minLength;
		}
		
	}
}