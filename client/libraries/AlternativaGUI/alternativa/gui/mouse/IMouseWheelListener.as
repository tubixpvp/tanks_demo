package alternativa.gui.mouse {
	
	/**
	 * Интерфейс слушателя колесика мыши 
	 */	
	public interface IMouseWheelListener {
		
		/**
		 * Рассылка прокрутки колесика мыши 
		 * @param delta поворот
		 */		
		function mouseWheel(delta:int):void;
		
	}
}