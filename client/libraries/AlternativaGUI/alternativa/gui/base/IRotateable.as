package alternativa.gui.base {
	
	/**
	 * Интерфейс поворачиваемого объекта 
	 */
	public interface IRotateable {
		
		/**
		 * Задать начальный угол поворота (без поворота графики)
		 * @param value угол кратный 90 градусам, заданный в радианах
		 */		
		function initAngle(value:Number):void;
		
		function set angle(value:Number):void;
		
		/**
		 * Угол поворота графики объекта (кратный 90 градусам и заданный в радианах)
		 */			
		function get angle():Number;
			
	}
}