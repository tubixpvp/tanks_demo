package alternativa.debug.dump {
	import alternativa.init.Main;
	import alternativa.object.ClientObject;
	import alternativa.osgi.service.dump.dumper.IDumper;
	import alternativa.register.SpaceInfo;
	import alternativa.service.ISpaceService;
	
	import flash.utils.Dictionary;
	
	
	public class ObjectDumper implements IDumper {
		
		public function ObjectDumper() {}
		
		/**
		 * Сформировать дамп
		 * @param параметры
		 */		
		public function _dump(params:Vector.<String>):String {
			var result:String = "\n";
			var spaces:Array = ISpaceService(Main.osgi.getService(ISpaceService)).spaceList;
			for (var i:int = 0; i < spaces.length; i++) {
				var objects:Dictionary = SpaceInfo(spaces[i]).objectRegister.getObjects();
				for each (var obj:ClientObject in objects) {
					result += "   object id: " + obj.id + "\n";
				}
				result += "\n";							
			}
			return result;
		}
		
		/**
		 * Имя дампера (используемое в команде)
		 */		
		public function get name():String {
			return "object";
		}

	}
}