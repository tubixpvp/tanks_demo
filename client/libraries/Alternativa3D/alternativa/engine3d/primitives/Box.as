package alternativa.engine3d.primitives {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	
	import flash.geom.Point;
	
	use namespace alternativa3d;
	
	/**
	 * Прямоугольный параллелепипед.
	 * <p>Параллелепипед содержит шесть поверхностей с идентификаторами <code>"front"</code>, <code>"back"</code>, <code>"left"</code>,
	 * <code>"right"</code>, <code>"top"</code>, <code>"bottom"</code>, на каждую из которых может быть установлен свой материал.
	 * </p>
	 */
	public class Box extends Mesh {

		// Инкремент количества объектов
		private static var counter:uint = 0;

		/**
		 * Создание нового параллелепипеда. 
		 * 
		 * @param width ширина. Размерность по оси X. Не может быть меньше нуля.
		 * @param length длина. Размерность по оси Y. Не может быть меньше нуля.
		 * @param height высота. Размерность по оси Z. Не может быть меньше нуля.
		 * @param widthSegments количество сегментов по ширине
		 * @param lengthSegments количество сегментов по длине
		 * @param heightSegments количество сегментов по по высоте
		 * @param reverse задает направление нормалей граней. Если указано значение <code>true</code>, то нормали будут направлены внутрь фигуры.
		 * @param triangulate флаг триангуляции. Если указано значение <code>true</code>, четырехугольники в параллелепипеде будут триангулированы.
		 */
		public function Box(width:Number = 100, length:Number = 100, height:Number = 100, widthSegments:uint = 1, lengthSegments:uint = 1, heightSegments:uint = 1, reverse:Boolean = false, triangulate:Boolean = false) {
			super();
			
			if ((widthSegments == 0) || (lengthSegments == 0) || (heightSegments == 0)) {
				return;
			}
			width = (width < 0)? 0 : width;
			length = (length < 0)? 0 : length;
			height = (height < 0)? 0 : height;
			
			var wh:Number = width/2;
			var lh:Number = length/2;
			var hh:Number = height/2;
			var ws:Number = width/widthSegments;
			var ls:Number = length/lengthSegments;
			var hs:Number = height/heightSegments;
			var x:int;
			var y:int;
			var z:int;
			
			// Создание точек
			for (x = 0; x <= widthSegments; x++) {
				for (y = 0; y <= lengthSegments; y++) {
					for (z = 0; z <= heightSegments; z++) {
						if (x == 0 || x == widthSegments || y == 0 || y == lengthSegments || z == 0 || z == heightSegments) {
							createVertex(x*ws - wh, y*ls - lh, z*hs - hh, x + "_" + y + "_" + z);
						}
					}
				}
			}
			
			// Создание поверхностей
			var front:Surface = createSurface(null, "front");
			var back:Surface = createSurface(null, "back");
			var left:Surface = createSurface(null, "left");
			var right:Surface = createSurface(null, "right");
			var top:Surface = createSurface(null, "top");
			var bottom:Surface = createSurface(null, "bottom");

			// Создание граней
			var wd:Number = 1/widthSegments;
			var ld:Number = 1/lengthSegments;
			var hd:Number = 1/heightSegments;
			var faceId:String;
			
			// Для оптимизаций UV при триангуляции
			var aUV:Point;
			var cUV:Point;
			
			// Построение верхней грани
			for (y = 0; y < lengthSegments; y++) {
				for (x = 0; x < widthSegments; x++) {
					faceId = "top_"+x+"_"+y;
					if (reverse) {
						if (triangulate) {
							aUV = new Point(x*wd, (lengthSegments - y)*ld);
							cUV = new Point((x + 1)*wd, (lengthSegments - y - 1)*ld);
							createFace([x + "_" + y + "_" + heightSegments, x + "_" + (y + 1) + "_" + heightSegments, (x + 1) + "_" + (y + 1) + "_" + heightSegments], faceId + ":1");
							setUVsToFace(aUV, new Point(x*wd, (lengthSegments - y - 1)*ld), cUV, faceId + ":1");
							createFace([(x + 1) + "_" + (y + 1) + "_" + heightSegments, (x + 1) + "_" + y + "_" + heightSegments, x + "_" + y + "_" + heightSegments], faceId + ":0");
							setUVsToFace(cUV, new Point((x + 1)*wd, (lengthSegments - y)*ld), aUV, faceId + ":0");
						} else {
							createFace([x + "_" + y + "_" + heightSegments, x + "_" + (y + 1) + "_" + heightSegments, (x + 1) + "_" + (y + 1) + "_" + heightSegments, (x + 1) + "_" + y + "_" + heightSegments], faceId);
							setUVsToFace(new Point(x*wd, (lengthSegments - y)*ld), new Point(x*wd, (lengthSegments - y - 1)*ld), new Point((x + 1)*wd, (lengthSegments - y - 1)*ld), faceId);
						}
					} else {
						if (triangulate) {
							aUV = new Point(x*wd, y*ld);
							cUV = new Point((x + 1)*wd, (y + 1)*ld);
							createFace([x + "_" + y + "_" + heightSegments, (x + 1) + "_" + y + "_" + heightSegments, (x + 1) + "_" + (y + 1) + "_" + heightSegments], faceId + ":0");
							setUVsToFace(aUV, new Point((x + 1)*wd, y*ld), cUV, faceId + ":0");
							createFace([(x + 1) + "_" + (y + 1) + "_" + heightSegments, x + "_" + (y + 1) + "_" + heightSegments, x + "_" + y + "_" + heightSegments], faceId + ":1");
							setUVsToFace(cUV, new Point(x*wd, (y + 1)*ld), aUV, faceId + ":1");
						} else {
							createFace([x + "_" + y + "_" + heightSegments, (x + 1) + "_" + y + "_" + heightSegments, (x + 1) + "_" + (y + 1) + "_" + heightSegments, x + "_" + (y + 1) + "_" + heightSegments], faceId);
							setUVsToFace(new Point(x*wd, y*ld), new Point((x + 1)*wd, y*ld), new Point((x + 1)*wd, (y + 1)*ld), faceId);
						}
					}
					if (triangulate) {
						top.addFace(faceId + ":0");
						top.addFace(faceId + ":1");
					} else {
						top.addFace(faceId);
					}
				}
			}
			
			// Построение нижней грани
			for (y = 0; y < lengthSegments; y++) {
				for (x = 0; x < widthSegments; x++) {
					faceId = "bottom_" + x + "_" + y;
					if (reverse) {
						if (triangulate) {
							aUV = new Point((widthSegments - x)*wd, (lengthSegments - y)*ld);
							cUV = new Point((widthSegments - x - 1)*wd, (lengthSegments - y - 1)*ld);
							createFace([x + "_" + y + "_" + 0, (x + 1) + "_" + y + "_" + 0, (x + 1) + "_" + (y + 1) + "_" + 0], faceId + ":0");
							setUVsToFace(aUV, new Point((widthSegments - x - 1)*wd, (lengthSegments - y)*ld), cUV, faceId + ":0");
							createFace([(x + 1) + "_" + (y + 1) + "_" + 0, x + "_" + (y + 1) + "_" + 0, x + "_" + y + "_" + 0], faceId + ":1");
							setUVsToFace(cUV, new Point((widthSegments - x)*wd, (lengthSegments - y - 1)*ld), aUV, faceId + ":1");
						} else {
							createFace([x + "_" + y + "_"+0, (x + 1) + "_" + y + "_" + 0, (x + 1) + "_" + (y + 1) + "_" + 0, x + "_" + (y + 1) + "_" + 0], faceId);
							setUVsToFace(new Point((widthSegments - x)*wd, (lengthSegments - y)*ld), new Point((widthSegments - x - 1)*wd, (lengthSegments - y)*ld), new Point((widthSegments - x - 1)*wd, (lengthSegments - y - 1)*ld), faceId);
						}
					} else {
						if (triangulate) {
							aUV = new Point((widthSegments - x)*wd, y*ld);
							cUV = new Point((widthSegments - x - 1)*wd, (y + 1)*ld);
							createFace([x + "_" + y + "_" + 0, x + "_" + (y + 1) + "_" + 0, (x + 1) + "_" + (y + 1) + "_" + 0], faceId + ":1");
							setUVsToFace(aUV, new Point((widthSegments - x)*wd, (y + 1)*ld), cUV, faceId + ":1");
							createFace([(x + 1) + "_" + (y + 1) + "_" + 0, (x + 1) + "_" + y + "_" + 0, x + "_" + y + "_" + 0], faceId + ":0");
							setUVsToFace(cUV, new Point((widthSegments - x - 1)*wd, y*ld), aUV, faceId + ":0");
						} else {
							createFace([x + "_" + y + "_" + 0, x + "_" + (y + 1) +"_" + 0, (x + 1) + "_" + (y + 1) + "_" + 0, (x + 1) + "_" + y + "_" + 0], faceId);
							setUVsToFace(new Point((widthSegments - x)*wd, y*ld), new Point((widthSegments - x)*wd, (y + 1)*ld), new Point((widthSegments - x - 1)*wd, (y + 1)*ld), faceId);
						}
					}
					if (triangulate) {
						bottom.addFace(faceId + ":0");
						bottom.addFace(faceId + ":1");
					} else {
						bottom.addFace(faceId);
					}
				}
			}
			
			// Построение фронтальной грани
			for (z = 0; z < heightSegments; z++) {
				for (x = 0; x < widthSegments; x++) {
					faceId = "front_"+x+"_"+z;
					if (reverse) {
						if (triangulate) {
							aUV = new Point((widthSegments - x)*wd, z*hd);
							cUV = new Point((widthSegments - x - 1)*wd, (z + 1)*hd);
							createFace([x + "_" + 0 + "_" + z, x + "_" + 0 + "_" + (z + 1), (x + 1) + "_" + 0 + "_" + (z + 1)], faceId + ":1");
							setUVsToFace(aUV, new Point((widthSegments - x)*wd, (z + 1)*hd), cUV, faceId + ":1");
							createFace([(x + 1) + "_" + 0 + "_" + (z + 1), (x + 1) + "_" + 0 + "_" + z, x + "_" + 0 + "_" + z], faceId + ":0");
							setUVsToFace(cUV, new Point((widthSegments - x - 1)*wd, z*hd), aUV, faceId + ":0");
						} else {
							createFace([x + "_" + 0 + "_" + z, x + "_" + 0 + "_" + (z + 1), (x + 1) + "_" + 0 + "_" + (z + 1), (x + 1) + "_" + 0 + "_" + z], faceId);
							setUVsToFace(new Point((widthSegments - x)*wd, z*hd), new Point((widthSegments - x)*wd, (z + 1)*hd), new Point((widthSegments - x - 1)*wd, (z + 1)*hd), faceId);
						}
					} else {
						if (triangulate) {
							aUV = new Point(x*wd, z*hd);
							cUV = new Point((x + 1)*wd, (z + 1)*hd);
							createFace([x + "_" + 0 + "_" + z, (x + 1) + "_" + 0 + "_" + z, (x + 1) + "_" + 0 + "_" + (z + 1)], faceId + ":0");
							setUVsToFace(aUV, new Point((x + 1)*wd, z*hd), cUV, faceId + ":0");
							createFace([(x + 1) + "_" + 0 + "_" + (z + 1), x + "_" + 0 + "_" + (z + 1), x + "_" + 0 + "_" + z], faceId + ":1");
							setUVsToFace(cUV, new Point(x*wd, (z + 1)*hd), aUV, faceId + ":1");
						} else {
							createFace([x + "_" + 0 + "_" + z, (x + 1) + "_" + 0 + "_" + z, (x + 1) + "_" + 0 + "_" + (z + 1), x + "_" + 0 + "_" + (z + 1)], faceId);
							setUVsToFace(new Point(x*wd, z*hd), new Point((x + 1)*wd, z*hd), new Point((x + 1)*wd, (z + 1)*hd), faceId);
						}
					}
					if (triangulate) {
						front.addFace(faceId + ":0");
						front.addFace(faceId + ":1");
					} else {
						front.addFace(faceId);
					}
				}
			}

			// Построение задней грани
			for (z = 0; z < heightSegments; z++) {
				for (x = 0; x < widthSegments; x++) {
					faceId = "back_"+x+"_"+z;
					if (reverse) {
						if (triangulate) {
							aUV = new Point(x * wd, (z + 1) * hd);
							cUV = new Point((x + 1) * wd, z * hd);
							createFace([x + "_" + lengthSegments+"_" + (z + 1), x + "_"+lengthSegments + "_" + z, (x + 1) + "_" + lengthSegments + "_" + z], faceId + ":0");
							setUVsToFace(aUV, new Point(x * wd, z * hd), cUV, faceId + ":0");
							createFace([(x + 1) + "_" + lengthSegments + "_" + z, (x + 1) + "_" + lengthSegments + "_" + (z + 1), x + "_" + lengthSegments + "_" + (z + 1)], faceId + ":1");
							setUVsToFace(cUV, new Point((x + 1) * wd, (z + 1) * hd), aUV, faceId + ":1");
						} else {
							createFace([x + "_" + lengthSegments + "_" + z, (x + 1) + "_" + lengthSegments + "_" + z, (x + 1) + "_" + lengthSegments + "_" + (z + 1), x + "_" + lengthSegments + "_" + (z + 1)], faceId);
							setUVsToFace(new Point(x*wd, z*hd), new Point((x + 1)*wd, z*hd), new Point((x + 1)*wd, (z + 1)*hd), faceId);
						}
					} else {
						if (triangulate) {
							aUV = new Point((widthSegments - x)*wd, (z + 1)*hd);
							cUV = new Point((widthSegments - x - 1)*wd, z*hd);
							createFace([x + "_" + lengthSegments + "_" + z, x + "_" + lengthSegments + "_" + (z + 1), (x + 1) + "_" + lengthSegments + "_" + z], faceId + ":0");
							setUVsToFace(new Point((widthSegments - x)*wd, z*hd), aUV, cUV, faceId + ":0");
							createFace([x + "_" + lengthSegments + "_" + (z + 1), (x + 1) + "_" + lengthSegments + "_" + (z + 1), (x + 1) + "_" + lengthSegments + "_" + z], faceId + ":1");
							setUVsToFace(aUV, new Point((widthSegments - x - 1)*wd, (z + 1)*hd), cUV, faceId + ":1");
						} else {
							createFace([x + "_" + lengthSegments + "_" + z, x + "_" + lengthSegments + "_" + (z + 1), (x + 1) + "_" + lengthSegments + "_" + (z + 1), (x + 1) + "_" + lengthSegments + "_" + z], faceId);
							setUVsToFace(new Point((widthSegments - x)*wd, z*hd), new Point((widthSegments - x)*wd, (z + 1)*hd), new Point((widthSegments - x - 1)*wd, (z + 1)*hd), faceId);
						}
					}
					if (triangulate) {
						back.addFace(faceId + ":0");
						back.addFace(faceId + ":1");
					} else {
						back.addFace(faceId);
					}
				}
			}

			// Построение левой грани
			for (y = 0; y < lengthSegments; y++) {
				for (z = 0; z < heightSegments; z++) {
					faceId = "left_" + y + "_" + z;
					if (reverse) {
						if (triangulate) {
							aUV = new Point(y*ld, (z + 1)*hd);
							cUV = new Point((y + 1)*ld, z*hd);
							createFace([0 + "_" + y + "_" + (z + 1), 0 + "_" + y + "_" + z, 0 + "_" + (y + 1) + "_" + z], faceId + ":0");
							setUVsToFace(aUV, new Point(y*ld, z*hd), cUV, faceId + ":0");
							createFace([0 + "_" + (y + 1) + "_" + z, 0 + "_" + (y + 1) + "_" + (z + 1), 0 + "_" + y + "_" + (z + 1)], faceId + ":1");
							setUVsToFace(cUV, new Point((y + 1)*ld, (z + 1)*hd), aUV, faceId + ":1");
						} else {
							createFace([0 + "_" + y + "_" + z, 0 + "_" + (y + 1) + "_" + z, 0 + "_" + (y + 1) + "_" + (z + 1), 0 + "_" + y + "_" + (z + 1)], faceId);
							setUVsToFace(new Point(y*ld, z*hd), new Point((y + 1)*ld, z*hd), new Point((y + 1)*ld, (z + 1)*hd), faceId);
						}
					} else {
						if (triangulate) {
							aUV = new Point((lengthSegments - y - 1)*ld, z*hd);
							cUV = new Point((lengthSegments - y)*ld, (z + 1)*hd);
							createFace([0 + "_" + (y + 1) + "_" + z, 0 + "_" + y + "_" + z, 0 + "_" + y + "_" + (z + 1)], faceId + ":0");
							setUVsToFace(aUV, new Point((lengthSegments - y)*ld, z*hd), cUV, faceId + ":0");
							createFace([0 + "_" + y + "_" + (z + 1), 0 + "_" + ((y + 1)) + "_" + (z + 1), 0 + "_" + (y + 1) + "_" + z], faceId + ":1");
							setUVsToFace(cUV, new Point((lengthSegments - y - 1)*ld, (z + 1)*hd), aUV, faceId + ":1");
						} else {
							createFace([0 + "_" + y + "_" + z, 0 + "_" + y + "_" + (z + 1), 0 + "_" + ((y + 1)) + "_" + (z + 1), 0 + "_" + ((y + 1)) + "_" + z], faceId);
							setUVsToFace(new Point((lengthSegments - y)*ld, z*hd), new Point((lengthSegments - y)*ld, (z + 1)*hd), new Point((lengthSegments - y - 1)*ld, (z + 1)*hd), faceId);
						}
					}
					if (triangulate) {
						left.addFace(faceId + ":0");
						left.addFace(faceId + ":1");
					} else {
						left.addFace(faceId);
					}
				}
			}
			
			// Построение правой грани
			for (y = 0; y < lengthSegments; y++) {
				for (z = 0; z < heightSegments; z++) {
					faceId = "right_" + y + "_" + z;
					if (reverse) {
						if (triangulate) {
							aUV = new Point((lengthSegments - y)*ld, z*hd);
							cUV = new Point((lengthSegments - y - 1)*ld, (z + 1)*hd);
							createFace([widthSegments + "_" + y + "_" + z, widthSegments + "_" + y + "_" + (z + 1), widthSegments + "_" + (y + 1) + "_" + (z + 1)], faceId + ":1");
							setUVsToFace(aUV, new Point((lengthSegments - y)*ld, (z + 1)*hd), cUV, faceId + ":1");
							createFace([widthSegments + "_" + (y + 1) + "_" + (z + 1), widthSegments + "_" + (y + 1) + "_" + z, widthSegments + "_" + y + "_" + z], faceId + ":0");
							setUVsToFace(cUV, new Point((lengthSegments - y - 1)*ld, z*hd), aUV, faceId + ":0");
						} else {
							createFace([widthSegments + "_" + y + "_" + z, widthSegments + "_" + y + "_" + (z + 1), widthSegments + "_" + (y + 1) + "_" + (z + 1), widthSegments + "_" + (y + 1) + "_" + z], faceId);
							setUVsToFace(new Point((lengthSegments - y)*ld, z*hd), new Point((lengthSegments - y)*ld, (z + 1)*hd), new Point((lengthSegments - y - 1)*ld, (z + 1)*hd), faceId);
						}
					} else {
						if (triangulate) {
							aUV = new Point(y*ld, z*hd);
							cUV = new Point((y + 1)*ld, (z + 1)*hd);
							createFace([widthSegments + "_" + y + "_" + z, widthSegments + "_" + (y + 1) + "_" + z, widthSegments + "_" + (y + 1) + "_" + (z + 1)], faceId + ":0");
							setUVsToFace(aUV, new Point((y + 1)*ld, z*hd), cUV, faceId + ":0");
							createFace([widthSegments + "_" + (y + 1) + "_" + (z + 1), widthSegments + "_" + y + "_" + (z + 1), widthSegments + "_" + y + "_" + z], faceId + ":1");
							setUVsToFace(cUV, new Point(y*ld, (z + 1)*hd), aUV, faceId + ":1");
						} else {
							createFace([widthSegments + "_" + y + "_" + z, widthSegments + "_" + (y + 1) + "_" + z, widthSegments + "_" + (y + 1) + "_" + (z + 1), widthSegments + "_" + y + "_" + (z + 1)], faceId);
							setUVsToFace(new Point(y*ld, z*hd), new Point((y + 1)*ld, z*hd), new Point((y + 1)*ld, (z + 1)*hd), faceId);
						}
					}
					if (triangulate) {
						right.addFace(faceId + ":0");
						right.addFace(faceId + ":1");
					} else {
						right.addFace(faceId);
					}
				}
			}
		}

		/**
		 * @inheritDoc
		 */		
		protected override function createEmptyObject():Object3D {
			return new Box(0, 0, 0, 0);
		}

		/**
		 * @inheritDoc
		 */
		override protected function defaultName():String {
			return "box" + ++counter;
		}

	}
}
