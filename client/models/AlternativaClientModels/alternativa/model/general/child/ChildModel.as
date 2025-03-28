package alternativa.model.general.child {
	
	import __AS3__.vec.Vector;
	
	import alternativa.init.Main;
	import alternativa.model.IObjectLoadListener;
	import alternativa.object.ClientObject;
	import alternativa.service.IModelService;
	import alternativa.types.Long;
	
	import platform.models.core.child.ChildModelBase;
	import platform.models.core.child.IChildModelBase;
	import alternativa.model.IModel;

	/**
	 * Модель дочернего объекта.
	 */
	public class ChildModel extends ChildModelBase implements IChildModelBase, IChild, IObjectLoadListener {
		
		private var modelRegister:IModelService;
		
		public function ChildModel() {
			modelRegister = Main.osgi.getService(IModelService) as IModelService;
		}
		
		public function initObject(clientObject:ClientObject, parentId:Long):void {
			Main.writeToConsole("ChildModel.initData: clientObject.id = " + clientObject.id + ", parentId = " + parentId);
			// Родительский объект сохраняется в виде параметра модели
			var parent:ClientObject = clientObject.register.getObject(parentId);
			clientObject.putParams(ChildModelBase, parent);
		}

		/**
		 * Изменяет родителя объекта.
		 * 
		 * @param clientObject
		 * @param parent
		 */
		public function changeParent(clientObject:ClientObject, parentId:Long):void {
			var models:Array;
			var model:IChildListener;
			
			// Объект удаляется из старого родителя
			var oldParent:ClientObject = clientObject.getParams(ChildModelBase) as ClientObject;
			models = modelRegister.getModelsForObject(oldParent, IChildListener);
			for each (model in models) {
				model.removeChild(clientObject, oldParent);
			}
			// Объект добавляется к новому родителю
			var parent:ClientObject = clientObject.register.getObject(parentId);
			models = modelRegister.getModelsForObject(parent, IChildListener);
			for each (model in models) {
				model.addChild(clientObject, parent);
			}
		}
		
		/**
		 * 
		 * @param child
		 * @return 
		 */
		public function getParent(child:ClientObject):ClientObject{
			return child.getParams(ChildModelBase) as ClientObject;		
		}

		/**
		 * 
		 * @param object
		 */
		public function objectLoaded(object:ClientObject):void {
			// Объект добавляется к родительскому
			var parent:ClientObject = object.getParams(ChildModelBase) as ClientObject;
			if (parent == null) {
				return;
			}
			var listeners:Array = modelRegister.getModelsForObject(parent, IChildListener);
			for each (var listener:IChildListener in listeners) {
				listener.addChild(object, parent);
			}
		}
			
		public function objectUnloaded(object:ClientObject):void {
			// Объект удаляется из родительского
			var parent:ClientObject = object.getParams(ChildModelBase) as ClientObject;
			if (parent == null) {
				return;
			}
			var listeners:Array = modelRegister.getModelsForObject(parent, IChildListener);
			for each (var listener:IChildListener in listeners) {
				listener.removeChild(object, parent);
			}
		}

	}
}