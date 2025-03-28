package alternativa.iointerfaces.focus {
	
	/**
	 * Интерфейс объекта, на который можно установить фокус 
	 */	
	public interface IFocus	{
		
		/**
		 * Флаг фокусировки
		 */		
		function get focused():Boolean;
		function set focused(value:Boolean):void;
		
		/**
		 * Флаг фокусировки (на ком-то из детей)
		 */		
		function get childFocused():Boolean;
		function set childFocused(value:Boolean):void;
		
		/**
		 * Флаг возможности фокусировки
		 */		
		function get tabEnabled():Boolean;
		function set tabEnabled(value:Boolean):void;
		
		/**
		 * Индекс при табуляции
		 */		
		function get tabIndex():int;
		function set tabIndex(value:int):void;
		
	}
}