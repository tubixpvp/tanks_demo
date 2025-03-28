package alternativa.physics.particle {
	import alternativa.types.Point3D;
	
	public class ParticleRod extends ParticleLink {
		
		private static var vector:Point3D = new Point3D();

		public var length:Number;

		public function ParticleRod(particle1:Particle, particle2:Particle, length:Number = 0) {
			super(particle1, particle2);
			if (length <= 0) {
				this.length = Point3D.difference(particle1.position, particle2.position).length;
			} else {
				this.length = length;
			}
		}
		
		override protected function getCurrentLength():Number {
			var x:Number = particle1.position.x - particle2.position.x;
			var y:Number = particle1.position.y - particle2.position.y;
			var z:Number = particle1.position.z - particle2.position.z;
			return Math.sqrt(x*x + y*y + z*z);
		}
		
		override public function fillContact(contact:ParticleContact):Boolean {
			vector.x = particle1.position.x - particle2.position.x;
			vector.y = particle1.position.y - particle2.position.y;
			vector.z = particle1.position.z - particle2.position.z;
			var len:Number = Math.sqrt(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z);
			
			if (len == length) {
				return false;
			}
			
			var penetration:Number; 
			if (len > length) {
				vector.x = -vector.x;
				vector.y = -vector.y;
				vector.z = -vector.z;
				penetration = len - length;
			} else {
				penetration = length - len;
			}
			
			contact.particle1 = particle1;
			contact.particle2 = particle2;
			contact.contactNormal.x = vector.x/len;
			contact.contactNormal.y = vector.y/len;
			contact.contactNormal.z = vector.z/len;
			contact.penetration = penetration;
			contact.restitution = 0;
			contact.isCollision = false;
			
			return true; 
		}
	}
}