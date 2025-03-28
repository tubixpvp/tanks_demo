package alternativa.register {
	import alternativa.init.Main;
	import alternativa.resource.IResource;
	import alternativa.resource.factory.IResourceFactory;
	import alternativa.types.Long;
	
	import flash.utils.Dictionary;
	
	/**
	 * Реестр ресурсов.
	 */	
	public class ResourceRegister {
		/**
		 * Список зарегистрированных фабрик ресурсов. Каждая библиотека во время своей инициализации должна зарегистрировать
		 * фабрики для используемых ею ресурсов.
		 */		
		private var resourceFactories:Dictionary;
		/**
		 * Ресурсы по id.
		 */		
		private var resources:Dictionary;
		/**
		 * Список ресурсов.
		 */
		private var _resourcesList:Array;
		
		/**
		 * Создаёт новый экземпляр реестра ресурсов.
		 */
		public function ResourceRegister() {
			resources = new Dictionary();
			resourceFactories = new Dictionary();
			_resourcesList = new Array();
		}
		
		/**
		 * Регистрирует ресурс.
		 * 
		 * @param resource регистрируемый ресурс
		 * @param id
		 */
		public function registerResource(resource:IResource):void {
			resources[resource.id] = resource;
			_resourcesList.push(resource);
			Main.writeToConsole("Ресурс " + resource.name + " id:" + resource.id + " зарегистрирован", 0x666666);
		}
		
		public function unregisterResource(id:Long):void {
			Main.writeToConsole("Регистрация ресурса " + IResource(resources[id]).name + " id:" + id + " удалена", 0x666666);
			_resourcesList.splice(_resourcesList.indexOf(resources[id], 1));
			delete resources[id];
		}
		
		// Получить ресурс по идентификатору
		public function getResource(id:Long):IResource {
			if (resources[id] == undefined) {
				//writeFatalConsole(TextUtils.insertVars(ConsoleText.RESOURCE_NOT_FOUND, id));
				return null;
			} else {
				return resources[id];
			}
		}
		
		public function registerResourceFactory(resourceFactory:IResourceFactory, resourceType:int):void {
			resourceFactories[resourceType] = resourceFactory;
			Main.writeToConsole("Loader for resource " + resourceFactory + " registered", 0x666666);
		}
		
		public function getResourceFactory(resourceType:int):IResourceFactory {
			return resourceFactories[resourceType];
		}
		
		public function get resourcesList():Array {
			return _resourcesList;
		}
		
	}
}