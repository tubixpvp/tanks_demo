package alternativa.physics.rigid {
	import alternativa.physics.force.IRigidBodyForceGenerator;
	import alternativa.physics.rigid.RigidBody;
	
	public class BodyForceRegistry {
		
		protected var registrations:BodyForceRegistration;
		
		public function BodyForceRegistry() {
		}
		
		public function add(body:RigidBody, fg:IRigidBodyForceGenerator):void {
			var registration:BodyForceRegistration = new BodyForceRegistration(body, fg);
			registration.next = registrations;
			registrations = registration;
		}

		public function remove(body:RigidBody, fg:IRigidBodyForceGenerator):void {
			var current:BodyForceRegistration = registrations;
			var prev:BodyForceRegistration = null;
			while (current != null) {
				if (current.body == body && current.forceGenerator == fg) {
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
			var current:BodyForceRegistration = registrations;
			while (current != null) {
				current.forceGenerator.updateForce(current.body, time);
				current = current.next;
			}
		}
	}
}