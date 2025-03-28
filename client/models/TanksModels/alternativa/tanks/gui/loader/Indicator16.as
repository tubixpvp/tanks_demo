package alternativa.tanks.gui.loader {
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	
	public class Indicator16 extends Indicator7 {
		
		public function Indicator16(width:int, height:int, thickness:int, space:int, pointSpace:int, color:uint, alphaLow:Number, alphaHigh:Number) {
			super(width, height, thickness, space, pointSpace, color, alphaLow, alphaHigh);
		}
		
		override protected function getSegNum():Number {
			return 16;
		}
		
		override protected function placeSegment(segment0:Shape, segment1:Shape, segIndex:int, matrix:Matrix):void {
			switch (segIndex) {
				case 0:
					matrix.tx = shift;
					break;
				case 1:
					matrix.scale(-1, 1);
					matrix.tx = minSize.x - shift;
					break;
				case 2:
					matrix.rotate(Math.PI*0.5);
					matrix.tx = minSize.x;
					matrix.ty = shift;
					break;
				case 3:
					matrix.scale(1, -1);
					matrix.rotate(-Math.PI*0.5);
					matrix.tx = minSize.x;
					matrix.ty = minSize.y - shift;
					break;
				case 4:
					matrix.scale(-1, -1);
					matrix.tx = minSize.x - shift;
					matrix.ty = minSize.y;
					break;
				case 5:
					matrix.scale(1, -1);
					matrix.tx = shift;
					matrix.ty = minSize.y;
					break;
				case 6:
					matrix.rotate(-Math.PI*0.5);
					matrix.ty = minSize.y - shift;
					break;
				case 7:
					matrix.scale(1, -1);
					matrix.rotate(Math.PI*0.5);
					matrix.ty = shift;
					break;
				case 8:
					matrix.tx = shift;
					matrix.ty = (minSize.y - thickness)*0.5;
					break;
				case 9:
					matrix.scale(-1, 1);
					matrix.tx = minSize.x - shift;
					matrix.ty = (minSize.y - thickness)*0.5;
					break;
				case 10:
					matrix.tx = shift;
					matrix.ty = shift;
					break;
				case 11:
					matrix.rotate(Math.PI*0.5);
					matrix.tx = (minSize.x + thickness)*0.5;
					matrix.ty = shift;
					break;
				case 12:
					matrix.scale(-1, 1);
					matrix.tx = minSize.x - shift;
					matrix.ty = shift;
					break;
				case 13:
					matrix.scale(-1, -1);
					matrix.tx = minSize.x - shift;
					matrix.ty = minSize.y - shift;
					break;
				case 14:
					matrix.rotate(-Math.PI*0.5);
					matrix.tx = (minSize.x - thickness)*0.5;
					matrix.ty = minSize.y - shift;
					break;
				case 15:
					matrix.scale(1, -1);
					matrix.tx = shift;
					matrix.ty = minSize.y - shift;
					break;
			}
			segment0.transform.matrix = matrix;
			segment1.transform.matrix = matrix;
		}
		
		override protected function drawSegment(segment:Graphics, segIndex:int, level:Boolean):void {
			
			segment.clear();
			if (level) {
				segment.beginFill(color, alphaHigh);
			} else {
				segment.beginFill(0, alphaLow);
			}
			
			var length:Number;
			
			if (segIndex <= 7) {
				if (segIndex == 0 || segIndex == 1 || segIndex == 4 || segIndex == 5) {
					length = _currentSize.x*0.5 - shift*2;
				} else {
					length = _currentSize.y*0.5 - space*0.5 - shift;
				}
				segment.moveTo(thickness, 0);
				segment.lineTo(length - thickness*0.5, 0);
				segment.lineTo(length, thickness*0.5);
				segment.lineTo(length - thickness*0.5, thickness);
				segment.lineTo(thickness*(1 + Math.sin(Math.PI*0.25)), thickness);
				segment.lineTo(thickness*0.75, thickness*0.75);
				segment.lineTo(thickness*0.5, thickness*0.5);
				segment.lineTo(thickness, 0);
			} else if (segIndex == 8 || segIndex == 9) {
				length = _currentSize.x*0.5 - space*0.5 - shift*2;
				
				var tgA:Number = (minSize.x - thickness*2)/(minSize.y - thickness*(1+Math.sin(Math.PI*0.25)));
				var x:Number = tgA*(minSize.y*0.5 - thickness*(1.5 + Math.sin(Math.PI*0.25))) - shift*2;
				
				segment.moveTo(thickness, 0);
				segment.lineTo(thickness + x, 0);
				segment.lineTo(length, thickness*0.5);
				segment.lineTo(thickness + x, thickness);
				segment.lineTo(thickness, thickness);
				segment.lineTo(thickness*0.5, thickness*0.5);
				segment.lineTo(thickness, 0);
			} else if (segIndex == 11 || segIndex == 14) {
				length = _currentSize.y*0.5 - space*0.5 - shift*2;
				
				tgA = (minSize.x - thickness*2)/(minSize.y - thickness*(1+Math.sin(Math.PI*0.25)));
				x = (minSize.x*0.5 - thickness*(1.5 + Math.sin(Math.PI*0.25)))/tgA - space*0.5 - shift*2;
				
				segment.moveTo(thickness, 0);
				segment.lineTo(thickness + x, 0);
				segment.lineTo(length, thickness*0.5);
				segment.lineTo(thickness + x, thickness);
				segment.lineTo(thickness, thickness);
				segment.lineTo(thickness*0.5, thickness*0.5);
				segment.lineTo(thickness, 0);
			} else if (segIndex == 10 || segIndex == 12 || segIndex == 13 || segIndex == 15) {
				tgA = (minSize.x - thickness*2)/(minSize.y - thickness*(1+Math.sin(Math.PI*0.25)));
				var a:Number = Math.atan(tgA);
				
				x= tgA*(minSize.y*0.5 - thickness*(1.5 + Math.sin(Math.PI*0.25)));
				var m:Number = (minSize.x*0.5 - thickness*(1.5 + Math.sin(Math.PI*0.25)))/tgA;
				
				var dx:Number = space*(1 + Math.sin(a));
				var dy:Number = space*(1 + Math.cos(a));
				
				segment.moveTo(thickness*0.75, thickness*0.75);
				segment.lineTo(thickness*(1 + Math.sin(Math.PI*0.25)), thickness);
				segment.lineTo((minSize.x - thickness)*0.5 - dx, thickness + m - dy);
				segment.lineTo(minSize.x*0.5 - dx, minSize.y*0.5 - dy);
				segment.lineTo(thickness + x - dx, (minSize.y - thickness)*0.5 - dy);
				segment.lineTo(thickness, thickness*(1 + Math.sin(Math.PI*0.25)));
				segment.lineTo(thickness*0.75, thickness*0.75);
			}
		}
		
		override public function set sign(s:String):void {
			_sign = s;
			switch (s) {
				case "0":
					value = 37119;
					break;
				case "1":
					value = 4108;
					break;
				case "2":
					value = 887;
					break;
				case "3":
					value = 4923;
					break;
				case "4":
					value = 908;
					break;
				case "5":
					value = 955;
					break;
				case "6":
					value = 1019;
					break;
				case "7":
					value = 20483;
					break;
				case "8":
					value = 1023;
					break;
				case "9":
					value = 959;
					break;
				
				case "-":
					value = 768;
					break;
				case "+":
					value = 19200;
					break;
				case " ":
					value = 0;
					break;
				case "!":
					value = 12;
					if (!dp) {
						dp = true;
					}
					break;
				case "?":
					value = 16903;
					break;
				case "/":
					value = 36864;
					break;
				case "\\":
					value = 9216;
					break;
				case ":":
					value = 18432;
					break;
				case "<":
					value = 12288;
					break;
				case ">":
					value = 33792;
					break;
				case "[":
					value = 18450;
					break;
				case "]":
					value = 18465;
					break;
				case "|":
					value = 18432;
					break;
				case '"':
					value = 2176;
					break;
				case "'":
					value = 2048;
					break;
				case "*":
					value = 65280;
					break;
				
				case "А":
					value = 37388;
					break;
				case "Б":
					value = 1019;
					break;
				case "В":
					value = 5115;
					break;
				case "Г":
					value = 195;
					break;
				case "Д":
					value = 34878;//36924;
					if (!dp) {
						dp = true;
					}
					break;
				case "Е":
					value = 1011;
					break;
				case "Ж":
					value = 60292;
					break;
				case "З":
					value = 831;
					break;
				case "И":
					value = 37068;
					break;
				case "К":
					value = 12736;
					break;
				case "Л":
					value = 34830;//36876;
					break;
				case "М":
					value = 5324;
					break;
				case "Н":
					value = 972;
					break;
				case "О":
					value = 255;
					break;
				case "П":
					value = 207;
					break;
				case "Р":
					value = 967;
					break;
				case "С":
					value = 243;
					break;
				case "Т":
					value = 18435;
					break;
				case "У":
					value = 956;
					break;
				case "Ф":
					value = 19335;
					break;
				case "Х":
					value = 46080;
					break;
				case "Ц":
					value = 252;
					if (!dp) {
						dp = true;
					}
					break;
				case "Ч":
					value = 908;
					break;
				case "Ш":
					value = 16636;
					break;
				case "Щ":
					value = 16636;
					if (!dp) {
						dp = true;
					}
					break;
				case "Ъ":
					value = 1016;
					break;
				case "Ь":
					value = 1016;
					break;
				case "Ы":
					value = 16876;
					break;
				case "Э":
					value = 575;
					break;
				case "Ю":
					value = 18910;
					break;
				case "Я":
					value = 33679;
					break;
				
				case "A":
					value = 975;
					break;
				case "B":
					value = 5115;
					break;
				case "C":
					value = 243;
					break;
				case "D":
					value = 18495;
					break;
				case "E":
					value = 1011;
					break;
				case "F":
					value = 451;
					break;
				case "G":
					value = 763;
					break;
				case "H":
					value = 972;
					break;
				case "I":
					value = 18432;
					break;
				case "J":
					value = 124;
					break;
				case "K":
					value = 12736;
					break;
				case "L":
					value = 240;
					break;
				case "M":
					value = 5324;
					break;
				case "N":
					value = 9420;
					break;
				case "O":
					value = 255;
					break;
				case "P":
					value = 967;
					break;
				case "Q":
					value = 8447;
					if (!dp) {
						dp = true;
					}
					break;
				case "R":
					value = 9159;
					break;
				case "S":
					value = 955;
					break;
				case "T":
					value = 18435;
					break;
				case "U":
					value = 252;
					break;
				case "V":
					value = 37056;
					break;
				case "W":
					value = 41164;
					break;
				case "X":
					value = 46080;
					break;
				case "Y":
					value = 21504;
					break;
				case "Z":
					value = 37683;
					break;
				
				default:
				
					break;
			}
		}

	}
}