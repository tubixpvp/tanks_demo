package alternativa.gui.container {
	import alternativa.gui.window.WindowBase;
	
	/**
	 * Интерфейс оконного контейнера 
	 */	
	public interface IWindowContainer extends IContainer {
		
		/**
		 * Добавление окна
		 * @param window окно
		 */		
		function addWindow(window:WindowBase):void;
		
		/**
		 * Удаление окна  
		 * @param window окно
		 */		
		function removeWindow(window:WindowBase):void;
		
	}
}