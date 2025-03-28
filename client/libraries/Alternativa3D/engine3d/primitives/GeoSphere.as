package alternativa.engine3d.primitives {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.core.Vertex;
	import alternativa.types.Point3D;
	import alternativa.utils.MathUtils;
	
	import flash.geom.Point;

	use namespace alternativa3d;
	
	/**
	 * Геосфера.
	 */	
	public class GeoSphere extends Mesh	{

		// Инкремент количества объектов
		private static var counter:uint = 0;

		/**
		 * Создает геосферу.
		 * <p>Геосфера после создания содержит в себе одну поверхность с идентификатором по умолчанию.</p>
		 * <p>Текстурные координаты у геосферы не находятся в промежутке <code>[0, 1]</code>,
		 *  поэтому для материала с текстурой необходимо устанавливать флаг repeat.</p>
		 * 
		 * @param radius радиус геосферы. Не может быть меньше нуля.
		 * @param segments количество сегментов геосферы
		 * @param reverse флаг направления нормалей. При значении <code>true</code> нормали направлены внуть геосферы.
		 */
		public function GeoSphere(radius:Number = 100, segments:uint = 2, reverse:Boolean = false) {
			if (segments == 0) {
				return;
			}
			radius = (radius < 0)? 0 : radius;
			
			const sections:uint = 20;

			//var nfaces:uint = sections*segments*segments;
			//var nverts:Number = nfaces/2 + 2;
			var points:Array = new Array();

			var i:uint;
			var f:uint;

			var theta:Number;
			var sin:Number;
			var cos:Number;
			// z расстояние до нижней и верхней крышки полюса  
			var subz:Number = 4.472136E-001*radius;
			// радиус на расстоянии subz 
			var subrad:Number = 2*subz;
			points.push(createVertex(0, 0, radius, "poleUp"));
			// Создание вершин верхней крышки
			for (i = 0; i < 5; i++) {
				theta = MathUtils.DEG360*i/5;
				sin = Math.sin(theta);
				cos = Math.cos(theta);
				points.push(createVertex(subrad*cos, subrad*sin, subz));
			}
			// Создание вершин нижней крышки
			for (i = 0; i < 5; i++) {
				theta = MathUtils.DEG180*((i << 1) + 1)/5;
				sin = Math.sin(theta);
				cos = Math.cos(theta);
				points.push(createVertex(subrad*cos, subrad*sin, -subz));
			}
			points.push(createVertex(0, 0, -radius, "poleDown"));
			
			for (i = 1; i < 6; i++) {
				interpolate(0, i, segments, points);
			}
			for (i = 1; i < 6; i++) {
				interpolate(i, i % 5 + 1, segments, points);
			}
			for (i = 1; i < 6; i++) {
				interpolate(i, i + 5, segments, points);
			}
			for (i = 1; i < 6; i++) {
				interpolate(i, (i + 3) % 5 + 6, segments, points);
			}
			for (i = 1; i < 6; i++) {
				interpolate(i + 5, i % 5 + 6, segments, points);
			}
			for (i = 6; i < 11; i++) {
				interpolate(11, i, segments, points);
			}
			for (f = 0; f < 5; f++) {
				for (i = 1; i <= segments - 2; i++) {
					interpolate(12 + f*(segments - 1) + i, 12 + (f + 1) % 5*(segments - 1) + i, i + 1, points);
				}
			}
			for (f = 0; f < 5; f++) {
				for (i = 1; i <= segments - 2; i++) {
					interpolate(12 + (f + 15)*(segments - 1) + i, 12 + (f + 10)*(segments - 1) + i, i + 1, points);
				}
			}
			for (f = 0; f < 5; f++) {
				for (i = 1; i <= segments - 2; i++) {
					interpolate(12 + ((f + 1) % 5 + 15)*(segments - 1) + segments - 2 - i, 12 + (f + 10)*(segments - 1) + segments - 2 - i, i + 1, points);
				}
			}
			for (f = 0; f < 5; f++) {
				for (i = 1; i <= segments - 2; i++) {
					interpolate(12 + ((f + 1) % 5 + 25)*(segments - 1) + i, 12 + (f + 25)*(segments - 1) + i, i + 1, points);
				}
			}
			// Создание граней
			var face:Face;
			var surface:Surface = createSurface();
			for (f = 0; f < sections; f++) {
				for (var row:uint = 0; row < segments; row++) {
					for (var column:uint = 0; column <= row; column++) {
						var a:uint = findVertices(segments, f, row, column);
						var b:uint = findVertices(segments, f, row + 1, column);
						var c:uint = findVertices(segments, f, row + 1, column + 1);
						var va:Vertex = points[a];
						var vb:Vertex = points[b];
						var vc:Vertex = points[c];
						var aUV:Point;
						var bUV:Point;
						var cUV:Point;
						var coordA:Point3D = va._coords;
						var coordB:Point3D = vb._coords;
						var coordC:Point3D = vc._coords;
						
						if (coordA.y >= 0 && (coordA.x < 0) && (coordB.y < 0 || coordC.y < 0)) {
							aUV = new Point(Math.atan2(coordA.y, coordA.x)/MathUtils.DEG360 - 0.5, Math.asin(coordA.z/radius)/MathUtils.DEG180 + 0.5);
						} else {
							aUV = new Point(Math.atan2(coordA.y, coordA.x)/MathUtils.DEG360 + 0.5, Math.asin(coordA.z/radius)/MathUtils.DEG180 + 0.5);
						}
 						if (coordB.y >= 0 && (coordB.x < 0) && (coordA.y < 0 || coordC.y < 0)) {
							bUV = new Point(Math.atan2(coordB.y, coordB.x)/MathUtils.DEG360 - 0.5, Math.asin(coordB.z/radius)/MathUtils.DEG180 + 0.5);
						} else {
							bUV = new Point(Math.atan2(coordB.y, coordB.x)/MathUtils.DEG360 + 0.5, Math.asin(coordB.z/radius)/MathUtils.DEG180 + 0.5);
						}
						if (coordC.y >= 0 && (coordC.x < 0) && (coordA.y < 0 || coordB.y < 0)) {
							cUV = new Point(Math.atan2(coordC.y, coordC.x)/MathUtils.DEG360 - 0.5, Math.asin(coordC.z/radius)/MathUtils.DEG180 + 0.5);
						} else {
							cUV = new Point(Math.atan2(coordC.y, coordC.x)/MathUtils.DEG360 + 0.5, Math.asin(coordC.z/radius)/MathUtils.DEG180 + 0.5);
						}
    					// полюс
						if (a == 0 || a == 11) {
							aUV.x = bUV.x + (cUV.x - bUV.x)*0.5;
						}
						if (b == 0 || b == 11) {
							bUV.x = aUV.x + (cUV.x - aUV.x)*0.5;
						}
						if (c == 0 || c == 11) {
							cUV.x = aUV.x + (bUV.x - aUV.x)*0.5;
						}
  
						if (reverse) {
							face = createFace([va, vc, vb], (column << 1) + "_" + row + "_" + f);
							aUV.x = 1 - aUV.x;
							bUV.x = 1 - bUV.x;
							cUV.x = 1 - cUV.x;
							setUVsToFace(aUV, cUV, bUV, face);
						} else {
							face = createFace([va, vb, vc], (column << 1) + "_" + row + "_" + f);
 							setUVsToFace(aUV, bUV, cUV, face);
						}
						surface.addFace(face);
						//trace(a + "_" + b + "_" + c);
 						if (column < row) {
 							b = findVertices(segments, f, row, column + 1);
							var vd:Vertex = points[b];
							coordB = vd._coords;
							
							if (coordA.y >= 0 && (coordA.x < 0) && (coordB.y < 0 || coordC.y < 0)) {
								aUV = new Point(Math.atan2(coordA.y, coordA.x)/MathUtils.DEG360 - 0.5, Math.asin(coordA.z/radius)/MathUtils.DEG180 + 0.5);
							} else {
								aUV = new Point(Math.atan2(coordA.y, coordA.x)/MathUtils.DEG360 + 0.5, Math.asin(coordA.z/radius)/MathUtils.DEG180 + 0.5);
							}
	 						if (coordB.y >= 0 && (coordB.x < 0) && (coordA.y < 0 || coordC.y < 0)) {
								bUV = new Point(Math.atan2(coordB.y, coordB.x)/MathUtils.DEG360 - 0.5, Math.asin(coordB.z/radius)/MathUtils.DEG180 + 0.5);
							} else {
								bUV = new Point(Math.atan2(coordB.y, coordB.x)/MathUtils.DEG360 + 0.5, Math.asin(coordB.z/radius)/MathUtils.DEG180 + 0.5);
							}
							if (coordC.y >= 0 && (coordC.x < 0) && (coordA.y < 0 || coordB.y < 0)) {
								cUV = new Point(Math.atan2(coordC.y, coordC.x)/MathUtils.DEG360 - 0.5, Math.asin(coordC.z/radius)/MathUtils.DEG180 + 0.5);
							} else {
								cUV = new Point(Math.atan2(coordC.y, coordC.x)/MathUtils.DEG360 + 0.5, Math.asin(coordC.z/radius)/MathUtils.DEG180 + 0.5);
							}
							if (a == 0 || a == 11)  {
								aUV.x = bUV.x + (cUV.x - bUV.x)*0.5;
							}
							if (b == 0 || b == 11) {
								bUV.x = aUV.x + (cUV.x - aUV.x)*0.5;
							}
							if (c == 0 || c == 11)  {
								cUV.x = aUV.x + (bUV.x - aUV.x)*0.5;
							}
							
							if (reverse) {
								face = createFace([va, vd, vc], ((column << 1) + 1) + "_" + row + "_" + f);
								aUV.x = 1 - aUV.x;
								bUV.x = 1 - bUV.x;
								cUV.x = 1 - cUV.x;
								setUVsToFace(aUV, bUV, cUV, face);
							} else {
								face = createFace([va, vc, vd], ((column << 1) + 1) + "_" + row + "_" + f);
								setUVsToFace(aUV, cUV, bUV, face);
							}
							surface.addFace(face);
						}
 					}
				}
			}
		}

/* 		private function getUVSpherical(point:Point3D, radius:Number = 0, reverse:Boolean = false):Point {
			if (radius == 0) {
				radius = point.length;	
			}
			if (reverse) {
				var u:Number = 0.5 - Math.atan2(point.y, point.x)/MathUtils.DEG360; 
			} else {
				u = Math.atan2(point.y, point.x)/MathUtils.DEG360 + 0.5; 
			}
			return new Point(u, Math.asin(point.z/radius)/MathUtils.DEG180 + 0.5);
		}
 */
		private function interpolate(v1:uint, v2:uint, num:uint, points:Array):void {
			if (num < 2) {
				return;
			}
			var a:Vertex = Vertex(points[v1]);
			var b:Vertex = Vertex(points[v2]);
			var cos:Number = (a.x*b.x + a.y*b.y + a.z*b.z)/(a.x*a.x + a.y*a.y + a.z*a.z);
			cos = (cos < -1) ? -1 : ((cos > 1) ? 1 : cos);
			var theta:Number = Math.acos(cos);
			var sin:Number = Math.sin(theta);
			for (var e:uint = 1; e < num; e++) {
				var theta1:Number = theta*e/num;
				var theta2:Number = theta*(num - e)/num;
				var st1:Number = Math.sin(theta1);
				var st2:Number = Math.sin(theta2);
				points.push(createVertex((a.x*st2 + b.x*st1)/sin, (a.y*st2 + b.y*st1)/sin, (a.z*st2 + b.z*st1)/sin));
			}
		}

		private function findVertices(segments:uint, section:uint, row:uint, column:uint):uint {
			if (row == 0) {
				if (section < 5) {
					return (0);
				}
				if (section > 14) {
					return (11);
				}
				return (section - 4);
			}
			if (row == segments && column == 0) {
				if (section < 5) {
					return (section + 1);
				}
				if (section < 10) {
					return ((section + 4) % 5 + 6);
				}
				if (section < 15) {
					return ((section + 1) % 5 + 1);
				}
				return ((section + 1) % 5 + 6);
			}
			if (row == segments && column == segments) {
				if (section < 5) {
					return ((section + 1) % 5 + 1);
				}
				if (section < 10) {
					return (section + 1);
				}
				if (section < 15) {
					return (section - 9);
				}
				return (section - 9);
			}
			if (row == segments) {
				if (section < 5) {
					return (12 + (5 + section)*(segments - 1) + column - 1);
				}
				if (section < 10) {
					return (12 + (20 + (section + 4) % 5)*(segments - 1) + column - 1);
				}
				if (section < 15) {
					return (12 + (section - 5)*(segments - 1) + segments - 1 - column);
				}
				return (12 + (5 + section)*(segments - 1) + segments - 1 - column);
			}
			if (column == 0) {
				if (section < 5) {
					return (12 + section*(segments - 1) + row - 1);
				}
				if (section < 10) {
					return (12 + (section % 5 + 15)*(segments - 1) + row - 1);
				}
				if (section < 15) {
					return (12 + ((section + 1) % 5 + 15)*(segments - 1) + segments - 1 - row);
				}
				return (12 + ((section + 1) % 5 + 25)*(segments - 1) + row - 1);
			}
			if (column == row) {
				if (section < 5) {
					return (12 + (section + 1) % 5*(segments - 1) + row - 1);
				}
				if (section < 10) {
					return (12 + (section % 5 + 10)*(segments - 1) + row - 1);
				}
				if (section < 15) {
					return (12 + (section % 5 + 10)*(segments - 1) + segments - row - 1);
				}
				return (12 + (section % 5 + 25)*(segments - 1) + row - 1);
			}
			return (12 + 30*(segments - 1) + section*(segments - 1)*(segments - 2)/2 + (row - 1)*(row - 2)/2 + column - 1);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function createEmptyObject():Object3D {
			return new GeoSphere(0, 0);
		}

		/**
		 * @inheritDoc
		 */
		override protected function defaultName():String {
			return "geoSphere" + ++counter;
		}

	}
}
