package alternativa.debug.dump {
	import alternativa.osgi.service.dump.dumper.IDumper;
	
	
	public class ModelDumper implements IDumper {
		
		public function ModelDumper() {}
		
		/**
		 * Сформировать дамп
		 * @param параметры
		 */		
		public function _dump(params:Vector.<String>):String {
			var result:String = "\n";
			
					//var objectId:Long strings[1]
					//var models:Array = Main.modelsRegister.getModelsForObject(;
					/*for (var i:int = 0; i < spaces.length; i++) {
						result += "   socket " + i+1 + ": " + SpaceInfo(spaces[i]).sender + "\n";
					}*/					
			
			result += "\n";
			return result;
		}
		
		/**
		 * Имя дампера (используемое в команде)
		 */		
		public function get name():String {
			return "model";
		}

	}
}