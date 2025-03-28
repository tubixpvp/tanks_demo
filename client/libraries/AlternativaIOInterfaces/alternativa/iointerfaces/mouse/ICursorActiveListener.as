package alternativa.iointerfaces.mouse {
	
	/**
	 * Интерфейс слушателя событий мыши
	 */	
	public interface ICursorActiveListener {
		
		/**
		 * Рассылка одинарного щелчка
		 */		
		function click():void;
		/**
		 * Рассылка двойного щелчка
		 * (по второму подряд mouseDown)
		 */		
		function doubleClick():void;
		
		/**
		 * Флаг наведения
		 */		
		function get over():Boolean;
		function set over(value:Boolean):void;
		
		/**
		 * Флаг наведения
		 */	
		function get pressed():Boolean;
		function set pressed(value:Boolean):void;
		
		/**
		 * Флаг блокировки
		 */		
		function get locked():Boolean;
		function set locked(value:Boolean):void;
		
	}
}