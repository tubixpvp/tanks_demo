package alternativa.iointerfaces.keyboard {
	import flash.display.DisplayObjectContainer;
	
	/**
	 * Интерфейс менеджера клавиатуры
	 */	
	public interface IKeyboardManager {
		
		/**
		 * Инициализация (в том числе регистрация в <code>IOInterfaces</code>)
		 */		
		function init(container:DisplayObjectContainer):void;
		
		/**
		 * Добавить слушателя событий клавиатуры
		 * @param listener слушатель
		 */		
		function addKeyboardListener(listener:IKeyboardListener):void;
		/**
		 * Удалить слушателя событий клавиатуры
		 * @param listener слушатель
		 */		
		function removeKeyboardListener(listener:IKeyboardListener):void;
		
		/**
		 * Список кодов нажатых клавиш
		 */		
		function get pressedKeys():Array;
		
	}
}