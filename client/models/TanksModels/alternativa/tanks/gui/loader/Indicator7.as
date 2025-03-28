package alternativa.tanks.gui.loader {
	import alternativa.gui.base.GUIObject;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	
	public class Indicator7 extends GUIObject {
		
		protected var segNum:int;
		
		private var segments0:Sprite;
		private var segments1:Sprite;
		
		private var s0:Array;
		private var s1:Array;
		private var sLevel:Array;
		
		protected var color:uint;
		protected var thickness:int;
		
		protected var alphaLow:Number;
		protected var alphaHigh:Number;
		
		protected var space:Number;
		protected var shift:Number;
		private var pointShift:Number;
		
		private var _dp:Boolean;
		private var point:Sprite;
		private var point0:Shape;
		private var point1:Shape;
		
		private var glowFilter:GlowFilter;
		
		protected var _sign:String;
		
		private var setSignTimer:Timer;
		
		
		public function Indicator7(width:int, height:int, thickness:int, space:int, pointSpace:int, color:uint, alphaLow:Number, alphaHigh:Number) {
			super();
			
			segNum = getSegNum();
			
			this.space = space;
			shift = space*Math.sin(Math.PI*0.25);
			pointShift = pointSpace*Math.sin(Math.PI*0.25);
			
			minSize.x = width;
			minSize.y = height;
			
			this.thickness = thickness;
			this.color = color;
			this.alphaLow = alphaLow;
			this.alphaHigh = alphaHigh;
			
			s0 = new Array();
			s1 = new Array();
			sLevel = new Array();
			
			glowFilter = new GlowFilter(color, 1, thickness*0.75, thickness*0.75, 1, BitmapFilterQuality.MEDIUM);
			
			segments0 = new Sprite();
			segments0.mouseEnabled = false;
			segments0.mouseChildren = false;
			segments0.tabEnabled = false;
			segments0.tabChildren = false;
			addChild(segments0);
			
			segments1 = new Sprite();
			segments1.mouseEnabled = false;
			segments1.mouseChildren = false;
			segments1.tabEnabled = false;
			segments1.tabChildren = false;
			addChild(segments1);
			segments1.filters = new Array(glowFilter);
			
			var matrix:Matrix;
			for (var i:int = 0; i < segNum; i++) {
				var segment0:Shape = new Shape();
				s0.push(segment0);
				segments0.addChild(segment0);
				
				var segment1:Shape = new Shape();
				s1.push(segment1);
				segments1.addChild(segment1);
				segment1.visible = false;
				
				sLevel.push(0);
			}
			
			point = new Sprite();
			point.mouseEnabled = false;
			point.mouseChildren = false;
			point.tabEnabled = false;
			point.tabChildren = false;
			addChild(point);
			point.filters = new Array(glowFilter);
			
			point0 = new Shape();
			point1 = new Shape();
			point.addChild(point0);
			point.addChild(point1);
			point1.visible = false;
			
			_dp = false;
			
			setSignTimer = new Timer(0.001, int.MAX_VALUE);
		}
		
		protected function getSegNum():Number {
			return 7;
		}
		
		protected function placeSegment(segment0:Shape, segment1:Shape, segIndex:int, matrix:Matrix):void {
			switch (segIndex) {
				case 0:
					matrix.tx = shift;
					break;
				case 1:
					matrix.rotate(Math.PI*0.5);
					matrix.tx = _currentSize.x;
					matrix.ty = shift;
					break;
				case 2:
					matrix.rotate(Math.PI*0.5);
					matrix.tx = _currentSize.x;
					matrix.ty = _currentSize.y*0.5 - thickness*0.5 + shift;
					break;
				case 3:
					matrix.tx = shift;
					matrix.ty = _currentSize.y - thickness;
					break;
				case 4:
					matrix.rotate(Math.PI*0.5);
					matrix.tx = thickness;
					matrix.ty = _currentSize.y*0.5 - thickness*0.5 + shift;
					break;
				case 5:
					matrix.rotate(Math.PI*0.5);
					matrix.tx = thickness;
					matrix.ty = shift;
					break;
				case 6:
					matrix.tx = shift;
					matrix.ty = (_currentSize.y - thickness)*0.5;
					break;
			}
			segment0.transform.matrix = matrix;
			segment1.transform.matrix = matrix;
		}
		
		private function setSegmentLevel(segIndex:int, level:Boolean):void {
			if (sLevel[segIndex] != level) {
				var segment:Graphics;
				sLevel[segIndex] = level;
				
				Shape(s1[segIndex]).visible = level;
				Shape(s0[segIndex]).visible = !level;
			}
		}
		
		protected function drawSegment(segment:Graphics, segIndex:int, level:Boolean):void {
			segment.clear();
			if (level) {
				segment.beginFill(color, alphaHigh);
			} else {
				segment.beginFill(0, alphaLow);
			}
			
			var length:Number;
			if (segIndex == 0 || segIndex == 3 || segIndex == 6) {
				length = _currentSize.x - shift*2;
			} else {
				length = _currentSize.y*0.5 + thickness*0.5 - shift*2;
			}
			segment.moveTo(thickness, 0);
			segment.lineTo(length - thickness, 0);
			segment.lineTo(length - thickness*0.5, thickness*0.5);
			segment.lineTo(length - thickness, thickness);
			segment.lineTo(thickness, thickness);
			segment.lineTo(thickness*0.5, thickness*0.5);
			segment.lineTo(thickness, 0);
		}
		
		protected function drawPoint(point:Graphics, level:Boolean):void {
			point.clear();
			if (level) {
				point.beginFill(color, alphaHigh);
			} else {
				point.beginFill(0, alphaLow);
			}
			point.moveTo(0, thickness);
			point.lineTo(thickness, 0);
			point.lineTo(thickness*2, thickness);
			point.lineTo(0, thickness);
		}
		
		override public function draw(size:Point):void {
			super.draw(size);
			
	//		this.graphics.lineStyle(1, 0xff0000);
	//		this.graphics.drawRect(0, 0, size.x, size.y);
			
			var matrix:Matrix;
			for (var i:int = 0; i < segNum; i++) {
				var segment0:Shape = Shape(s0[i]);
				var segment1:Shape = Shape(s1[i]);
				drawSegment(segment0.graphics, i, false);
				drawSegment(segment1.graphics, i, true);
				
				matrix = new Matrix();
				placeSegment(segment0, segment1, i, matrix);
			}
			drawPoint(point0.graphics, false);
			drawPoint(point1.graphics, true);
			
			point.x = _currentSize.x - thickness - shift*0.5 + pointShift;
			point.y = _currentSize.y - thickness - shift*0.5 + pointShift;
		}
		
		public function set value(levels:int):void {
			
			
			for (var i:int = 0; i < segNum; i++) {
				setSegmentLevel(i, Boolean(levels & Math.pow(2, i)));
			}
			/*setSignTimer.stop();
			trace("set sign time: " + setSignTimer.currentCount);
			setSignTimer.reset();*/
		}
		
		public function get dp():Boolean {
			return _dp;
		}
		public function set dp(value:Boolean):void {
			if (_dp != value) {
				_dp = value;
				point1.visible = value;
				point0.visible = !value;
			}
		}
		
		public function set sign(s:String):void {
			//setSignTimer.start();
			_sign = s;
			switch (s) {
				case "0":
					value = 63;
					break;
				case "1":
					value = 6;
					break;
				case "2":
					value = 91;
					break;
				case "3":
					value = 79;
					break;
				case "4":
					value = 102;
					break;
				case "5":
					value = 109;
					break;
				case "6":
					value = 125;
					break;
				case "7":
					value = 7;
					break;
				case "8":
					value = 127;
					break;
				case "9":
					value = 111;
					break;
					
				default:
				
					break;
			}
		}
		public function get sign():String {
			return _sign;
		}
		
		

	}
}