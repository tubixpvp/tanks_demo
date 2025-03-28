package alternativa.osgi.service.loader {
	
	/**
	 * Сервис предоставления информации о загрузке 
	 */	
	public class LoaderService implements ILoaderService {
		
		private var _loadingProgress:LoadingProgress; 
		
		public function LoaderService()	{
			_loadingProgress = new LoadingProgress();
		}
		
		/**
		 * Класс для отображения статуса и прогресса загрузки
		 */		
		public function get loadingProgress():LoadingProgress {
			return _loadingProgress;
		}

	}
}