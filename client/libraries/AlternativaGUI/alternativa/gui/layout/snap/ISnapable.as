package alternativa.gui.layout.snap {
	import flash.geom.Rectangle;
	
	/**
	 * Интерфейс примагничивающегося (к себеподобным) объекта
	 */	
	public interface ISnapable {
		/**
		 * Флаг снапинга
		 */
		function get snapEnabled():Boolean;
		function set snapEnabled(value:Boolean):void;
		
		/**
		 * Побитовая конфигурация снапинга сторон
		 */		
		function get snapConfig():int;
		function set snapConfig(value:int):void;
		/* 7      ...     0
		   1 1 1 1  1 1 1 1
		   | | | |  | | | |  ----- Снапинг внешних сторон
		   | | | |  | | | \_ LEFT
		   | | | |  | | \___ TOP 
		   | | | |  | \_____ RIGHT
		   | | | |	\_______ BOTTOM
		   | | | |
		   | | | |			 ----- Снапинг внутренних сторон
		   | | | \__________ LEFT
		   | | \____________ TOP 
		   | \______________ RIGHT
		   \________________ BOTTOM
		   
		   1010 - объект снапится только верхней и нижней стороной и только снаружи 
		*/
		
		/**
		 * Габаритный контейнер для снапинга (в локальных коодинатах)
		 */		
		function get snapRect():Rectangle;
		function set snapRect(rect:Rectangle):void;
		
	}
}