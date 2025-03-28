package alternativa.engine3d.errors {
	
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Mesh;
	import alternativa.utils.TextUtils;

	/**
	 * Ошибка, возникающая, если грань не найдена в объекте. 
	 */
	public class FaceNotFoundError extends ObjectNotFoundError {
		
		/**
		 * Создание экземпляра класса.
		 *  
		 * @param face экземпляр или идентификатор грани
		 * @param source объект, в котором произошла ошибка
		 */
		public function FaceNotFoundError(face:Object = null, source:Object = null) {
			var message:String;
			if (source is Mesh) {
				message = "Mesh ";
			} else {
				message = "Surface ";
			}
			if (face is Face) {
				message += "%1. Face %2 not found.";
			} else {
				message += "%1. Face with ID '%2' not found.";
			}
			super(TextUtils.insertVars(message, source, face), face, source);
			this.name = "FaceNotFoundError";
		}
	}
}
