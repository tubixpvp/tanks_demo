package alternativa.engine3d.errors {
	
	import alternativa.engine3d.core.Object3D;
	import alternativa.utils.TextUtils;
	
	/**
	 * Ошибка, возникающая, когда объект сцены не был найден в списке связанных с необходимым объектом сцены.
	 */
	public class Object3DNotFoundError extends ObjectNotFoundError {
		
		/**
		 * Создание экземпляра класса.
		 * 
		 * @param object ненайденный объект сцены
		 * @param source объект сцены, в котором произошла ошибка
		 */
		public function Object3DNotFoundError(object:Object3D = null, source:Object3D = null) {
			super(TextUtils.insertVars("Object3D %1. Object %2 not in child list", source, object), object, source);
			this.name = "Object3DNotFoundError";
		}
	}
}
