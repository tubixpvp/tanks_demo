package alternativa.gui.skin.widget.button {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.text.TextFormat;
	
	public class ButtonSkin implements ISkin {
		
		public var nl:BitmapData;
		public var nc:BitmapData;
		public var nr:BitmapData;
		public var ol:BitmapData;
		public var oc:BitmapData;
		public var or:BitmapData;
		public var pl:BitmapData;
		public var pc:BitmapData;
		public var pr:BitmapData;
		public var ll:BitmapData;
		public var lc:BitmapData;
		public var lr:BitmapData;
		public var fl:BitmapData;
		public var fc:BitmapData;
		public var fr:BitmapData;
		
		public var yPressShift:int;
		
		public var tfNormal:TextFormat;
		public var tfOver:TextFormat;
		public var tfPressed:TextFormat;
		public var tfLocked:TextFormat;

		public var colorNormal:ColorTransform;
		public var colorOver:ColorTransform;
		public var colorPressed:ColorTransform;
		public var colorLocked:ColorTransform;
		
		public var textSharpness:Number;
		public var textThickness:Number;
		
		public var margin:int;
		public var space:int;
		
		public function ButtonSkin(nl:BitmapData,
								   nc:BitmapData,
								   nr:BitmapData,
								   ol:BitmapData,
								   oc:BitmapData,
								   or:BitmapData,
								   pl:BitmapData,
								   pc:BitmapData,
								   pr:BitmapData,
								   ll:BitmapData,
								   lc:BitmapData,
								   lr:BitmapData,
								   fl:BitmapData,
								   fc:BitmapData,
								   fr:BitmapData,
								   yPressShift:int,
								   textThickness:Number,
								   textSharpness:Number,
								   tfNormal:TextFormat,
								   tfOver:TextFormat,
								   tfPressed:TextFormat,
								   tfLocked:TextFormat,
								   colorNormal:ColorTransform,
								   colorOver:ColorTransform,
								   colorPressed:ColorTransform,
								   colorLocked:ColorTransform,
								   margin:int,
								   space:int) {
			this.nl = nl;							   	
			this.nc = nc;							   	
			this.nr = nr;
										   	
			this.ol = ol;							   	
			this.oc = oc;							   	
			this.or = or;	
									   	
			this.pl = pl;							   	
			this.pc = pc;							   	
			this.pr = pr;
									   	
			this.ll = ll;							   	
			this.lc = lc;							   	
			this.lr = lr;
			
			this.fl = fl;							   	
			this.fc = fc;							   	
			this.fr = fr;
			
			this.yPressShift = yPressShift;
			
			this.textSharpness = textSharpness;
			this.textThickness = textThickness;
			
			this.tfNormal = tfNormal;
			this.tfOver = tfOver;
			this.tfPressed = tfPressed;
			this.tfLocked = tfLocked;
			
			this.colorNormal = colorNormal;
			this.colorOver = colorOver;
			this.colorPressed = colorPressed;
			this.colorLocked = colorLocked;
			
			this.margin = margin;
			this.space = space;			
		}
		
	}
}