package alternativa.engine3d.primitives {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.core.Vertex;
	import alternativa.utils.MathUtils;
	
	import flash.geom.Point;
	
	use namespace alternativa3d;
	
	/**
	 * Усеченный конус или цилиндр.
	 */
	public class Cone extends Mesh {

		// Инкремент количества объектов
		private static var counter:uint = 0;

		/**
		 * Создает усеченный конус или цилиндр.
		 * <p>Различные значения параметров позволяют создавать различные примитивы. 
		 * При установленном параметре <code>topRadius = 0</code> или <code>bottomRadius = 0</code> будет построен конус. При установленном </code>bottomRadius = topRadius</code> будет построен цилиндр.</p>
		 * <p>По умолчанию параметр <code>triangulate</code> установлен в <code>false</code> и на примитив не может быть наложена текстура. 
		 * Только при установленном параметре <code>triangulate</code> в <code>true</code> это возможно.</p>
		 * <p>После создания примитив всегда содержит в себе поверхность <code>"side"</code>.
		 * При установленном параметре <code>bottomRadius</code> не равном нулю в примитиве создается поверхность <code>"bottom"</code>, 
		 * при установленном параметре <code>topRadius</code> в примитиве создается поверхность <code>"top"</code>.
		 * На каждую из поверхностей может быть наложен свой материал</p>
		 * 
		 * @param height высота примтива. Размерность по оси Z. Не может быть меньше нуля.
		 * @param bottomRadius нижний радиус примитива
		 * @param topRadius верхний радиус примтива
		 * @param heightSegments количество сегментов по высоте примитива
		 * @param radialSegments количество сегментов по радиусу примтива
		 * @param reverse задает направление нормалей. При значении <code>true</code> нормли будут направлены внутрь примитива.
		 * @param triangulate флаг триангуляции. При значении <code>true</code> все четырехугольные грани примитива будут триангулированы
		 * и появится возможность наложить на примитив текстуру.
		 */
		public function Cone(height:Number = 100, bottomRadius:Number = 100, topRadius:Number = 0, heightSegments:uint = 1, radialSegments:uint = 12, reverse:Boolean = false, triangulate:Boolean = false) {

			if ((radialSegments < 3) || (heightSegments < 1) || (heightSegments == 1 && topRadius == 0 && bottomRadius == 0)) {
				return;
			}
			height = (height < 0)? 0 : height;
			bottomRadius = (bottomRadius < 0)? 0 : bottomRadius;
			topRadius = (topRadius < 0)? 0 : topRadius;

			const radialSegment:Number = MathUtils.DEG360/radialSegments;
			const radiusSegment:Number = (bottomRadius - topRadius)/heightSegments;
			const heightSegment:Number = height/heightSegments;
			const halfHeight:Number = height*0.5
			const uSegment:Number = 1/radialSegments;
			const vSegment:Number = 1/heightSegments;
			
			// Создание вершин
			if (topRadius == 0 || triangulate) {
				var poleUp:Vertex = createVertex(0, 0, halfHeight, "poleUp");
			}
			if (bottomRadius == 0 || triangulate) {
				var poleDown:Vertex = createVertex(0, 0, -halfHeight, "poleDown");
			}

			var radial:uint;
			var segment:uint;

			var topSegment:uint = heightSegments - int(topRadius == 0);
			var bottomSegment:uint = int(bottomRadius == 0) ;
			for (segment = bottomSegment; segment <= topSegment; segment++) {
				for (radial = 0; radial < radialSegments; radial++) {
					var currentAngle:Number = radialSegment*radial;
					var currentRadius:Number = bottomRadius - (radiusSegment*segment);
					createVertex(Math.cos(currentAngle)*currentRadius, Math.sin(currentAngle)*currentRadius, heightSegment*segment - halfHeight, radial + "_" + segment);
				}
			}

			// Создание граней и поверхности
			var face:Face;

			var points:Array;

 			var side:Surface = createSurface(null, "side");

			if (topRadius == 0) {
				// Создание граней у верхнего полюса
				var prevRadial:uint = radialSegments - 1;
				var centerUV:Point = new Point(0.5, 1); 
 				var v:Number =  topSegment*vSegment;
 				if (reverse) {
					for (radial = 0; radial < radialSegments; radial++) {
						face = createFace([poleUp, radial + "_" + topSegment, prevRadial + "_" + topSegment], prevRadial + "_" + topSegment);
						if (triangulate) {
							setUVsToFace(centerUV, new Point(1 - (prevRadial + 1)*uSegment, v) , new Point(1 - prevRadial*uSegment, v), face);
						}
						side.addFace(face);
						prevRadial = radial;
					}
				} else  {
					for (radial = 0; radial < radialSegments; radial++) {
						face = createFace([poleUp, prevRadial + "_" + topSegment, radial + "_" + topSegment], prevRadial + "_" + topSegment);
						if (triangulate) {
							setUVsToFace(centerUV, new Point(prevRadial*uSegment, v), new Point((prevRadial + 1)*uSegment, v), face);
						}
						side.addFace(face);
						prevRadial = radial;
					}
				}
 			} else {
				// Создание граней верхней крышки
				var top:Surface = createSurface(null, "top");
				if (triangulate) {
					prevRadial = radialSegments - 1; 
					centerUV = new Point(0.5, 0.5);
					var UV:Point;
					var prevUV:Point;
 					if (reverse) {
						prevUV = new Point(0.5 - Math.cos(-radialSegment)*0.5, Math.sin(-radialSegment)*0.5 + 0.5);
						for (radial = 0; radial < radialSegments; radial++) {
							face = createFace([poleUp, radial + "_" + topSegment, prevRadial + "_" + topSegment], "top_" + prevRadial);
							currentAngle = radial * radialSegment;
							UV = new Point(0.5 - Math.cos(currentAngle)*0.5, Math.sin(currentAngle)*0.5 + 0.5);
							setUVsToFace(centerUV, UV, prevUV, face); 
							top.addFace(face);
							prevUV = UV;
							prevRadial = radial;
						}
					} else  {
 						prevUV = new Point(Math.cos(-radialSegment)*0.5 + 0.5, Math.sin(-radialSegment)*0.5 + 0.5);
						for (radial = 0; radial < radialSegments; radial++) {
							face = createFace([poleUp, prevRadial + "_" + topSegment, radial + "_" + topSegment], "top_" + prevRadial);
							currentAngle = radial*radialSegment;
							UV = new Point(Math.cos(currentAngle)*0.5 + 0.5, Math.sin(currentAngle)*0.5 + 0.5); 							
							setUVsToFace(centerUV, prevUV, UV, face); 
							top.addFace(face);
							prevUV = UV;
							prevRadial = radial;
						}
					}
   				} else {
					points = new Array();
					if (reverse) {
						for (radial = (radialSegments - 1); radial < uint(-1); radial--) {
							points.push(radial + "_" + topSegment);
						}
					} else {
						for (radial = 0; radial < radialSegments; radial++) {
							points.push(radial + "_" + topSegment);
						}
					}
					top.addFace(createFace(points, "top"));
				}
			}
			// Создание боковых граней
			var face2:Face;
			var aUV:Point;
			var cUV:Point;
			for (segment = bottomSegment; segment < topSegment; segment++) {
				prevRadial = radialSegments - 1;
				v = segment * vSegment;
				for (radial = 0; radial < radialSegments; radial++) {
					if (triangulate) {
						if (reverse) {
							face = createFace([radial + "_" + (segment + 1), radial + "_" + segment, prevRadial + "_" + segment], prevRadial + "_" + segment + ":0");
							face2 = createFace([prevRadial + "_" + segment, prevRadial + "_" + (segment + 1), radial + "_" + (segment + 1)], prevRadial + "_" + segment + ":1");
							aUV = new Point(1 - (prevRadial + 1)*uSegment, v + vSegment)
							cUV = new Point(1 - prevRadial*uSegment, v);
							setUVsToFace(aUV, new Point(1 - (prevRadial + 1)*uSegment, v), cUV, face);
							setUVsToFace(cUV, new Point(1 - prevRadial*uSegment, v + vSegment), aUV, face2); 
						} else {
							face = createFace([prevRadial + "_" + segment, radial + "_" + segment, radial + "_" + (segment + 1)], prevRadial + "_" + segment + ":0");
							face2 = createFace([radial + "_" + (segment + 1), prevRadial + "_" + (segment + 1), prevRadial + "_" + segment], prevRadial + "_" + segment + ":1");
							aUV = new Point(prevRadial*uSegment, v)
							cUV = new Point((prevRadial + 1)*uSegment, v + vSegment);
							setUVsToFace(aUV, new Point((prevRadial + 1)*uSegment, v), cUV, face);
							setUVsToFace(cUV, new Point(prevRadial*uSegment, v + vSegment), aUV, face2); 
						}
						side.addFace(face);
						side.addFace(face2);
					} else {
						if (reverse) {
							side.addFace(createFace([prevRadial + "_" + segment, prevRadial + "_" + (segment + 1), radial + "_" + (segment + 1), radial + "_" + segment], prevRadial + "_" + segment));
						} else {
							side.addFace(createFace([prevRadial + "_" + segment, radial + "_" + segment, radial + "_" + (segment + 1), prevRadial + "_" + (segment + 1)], prevRadial + "_" + segment));
						}
					}
					prevRadial = radial;
				}
			}
			
			if (bottomRadius == 0) {
				// Создание граней у нижнего полюса
				prevRadial = radialSegments - 1; 
				centerUV = new Point(0.5, 0);
 				v =  bottomSegment*vSegment;
 				if (reverse) {
					for (radial = 0; radial < radialSegments; radial++) {
						face = createFace([poleDown, prevRadial + "_" + bottomSegment, radial + "_" + bottomSegment], prevRadial + "_0");
						if (triangulate) {
							setUVsToFace(centerUV, new Point(1 - prevRadial*uSegment, v), new Point(1 - (prevRadial + 1)*uSegment, v), face);
						}
						side.addFace(face);
						prevRadial = radial;
					}
				} else  {
					for (radial = 0; radial < radialSegments; radial++) {
						face = createFace([poleDown, radial + "_" + bottomSegment, prevRadial + "_" + bottomSegment], prevRadial + "_0");
						if (triangulate) {
							setUVsToFace(centerUV, new Point((prevRadial + 1)*uSegment, v), new Point(prevRadial*uSegment, v), face);
						}
						side.addFace(face);
						prevRadial = radial;
					}
				}
 			} else {
				// Создание граней нижней крышки
				var bottom:Surface = createSurface(null, "bottom");
				if (triangulate) {
					prevRadial = radialSegments - 1; 
					centerUV = new Point(0.5, 0.5);
 					if (reverse) {
 						prevUV = new Point(Math.cos(-radialSegment)*0.5 + 0.5, Math.sin(-radialSegment)*0.5 + 0.5);
						for (radial = 0; radial < radialSegments; radial++) {
							face = createFace([poleDown, prevRadial + "_" + bottomSegment, radial + "_" + bottomSegment], "bottom_" + prevRadial);
							currentAngle = radial*radialSegment;
							UV = new Point(Math.cos(currentAngle)*0.5 + 0.5, Math.sin(currentAngle)*0.5 + 0.5); 							
							setUVsToFace(centerUV, prevUV, UV, face); 
							bottom.addFace(face);
							prevUV = UV;
							prevRadial = radial;
						}
					} else  {
						prevUV = new Point(0.5 - Math.cos(-radialSegment)*0.5, Math.sin(-radialSegment)*0.5 + 0.5);
						for (radial = 0; radial < radialSegments; radial++) {
							face = createFace([poleDown, radial + "_" + bottomSegment, prevRadial + "_" + bottomSegment], "bottom_" + prevRadial);
							currentAngle = radial * radialSegment;
							UV = new Point(0.5 - Math.cos(currentAngle)*0.5, Math.sin(currentAngle)*0.5 + 0.5);
							setUVsToFace(centerUV, UV, prevUV, face); 
							bottom.addFace(face);
							prevUV = UV;
							prevRadial = radial;
						}
					}
   				} else {
					points = new Array();
					if (reverse) {
						for (radial = 0; radial < radialSegments; radial++) {
							points.push(radial + "_" + bottomSegment);
						}
					} else {
						for (radial = (radialSegments - 1); radial < uint(-1); radial--) {
							points.push(radial + "_" + bottomSegment);
						}
					}
					bottom.addFace(createFace(points, "bottom"));
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		protected override function createEmptyObject():Object3D {
			return new Cone(0, 0, 0, 0);
		}

		/**
		 * @inheritDoc
		 */
		override protected function defaultName():String {
			return "cone" + ++counter;
		}

	}
}
