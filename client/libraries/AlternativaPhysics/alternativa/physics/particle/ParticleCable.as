package alternativa.physics.particle {
	import alternativa.types.Point3D;
	
	public class ParticleCable extends ParticleLink {
		
		private static var vector:Point3D = new Point3D();

		public var maxLength:Number;
		public var restitution:Number;

		public function ParticleCable(particle1:Particle, particle2:Particle, maxLength:Number, restitution:Number) {
			super(particle1, particle2);
			this.maxLength = maxLength;
			this.restitution = restitution;
		}
		
		override protected function getCurrentLength():Number {
			var x:Number = particle1.position.x - particle2.position.x;
			var y:Number = particle1.position.y - particle2.position.y;
			var z:Number = particle1.position.z - particle2.position.z;
			return Math.sqrt(x*x + y*y + z*z);
		}
		
		override public function fillContact(contact:ParticleContact):Boolean {
			// Для кабеля нормаль контакта направлена в сторону второй частицы
			vector.x = particle2.position.x - particle1.position.x;
			vector.y = particle2.position.y - particle1.position.y;
			vector.z = particle2.position.z - particle1.position.z;
			var len:Number = Math.sqrt(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z);
			
			if (len < maxLength) {
				return false;
			}
			
			contact.particle1 = particle1;
			contact.particle2 = particle2;
			contact.contactNormal.x = vector.x;
			contact.contactNormal.y = vector.y;
			contact.contactNormal.z = vector.z;
			contact.penetration = len - maxLength;
			contact.restitution = restitution;
			
			return true; 
		}
	}
}