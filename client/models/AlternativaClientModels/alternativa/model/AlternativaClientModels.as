package alternativa.model {
	import __AS3__.vec.Vector;
	
	import alternativa.init.Main;
	import alternativa.model.general.IUIContainer;
	import alternativa.model.general.child.ChildModel;
	import alternativa.model.general.child.IChild;
	import alternativa.model.general.child.IChildListener;
	import alternativa.model.general.layer.LayerModel;
	import alternativa.model.general.parent.IParent;
	import alternativa.model.general.parent.ParentModel;
	import alternativa.model.general.quadro.QuadroModel;
	import alternativa.service.IModelService;
	
	import platform.models.core.child.IChildModelBase;
	import platform.models.core.layer.ILayerModelBase;
	import platform.models.core.parent.IParentModelBase;
	import platform.models.core.quadro.IQuadroModelBase;
	
	
	public class AlternativaClientModels {
		
		public static function init():void {
			Main.writeToConsole("AlternativaClientModels init", 0xff0000);
			var modelRegister:IModelService = Main.modelsRegister;
			
			// Добавление реализаций моделей
			var model:IModel = new QuadroModel();
			modelRegister.add(model, [IModel, IQuadroModelBase]);
			
			model = new ChildModel();
			modelRegister.add(model, [IModel, IChildModelBase, IChild, IObjectLoadListener]);
			
			model = new ParentModel();
			modelRegister.add(model, [IModel, IParentModelBase, IParent, IChildListener]);
			
			model = new LayerModel();
			modelRegister.add(model, [IModel, ILayerModelBase, IUIContainer]);
		}
		
	}
}