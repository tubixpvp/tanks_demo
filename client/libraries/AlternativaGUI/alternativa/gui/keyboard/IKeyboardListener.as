package alternativa.gui.keyboard {
	
	/**
	 * Интерфейс слушателя событий клавиатуры
	 */	
	public interface IKeyboardListener {
		
		/**
		 * Конфигурация фильтров и функций,
		 * вызываемых по нажатию и отжатию клавиш клавиатуры 
		 */		
		function get keyFiltersConfig():KeyFiltersConfig;
		
	}
}