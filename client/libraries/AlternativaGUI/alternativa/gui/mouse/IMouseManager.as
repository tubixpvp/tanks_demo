package alternativa.gui.mouse {
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	
	/**
	 * Интерфейс менеджера мыши 
	 */	
	public interface IMouseManager {
		
		/**
		 * Инициализация (в том числе регистрация в <code>IOInterfaces</code>)
		 */		
		function init(stage:Stage, GUIcursorEnabled:Boolean = false, cursorContainer:DisplayObjectContainer = null):void;
		
		/**
		 * Смена курсора
		 * @param cursorId идентификатор курсора
		 */		
		function changeCursor(cursorId:uint):void;
		
		/**
		 * Перепроверить список объектов под курсором 
		 */
		function updateCursor():void;
		
		/**
		 * Добавить слушателя изменения координат мыши
		 * @param listener слушатель
		 */		
		function addMouseCoordListener(listener:IMouseCoordListener):void;
		/**
		 * Удалить слушателя изменения координат мыши
		 * @param listener слушатель
		 */		
		function removeMouseCoordListener(listener:IMouseCoordListener):void;
		
		/**
		 * Добавить слушателя прокрутки колесика мыши
		 * @param listener слушатель
		 */		
		function addMouseWheelListener(listener:IMouseWheelListener):void;
		/**
		 * Удалить слушателя прокрутки колесика мыши
		 * @param listener слушатель
		 */		
		function removeMouseWheelListener(listener:IMouseWheelListener):void;
		
		/**
		 * Получить список доступных типов курсоров 
		 * @return список типов курсоров 
		 */		
		function get cursorTypes():ICursorTypes;
		
		/**
		 * Получить константы мыши 
		 * @return константы мыши
		 */		
		function get mouseConst():IMouseConst;
		
		/**
		 * Объект, над которым находится курсор
		 */		
		function get overed():ICursorActive;
		
		/**
		 * Нажатый объект 
		 */		
		function get pressed():ICursorActive;
		
		/**
		 * Иерархия объектов с overed = true
		 */		
		function get overedTree():Array;
		
		/**
		 * Объекты под курсором
		 */		
		function get objectsUnderCursor():Array;
		
	}
}