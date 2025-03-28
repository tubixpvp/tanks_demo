package alternativa.tanks.gui.loader {
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	
	import flash.geom.Point;
	
	
	public class IndicatorBoard extends Container {
		
		
		protected var color:uint;
		
		protected var digitsNum:int;
		protected var digit:Array;
		
		protected var digitHeight:int;
		protected var digitWidth:int;
		
		protected var digitColor:uint;
		protected var digitAlphaLow:Number;
		protected var digitAlphaHigh:Number;
		
		protected var _value:String;
		
		
		public function IndicatorBoard(width:int, height:int, color:uint, digitsNum:int, digitProportion:Number, digitColor:uint, digitAlphaLow:Number, digitAlphaHigh:Number, marginLeft:int = 0, marginTop:int = 0, marginRight:int = 0, marginBottom:int = 0) {
			super(marginLeft, marginTop, marginRight, marginBottom);
			
			this.color = color;
			
			digitHeight = height - marginTop - marginBottom;
			digitWidth = Math.round(digitHeight*digitProportion);
			
			minSize.x = Math.max(width, digitWidth*digitsNum + marginLeft + marginRight);
			minSize.y = height;
			
			this.digitColor = digitColor;
			this.digitAlphaLow = digitAlphaLow;
			this.digitAlphaHigh = digitAlphaHigh;
			
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.BOTTOM, digitWidth/3);
			
			this.digitsNum = digitsNum;
			
			digit = new Array();
			
			for (var i:int = 0; i < digitsNum; i++) {
				addIndicator();
			}
		}
		
		protected function addIndicator():void {
			var d:Indicator7 = new Indicator7(digitWidth, digitHeight, digitWidth/4, digitWidth/6, digitWidth/3, digitColor, digitAlphaLow, digitAlphaHigh);
			digit.push(d);
			addObject(d);
		}
		
		override public function draw(size:Point):void {
			super.draw(size);
			
			//this.graphics.beginFill(color, 1);
			//this.graphics.drawRoundRect(0, 0, size.x, size.y, 5, 5);
		}
		
		public function get value():String {
			return _value;
		}
		public function set value(s:String):void {
			_value = s;
			
			var n:int = s.length-1;
			var i:int = digit.length-1;
			while (i >= 0) {
				var char:String = s.charAt(n);
				switch (char) {
					case ".":
						Indicator7(digit[i]).dp = true;
						break;
					case ",":
						Indicator7(digit[i]).dp = true;
						break;
						
					default :
						Indicator7(digit[i]).sign = char;
						i--;
						break;
				}
				n--;
			}
		}

	}
}