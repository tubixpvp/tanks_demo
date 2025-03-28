package alternativa.gui.layout {
	import alternativa.gui.container.IWindowContainer;
	import alternativa.gui.window.WindowBase;
	
	/**
	 * Интерфейс оконного компоновщика
	 */	
	public interface IWindowLayoutManager extends ILayoutManager {
		
		/**
		 * Свернуть окно 
		 * @param window окно
		 */		
		function minimizeWindow(window:WindowBase):void;
		
		/**
		 * Развернуть окно
		 * @param window окно
		 */		
		function maximizeWindow(window:WindowBase):void;
		
		/**
		 * Вернуть окну прежний размер (каким он был до разворачивания)
		 * @param window окно
		 */		
		function restoreWindow(window:WindowBase):void;
			
	}
}