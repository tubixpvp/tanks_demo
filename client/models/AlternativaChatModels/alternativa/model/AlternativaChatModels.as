package alternativa.model {
	import alternativa.init.Main;
	import alternativa.model.chat.ChatModel;
	import alternativa.osgi.bundle.IBundleActivator;
	import alternativa.init.OSGi;
	import projects.tanks.models.chat.IChatModelBase;
	
	public class AlternativaChatModels implements IBundleActivator {

		public function start(osgi:OSGi) : void
		{
			Main.console.writeToConsole("AlternativaChatModels init start", 0xFF0000);
			
			var model:IModel;
			
			model = new ChatModel();
			Main.modelsRegister.add(model, [IModel, IChatModelBase, IObjectLoadListener]);
			
			Main.console.writeToConsole("AlternativaChatModels init completed", 0xFF0000);
		}
		public function stop(osgi:OSGi) : void
		{
		}

	}
}