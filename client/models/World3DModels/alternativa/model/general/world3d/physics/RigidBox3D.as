package alternativa.model.general.world3d.physics {
	
	import alternativa.engine3d.core.Object3D;
	import alternativa.physics.altphysics;
	import alternativa.physics.rigid.generators.RigidBox;
	import alternativa.types.Point3D;
	
	use namespace altphysics;

	/**
	 * Класс для связи трёхмерного объекта с физическим представлением в виде прямоугольного параллелепипеда.
	 */
	public class RigidBox3D extends RigidBox {
		/**
		 * Объект, связанный с телом.
		 */
		private var object:Object3D;
		/**
		 * Точка привязки параллелепипеда к объекту в системе координат объекта.
		 */
		private var pivot:Point3D = new Point3D();
		
		// Вспомогательная переменная
		private var point:Point3D = new Point3D();
		
		private var _animator:IObjectAnimator;
		
		/**
		 * 
		 * @param width
		 * @param length
		 * @param height
		 * @param mass
		 */		
		public function RigidBox3D(width:Number, length:Number, height:Number, mass:Number) {
			super(width, length, height, mass);
		}

		/**
		 * Устанавливает трансформацию связанного объекта согласно ориентации тела и заданной точки привязки.
		 */
		public function updateObjectTransform():void {
			if (object != null) {
				point.x = pivot.x;
				point.y = pivot.y;
				point.z = pivot.z;
				point.transform(body.transformMatrix);
				object.coords = point;

				if (_animator != null) {
					_animator.animateObject(object, body);
				} else {
					body.orientation.getEulerAngles(point);
					object.rotationX = point.x;
					object.rotationY = point.y;
					object.rotationZ = point.z;
				}
			}
		}
		
		/**
		 * Устанавливает трёхмерный объект, связанный с телом.
		 * 
		 * @param object объект, визуализирующий физическое тело 
		 * @param pivot точка привязки объекта
		 */
		public function setObject(object:Object3D):void {
			this.object = object;
		}
		
		public function setPivot(pivot:Point3D):void {
			this.pivot.copy(pivot);
		}
		
		public function get animator():IObjectAnimator {
			return _animator;
		}

		public function set animator(value:IObjectAnimator):void {
			_animator = value;
		}
		
	}
}
