package alternativa.physics.registry {
	import alternativa.physics.force.IParticelForceGenerator;
	import alternativa.physics.particle.Particle;
	
	public class ParticleForceRegistration {
		public var particle:Particle;
		public var forceGenerator:IParticelForceGenerator;
		
		public var next:ParticleForceRegistration;
		
		public function ParticleForceRegistration(particle:Particle, forceGenerator:IParticelForceGenerator) {
			this.particle = particle;
			this.forceGenerator = forceGenerator;
		}
	}
}