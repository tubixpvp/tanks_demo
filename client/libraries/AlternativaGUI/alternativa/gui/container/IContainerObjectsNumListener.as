package alternativa.gui.container {
	
	/**
	 * Интерфейс слушателя изменений количества объектов в контейнере 
	 */	
	public interface IContainerObjectsNumListener {
		
		/**
		 * В контейнер добавлены объекты 
		 * @param objects добавленные объекты
		 */		
		function objectsAdded(objects:Array):void;
		
		/**
		 * Из контейнера удалены объекты 
		 * @param objects удаленные объекты
		 */		
		function objectsRemoved(objects:Array):void;
		
	}
	
}