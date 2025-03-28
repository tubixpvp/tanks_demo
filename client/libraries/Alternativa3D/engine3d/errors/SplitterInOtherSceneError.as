package alternativa.engine3d.errors {

	import alternativa.engine3d.core.Scene3D;
	import alternativa.engine3d.core.Splitter;
	import alternativa.utils.TextUtils;

	/**
	 * Ошибка, возникающая при попытке добавить на сцену сплиттер, расположенный в другой сцене.  
	 */
	public class SplitterInOtherSceneError extends Engine3DError {

		/**
		 * Создание экземпляра класса.
		 * 
		 * @param splitter экземпляр сплиттера, расположенный в другой сцене 
		 * @param source сцена, из которой было вызвано исключение.
		 */
		public function SplitterInOtherSceneError(splitter:Splitter = null, source:Scene3D = null) {
			super(TextUtils.insertVars("%1. Splitter %2 is aready situated in the other scene", source, splitter), source);
			this.name = "SplitterInOtherSceneError";
		}

	}
}
