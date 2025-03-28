package alternativa.engine3d.physics {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Face;
	import alternativa.types.Point3D;
	
	use namespace alternativa3d;

	/**
	 * Параметры столкновения эллипсоида с гранью объекта. Плоскостью столкновения является касательная к
	 * эллипсоиду плоскость, проходящая через точку столкновения с гранью.
	 */
	public class Collision {
		/**
		 * Грань, с которой произошло столкновение.
		 */
		public var face:Face;
		/**
		 * Нормаль плоскости столкновения.
		 */
		public var normal:Point3D;
		/**
		 * Смещение плоскости столкновения.
		 */
		public var offset:Number;
		/**
		 * Координаты точки столкновения.
		 */
		public var point:Point3D;

	}
}
