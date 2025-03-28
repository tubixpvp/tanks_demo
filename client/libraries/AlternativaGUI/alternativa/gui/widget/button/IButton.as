package alternativa.gui.widget.button {
	import alternativa.gui.base.IGUIObject;
	
	/**
	 * Интерфейс кнопка
	 */
	public interface IButton extends IGUIObject	{
		
		function set pressed(value:Boolean):void;
		
		function get pressed():Boolean;
		
		function set group(value:ButtonGroup):void;
		
		function get group():ButtonGroup;
		
	}
}