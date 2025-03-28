package alternativa.physics.particle {
	
	/**
	 * Базовй класс для генераторов контактов. Реализует поддержку однонаправленного списока генераторов.
	 */
	public class ParticleContactGenerator {
		
		/**
		 * Следующий генератор в списке.
		 */		
		public var next:ParticleContactGenerator;
		
		/**
		 * Метод создаёт информацию о контактах.
		 * 
		 * @param contact первый свободный для записи контакт в списке контактов мира
		 * 
		 * @return следующий свободный для записи контакт после того, как генератор записал свою информацию. Если возвращено значение null,
		 * то значит список доступных контактов исчерпан.  
		 */
		public function addContacts(contact:ParticleContact):ParticleContact {
			return null;
		}
		
	}
}