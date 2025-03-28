package alternativa.engine3d.errors {
	
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Surface;
	import alternativa.utils.TextUtils;
	
	/**
	 * Ошибка, обозначающая, что поверхность не найдена в контейнере. 
	 */
	public class SurfaceNotFoundError extends ObjectNotFoundError {

		/**
		 * Создание экземпляра класса.
		 * 
		 * @param surface поверхность, которая отсутствует в объекте
		 * @param mesh объект, который вызвал ошибку
		 */
		public function SurfaceNotFoundError(surface:Object = null, mesh:Mesh = null) {
			if (mesh == null) {
				
			}
			if (surface is Surface) {
				message = "Mesh %1. Surface %2 not found.";
			} else {
				message = "Mesh %1. Surface with ID '%2' not found.";
			}
			super(TextUtils.insertVars(message, mesh, surface), surface, mesh);
			this.name = "SurfaceNotFoundError";
		}
	}
}
