package alternativa.gui.mouse {
	
	/**
	 * Интерфейс констант мыши
	 */	
	public interface IMouseConst {
		
		/**
		 * Максимальное время между кликами двойного щелчка в мс
		 */		
		function get DOUBLE_CLICK_DELAY():int;
		
		/**
		 * Задержка перед показом хинта в мс
		 */		
		function get HINT_DELAY():int;
		
		/**
		 * Время показа хинта в мс
		 */
		function get HINT_TIMEOUT():int;
		
	}
}