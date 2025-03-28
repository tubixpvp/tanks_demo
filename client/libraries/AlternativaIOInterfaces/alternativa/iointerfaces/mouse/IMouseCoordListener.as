package alternativa.iointerfaces.mouse {
	import flash.geom.Point;
	
	/**
	 * Интерфейс слушателя координат мыши 
	 */	
	public interface IMouseCoordListener {
		
		/**
		 * Рассылка изменения координат мыши 
		 * @param mouseCoord координаты мыши
		 */		
		function mouseMove(mouseCoord:Point):void;
			
	}
}