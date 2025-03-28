package alternativa.debug.dump {
	import alternativa.init.Main;
	import alternativa.resource.IResource;
	
	
	public class ResourceDumper	{
		
		public function ResourceDumper() {}
		
		/**
		 * Сформировать дамп
		 * @param параметры
		 */		
		public function _dump(params:Array):String {
			var result:String = "\n";
			var resources:Array = Main.resourceRegister.resourcesList;
			for (var i:int = 0; i < resources.length; i++) {
				result += "   resource id: " + IResource(resources[i]).id + "  " + IResource(resources[i]).name + "\n";
			}					
			result += "\n";
			return result;
		}
		
		/**
		 * Имя дампера (используемое в команде)
		 */		
		public function get name():String {
			return "resource";
		}

	}
}