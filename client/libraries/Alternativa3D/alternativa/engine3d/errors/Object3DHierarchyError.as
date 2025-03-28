package alternativa.engine3d.errors {
	
	import alternativa.engine3d.core.Object3D;
	import alternativa.utils.TextUtils;
	
	/**
	 * Ошибка, связанная с нарушением иерархии объектов сцены. 
	 */
	public class Object3DHierarchyError extends Engine3DError
	{
		
		/**
		 * Объект сцены, нарушающий иерархию 
		 */
		public var object:Object3D;
		
		/**
		 * Создание экземпляра класса.
		 *   
		 * @param object объект, нарушающий иерархию
		 * @param source источник ошибки
		 */
		public function Object3DHierarchyError(object:Object3D = null, source:Object3D = null) {
			super(TextUtils.insertVars("Object3D %1. Object %2 cannot be added", source, object), source);
			this.object = object;
			this.name = "Object3DHierarchyError";
		}
	}
}
