package alternativa.engine3d.errors {

	import alternativa.engine3d.core.Scene3D;
	import alternativa.engine3d.core.Sector;
	import alternativa.utils.TextUtils;

	/**
	 * Ошибка, возникающая при попытке добавить на сцену сектор, расположенный в другой сцене.  
	 */
	public class SectorInOtherSceneError extends Engine3DError {

		/**
		 * Создание экземпляра класса.
		 * 
		 * @param sector экземпляр сектора, расположенный в другой сцене 
		 * @param source сцена, из которой было вызвано исключение.
		 */
		public function SectorInOtherSceneError(sector:Sector = null, source:Scene3D = null) {
			super(TextUtils.insertVars("%1. Sector %2 is aready situated in the other scene", source, sector), source);
			this.name = "SectorInOtherSceneError";
		}

	}
}
