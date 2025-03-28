package alternativa.physics.particle {
	import alternativa.types.Point3D;
	
	public class Particle {
		
		private static var resultingAcceleration:Point3D = new Point3D();
		
		public var position:Point3D = new Point3D();
		public var velocity:Point3D = new Point3D();
		public var acceleration:Point3D = new Point3D();
		public var accumulatedForce:Point3D = new Point3D();
		public var mass:Number;
		public var inverseMass:Number;
		public var damping:Number = 0.995;
		
		public var next:Particle;
		
		/**
		 * @param mass масса частицы. Значение меньшее или равное нулю означает бесконечную массу.
		 */
		public function Particle(mass:Number = 0) {
			if (mass <= 0) {
				this.mass = 0;
				inverseMass = 0;
			} else {
				this.mass = mass;
				inverseMass = 1/mass;
			}
		}
		
		/**
		 * 
		 * @param time время в секундах
		 */
		public function integrate(time:Number):void {
			if (time <= 0) {
				return;
			}
			
			position.x += velocity.x*time;
			position.y += velocity.y*time;
			position.z += velocity.z*time;
			
			resultingAcceleration.x =	acceleration.x + inverseMass*accumulatedForce.x;
			resultingAcceleration.y = acceleration.y + inverseMass*accumulatedForce.y;
			resultingAcceleration.z = acceleration.z + inverseMass*accumulatedForce.z;
			
			velocity.x += resultingAcceleration.x*time;
			velocity.y += resultingAcceleration.y*time;
			velocity.z += resultingAcceleration.z*time;
			
			var d:Number = Math.pow(damping, time);
			velocity.x *= d;
			velocity.y *= d;
			velocity.z *= d;
			
			accumulatedForce.x = 0;
			accumulatedForce.y = 0;
			accumulatedForce.z = 0;
		}
		
		public function clearForce():void {
			accumulatedForce.x = 0;
			accumulatedForce.y = 0;
			accumulatedForce.z = 0;
		}
		
		public function addForce(force:Point3D):void {
			accumulatedForce.x += force.x;
			accumulatedForce.y += force.y;
			accumulatedForce.z += force.z;
		}
		
		public function hasFiniteMass():Boolean {
			return inverseMass > 0;
		}
	}
}