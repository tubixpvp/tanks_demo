package alternativa.engine3d.errors {
	
	import alternativa.engine3d.core.Mesh;
	import alternativa.utils.TextUtils;
	
	/**
	 * Ошибка, обозначающая недостаточное количество вершин для создания грани.
	 * Для создания грани должно быть указано не менее трех вершин. 
	 */
	public class FaceNeedMoreVerticesError extends Engine3DError {
		
		/**
		 * Количество переданных для создания грани вершин 
		 */
		public var count:uint;
		
		/**
		 * Создание экземпляра класса.
		 *  
		 * @param mesh объект, в котором произошла ошибка
		 * @param count количество вершин, переданное для создания грани
		 */
		public function FaceNeedMoreVerticesError(mesh:Mesh = null, count:uint = 0) {
			super(TextUtils.insertVars("Mesh %1. %2 vertices not enough for face creation.", mesh, count), mesh);
			this.count = count;
			this.name = "FaceNeedMoreVerticesError";
		}
	}
}