package alternativa.physics.force {
	import alternativa.physics.particle.Particle;
	import alternativa.types.Point3D;

	public class ParticleSpring implements IParticelForceGenerator {
		
		private var force:Point3D = new Point3D();
		
		private var otherParticle:Particle;
		private var springCoeff:Number;
		private var restLength:Number;
		
		public function ParticleSpring(otherParticle:Particle, springCoeff:Number, restLength:Number) {
			this.otherParticle = otherParticle;
			this.springCoeff = springCoeff;
			this.restLength = restLength;
		}

		public function updateForce(particle:Particle, time:Number):void {
			force.x = particle.position.x - otherParticle.position.x;
			force.y = particle.position.y - otherParticle.position.y;
			force.z = particle.position.z - otherParticle.position.z;
			var len:Number = force.length;
			var k:Number = (restLength - len)*springCoeff/len;
			force.x *= k;
			force.y *= k;
			force.z *= k;
			particle.addForce(force);
		}
	}
}