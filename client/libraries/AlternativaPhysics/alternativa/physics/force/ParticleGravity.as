package alternativa.physics.force {
	import alternativa.physics.particle.Particle;
	import alternativa.types.Point3D;

	public class ParticleGravity implements IParticelForceGenerator {
		private var force:Point3D = new Point3D();
		
		private var _gravity:Point3D;
		
		public function ParticleGravity(gravity:Point3D)	{
			_gravity = gravity.clone();
		}

		public function updateForce(particle:Particle, time:Number):void {
			if (!particle.hasFiniteMass()) {
				return;
			}
			force.x = _gravity.x*particle.mass;
			force.y = _gravity.y*particle.mass;
			force.z = _gravity.z*particle.mass;
			particle.addForce(force);
		}
	}
}