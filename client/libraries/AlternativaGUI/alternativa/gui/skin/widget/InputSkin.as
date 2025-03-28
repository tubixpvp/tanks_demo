package alternativa.gui.skin.widget {
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.text.TextFormat;
	
	public class InputSkin extends TextSkin {
		
		// Normal
		public var bmpNL:BitmapData;
		public var bmpNC:BitmapData;
		public var bmpNR:BitmapData;
		// Over
		public var bmpOL:BitmapData;
		public var bmpOC:BitmapData;
		public var bmpOR:BitmapData;
		// Lock
		public var bmpLL:BitmapData;
		public var bmpLC:BitmapData;
		public var bmpLR:BitmapData;
		// Focus
		public var bmpFL:BitmapData;
		public var bmpFC:BitmapData;
		public var bmpFR:BitmapData;
		// Wrong
		public var bmpWL:BitmapData;
		public var bmpWC:BitmapData;
		public var bmpWR:BitmapData;
		// Wrong over
		public var bmpWOL:BitmapData;
		public var bmpWOC:BitmapData;
		public var bmpWOR:BitmapData;
		
		// Толщина бортика
		public var borderThickness:int;
		
		// Отступы от бортика
		public var topMargin:int;
		public var leftMargin:int;
		public var rightMargin:int;
		
		
		public function InputSkin(bmpNL:BitmapData,
								  bmpNC:BitmapData,
								  bmpNR:BitmapData,
								  bmpOL:BitmapData,
								  bmpOC:BitmapData,
								  bmpOR:BitmapData,
					  			  bmpLL:BitmapData,
								  bmpLC:BitmapData,
								  bmpLR:BitmapData,
					  			  bmpFL:BitmapData,
								  bmpFC:BitmapData,
								  bmpFR:BitmapData,
								  bmpWL:BitmapData,
								  bmpWC:BitmapData,
								  bmpWR:BitmapData,
								  bmpWOL:BitmapData,
								  bmpWOC:BitmapData,
								  bmpWOR:BitmapData,
								  borderThickness:int,
								  topMargin:int,
								  leftMargin:int,
								  rightMargin:int,
								  thickness:Number,
								  sharpness:Number,
								  tfNormal:TextFormat,
								  tfLocked:TextFormat) {
				super(tfNormal,
					  tfLocked,
					  thickness,
					  sharpness);
				
				this.bmpNL = bmpNL;
				this.bmpNC = bmpNC;
				this.bmpNR = bmpNR;
				
				this.bmpOL = bmpOL;
				this.bmpOC = bmpOC;
				this.bmpOR = bmpOR;
				
				this.bmpLL = bmpLL;
				this.bmpLC = bmpLC;
				this.bmpLR = bmpLR;

				this.bmpFL = bmpFL;
				this.bmpFC = bmpFC;
				this.bmpFR = bmpFR;
				
				this.bmpWL = bmpWL;
				this.bmpWC = bmpWC;
				this.bmpWR = bmpWR;
				
				this.bmpWOL = bmpWOL;
				this.bmpWOC = bmpWOC;
				this.bmpWOR = bmpWOR;

				this.borderThickness = borderThickness;
				
				this.topMargin = topMargin;
				this.leftMargin = leftMargin;
				this.rightMargin = rightMargin;
		}
		
	}
}