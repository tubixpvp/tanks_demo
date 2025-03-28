package alternativa.resource {
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class LoadingProgressBar	extends Sprite {
		
		[Embed(source="images/progressbar_back_fill.png")] private static const backFillBitmap:Class;
		private static const backFillBd:BitmapData = new backFillBitmap().bitmapData;
		[Embed(source="images/progressbar_fill.png")] private static const fillBitmap:Class;
		private static const fillBd:BitmapData = new fillBitmap().bitmapData;
		
		private var _value:Number;
		
		private var _currentSize:Point;
		
		private var fill:Shape;
		
		
		public function LoadingProgressBar() {
			super();
			mouseEnabled = false;
			tabEnabled = false;
			mouseChildren = false;
			tabChildren = false;
			
			_value = 0;
			
			fill = new Shape();
			addChild(fill);
			
			_currentSize = new Point(backFillBd.width*10, backFillBd.height);
			
			fill.y = Math.round((_currentSize.y - fillBd.height)*0.5);
		}
		
		public function repaint(width:int):void {
			_currentSize.x = width;
			
			this.graphics.clear();
			this.graphics.beginBitmapFill(backFillBd, new Matrix(), true);
			this.graphics.drawRect(0, 0, width, _currentSize.y);
			
			fill.graphics.clear();
			if (_value > 0) {
				fill.graphics.beginBitmapFill(fillBd, new Matrix(), true);
				fill.graphics.drawRect(0, 0, _currentSize.x*_value, fillBd.height);
			}
		}
		
		public function get currentSize():Point {
			return _currentSize;
		}
		
		public function set value(n:Number):void {
			if (n > 1) {
				n = 1;
			} else if (n < 0) {
				n = 0;
			} else {
				_value = n;
			}
			fill.graphics.clear();
			if (n > 0) {
				fill.graphics.beginBitmapFill(fillBd, new Matrix(), true);
				fill.graphics.drawRect(0, 0, _currentSize.x*n, fillBd.height);
			}
		}
		public function get value():Number {
			return _value;
		}

	}
}