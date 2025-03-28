package alternativa.physics.particle {
	import alternativa.physics.particle.Particle;
	import alternativa.physics.particle.ParticleContact;
	import alternativa.physics.particle.ParticleContactGenerator;
	import alternativa.physics.particle.ParticleContactResolver;
	import alternativa.physics.registry.ParticleForceRegistry;
	
	public class ParticleWorld {

		public var particles:Particle;
		public var last:Particle;
		
		public var contacts:ParticleContact;
		public var contactGenerators:ParticleContactGenerator;
		public var forceRegistry:ParticleForceRegistry;

		public var resolver:ParticleContactResolver;
		
		public var maxContacts:int;
		public var iterations:int;

		public function ParticleWorld(maxContacts:int, iterations:int = 0) {
			this.maxContacts = maxContacts;
			this.iterations = iterations;
			
			// Создаём контакты
			contacts = new ParticleContact(0);
			var contact:ParticleContact = contacts;
			for (var i:int = 1; i < maxContacts; i++) {
				contact = contact.next = new ParticleContact(i);
			}
			
			resolver = new ParticleContactResolver(0);
			forceRegistry = new ParticleForceRegistry();
		}
		
		public function addParticle(particle:Particle):void {
			if (particles == null) {
				last = particles = particle;
			} else {
				last.next = particle;
				last = particle;
			}
		}
		
		public function addContactGenerator(generator:ParticleContactGenerator):void {
			if (contactGenerators == null) {
				contactGenerators = generator;
			} else {
				var gen:ParticleContactGenerator = contactGenerators;
				while (gen.next != null) {
					gen = gen.next;
				}
				gen.next = generator;
			}
		}
		
		public function startFrame():void {
			var particle:Particle = particles;
			while (particle != null) {
				particle.clearForce();
				particle = particle.next;
			}
		}
		
		/**
		 * Последоавтельно запускает все зарегистрированные генераторы контактов.
		 * 
		 * @return количество использованных контактов
		 */
		public function generateContacts():int {
			var contact:ParticleContact = contacts;
			var generator:ParticleContactGenerator = contactGenerators;
			while (generator != null) {
				contact = generator.addContacts(contact);
				if (contact == null) {
					// Доступные контакты исчерпаны
					return maxContacts;
				}
				generator = generator.next;
			}
			return contact.index;
		}
		
		public function intergrate(time:Number):void {
			var particle:Particle = particles;
			while (particle != null) {
				particle.integrate(time);
				particle = particle.next;
			}
		}
		
		/**
		 * Запускает физическую симуляцию.
		 * 
		 * @param time
		 */		
		public function runPhysics(time:Number):void {
			// Применение генераторов сил
			forceRegistry.updateForces(time);
			// Запуск интеграторов для всех частиц
			intergrate(time);
			// Создание контактов
			var contactsUsed:int = generateContacts();
			// Обработка полученных контактов
			if (iterations == 0) {
				resolver.setIterations(3*contactsUsed);
			}
			resolver.resolveContacts(contacts, contactsUsed, time);
		}

	}
}