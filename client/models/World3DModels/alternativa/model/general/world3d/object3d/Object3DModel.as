package alternativa.model.general.world3d.object3d {
	import alternativa.init.Main;
	import alternativa.model.general.child.IChildListener;
	import alternativa.model.general.world3d.IObject3D;
	import alternativa.model.general.world3d.IObject3DParams;
	import alternativa.object.ClientObject;
	import alternativa.types.Point3D;

	import platform.models.general.world3d.object3d.Object3DModelBase;
	import platform.models.general.world3d.object3d.IObject3DModelBase;
	import platform.models.general.world3d.Vector3d;

	/**
	 * Модель поведения трёхмерного объекта.
	 */
	public class Object3DModel extends Object3DModelBase implements IObject3DModelBase, IChildListener, IObject3DParams {
		
		/**
		 * 
		 */
		public function Object3DModel() {
			super();
		}
		
		/**
		 * 
		 * @param clientObject
		 * @param position
		 * @param scale
		 * @param rotation
		 */
		public function initObject(clientObject:ClientObject, position:Vector3d, rotation:Vector3d, scale:Vector3d):void {
			var params:Object3DParams = new Object3DParams();
			params.position = new Point3D(position.x, position.y, position.z);
			params.rotation = new Point3D(rotation.x, rotation.y, rotation.z);
			params.scale = new Point3D(scale.x, scale.y, scale.z);
			Main.writeToConsole("Object3DModel::initObject " + params.position + ", " + params.rotation + ", " + params.scale);
			clientObject.putParams(Object3DModelBase, params);
		}

		/**
		 * 
		 * @param child
		 * @param parent
		 */
		public function addChild(child:ClientObject, parent:ClientObject):void {
			var parentModel:IObject3D = Main.modelsRegister.getModelForObject(parent, IObject3D) as IObject3D;
			var childModel:IObject3D = Main.modelsRegister.getModelForObject(child, IObject3D) as IObject3D;
			
			parentModel.getObject3D(parent).addChild(childModel.getObject3D(child));
		}
		
		/**
		 * 
		 * @param child
		 * @param parent
		 */
		public function removeChild(child:ClientObject, parent:ClientObject):void {
			var parentModel:IObject3D = Main.modelsRegister.getModelForObject(parent, IObject3D) as IObject3D;
			var childModel:IObject3D = Main.modelsRegister.getModelForObject(child, IObject3D) as IObject3D;
			
			parentModel.getObject3D(parent).removeChild(childModel.getObject3D(child));
		}
		
		/**
		 * 
		 * @param object
		 * @return 
		 */
		public function getChildren(object:ClientObject):Array {
			var model:IObject3D = Main.modelsRegister.getModelForObject(object, IObject3D) as IObject3D;
			return model.getObject3D(object).children.toArray();
		}
		
		/**
		 * 
		 * @param clientObject
		 * @return 
		 */
		public function getObject3DParams(clientObject:ClientObject):Object3DParams {
			return clientObject.getParams(Object3DModelBase) as Object3DParams;
		}

	}
}