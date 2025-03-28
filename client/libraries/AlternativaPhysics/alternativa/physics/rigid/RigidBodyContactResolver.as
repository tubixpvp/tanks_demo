package alternativa.physics.rigid {

	import alternativa.physics.*;
	import alternativa.types.Point3D;

	use namespace altphysics;

	/**
	 * 
	 */
	public class RigidBodyContactResolver {
		
		private var velocityIterations:int;
		private var positionIterations:int;
		private var velocityEpsilon:Number;
		private var positionEpsilon:Number;
		
		private var velocityIterationsUsed:int;
		private var positionIterationsUsed:int;
		
		private var linearChange1:Point3D = new Point3D();
		private var linearChange2:Point3D = new Point3D();
		private var angularChange1:Point3D = new Point3D();
		private var angularChange2:Point3D = new Point3D();
		
		private var velocityChange1:Point3D = new Point3D();
		private var velocityChange2:Point3D = new Point3D();
		private var rotationChange1:Point3D = new Point3D();
		private var rotationChange2:Point3D = new Point3D();

		private var deltaVector:Point3D = new Point3D();
		
		/**
		 * 
		 * @param velocityIterations
		 * @param positionIterations
		 * @param velocityEpsilon
		 * @param positionEpsilon
		 */
		public function RigidBodyContactResolver(velocityIterations:int, positionIterations:int, velocityEpsilon:Number = 0.001, positionEpsilon:Number = 0.001) {
			this.velocityIterations = velocityIterations;
			this.positionIterations = positionIterations;
			this.velocityEpsilon = velocityEpsilon;
			this.positionEpsilon = positionEpsilon;
		}
		
		/**
		 * 
		 * @param velocityIterations
		 * @param positionEpsilon
		 */
		public function setIterations(velocityIterations:int, positionIterations:int):void {
			this.velocityIterations = velocityIterations;
			this.positionIterations = positionIterations;
		}
		
		/**
		 * 
		 * @return 
		 */		
		private function isValid():Boolean {
			return (positionIterations > 0) && (velocityIterations > 0) && (positionEpsilon >= 0) && (velocityEpsilon >= 0);
		}
		
		/**
		 * 
		 * @param firstContact
		 * @param numContacts
		 * @param time
		 */
		public function resolveContacts(firstContact:RigidBodyContact, numContacts:int, time:Number):void {
			if (numContacts == 0 || !isValid()) {
				return;
			}
			// Подготовка контактов к обработке
			prepareContacts(firstContact, numContacts, time);
			// Разделение взаимно проникающих контактов
			adjustPositions(firstContact, numContacts, time);
			// Коррекция скорости для контактов
			adjustVelocities(firstContact, numContacts, time);
		}

		/**
		 * 
		 * @param firstContact
		 * @param numContacts
		 * @param time
		 */
		public function prepareContacts(firstContact:RigidBodyContact, numContacts:int, time:Number):void {
			var contact:RigidBodyContact = firstContact;
			while (contact.index < numContacts) {
				// Вычисление внутренних данных контакта, необходимых для дальнейшей работы
				contact.calculateInternals(time);
				contact = contact.next;
			}
		}

		/**
		 * 
		 * @param firstContact
		 * @param numContacts
		 * @param time
		 */
		public function adjustPositions(firstContact:RigidBodyContact, numContacts:int, time:Number):void {
			positionIterationsUsed = 0;
			// Итерационное устранение взаимного проникновения тел в точках контактов в порядке наибольшего пересечения тел
			while (positionIterationsUsed < positionIterations) {
				var max:Number = positionEpsilon;
				var mostSevereContact:RigidBodyContact = null;
				// Поиск контакта с наибольшим пересечением
				var contact:RigidBodyContact = firstContact;
				while (contact.index < numContacts) {
					if (contact.penetration > max) {
						max = contact.penetration;
						mostSevereContact = contact;
					}
					contact = contact.next;
				}
				if (mostSevereContact == null) {
					// Алгоритм прерывается, если не осталось пересечений
					return;
				}
				// Будим спящего
				mostSevereContact.matchAwakeState();
				
				// Разделяем контакт
				mostSevereContact.applyPositionChange(linearChange1, linearChange2, angularChange1, angularChange2, max);
				// Обновляем величину проникновения в каждом контакте, содержащем обработанные объекты
				contact = firstContact;
				while (contact.index < numContacts) {
					if (contact.body1 == mostSevereContact.body1) {
						deltaVector.copy(angularChange1);
						deltaVector.cross(contact.relativeContactPosition1);
						deltaVector.add(linearChange1);
						contact.penetration -= deltaVector.dot(contact.contactNormal); 
					}
					if (contact.body1 == mostSevereContact.body2) {
						deltaVector.copy(angularChange2);
						deltaVector.cross(contact.relativeContactPosition1);
						deltaVector.add(linearChange2);
						contact.penetration -= deltaVector.dot(contact.contactNormal); 
					}
					if (contact.body2 != null) {
						if (contact.body2 == mostSevereContact.body1) {
							deltaVector.copy(angularChange1);
							deltaVector.cross(contact.relativeContactPosition2);
							deltaVector.add(linearChange1);
							contact.penetration += deltaVector.dot(contact.contactNormal); 
						}
						if (contact.body2 == mostSevereContact.body2) {
							deltaVector.copy(angularChange2);
							deltaVector.cross(contact.relativeContactPosition2);
							deltaVector.add(linearChange2);
							contact.penetration += deltaVector.dot(contact.contactNormal); 
						}
					}
					contact = contact.next;
				}
				positionIterationsUsed++;
			}
		}

		/**
		 * 
		 * @param firstContact
		 * @param numContacts
		 * @param time
		 */
		public function adjustVelocities(firstContact:RigidBodyContact, numContacts:int, time:Number):void {
			velocityIterationsUsed = 0;
			while (velocityIterationsUsed < velocityIterations) {
				var max:Number = velocityEpsilon;
				var mostSevereContact:RigidBodyContact = null;
				var contact:RigidBodyContact = firstContact;
				while (contact.index < numContacts) {
					if (contact.desiredDeltaVelocity > max) {
						max = contact.desiredDeltaVelocity;
						mostSevereContact = contact;
					}
					contact = contact.next;
				}
				if (mostSevereContact == null) {
					return;
				}
				// Будим спящих
				mostSevereContact.matchAwakeState();
				// Корректируем скорости
				mostSevereContact.applyVelocityChange(velocityChange1, velocityChange2, rotationChange1, rotationChange2);
				// Обновляем скорости сближения для каждого контакта, содержащего обработанные объекты
				contact = firstContact;
				var needRecalculation:Boolean = false;
				while (contact.index < numContacts) {
					if (contact.body1 == mostSevereContact.body1) {
						deltaVector.copy(rotationChange1);
						deltaVector.cross(contact.relativeContactPosition1);
						deltaVector.add(velocityChange1);
						deltaVector.transformTranspose(contact.contactToWorld);
						contact.contactVelocity.add(deltaVector);
						needRecalculation = true;
					}
					if (contact.body1 == mostSevereContact.body2) {
						deltaVector.copy(rotationChange2);
						deltaVector.cross(contact.relativeContactPosition1);
						deltaVector.add(velocityChange2);
						deltaVector.transformTranspose(contact.contactToWorld);
						contact.contactVelocity.add(deltaVector);
						needRecalculation = true;
					}
					if (contact.body2 != null) {
						if (contact.body2 == mostSevereContact.body1) {
							deltaVector.copy(rotationChange1);
							deltaVector.cross(contact.relativeContactPosition2);
							deltaVector.add(velocityChange1);
							deltaVector.transformTranspose(contact.contactToWorld);
							contact.contactVelocity.subtract(deltaVector);
							needRecalculation = true;
						}
						if (contact.body2 == mostSevereContact.body2) {
							deltaVector.copy(rotationChange2);
							deltaVector.cross(contact.relativeContactPosition2);
							deltaVector.add(velocityChange2);
							deltaVector.transformTranspose(contact.contactToWorld);
							contact.contactVelocity.subtract(deltaVector);
							needRecalculation = true;
						}
					}
					if (needRecalculation) {
						contact.calculateDesiredVelocity(time);
					}
					contact = contact.next;
				}
				velocityIterationsUsed++;
			}
		}

	}
}