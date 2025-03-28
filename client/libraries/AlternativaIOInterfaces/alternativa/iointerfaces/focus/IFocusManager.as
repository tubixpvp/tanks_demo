package alternativa.iointerfaces.focus {
	import flash.display.DisplayObject;
	import flash.display.Stage;
	
	/**
	 * Интерфейс менеджера фокусировки 
	 */	
	public interface IFocusManager {
		
		/**
		 * Инициализация 
		 * @param stage сцена
		 */		
		function init(stage:Stage):void;
		
		/**
		 * Добавить слушателя изменения фокуса
		 * @param listener слушатель
		 */	
		function addFocusListener(listener:IFocusListener):void;
		/**
		 * Удалить слушателя изменения фокуса
		 * @param listener слушатель
		 */		
		function removeFocusListener(listener:IFocusListener):void;
		
		/**
		 * Составить иерархию фокусных объектов вверх от заданного 
		 * @param focusTarget заданный объект, находящийся в фокусе
		 * @return иерархия фокусных объектов
		 */		
		function arrangeNewTree(focusTarget:IFocus):Array;
		
		/**
		 * Очистка иерархии фокусных объектов
		 */		
		function clearTree():void;
		
		/**
		 * Фокус 
		 */		
		function set focus(target:DisplayObject):void;
		
		/**
		 * Иерархия фокусных объектов
		 */		
		function get focusTree():Array;
		
		/**
		 * Объект, находящийся в фокусе
		 */		
		function get focused():IFocus;
			
	}
}