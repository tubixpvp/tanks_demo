package alternativa.gui.focus {
	
	/**
	 * Интерфейс слушателя изменений фокуса 
	 */	
	public interface IFocusListener	{
		
		/**
		 * Рассылка изменения фокуса 
		 * @param focusOutObject объект, потерявший фокус
		 * @param focusInObject объект, получивший фокус
		 */		
		function focusChanged(focusOutObject:IFocus, focusInObject:IFocus):void;
			
	}
}