package alternativa.engine3d.errors {
	
	/**
	 * Ошибка, обозначающая, что объект уже присутствует в контейнере.
	 */
	public class ObjectExistsError extends Engine3DError {
		
		/**
		 * Экземпляр или идентификатор объекта, который уже присутствует в контейнере 
		 */
		public var object:Object;
		
		/**
		 * Создание экземпляра класса.
		 *  
		 * @param message описание ошибки
		 * @param object объект, который уже присутствует в контейнере
		 * @param source объект, вызвавший ошибку
		 */
		public function ObjectExistsError(message:String = "", object:Object = null, source:Object = null) {
			super(message, source);
			this.object = object;
			this.name = "ObjectExistsError";
		}
	}
}
