package alternativa.gui.mouse {
	
	/**
	 * Интерфейс объекта, видимого для курсора
	 */
	public interface ICursorActive {
		
		/**
		 * Добавить слушателя событий курсора 
		 * @param listener слушатель событий курсора 
		 */		
		function addCursorListener(listener:ICursorActiveListener):void;
		
		/**
		 * Удалить слушателя событий курсора 
		 * @param listener слушатель событий курсора 
		 */		
		function removeCursorListener(listener:ICursorActiveListener):void;
		
		/**
		 * Список слушателей событий курсора
		 */		
		function get cursorListeners():Array;
		
		/**
		 * Флаг получения событий курсора
		 */		
		function get cursorActive():Boolean;
		function set cursorActive(value:Boolean):void;
		
		/**
		 * Внешний вид курсора при наведении на объект
		 */
		function get cursorOverType():uint;
		function set cursorOverType(type:uint):void;
		
		/**
		 * Внешний вид курсора при нажатии на объект или наведении на нажатый объект
		 */
		function get cursorPressedType():uint;
		function set cursorPressedType(type:uint):void;
		
		/**
		 * Текст всплывающей подсказки
		 */		 
		function get hint():String;
		function set hint(value:String):void;
		
	}
}