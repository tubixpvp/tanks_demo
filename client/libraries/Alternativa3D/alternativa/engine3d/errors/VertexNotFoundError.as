package alternativa.engine3d.errors {
	
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Vertex;
	import alternativa.utils.TextUtils;
	
	/**
	 * Ошибка, обозначающая, что вершина не найдена в объекте. 
	 */
	public class VertexNotFoundError extends ObjectNotFoundError {
		
		/**
		 * Создание экземпляра класса.
		 * 
		 * @param vertex вершина, которая не найдена в объекте
		 * @param mesh объект, вызвавший ошибку
		 */
		public function VertexNotFoundError(vertex:Object = null, mesh:Mesh = null) {
			if (vertex is Vertex) {
				message = "Mesh %1. Vertex %2 not found.";
			} else {
				message = "Mesh %1. Vertex with ID '%2' not found.";
			}
			super(TextUtils.insertVars(message, mesh, vertex), vertex, mesh);
			this.name = "VertexNotFoundError";
		}
	}
}
