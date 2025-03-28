package alternativa.gui.widget.list {
	import alternativa.gui.base.IGUIObject;
	import alternativa.gui.widget.button.ITriggerButton;
	
	/**
	 * Интерфейс отрисовщика элемента списка 
	 */	
	public interface IListRenderer extends IGUIObject, ITriggerButton {
		
		/**
		 * Данные
		 */
		function get data():Object;
		function set data(value:Object):void;
		
		/**
		 * Ссылка на родительский список
		 */			
		function set list(listObject:List):void;
			
	}
}