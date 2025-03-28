package alternativa.engine3d.loaders {
	
	/**
	 * Набор констант, которые описывают этапы загрузки.
	 */	
	public final class LoadingStage {
		/**
		 * Обозначает загрузку основного файла.
		 */
		public static const MAIN_FILE:int = 0;
		/**
		 * Обозначает загрузку текстур.
		 */
		public static const TEXTURE:int = 1;
		/**
		 * Обозначает загрузку библиотек материалов.
		 */
		public static const MATERIAL_LIBRARY:int = 2;
	}
}