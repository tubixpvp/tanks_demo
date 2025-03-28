package alternativa.physics.particle {
	import alternativa.types.Point3D;
	
	public class ParticleContact {
		
		private static var vector:Point3D = new Point3D();
		
		public var particle1:Particle;
		public var particle2:Particle;
		public var restitution:Number;
		public var penetration:Number;
		public var contactNormal:Point3D = new Point3D();
		public var isCollision:Boolean;
		public var frictionCoeff:Number = 0;
		
		public var next:ParticleContact;
		public var index:int;
		
		/**
		 * 
		 * @param particle1
		 * @param particle2
		 * @param restitution
		 * @param contactNormal
		 */
		public function ParticleContact(index:int, particle1:Particle = null, particle2:Particle = null, contactNormal:Point3D = null, penetration:Number = 0, restitution:Number = 0) {
			this.index = index;
			this.particle1 = particle1;
			this.particle2 = particle2;
			if (contactNormal != null) {
				this.contactNormal.x = contactNormal.x;
				this.contactNormal.y = contactNormal.y;
				this.contactNormal.z = contactNormal.z;
			}
			this.penetration = penetration;
			this.restitution = restitution;
		}
		
		/**
		 * 
		 * @param time
		 */
		public function resolve(time:Number):void {
			resolveVelocity(time);
			resolveInterpenetration(time);
		}
		
		/**
		 * 
		 * @return 
		 */
		public function calculateSeparatingVelocity():Number {
			vector.x = particle1.velocity.x;
			vector.y = particle1.velocity.y;
			vector.z = particle1.velocity.z;
			if (particle2 != null) {
				vector.x -= particle2.velocity.x;
				vector.y -= particle2.velocity.y;
				vector.z -= particle2.velocity.z;
			}
			return vector.x*contactNormal.x + vector.y*contactNormal.y + vector.z*contactNormal.z;
		}
		
		/**
		 * 
		 * @param time
		 */
		private function resolveVelocity(time:Number):void {
			var separatingVelocity:Number = calculateSeparatingVelocity();
			if (separatingVelocity > 0) {
				return;
			}
			var newSeparatingVelocity:Number = -restitution*separatingVelocity;
			
			var totalInverseMass:Number = particle1.inverseMass;
			if (particle2 != null) {
				totalInverseMass += particle2.inverseMass;
			}
			if (totalInverseMass <= 0) {
				// Пропускаем, т.к. обе частицы бесконечной массы
				return;
			}
			
			// Обработка покоящихся контактов
			// Проверяем, не была ли относительная скорость приобретена только в течении одного кадра
			if (particle2 != null) {
				vector.x = particle1.acceleration.x - particle2.acceleration.x;
				vector.y = particle1.acceleration.y - particle2.acceleration.y;
				vector.z = particle1.acceleration.z - particle2.acceleration.z;
			} else {
				vector.x = particle1.acceleration.x;
				vector.y = particle1.acceleration.y;
				vector.z = particle1.acceleration.z;
			}
			var accCausedSepVelocity:Number = (vector.x*contactNormal.x + vector.y*contactNormal.y + vector.z*contactNormal.z)*time;

			if (accCausedSepVelocity < 0) {
				// Вычтем скорость сближения, полученную под действием сил во время последнего кадра, из скорости разделения контакта
				newSeparatingVelocity += restitution*accCausedSepVelocity;
				if (newSeparatingVelocity < 0) {
					// Скорость разделения не может быть отрицательной
					newSeparatingVelocity = 0;
				}
			}
			 
			var impulse:Number = (newSeparatingVelocity - separatingVelocity)/totalInverseMass;
			vector.x = impulse*contactNormal.x;
			vector.y = impulse*contactNormal.y;
			vector.z = impulse*contactNormal.z;
			
			particle1.velocity.x += vector.x*particle1.inverseMass;
			particle1.velocity.y += vector.y*particle1.inverseMass;
			particle1.velocity.z += vector.z*particle1.inverseMass;
			
			if (particle2 != null) {
				particle2.velocity.x -= vector.x*particle2.inverseMass;
				particle2.velocity.y -= vector.y*particle2.inverseMass;
				particle2.velocity.z -= vector.z*particle2.inverseMass;
			}
			
//			if (isCollision) {
//				var tangentSpeed:Number = particle1.velocity.length;
//				var deltaSpeed:Number = frictionCoeff*particle1.inverseMass*impulse;
//				if (tangentSpeed < deltaSpeed) {
//					particle1.velocity.x = 0;
//					particle1.velocity.y = 0;
//					particle1.velocity.z = 0;
//				} else {
//					var k:Number = (tangentSpeed - deltaSpeed)/tangentSpeed;
//					particle1.velocity.x *= k;
//					particle1.velocity.y *= k;
//					particle1.velocity.z *= k;
//				}
//			}
		}
		
		/**
		 * 
		 * @param time
		 */
		private function resolveInterpenetration(time:Number):void {
			if (penetration <= 0) {
				return;
			}
			
			var totalInverseMass:Number = particle1.inverseMass;
			if (particle2 != null) {
				totalInverseMass += particle2.inverseMass;
			}
			if (totalInverseMass <= 0) {
				// Пропускаем, т.к. обе частицы бесконечной массы
				return;
			}
			
			var k:Number = penetration/totalInverseMass;
			
			vector.x = k*contactNormal.x;
			vector.y = k*contactNormal.y;
			vector.z = k*contactNormal.z;
			
//			trace("\nparticle1.position", particle1.position.z, particle1.velocity.z);
			particle1.position.x += vector.x*particle1.inverseMass;
			particle1.position.y += vector.y*particle1.inverseMass;
			particle1.position.z += vector.z*particle1.inverseMass;
//			trace("particle1.position", particle1.position.z, particle1.velocity.z);
			
			if (particle2 != null) {
				particle2.position.x -= vector.x*particle2.inverseMass;
				particle2.position.y -= vector.y*particle2.inverseMass;
				particle2.position.z -= vector.z*particle2.inverseMass;
			}
			penetration = 0;
		}
	}
}