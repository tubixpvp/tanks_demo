package alternativa.resource.factory {
	import alternativa.resource.BatchResourceLoader;
	import alternativa.resource.Resource;
	
	/**
	 * Интерфейс фабрики ресурсов. Загружаемые библиотеки должны регистрировать фабрики используемых ресурсов в центральном реестре ресурсов.
	 */
	public interface IResourceFactory {
		/**
		 * Создаёт новый ресурсный объект.
		 * 
		 * @param resourceType тип загружаемого ресурса
		 * @param loader загрузчик пакета ресурсов
		 * 
		 * @return новый ресурсный объект
		 */		
		function createResource(resourceType:int, loader:BatchResourceLoader):Resource;
	}
}