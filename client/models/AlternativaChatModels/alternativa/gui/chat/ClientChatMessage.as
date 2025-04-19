package alternativa.gui.chat {
	
	import alternativa.types.Long;

	/**
	 * Данные для одного сообщения
	 */
	public class ClientChatMessage {
		
		
		/**
		 * Идентификатор пользователя
		 */
		public var contactId:Long;
		
		/**
		 * Имя пользователя
		 */
		public var name:String;
		
		/**
		 * Сообщение
		 */
		public var message:String;
		
		/**
		 * Цвет текста
		 */
		public var textColor:uint;
		
		/**
		 * Создать сообщение 
		 */		
		public function ClientChatMessage(contactId:Long, name:String, message:String, textColor:uint) {
			this.contactId = contactId;
			this.name = name;
			this.message = message;	
			this.textColor = textColor;	
		}
		
		
	}
}