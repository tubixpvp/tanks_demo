package alternativa.gui.layout.snap {
	
	/**
	 * Интерфейс группирующегося (с себеподобными) объекта
	 */	
	public interface ISnapGroupable	{
		
		/**
		 * Флаг группировки
		 */
		function get groupEnabled():Boolean;
		function set groupEnabled(value:Boolean):void;
		
		/**
		 * Группа, к которой принадлежит объект
		 */		
		function get snapGroup():SnapGroup;
		function set snapGroup(group:SnapGroup):void;
		
	}
}