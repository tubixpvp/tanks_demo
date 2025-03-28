package alternativa.engine3d.errors {

	/**
	 * Базовый класс для ошибок 3d-engine.
	 */
	public class Engine3DError extends Error {
		
		/**
		 * Источник ошибки - объект в котором произошла ошибка.
		 */
		public var source:Object;
		
		/**
		 * Создание экземпляра класса.
		 *  
		 * @param message описание ошибки
		 * @param source источник ошибки
		 */
		public function Engine3DError(message:String = "", source:Object = null) {
			super(message);
			this.source = source;
			this.name = "Engine3DError";
		}
	}
}
