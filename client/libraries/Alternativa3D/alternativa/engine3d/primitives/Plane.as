package alternativa.engine3d.primitives {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	
	import flash.geom.Point;

	use namespace alternativa3d;
	
	/**
	 * Плоскость.
	 */
	public class Plane extends Mesh {

		// Инкремент количества объектов
		private static var counter:uint = 0;

		/**
		 * Создает плоскость.
		 * <p>Примитив после создания содержит в cебе одну или две поверхности, в зависимости от значения параметров. 
		 * При значении <code>reverse</code> установленном в <code>true</code> примитив будет содержать грань - <code>"back"</code>.
		 * При значении <code>reverse</code> установленном в <code>false</code> примитив будет содержать грань - <code>"front"</code>.
		 * Параметр <code>twoSided</code> указывает методу создать обе поверхности.</p>
		 * 
		 * @param width ширина. Размерность по оси Х. Не может быть меньше нуля.
		 * @param length длина. Размерность по оси Y. Не может быть меньше нуля.
		 * @param widthSegments количество сегментов по ширине
		 * @param lengthSegments количество сегментов по длине 
		 * @param twoSided если значении параметра равно <code>true</code>, то формируется двусторонняя плоскость
		 * @param reverse инвертирование нормалей
		 * @param triangulate флаг триангуляции. Если указано значение <code>true</code>, четырехугольники в плоскости будут триангулированы. 
		 */
		public function Plane(width:Number = 100, length:Number = 100, widthSegments:uint = 1, lengthSegments:uint = 1, twoSided:Boolean = true, reverse:Boolean = false, triangulate:Boolean = false) {
			super();
			
			if ((widthSegments == 0) || (lengthSegments == 0)) {
				return;
			}
			width = (width < 0)? 0 : width;
			length = (length < 0)? 0 : length;
			
			// Середина
			var wh:Number = width/2;
			var lh:Number = length/2;
			
			// Размеры сегмента
			var ws:Number = width/widthSegments;
			var ls:Number = length/lengthSegments;
			
			// Размеры UV-сегмента
			var wd:Number = 1/widthSegments;
			var ld:Number = 1/lengthSegments;
			
			// Создание точек и UV
			var x:int;
			var y:int;
			var uv:Array = new Array();
			for (y = 0; y <= lengthSegments; y++) {
				uv[y] = new Array();
				for (x = 0; x <= widthSegments; x++) {
					uv[y][x] = new Point(x*wd, y*ld);
					createVertex(x*ws - wh, y*ls - lh, 0, x+"_"+y);
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
			for (y = 0; y < lengthSegments; y++) {
				for (x = 0; x < widthSegments; x++) {
					if (twoSided || !reverse) {
						if (triangulate) {
							createFace([x + "_" + y, (x + 1) + "_" + y, (x + 1) + "_" + (y + 1)], "front" + x + "_" + y + ":0");
							setUVsToFace(uv[y][x], uv[y][x + 1], uv[y + 1][x + 1], "front" + x + "_" + y + ":0");
							createFace([(x + 1) + "_" + (y + 1), x + "_" + (y + 1), x + "_" + y], "front" + x + "_" + y + ":1");
							setUVsToFace(uv[y + 1][x + 1], uv[y + 1][x], uv[y][x], "front" + x + "_" + y + ":1");
							front.addFace("front" + x + "_" + y + ":0");
							front.addFace("front" + x + "_" + y + ":1");
						} else {
							createFace([x + "_" + y, (x + 1) + "_" + y, (x + 1) + "_" + (y + 1), x + "_" + (y + 1)], "front" + x + "_" + y);
							setUVsToFace(uv[y][x], uv[y][x + 1], uv[y + 1][x + 1], "front" + x + "_" + y);
							front.addFace("front" + x + "_" + y);
						}
					}
					if (twoSided || reverse) {
						if (triangulate) {
							createFace([x + "_" + y, x + "_" + (y + 1), (x + 1) + "_" + (y + 1)], "back" + x + "_" + y + ":0");
							setUVsToFace(uv[lengthSegments - y][x], uv[lengthSegments - y - 1][x], uv[lengthSegments - y - 1][x + 1], "back" + x + "_" + y + ":0");
							createFace([(x + 1) + "_" + (y + 1), (x + 1) + "_" + y, x + "_" + y], "back" + x + "_" + y + ":1");
							setUVsToFace(uv[lengthSegments - y - 1][x + 1], uv[lengthSegments - y][x + 1], uv[lengthSegments - y][x], "back" + x + "_" + y + ":1");
							back.addFace("back" + x + "_" + y + ":0");
							back.addFace("back"+x+"_"+y + ":1");
						} else {
							createFace([x + "_" + y, x + "_" + (y + 1), (x + 1) + "_" + (y + 1), (x + 1) + "_" + y], "back" + x + "_" + y);
							setUVsToFace(uv[lengthSegments - y][x], uv[lengthSegments - y - 1][x], uv[lengthSegments - y - 1][x + 1], "back" + x + "_" + y);
							back.addFace("back" + x + "_" + y);
						}
					}
				}
			}
		}

		/**
		 * @inheritDoc
		 */		
		protected override function createEmptyObject():Object3D {
			return new Plane(0, 0, 0);
		}

		/**
		 * @inheritDoc
		 */
		override protected function defaultName():String {
			return "plane" + ++counter;
		}

	}
}
