package alternativa.engine3d.errors {
	
	import alternativa.engine3d.core.Mesh;
	import alternativa.utils.TextUtils;
	
	/**
	 * Ошибка, обозначающая, что вершина уже содержится в объекте. 
	 */
	public class VertexExistsError extends ObjectExistsError {
		
		/**
		 * Создание экземпляра класса.
		 * 
		 * @param vertex вершина, которая уже есть в объекте
		 * @param mesh объект, вызвавший ошибку
		 */
		public function VertexExistsError(vertex:Object = null, mesh:Mesh = null)	{
			super(TextUtils.insertVars("Mesh %1. Vertex with ID '%2' already exists.", mesh, vertex), vertex, mesh);
			this.name = "VertexExistsError";
		}
	}
}
