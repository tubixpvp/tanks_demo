package alternativa.physics.particle {
	public class ParticleContactResolver {
		
		private var iterations:int;
		private var iterationsUsed:int;
		
		public function ParticleContactResolver(iterations:int) {
			this.iterations = iterations;
		}
		
		public function setIterations(value:int):void {
			iterations = value;
		}
		
		public function resolveContacts(contacts:ParticleContact, contactsUsed:int, time:Number):void {
			resolveAllContacts(contacts, contactsUsed, time);
//			resolveCollisionContacts(contacts, contactsUsed, time);
//			resolveNonCollisionContacts(contacts, contactsUsed, time);
		}
		
		private function resolveAllContacts(contacts:ParticleContact, contactsUsed:int, time:Number):void {
			iterationsUsed = 0;
			iterations = 5;
			while (iterationsUsed < iterations) {
				var maxSepVelocity:Number = 0;
				var maxPenetration:Number = 0;
				var mostSevereContact:ParticleContact = null;
				var contact:ParticleContact = contacts;
				while (contact.index < contactsUsed) {
					var sepVelocity:Number = contact.calculateSeparatingVelocity();
					if (sepVelocity < maxSepVelocity) {
						maxSepVelocity = sepVelocity;
						mostSevereContact = contact;
					}
					contact = contact.next;
				}
				if (mostSevereContact != null) {
					mostSevereContact.resolve(time);
				}
				iterationsUsed++;
			}
		}

		private function resolveNonCollisionContacts(contacts:ParticleContact, contactsUsed:int, time:Number):void {
			iterationsUsed = 0;
			while (iterationsUsed < iterations) {
				var maxSepVelocity:Number = 0;
				var maxPenetration:Number = 0;
				var mostSevereContact:ParticleContact = null;
				var contact:ParticleContact = contacts;
				while (contact.index < contactsUsed) {
					if (!contact.isCollision) {
						var sepVelocity:Number = contact.calculateSeparatingVelocity();
						if (sepVelocity < maxSepVelocity) {
							maxSepVelocity = sepVelocity;
							mostSevereContact = contact;
						}
					}
					contact = contact.next;
				}
				if (mostSevereContact != null) {
					mostSevereContact.resolve(time);
				}
				iterationsUsed++;
			}
		}
		
		private function resolveCollisionContacts(contacts:ParticleContact, contactsUsed:int, time:Number):void {
			var maxPenetration:Number = 0;
			var mostSevereContact:ParticleContact = null;
			var contact:ParticleContact = contacts;
			while (contact.index < contactsUsed) {
				if (contact.isCollision && contact.penetration > maxPenetration) {
					maxPenetration = contact.penetration;
					mostSevereContact = contact;
				}
				contact = contact.next;
			}
			if (mostSevereContact != null) {
				if (mostSevereContact.calculateSeparatingVelocity() < 0) {
					mostSevereContact.resolve(time);
				}
			}
		}
		
	}
}