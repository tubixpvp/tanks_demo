package alternativa.engine3d.loaders {
	
	/**
	 * @private
	 * Возможные состояния загрузчиков. 
	 */
	public final class Loader3DState {
		
		public static const IDLE:int = 0;
		public static const LOADING_MAIN:int = 1;
		public static const LOADING_TEXTURE:int = 2;
		public static const LOADING_LIBRARY:int = 3;
		
	}
}