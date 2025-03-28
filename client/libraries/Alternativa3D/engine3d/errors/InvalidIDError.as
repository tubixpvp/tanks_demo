package alternativa.engine3d.errors {
	import alternativa.utils.TextUtils;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Surface;
	
	
	/**
	 * Ошибка, обозначающая, что идентификатор зарезервирован и не может быть использован. 
	 */
	public class InvalidIDError extends Engine3DError {
		/**
		 * Зарезервированный идентификатор 
		 */
		public var id:Object;
		
		/**
		 * Создание экземпляра класса.
		 *  
		 * @param id идентификатор
		 * @param source объект, в котором произошла ошибка
		 */
		public function InvalidIDError(id:Object = null, source:Object = null) {
			var message:String;
			if (source is Mesh) {
				message = "Mesh %2. ";
			} else if (source is Surface) {
				message = "Surface %2. ";
			}
			super(TextUtils.insertVars(message + "ID %1 is reserved and cannot be used", [id, source]), source);
			this.id = id;
			this.name = "InvalidIDError";
		}
	}
}
