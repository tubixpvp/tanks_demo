package alternativa.model.general.world3d.view3d {
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.display.View;
	import alternativa.init.Main;
	import alternativa.model.IObjectLoadListener;
	import alternativa.model.general.IUIContainer;
	import alternativa.model.general.world3d.IObject3D;
	import alternativa.object.ClientObject;
	import alternativa.types.Map;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;

	import platform.models.general.world3d.Vector3d;
	import platform.models.general.world3d.view3d.View3DModelBase;
	import platform.models.general.world3d.view3d.IView3DModelBase;

	/**
	 * Модель поведения камеры.
	 */
	public class View3DModel extends View3DModelBase implements IView3DModelBase, IObject3D, IView3DModel, IObjectLoadListener {
		
		private var views:Map = new Map();
		private var viewCount:int;
		
		/**
		 * 
		 */
		public function View3DModel() {
			super();
		}
		
		/**
		 * 
		 * @param clientObject
		 * @param position
		 * @param rotation
		 */
		public function initObject(clientObject:ClientObject, position:Vector3d, rotation:Vector3d):void {
			Main.writeToConsole("[View3DModel::initData] object: " + clientObject + ", position: [" + position.x + ", " + position.y + ", " + position.z + "], rotation: [" + rotation.x + ", " + rotation.y + ", " + rotation.z + "]");
			var camera:Camera3D = new Camera3D();
			camera.x = position.x;
			camera.y = position.y;
			camera.z = position.z;
			camera.rotationX = rotation.x;
			camera.rotationY = rotation.y;
			camera.rotationZ = rotation.z;
			Main.writeToConsole("[View3DModel::initData] camera coords: " + camera.coords);
			
			var view:View = new View(camera, 800, 600);

			var viewParams:View3DModelParams = new View3DModelParams(camera, view);
			clientObject.putParams(View3DModelBase, viewParams);
			views.add(clientObject, viewParams);
			viewCount++;
			
			// Вьюпорт помещается в контейнер
			var model:IUIContainer = Main.modelsRegister.getModelForObject(clientObject, IUIContainer) as IUIContainer;
			var container:DisplayObjectContainer = model.getContainer(clientObject);
			container.addChild(view);
			view.width = container.stage.stageWidth;
			view.height = container.stage.stageHeight;
			view.graphics.beginFill(0);
			view.graphics.drawRect(0, 0, view.width, view.height);

			if (viewCount == 1) {
				container.stage.addEventListener(Event.RESIZE, onResize);
			}
		}
		
		/**
		 * 
		 */
		private function onResize(e:Event):void {
			for (var key:* in views) {
				var viewParams:View3DModelParams = views[key];
				var view:View = viewParams.view;
				view.width = view.stage.stageWidth;
				view.height = view.stage.stageHeight;
				view.graphics.clear();
				view.graphics.beginFill(0);
				view.graphics.drawRect(0, 0, view.width, view.height);
			}
		}
		
		/**
		 * 
		 * @param clientObject
		 * @return 
		 */
		public function getObject3D(clientObject:ClientObject):Object3D {
			return (clientObject.getParams(View3DModelBase) as View3DModelParams).camera;
		}
		
		/**
		 * 
		 * @param clientObject
		 * @return 
		 */
		public function getParams(clientObject:ClientObject):View3DModelParams {
			return clientObject.getParams(View3DModelBase) as View3DModelParams;
		}

		/**
		 * 
		 */
		public function objectLoaded(clientObject:ClientObject):void {
		}
			
		/**
		 * 
		 */
		public function objectUnloaded(clientObject:ClientObject):void {
			Main.writeVarsToConsole("[View3DModel::objectUnloaded] %1", clientObject.id);
			var viewParams:View3DModelParams = views[clientObject];
			views.remove(clientObject);
			viewCount--;
			if (viewCount == 0) {
				viewParams.view.stage.removeEventListener(Event.RESIZE, onResize);
			}
			viewParams.view.parent.removeChild(viewParams.view);
		}

	}
}