package alternativa.gui.skin.container.scrollBox {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class ScrollBarSkin implements ISkin {
		
		// Вертикальный скроллбар
		public var bmpT:BitmapData;
		public var bmpM:BitmapData;
		public var bmpB:BitmapData;
		public var bmpUN:BitmapData;
		public var bmpUO:BitmapData;
		public var bmpUP:BitmapData;
		public var bmpUL:BitmapData;
		public var bmpDN:BitmapData;
		public var bmpDO:BitmapData;
		public var bmpDP:BitmapData;
		public var bmpDL:BitmapData;
		
		// Горизонтальный скроллбар
		public var bmpL:BitmapData;
		public var bmpC:BitmapData;
		public var bmpR:BitmapData;
		public var bmpLN:BitmapData;
		public var bmpLO:BitmapData;
		public var bmpLP:BitmapData;
		public var bmpLL:BitmapData;
		public var bmpRN:BitmapData;
		public var bmpRO:BitmapData;
		public var bmpRP:BitmapData;
		public var bmpRL:BitmapData;
		
		public var pageButtonFillColor:uint;
		public var pageButtonFillAlpha:Number;
		
		public function ScrollBarSkin(
			bmpT:BitmapData,
			bmpM:BitmapData,
			bmpB:BitmapData,
			bmpUN:BitmapData,
			bmpUO:BitmapData,
			bmpUP:BitmapData,
			bmpUL:BitmapData,
			bmpDN:BitmapData,
			bmpDO:BitmapData,
			bmpDP:BitmapData,
			bmpDL:BitmapData,
			bmpL:BitmapData,
			bmpC:BitmapData,
			bmpR:BitmapData,
			bmpLN:BitmapData,
			bmpLO:BitmapData,
			bmpLP:BitmapData,
			bmpLL:BitmapData,
			bmpRN:BitmapData,
			bmpRO:BitmapData,
			bmpRP:BitmapData,
			bmpRL:BitmapData,
			pageButtonFillColor:uint,
			pageButtonFillAlpha:Number
		) {
				this.bmpT = bmpT;
				this.bmpM = bmpM; 
				this.bmpB = bmpB; 
				this.bmpUN = bmpUN;
				this.bmpUO = bmpUO;
				this.bmpUP = bmpUP;
				this.bmpUL = bmpUL;
				this.bmpDN = bmpDN;
				this.bmpDO = bmpDO;
				this.bmpDP = bmpDP;
				this.bmpDL = bmpDL;
				this.bmpL = bmpL;
				this.bmpC = bmpC;
				this.bmpR = bmpR;
				this.bmpLN = bmpLN;
				this.bmpLO = bmpLO;
				this.bmpLP = bmpLP;
				this.bmpLL = bmpLL;
				this.bmpRN = bmpRN;
				this.bmpRO = bmpRO;
				this.bmpRP = bmpRP;
				this.bmpRL = bmpRL;
				
				this.pageButtonFillColor = pageButtonFillColor;
				this.pageButtonFillAlpha = pageButtonFillAlpha;
		
		}
		
	}
}