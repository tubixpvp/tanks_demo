package alternativa.physics.rigid {
	
	/**
	 * Генератор контактов для твёрдых тел.
	 */
	public class RigidBodyContactGenerator {
		/**
		 * Следующий генератор в списке.
		 */
		public var next:RigidBodyContactGenerator;
		
		/**
		 * Метод создаёт контакты. 
		 * 
		 * @param contact первый свободный для записи контакт в списке контактов мира
		 * @return следующий свободный для записи контакт после окончания работы метода. Значение null означает, что доступные контакты исчерпаны. 
		 */		
		public function addContacts(contact:RigidBodyContact):RigidBodyContact {
			return null;
		}
	}
}