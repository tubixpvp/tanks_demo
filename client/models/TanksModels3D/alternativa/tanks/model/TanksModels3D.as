package alternativa.tanks.model {
	import alternativa.init.Main;
	import alternativa.model.IModel;
	import alternativa.model.IObjectLoadListener;
	import alternativa.model.general.world3d.IObject3DListener;
	import alternativa.resource.ResourceType;
	import alternativa.resource.factory.A3DResourceFactory;
	import projects.tanks.models.tank.ITankModelBase;
	import projects.tanks.models.map.IMapModelBase;
	import alternativa.osgi.service.console.IConsoleService;
	
	
	public class TanksModels3D {
		
		public static function init():void {
			//Main.console.write("[TanksModels3D::init]");
			(Main.osgi.getService(IConsoleService) as IConsoleService).writeToConsole("[TanksModels3D::init]");
			
			var model:IModel = new TankModel();
			Main.modelsRegister.add(model, [IModel, ITankModelBase, IObjectLoadListener, ITankParams, IObject3DListener]);

			model = new MapModel();
			Main.modelsRegister.add(model, [IModel, IMapModelBase, IObject3DListener]);
			
			// Регистрация загрузчика 
			Main.resourceRegister.registerResourceFactory(new A3DResourceFactory(), ResourceType.A3D_COLLISION_DATA);
		}
		
	}
}