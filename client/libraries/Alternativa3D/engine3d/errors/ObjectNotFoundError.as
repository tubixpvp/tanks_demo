package alternativa.engine3d.errors {
	
	/**
	 * Необходимый объект не был найден в контейнере. 
	 */
	public class ObjectNotFoundError extends Engine3DError {
		
		/**
		 * Объект, который отсутствует в контейнере. 
		 */
		public var object:Object;

		/**
		 * Создание экземпляра класса.
		 * 
		 * @param message описание ошибки
		 * @param object отсутствующий объект
		 * @param source объект, вызвавший ошибку
		 */
		public function ObjectNotFoundError(message:String = "", object:Object = null, source:Object = null) {
			super(message, source);
			this.object = object;
			this.name = "ObjectNotFoundError";
		}
	}
}
