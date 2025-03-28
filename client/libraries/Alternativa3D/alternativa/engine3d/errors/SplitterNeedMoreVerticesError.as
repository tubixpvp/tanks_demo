package alternativa.engine3d.errors {
	
	import alternativa.engine3d.core.Mesh;
	import alternativa.utils.TextUtils;
	
	/**
	 * Ошибка, обозначающая недостаточное количество точек для создания сплиттера.
	 * Для создания сплиттера должно быть указано не менее трех точек. 
	 */
	public class SplitterNeedMoreVerticesError extends Engine3DError {

		/**
		 * Количество переданных для создания сплиттера точек
		 */
		public var count:uint;

		/**
		 * Создание экземпляра класса.
		 *  
		 * @param count количество точек, переданное для создания сплиттера
		 */
		public function SplitterNeedMoreVerticesError(count:uint = 0) {
			super(TextUtils.insertVars("%1 points not enough for splitter creation.", count), null);
			this.count = count;
			this.name = "SplitterNeedMoreVerticesError";
		}

	}
}
