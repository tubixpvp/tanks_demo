package alternativa.physics.force {
	import alternativa.physics.particle.Particle;
	import alternativa.types.Point3D;

	public class ParticleAnchoredSpring implements IParticelForceGenerator {
		
		private var force:Point3D = new Point3D();
		
		private var anchor:Point3D;
		private var springCoeff:Number;
		private var restLength:Number;
		
		public function ParticleAnchoredSpring(anchor:Point3D, springCoeff:Number, restLength:Number) {
			this.anchor = anchor;
			this.springCoeff = springCoeff;
			this.restLength = restLength;
		}

		public function updateForce(particle:Particle, time:Number):void {
			force.x = particle.position.x - anchor.x;
			force.y = particle.position.y - anchor.y;
			force.z = particle.position.z - anchor.z;
			var len:Number = force.length;
			var k:Number = (restLength - len)*springCoeff/len;
			force.x *= k;
			force.y *= k;
			force.z *= k;
			particle.addForce(force);
		}
	}
}