package alternativa.engine3d.primitives {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	
	import flash.geom.Point;

	use namespace alternativa3d;

	/**
	 * Геоплоскость.
	 */
	public class GeoPlane extends Mesh {

		// Инкремент количества объектов
		private static var counter:uint = 0;

		/**
		 * Создает геоплоскость.
		 * <p>Геоплоскость это плоскость с сетчатой структурой граней.</p>
		 * <p>Примитив после создания содержит в cебе одну или две поверхности, в зависимости от значения параметров. 
		 * При значении <code>reverse</code> установленном в <code>true</code> примитив будет содержать грань - <code>"back"</code>.
		 * При значении <code>reverse</code> установленном в <code>false</code> примитив будет содержать грань - <code>"front"</code>.
		 * Параметр <code>twoSided</code> указывает методу создать обе поверхности.</p>
		 *  
		 * @param width ширина. Размерность по оси X. Не может быть меньше нуля.
		 * @param length длина. Размерность по оси Y. Не может быть меньше нуля.
		 * @param widthSegments количество сегментов по ширине
		 * @param lengthSegments количество сегментов по длине
		 * @param twoSided если значение параметра равно <code>true</code>, то создаётся двусторонняя поверхность
		 * @param reverse флаг инвертирования нормалей
		 */
		public function GeoPlane(width:Number = 100, length:Number = 100, widthSegments:uint = 1, lengthSegments:uint = 1, twoSided:Boolean = true, reverse:Boolean = false) {
			super();
			
			if ((widthSegments == 0) || (lengthSegments == 0)) {
				return;
			}
			width = (width < 0)? 0 : width;
			length = (length < 0)? 0 : length;
			
			// Середина
			var wh:Number = width/2;
			var hh:Number = length/2;
			// Размеры сегмента
			var ws:Number = width/widthSegments;
			var hs:Number = length/lengthSegments;
			
			// Размеры UV-сегмента
			var us:Number = 1/widthSegments;
			var vs:Number = 1/lengthSegments;
			
			// Создание точек
			var x:uint;
			var y:uint;
			var frontUV:Array = new Array();
			var backUV:Array = ((lengthSegments & 1) == 0) ? null : new Array();
			for (y = 0; y <= lengthSegments; y++) {
				frontUV[y] = new Array();
				if (backUV != null) {
					backUV[y] = new Array();
				}
				for (x = 0; x <= widthSegments; x++) {
					if ((y & 1) == 0) {
						// Если чётный ряд
						createVertex(x*ws - wh, y*hs - hh, 0, y + "_" + x);
						frontUV[y][x] = new Point(x*us, y*vs);
						if (backUV != null) {
							backUV[y][x] = new Point(x*us, 1 - y*vs);
						}
					} else {
						// Если нечётный ряд
						if (x == 0) {
							// Первая точка
							createVertex(-wh, y*hs - hh, 0, y + "_" + x);
							frontUV[y][x] = new Point(0, y*vs);
							if (backUV != null) {
								backUV[y][x] = new Point(0, 1 - y*vs);
							}
						} else {
							createVertex(x*ws - wh - ws/2, y*hs - hh, 0, y + "_" + x);
							frontUV[y][x] = new Point((x - 0.5)*us, y*vs);
							if (backUV != null) {
								backUV[y][x] = new Point((x - 0.5)*us, 1 - y*vs);
							}
							if (x == widthSegments) {
								// Последняя точка
								createVertex(wh, y*hs - hh, 0, y + "_" + (x + 1));
								frontUV[y][x + 1] = new Point(1, y*vs);
								if (backUV != null) {
									backUV[y][x + 1] = new Point(1, 1 - y*vs);
								}
							}
						}
					}
				}
			}

			// Создание поверхностей
			var front:Surface;
			var back:Surface;
			
			if (twoSided || !reverse) {
				front = createSurface(null, "front");
			}
			if (twoSided || reverse) {
				back = createSurface(null, "back");
			}

			// Создание полигонов
			var face:Face;
			for (y = 0; y < lengthSegments; y++) {
				for (var n:uint = 0; n <= (widthSegments << 1); n++) {
					x = n >> 1;
					if ((y & 1) == 0) {
						// Если чётный ряд
						if ((n & 1) == 0) {
							// Если остриём вверх
							if (twoSided || !reverse) {
								face = createFace([y + "_" + x, (y + 1) + "_" + (x + 1), (y + 1) + "_" + x]);
								setUVsToFace(frontUV[y][x], frontUV[y + 1][x + 1], frontUV[y + 1][x], face); 
								front.addFace(face);
							}
							if (twoSided || reverse) {
								face = createFace([y + "_" + x, (y + 1) + "_" + x, (y + 1) + "_" + (x + 1)]);
								if (backUV != null) {
									setUVsToFace(backUV[y][x], backUV[y + 1][x], backUV[y + 1][x + 1], face);
								} else {
									setUVsToFace(frontUV[lengthSegments - y][x], frontUV[lengthSegments - y - 1][x], frontUV[lengthSegments - y - 1][x + 1], face);
								}
								back.addFace(face);
							}
						} else {
							// Если остриём вниз 
							if (twoSided || !reverse) {
								face = createFace([y + "_" + x, y + "_" + (x + 1), (y + 1) + "_" + (x + 1)]);
								setUVsToFace(frontUV[y][x], frontUV[y][x + 1], frontUV[y + 1][x + 1], face);
								front.addFace(face);
							}
							if (twoSided || reverse) {
								face = createFace([y + "_" + x, (y + 1) + "_" + (x + 1), y + "_" + (x + 1)]);
								if (backUV != null) {
									setUVsToFace(backUV[y][x], backUV[y + 1][x + 1], backUV[y][x + 1], face);
								} else {
									setUVsToFace(frontUV[lengthSegments - y][x], frontUV[lengthSegments - y - 1][x + 1], frontUV[lengthSegments - y][x + 1], face);
								}
								back.addFace(face);
							}
						}
					} else {
						// Если нечётный ряд
						if ((n & 1) == 0) {
							// Если остриём вниз 
							if (twoSided || !reverse) {
								face = createFace([y + "_" + x, y + "_" + (x + 1), (y + 1) + "_" + x]);
								setUVsToFace(frontUV[y][x], frontUV[y][x + 1], frontUV[y + 1][x], face);
								front.addFace(face);
							}
							if (twoSided || reverse) {
								face = createFace([y + "_" + x, (y + 1) + "_" + x, y + "_" + (x + 1)]);
								if (backUV != null) {
									setUVsToFace(backUV[y][x], backUV[y + 1][x], backUV[y][x + 1], face);
								} else {
									setUVsToFace(frontUV[lengthSegments - y][x], frontUV[lengthSegments - y - 1][x], frontUV[lengthSegments - y][x + 1], face);
								}
								back.addFace(face);
							}
						} else {
							// Если остриём вверх
							if (twoSided || !reverse) {
								face = createFace([y + "_" + (x + 1), (y + 1) + "_" + (x + 1), (y + 1) + "_" + x]);
								setUVsToFace(frontUV[y][x+1], frontUV[y + 1][x + 1], frontUV[y + 1][x], face);
								front.addFace(face);
							}
							if (twoSided || reverse) {
								face = createFace([y + "_" + (x + 1), (y + 1) + "_" + x, (y + 1) + "_" + (x + 1)]);
								if (backUV != null) {
									setUVsToFace(backUV[y][x + 1], backUV[y + 1][x], backUV[y + 1][x + 1], face);
								} else {
									setUVsToFace(frontUV[lengthSegments - y][x + 1], frontUV[lengthSegments - y - 1][x], frontUV[lengthSegments - y - 1][x + 1], face);
								}
								back.addFace(face);
							}
						}
					}
				}
			}
			
		}

		/**
		 * @inheritDoc
		 */		
		protected override function createEmptyObject():Object3D {
			return new GeoPlane(0, 0, 0);
		}

		/**
		 * @inheritDoc
		 */
		override protected function defaultName():String {
			return "geoPlane" + ++counter;
		}

	}
}
