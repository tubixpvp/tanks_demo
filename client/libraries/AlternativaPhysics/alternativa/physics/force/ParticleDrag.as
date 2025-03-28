package alternativa.physics.force {
	import alternativa.physics.particle.Particle;
	import alternativa.types.Point3D;

	public class ParticleDrag implements IParticelForceGenerator {
		private var force:Point3D = new Point3D();
		
		private var k1:Number;
		private var k2:Number;
		
		public function ParticleDrag(k1:Number, k2:Number) {
			this.k1 = k1;
			this.k2 = k2;
		}

		public function updateForce(particle:Particle, time:Number):void {
			force.x = particle.velocity.x;
			force.y = particle.velocity.y;
			force.z = particle.velocity.z;
			var len:Number = force.length;
			var coeff:Number = len;
			coeff = -(k1*coeff + k2*coeff*coeff)/len;
			force.x *= coeff;
			force.y *= coeff;
			force.z *= coeff;
			particle.addForce(force);
		}
	}
}