package alternativa.tanks.gui.radar {
	import alternativa.gui.base.GUIObject;
	import alternativa.gui.widget.Label;
	import alternativa.tanks.gui.loader.IndicatorBoard;
	import alternativa.tanks.gui.skin.RadarSkinManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import alternativa.types.Long;
	
	
	public class Radar extends GUIObject {
		
		[Embed(source="../../resources/radar_back.png")] private static const bitmapBack:Class;
		private static const backBitmap:BitmapData = new bitmapBack().bitmapData;
		[Embed(source="../../resources/radar_outline.png")] private static const bitmapOutline:Class;
		private static const outlineBitmap:BitmapData = new bitmapOutline().bitmapData;
		
		/*[Embed(source="../../resources/radar_north.png")] private static const bitmapNorth:Class;
		private static const northBitmap:BitmapData = new bitmapNorth().bitmapData;
		[Embed(source="../../resources/radar_south.png")] private static const bitmapSouth:Class;
		private static const southBitmap:BitmapData = new bitmapSouth().bitmapData;
		[Embed(source="../../resources/radar_west.png")] private static const bitmapWest:Class;
		private static const westBitmap:BitmapData = new bitmapWest().bitmapData;
		[Embed(source="../../resources/radar_east.png")] private static const bitmapEast:Class;
		private static const eastBitmap:BitmapData = new bitmapEast().bitmapData;*/
		
		[Embed(source="../../resources/compas.swf")] private static const compasMovieClip:Class;
		private static const compasMc:MovieClip = new compasMovieClip();
		
		private var r:Number;
		private var center:Point;
		
		private var screenFill:Shape;
		private var minimap:MovieClip;
		private var minimapContainer:Sprite;
		private var minimapMask:Shape;
		//private var grid:Shape;
		private var compas:Sprite;
		private var highlight:Shape;
		
		private var screen:Sprite;
		private var outline:Bitmap;
		private var back:Bitmap;
		
		private var indicator:IndicatorBoard;
		
		private var targetPoints:Object;
		private var targetLaying:Object;
		private var targetObjects:Object;
		private var targets:Array;
		private var targetsRadius:Number;
		
		private var  selectedTargetId:Long;
		
		private var area:Number;
		
		private var _power:Boolean;
		
		private var distLabel:Label;
		
		private var compasTrasformMatrix:Matrix = new Matrix();
		
		private var powerAnimInt:int;
		private var powerAnimDelay:int;
		private var powerOnMaskScales:Array = new Array(0.05, 0.2, 0.5, 0.8, 0.9, 0.95);
		private var powerOffMaskScales:Array = new Array(0.95, 0.8, 0.5, 0.2, 0.1, 0.05);
		
		
		public function Radar()	{
			super();
			
			back = new Bitmap(backBitmap);
			addChild(back);
			minSize.x = back.width;
			minSize.y = back.height;
			
			_power = false;
			
			area = 2000;
			
			r = 62.5;
			center = new Point(r + 5 + 12, r + 5 + 8);
			targetsRadius = 1.5;
			
			screenFill = new Shape();
			addChild(screenFill);
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(6*r, 6*r, 0, -2*r, 0);
			screenFill.graphics.beginGradientFill(GradientType.RADIAL, new Array(0x272e33, 0), new Array(1, 1), new Array(0, 255), matrix);
			screenFill.graphics.drawCircle(center.x, center.y, r);
			
			minimapContainer = new Sprite();
			minimapContainer.mouseEnabled = false;
			minimapContainer.mouseChildren = false;
			minimapContainer.tabEnabled = false;
			minimapContainer.tabChildren = false;
			addChild(minimapContainer);
			minimapContainer.x = center.x;
			minimapContainer.y = center.y;
			
			minimapMask = new Shape();
			minimapMask.graphics.beginFill(0, 1);
			minimapMask.graphics.drawCircle(center.x, center.y, r);
			addChild(minimapMask);
			minimapContainer.mask = minimapMask;
			minimapContainer.visible = false;
						
			/*grid = new Shape();
			grid.x = center.x - r;
			grid.y = center.y - r;
			matrix.createGradientBox(2*r, 2*r, 0, 0, 0);
			grid.graphics.lineStyle(1, 0);
			grid.graphics.lineGradientStyle(GradientType.RADIAL, [0x00ff00, 0x00ff00], [0.5, 0.1], [0, 255], matrix);
			grid.graphics.drawCircle(r, r, 0.5*r);
			grid.graphics.moveTo(r, 0);
			grid.graphics.lineTo(r, 2*r);
			grid.graphics.moveTo(0, r);
			grid.graphics.lineTo(2*r, r);
			addChild(grid);
			grid.visible = false;*/
			
			compas = new Sprite();
			compas.mouseEnabled = false;
			compas.mouseChildren = false;
			compas.tabEnabled = false;
			compas.tabChildren = false;
			compas.x = center.x;
			compas.y = center.y;
			
			/*var nBmp:Bitmap = new Bitmap(northBitmap, PixelSnapping.AUTO, true);
			var sBmp:Bitmap = new Bitmap(southBitmap, PixelSnapping.AUTO, true);
			var wBmp:Bitmap = new Bitmap(westBitmap, PixelSnapping.AUTO, true);
			var eBmp:Bitmap = new Bitmap(eastBitmap, PixelSnapping.AUTO, true);
			
			compas.addChild(nBmp);
			compas.addChild(sBmp);
			compas.addChild(wBmp);
			compas.addChild(eBmp);
			
			nBmp.x = -nBmp.width*0.5;
			nBmp.y = -r + 5;
			sBmp.x = -sBmp.width*0.5;
			sBmp.y = r - 5 - sBmp.height;
			wBmp.x = -r + 5;
			wBmp.y = -wBmp.height*0.5;
			eBmp.x = r - 5 - eBmp.width;
			eBmp.y = -eBmp.height*0.5;*/
			
			compas.addChild(compasMc);
			compasMc.x = -compasMc.width*0.5;
			compasMc.y = -compasMc.height*0.5;
			
			addChild(compas);
			compas.visible = false;
			
			screen = new Sprite();
			screen.mouseEnabled = false;
			screen.mouseChildren = false;
			screen.tabEnabled = false;
			screen.tabChildren = false;
			addChild(screen);
			screen.visible = false;
			
			indicator = new IndicatorBoard(11, 16, 0, 1, 0.6875, 0xcc0000, 0.2, 0.8, 0, 0, 0, 0);
			addChild(indicator);
			indicator.x = 10;
			indicator.y = back.height - 25;
			indicator.value = "0";
			indicator.draw(indicator.computeSize(indicator.computeMinSize()));
			indicator.visible = false;
			
			highlight = new Shape();
			highlight.x = center.x - r;
			highlight.y = center.y - r;
			matrix.createGradientBox(4*r, 4*r, -Math.PI*0.6, -r*0.8, -r*0.8);
			highlight.graphics.beginGradientFill(GradientType.RADIAL, [0xffffff, 0xaaffff, 0x006699], [0.25, 0.1, 0.05], [0, 70, 255], matrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB, 0.75);
			highlight.graphics.drawCircle(r, r, r);
			addChild(highlight);
			
			outline = new Bitmap(outlineBitmap);
			addChild(outline);
			outline.x = 12;
			outline.y = 8;
			
			distLabel = new Label();
			screen.addChild(distLabel);
			distLabel.x = center.x;
			distLabel.y = center.y;
			
			targets = new Array();
			targetObjects = new Object();
			targetPoints = new Object();
			targetLaying = new Object();
		}
		
		override public function updateSkin():void {
			super.updateSkin();
			distLabel.skinManager = new RadarSkinManager(); 
		}
		
		override public function computeMinSize():Point {
			distLabel.computeMinSize();
			super.computeMinSize();
			return minSize;
		}
		override public function computeSize(size:Point):Point {
			distLabel.computeSize(distLabel.minSize);
			return super.computeSize(size);
		}
		override public function draw(size:Point):void {
			distLabel.draw(distLabel.minSize);
			super.draw(size);
		}
		
		private function drawTarget(target:Shape, selected:Boolean):void {
			target.graphics.clear();
			if (selected) {
				target.graphics.beginFill(0xffffff, 1);
				target.graphics.drawCircle(0, 0, targetsRadius + 1);
			} 
			target.graphics.beginFill(0xff0000, 1);
			target.graphics.drawCircle(0, 0, targetsRadius);
		}
		private function placeTarget(target:Shape, angle:Number, distance:Number):void {
			if (distance < area) {
				distance = distance*(r/area);
				
				target.visible = true;
				
				// Определяем четверть, в которой находится цель
				if (angle <= Math.PI*0.5) {
					// I
					target.x = distance*Math.sin(angle);
					target.y = -distance*Math.cos(angle);
				} else if (angle <= Math.PI) {
					// II
					angle -= Math.PI*0.5;
					target.x = distance*Math.cos(angle);
					target.y = distance*Math.sin(angle);
				} else if (angle <= Math.PI*1.5) {
					// III
					angle -= Math.PI;
					target.x = -distance*Math.sin(angle);
					target.y = distance*Math.cos(angle);
				} else {
					// IV
					angle -= Math.PI*1.5;
					target.x = -distance*Math.cos(angle);
					target.y = -distance*Math.sin(angle);
				}
				target.x += center.x;
				target.y += center.y;
			} else {
				target.visible = false;
			}
		}			
		
		public function addTarget(id:Long, angle:Number, distance:Number):void {
			//Main.console.write("Radar addTarget id: " + id);
			
			targets.push(id);
			targetLaying[id] = new Point(angle, distance);
			var target:Shape = new Shape();
			drawTarget(target, false);
			targetObjects[id] = target;
			
			placeTarget(target, angle, distance);
			
			targetPoints[id] = new Point(target.x - center.x, target.y - center.y);
			screen.addChild(target);
		}
		
		public function removeTarget(id:Long):void {
			//Main.console.write("Radar removeTarget id: " + id);
			targets.splice(targets.indexOf(id), 1);
			screen.removeChild(targetObjects[id]);
			targetObjects[id] = null;
			targetPoints[id] = null;
			targetLaying[id] = null;
		}
		
		public function updateTargetPosition(id:Long, angle:Number, distance:Number):void {
			//Main.console.write("updateTargetPosition id: " + id + " angle: " + angle + " distance: " + distance, 0x666666);
			
			if (angle < 0) {
				angle = Math.PI*2 + angle;
			}
			if (angle > Math.PI*2) {
				angle -= Math.PI*2*(Math.floor(angle/(Math.PI*2)));
			}
			
			var target:Shape = Shape(targetObjects[id]);
			if (target != null) {
				placeTarget(target, angle, distance);
				
				Point(targetPoints[id]).x = target.x - center.x;
				Point(targetPoints[id]).y = target.y - center.y;
				Point(targetLaying[id]).x = angle;
				Point(targetLaying[id]).y = distance;
				
				if (selectedTargetId == id) {
					updateDistLabel(target, id);
				}
			}
		}
		
		public function updateCompasAngle(angle:Number):void {
			compas.rotation = (angle/(Math.PI*2))*360;
		}
		
		public function updateMinimap(shift:Point, angle:Number):void {
			minimapContainer.rotation = (angle/(Math.PI*2))*360;
			
			minimap.x = shift.x;
			minimap.y = shift.y;
		}
		
		private function updateDistLabel(target:Shape, id:Long):void {
			if (Point(targetLaying[id]).y < area) {
				
				distLabel.visible = true;
				
				distLabel.text = Math.round(Point(targetLaying[id]).y).toString();
				// Определяем четверть, в которой находится цель
				var angle:Number = Point(targetLaying[id]).x;
				var range:Boolean = (Point(targetLaying[id]).y < area*0.5) ? true : false;
				distLabel.textColor = (range)?  0xff0000 : 0x224422;
				if (angle <= Math.PI*0.5) {
					// I
					if (range) {
						distLabel.x = target.x + 2;
						distLabel.y = target.y - distLabel.currentSize.y - 2;
					} else {
						distLabel.x = target.x - distLabel.currentSize.x - 2;
						distLabel.y = target.y + distLabel.currentSize.y - 2;
					}
				} else if (angle <= Math.PI) {
					// II
					if (range) {
						distLabel.x = target.x + 2;
						distLabel.y = target.y + 2;
					} else {
						distLabel.x = target.x - distLabel.currentSize.x - 2;
						distLabel.y = target.y - distLabel.currentSize.y - 2;
					}
				} else if (angle <= Math.PI*1.5) {
					// III
					if (range) {
						distLabel.x = target.x - distLabel.currentSize.x - 2;
						distLabel.y = target.y + 2;
					} else {
						distLabel.x = target.x + 2;
						distLabel.y = target.y - distLabel.currentSize.y - 2;
					}
				} else {
					// IV
					if (range) {
						distLabel.x = target.x - distLabel.currentSize.x - 2;
						distLabel.y = target.y - distLabel.currentSize.y - 2;
					} else {
						distLabel.x = target.x + 2;
						distLabel.y = target.y + 2;
					}
				}
			} else {
				distLabel.visible = false;
			}
		}
		
		public function selectTarget(id:Long):void {
			selectedTargetId = id;
			
			var target:Shape = Shape(targetObjects[id]);
			drawTarget(target, true);
			target.filters = new Array(new GlowFilter(0xffffff,0.5, targetsRadius*3, targetsRadius*3, 2, BitmapFilterQuality.MEDIUM, false, false));
			
			updateDistLabel(target, id);
		}
		public function unselectTarget(id:Long):void {
			var target:Shape = Shape(targetObjects[id]);
			drawTarget(target, false);
			target.filters = new Array();
			
			distLabel.visible = false;
		}
		
		public function set areaRadius(value:int):void {
			//Main.console.write("Radar areaRadius: " + value);
			area = value;
		}
		public function set minimapMc(mc:MovieClip):void {
			minimap = mc;
			minimapContainer.addChild(minimap);
		}
		
		public function set playersNum(value:int):void {
			indicator.value = value.toString();
		}
		public function get playersNum():int {
			return int(indicator.value);
		}
		
		// Радиус экрана радара в пикселях
		public function get radius():Number {
			return r;
		}
		
		public function get power():Boolean {
			return _power;
		}
		public function set power(value:Boolean):void {
			_power = value;
			
			//grid.visible = value;
			compas.visible = value;
			minimapContainer.visible = value;
			screen.visible = value;
			indicator.visible = value;
		}
		
		private function powerOnAnimation():void {
			
		}
		private function powerOffAnimation():void {
			
		}
		

	}
}