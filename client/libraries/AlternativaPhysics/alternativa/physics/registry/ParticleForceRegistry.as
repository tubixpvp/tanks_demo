package alternativa.physics.registry {
	import alternativa.physics.force.IParticelForceGenerator;
	import alternativa.physics.particle.Particle;
	
	public class ParticleForceRegistry {
		
		protected var registrations:ParticleForceRegistration;
		
		public function ParticleForceRegistry() {
		}
		
		public function add(particle:Particle, fg:IParticelForceGenerator):void {
			var registration:ParticleForceRegistration = new ParticleForceRegistration(particle, fg);
			registration.next = registrations;
			registrations = registration;
		}

		public function remove(particle:Particle, fg:IParticelForceGenerator):void {
			var current:ParticleForceRegistration = registrations;
			var prev:ParticleForceRegistration = null;
			while (current != null) {
				if (current.particle == particle && current.forceGenerator == fg) {
					if (current == registrations) {
						registrations = current.next;
					} else {
						prev.next = current.next;
					}
					break;
				}
				prev = current;
				current = current.next;
			}
		}
		
		public function clear():void {
			registrations = null;
		}
		
		public function updateForces(time:Number):void {
			var current:ParticleForceRegistration = registrations;
			while (current != null) {
				current.forceGenerator.updateForce(current.particle, time);
				current = current.next;
			}
		}
	}
}