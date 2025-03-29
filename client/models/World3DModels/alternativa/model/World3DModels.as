package alternativa.model {
	import alternativa.init.Main;
	import alternativa.model.general.child.IChildListener;
	import alternativa.model.general.world3d.IObject3D;
	import alternativa.model.general.world3d.IObject3DParams;
	import alternativa.model.general.world3d.IPhysicsObject;
	import alternativa.model.general.world3d.a3d.A3DModel;
	import alternativa.model.general.world3d.object3d.Object3DModel;
	import alternativa.model.general.world3d.scene.Scene3DModel;
	import alternativa.model.general.world3d.view3d.IView3DModel;
	import alternativa.model.general.world3d.view3d.View3DModel;
	import alternativa.resource.ResourceType;
	import alternativa.resource.factory.A3DResourceFactory;
	import platform.models.general.world3d.a3d.IA3DModelBase;
	import platform.models.general.world3d.scene.IScene3DModelBase;
	import platform.models.general.world3d.object3d.IObject3DModelBase;
	import platform.models.general.world3d.view3d.IView3DModelBase;
	import alternativa.osgi.bundle.IBundleActivator;
	import alternativa.init.OSGi;
	
	public class World3DModels implements IBundleActivator {
		
		public static const A3D_RESOURCE_TYPE:int = 5;
		
		public function start(osgi:OSGi):void {
			Main.writeToConsole("World3DModels init", 0xFF0000);
			
			var model:IModel;
			
			model = new A3DModel();
			Main.modelsRegister.add(model, [IModel, IA3DModelBase, IObject3D, IObjectLoadListener, IPhysicsObject]);

			model = new Scene3DModel();
			Main.modelsRegister.add(model, [IModel, IScene3DModelBase, IObject3D, IChildListener]);
			
			model = new Object3DModel();
			Main.modelsRegister.add(model, [IModel, IObject3DModelBase, IObject3DParams, IChildListener]);
			
			model = new View3DModel();
			Main.modelsRegister.add(model, [IModel, IView3DModelBase, IObject3D, IView3DModel]);
			
			// Регистрация загрузчика A3D
			Main.resourceRegister.registerResourceFactory(new A3DResourceFactory(), ResourceType.A3D);
		}

		public function stop(osgi:OSGi) : void
		{
		}
	}
}