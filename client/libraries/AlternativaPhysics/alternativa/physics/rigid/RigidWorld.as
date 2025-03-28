package alternativa.physics.rigid {
	
	public class RigidWorld {
		
		private var firstBody:RigidBody;
		private var lastBody:RigidBody;
		private var contactGenerators:RigidBodyContactGenerator;
		private var lastContactGenerator:RigidBodyContactGenerator;
		
		public var contacts:RigidBodyContact;
		private var maxContacts:int;
		private var resolver:RigidBodyContactResolver;
		
		public var forceRegistry:BodyForceRegistry = new BodyForceRegistry();
		public var calculateIterations:Boolean;
		
		public var numContacts:int;
		
		public function RigidWorld(maxContacts:int, iterations:int) {
			this.maxContacts = maxContacts;
			resolver = new RigidBodyContactResolver(iterations, iterations);
			createContactList(maxContacts);
		}
		
		private function createContactList(numContacts:int):void {
			if (numContacts > 0) {
				var contact:RigidBodyContact = contacts = new RigidBodyContact(0);
				for (var i:int = 1; i < numContacts; i++) {
					contact.next = new RigidBodyContact(i);
					contact = contact.next;
				}
			}
		}
		
		public function addBody(body:RigidBody):void {
			if (firstBody == null) {
				firstBody = body;
			} else {
				lastBody.next = body;
			}
			lastBody = body;
			while (lastBody.next != null) {
				lastBody = lastBody.next;
			}
		}
		
		public function removeBody(body:RigidBody):void {
			if (body == firstBody) {
				firstBody = firstBody.next;
				body.next = null;
			} else {
				var current:RigidBody = firstBody;
				var prev:RigidBody = null;
				while (current != body && current != null) {
					prev = current;
					current = current.next;
				}
				if (current != null) {
					if (lastBody == body) {
						lastBody = prev;
					}
					prev.next = current.next;
					current.next = null;
				}
			}
		}
		
		public function addContactGenerator(gen:RigidBodyContactGenerator):void {
			if (contactGenerators == null) {
				contactGenerators = gen;
			} else {
				lastContactGenerator.next = gen;
			}
			lastContactGenerator = gen;
			while (lastContactGenerator.next != null) {
				lastContactGenerator = lastContactGenerator.next;
			}
		}
		
		public function removeContactGenerator(gen:RigidBodyContactGenerator):void {
			if (gen == contactGenerators) {
				contactGenerators = gen.next;
				gen.next = null;
			} else {
				var prev:RigidBodyContactGenerator = contactGenerators;
				var curr:RigidBodyContactGenerator = contactGenerators.next;
				while (curr != gen && curr != null) {
					prev = curr;
					curr = curr.next;
				}
				if (curr == gen) {
					if (lastContactGenerator == gen) {
						lastContactGenerator = prev;
					}
					prev.next = curr.next;
					curr.next = null;
				}
			}
		}
		
		public function startFrame():void {
			var body:RigidBody = firstBody;
			while (body != null) {
				body.clearAccumulators();
				body.calculateDerivedData();
				body = body.next;
			}
		}
		
		private function generateContacts():int {
			var contact:RigidBodyContact = contacts;
			var gen:RigidBodyContactGenerator = contactGenerators;
			while (gen != null && contact != null) {
				contact = gen.addContacts(contact);
				gen = gen.next;
			}
			return contact == null ? maxContacts : contact.index;
		}
		
		public function runPhysics(time:Number):void {
			forceRegistry.updateForces(time);
			var body:RigidBody = firstBody;
			while (body != null) {
				body.integrate(time);
				body = body.next;
			}
			numContacts = generateContacts();
//			trace("[RigidWorld.runPhysics] numContacts", numContacts);
			if (calculateIterations) {
				resolver.setIterations(4*numContacts, 4*numContacts);
			}
			resolver.resolveContacts(contacts, numContacts, time);
		}

	}
}