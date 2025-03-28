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
	 * Сфера.
	 */
	public class Sphere extends Mesh {

		// Инкремент количества объектов
		private static var counter:uint = 0;

		/**
		 * Создает сферу.
		 * <p>После создания примитив содержит в себе одну поверхность с идентификатором по умолчанию.</p>
		 * <p>По умолчанию параметр <code>triangulate</code> установлен в <code>false</code> и на сферу нельзя наложить текстуру. 
		 * Только при установленном <code>triangulate</code> в <code>true</code> это возможно.</p>
		 * 
		 * @param radius Радиус сферы. Не может быть меньше нуля.
		 * @param radialSegments количество сегментов по экватору сферы
		 * @param heightSegments количество сегментов по высоте
		 * @param reverse флаг инвертирования нормалей. При параметре установленном в <code>true</code> нормали направлены внутрь сферы.
		 * @param triangulate флаг триангуляции. Если указано значение <code>true</code>, грани будут триангулированы,
		 *  и будет возможно наложить на примитив текстуру.
		 */
		public function Sphere(radius:Number = 100, radialSegments:uint = 8, heightSegments:uint = 8, reverse:Boolean = false, triangulate:Boolean = false) {
			if ((radialSegments < 3) || (heightSegments < 2)) {
				return;
			}
			radius = (radius < 0)? 0 : radius;

			var poleUp:Vertex = createVertex(0, 0, radius, "poleUp");
			var poleDown:Vertex = createVertex(0, 0, -radius, "poleDown");

			const radialAngle:Number = MathUtils.DEG360/radialSegments;
			const heightAngle:Number = MathUtils.DEG360/(heightSegments << 1);

			var radial:uint;
			var segment:uint;

			// Создание вершин 
			for (segment = 1; segment < heightSegments; segment++) {
				var currentHeightAngle:Number = heightAngle*segment;
				var segmentRadius:Number = Math.sin(currentHeightAngle)*radius;
				var segmentZ:Number = Math.cos(currentHeightAngle)*radius;
				for (radial = 0; radial < radialSegments; radial++) {
					var currentRadialAngle:Number = radialAngle*radial;
					createVertex(-Math.sin(currentRadialAngle)*segmentRadius, Math.cos(currentRadialAngle)*segmentRadius, segmentZ, radial + "_" + segment);
				}
			}

			// Создание граней и поверхности
			var surface:Surface = createSurface();

			var prevRadial:uint = radialSegments - 1; 
			var lastSegmentString:String = "_" + (heightSegments - 1);
			
			var uStep:Number = 1/radialSegments;
			var vStep:Number = 1/heightSegments;
			
			var face:Face;
			
			// Для триангуляции
			var aUV:Point;
			var cUV:Point;

			var u:Number;

			if (reverse) {
				for (radial = 0; radial < radialSegments; radial++) {
					// Грани верхнего полюса
					surface.addFace(createFace([poleUp, radial + "_1", prevRadial + "_1"], prevRadial + "_0"));
					// Грани нижнего полюса
					surface.addFace(createFace([radial + lastSegmentString, poleDown, prevRadial + lastSegmentString], prevRadial + lastSegmentString));
	
					// Если включена триангуляция 
					if (triangulate) {
						// Триангулируем середину и просчитываем маппинг
						u = uStep*prevRadial;
						setUVsToFace(new Point(1 - u, 1), new Point(1 - u - uStep, 1 - vStep), new Point(1 - u, 1 - vStep), prevRadial + "_0");
						// Грани середки
						for (segment = 1; segment < (heightSegments - 1); segment++) {
							aUV = new Point(1 - u - uStep, 1 - (vStep*(segment + 1)));
							cUV = new Point(1 - u, 1 - vStep*segment);
							surface.addFace(createFace([radial + "_" + (segment + 1), prevRadial + "_" + (segment + 1), prevRadial + "_" + segment], prevRadial + "_" + segment + ":0"));
							surface.addFace(createFace([prevRadial + "_" + segment, radial + "_" + segment, radial + "_" + (segment + 1)], prevRadial + "_" + segment + ":1"));
							setUVsToFace(aUV, new Point(1 - u, 1 - (vStep*(segment + 1))), cUV, prevRadial + "_" + segment + ":0");
							setUVsToFace(cUV, new Point(1 - u - uStep, 1 - (vStep*segment)), aUV, prevRadial + "_" + segment + ":1"); 
						}
						setUVsToFace(new Point(1 - u - uStep, vStep), new Point(1 - u, 0), new Point(1 - u, vStep), prevRadial + lastSegmentString); 

					} else {
						// Просто создаем середину
						// Грани середки
						for (segment = 1; segment < (heightSegments - 1); segment++) {
							surface.addFace(createFace([radial + "_" + (segment + 1), prevRadial + "_" + (segment + 1), prevRadial + "_" + segment, radial + "_" + segment], prevRadial + "_" + segment));
						}
					}
					prevRadial = (radial == 0) ? 0 : prevRadial + 1;
				}
			} else {
				for (radial = 0; radial < radialSegments; radial++) {
					// Грани верхнего полюса
					surface.addFace(createFace([poleUp, prevRadial + "_1", radial + "_1"], prevRadial + "_0"));
					// Грани нижнего полюса
					surface.addFace(createFace([prevRadial + lastSegmentString, poleDown, radial + lastSegmentString], prevRadial + lastSegmentString));

					if (triangulate) {
						u = uStep*prevRadial;
						setUVsToFace(new Point(u, 1), new Point(u, 1 - vStep), new Point(u + uStep, 1 - vStep), prevRadial + "_0");
						// Грани середки
						for (segment = 1; segment < (heightSegments - 1); segment++) {
							aUV = new Point(u, 1 - (vStep*segment));
							cUV = new Point(u + uStep, 1 - vStep * (segment + 1));
							surface.addFace(createFace([prevRadial + "_" + segment, prevRadial + "_" + (segment + 1), radial + "_" + (segment + 1)], prevRadial + "_" + segment + ":0"));
							surface.addFace(createFace([radial + "_" + (segment + 1), radial + "_" + segment, prevRadial + "_" + segment], prevRadial + "_" + segment + ":1"));
							setUVsToFace(aUV, new Point(u, 1 - (vStep*(segment + 1))), cUV, prevRadial + "_" + segment + ":0");
							setUVsToFace(cUV, new Point(u + uStep, 1 - (vStep*segment)), aUV, prevRadial + "_" + segment + ":1"); 
						}
						setUVsToFace(new Point(u, vStep), new Point(u, 0), new Point(u + uStep, vStep), prevRadial + lastSegmentString); 
					} else {
						// Грани середки
						for (segment = 1; segment < (heightSegments - 1); segment++) {
							surface.addFace(createFace([prevRadial + "_" + segment, prevRadial + "_" + (segment + 1), radial + "_" + (segment + 1), radial + "_" + segment], prevRadial + "_" + segment));
						}
					}
					prevRadial = (radial == 0) ? 0 : prevRadial + 1;
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		protected override function createEmptyObject():Object3D {
			return new Sphere(0, 0);
		}

		/**
		 * @inheritDoc
		 */
		override protected function defaultName():String {
			return "sphere" + ++counter;
		}

	}
}
