package alternativa.osgi.service.loader {
	
	public interface ILoaderService	{
		
		/**
		 * Класс для отображения статуса и прогресса загрузки
		 */		
		function get loadingProgress():LoadingProgress;
		
	}
}