package alternativa.physics.particle {
	
	public class ParticleLink {
		
		public var particle1:Particle;
		public var particle2:Particle;
		
		public function ParticleLink(particle1:Particle, particle2:Particle) {
			this.particle1 = particle1;
			this.particle2 = particle2;
		}
		
		protected function getCurrentLength():Number {
			return 0;
		}
		
		public function fillContact(contact:ParticleContact):Boolean {
			return false;
		}
	}
}