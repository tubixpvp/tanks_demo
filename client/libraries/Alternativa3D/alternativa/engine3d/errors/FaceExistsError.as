package alternativa.engine3d.errors {
	
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Mesh;
	import alternativa.utils.TextUtils;
	import alternativa.engine3d.core.Surface;
	
	/**
	 * Ошибка, возникающая при попытке добавить в какой-либо объект грань, уже содержащуюся в данном объекте.  
	 */
	public class FaceExistsError extends ObjectExistsError {
		
		/**
		 * Создание экземпляра класса.
		 * 
		 * @param face экземпляр или идентификатор грани, которая уже содержится в объекте 
		 * @param source источник ошибки
		 */
		public function FaceExistsError(face:Object = null, source:Object = null) {
			var message:String;
			if (source is Mesh) {
				message = "Mesh ";
			} else if (source is Surface) {
				message = "Surface ";
			}
			if (face is Face) {
				message += "%1. Face %2 already exists.";
			} else {
				message += "%1. Face with ID '%2' already exists.";
			}
			super(TextUtils.insertVars(message, source, face), face, source);
			this.name = "FaceExistsError";
		}
	}
}
