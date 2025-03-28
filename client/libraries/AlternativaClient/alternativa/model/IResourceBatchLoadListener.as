package alternativa.model {
	import alternativa.resource.BatchResourceLoader;
	
	/**
	 * Интерфейс слушателя события загрузки пакета ресурсов.
	 */
	public interface IResourceBatchLoadListener {
		/**
		 * Обрабатывает окончание загрузки пакета ресусров.
		 * 
		 * @param batchLoader загрузчик, выполнивший загрузку пакета ресурсов
		 */		
		function resourceBatchLoaded(batchLoader:BatchResourceLoader):void;
	}
}