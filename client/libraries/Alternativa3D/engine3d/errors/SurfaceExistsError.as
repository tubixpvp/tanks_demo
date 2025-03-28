package alternativa.engine3d.errors {
	
	import alternativa.engine3d.core.Mesh;
	import alternativa.utils.TextUtils;
	
	/**
	 * Ошибка, обозначающая, что поверхность уже присутствует в контейнере. 
	 */
	public class SurfaceExistsError extends ObjectExistsError {
		
		/**
		 * Создание экземпляра класса.
		 * 
		 * @param surface поверхность, которая уже присутствует в контейнере
		 * @param mesh объект, вызвавший ошибку
		 */
		public function SurfaceExistsError(surface:Object = null, mesh:Mesh = null)	{
			super(TextUtils.insertVars("Mesh %1. Surface with ID '%2' already exists.", mesh, surface), surface, mesh);
			this.name = "SurfaceExistsError";
		}
	}
}
