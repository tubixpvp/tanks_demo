package alternativa.gui.container {
	import alternativa.gui.base.IGUIObject;
	import alternativa.gui.layout.ILayoutManager;
	
	import flash.display.DisplayObject;
	
	/**
	 * Интерфейс контейнера GUI объектов
	 */	
	public interface IContainer	{
		
		/**
		 * Добавить объект в контейнер
		 * @param object GUI объект
		 */		
		function addObject(object:IGUIObject):void;
		
		/**
		 * Удалить объект из контейнера
		 * @param object GUI объект
		 */		
		function removeObject(object:IGUIObject):void;
		
		/**
		 * Добавить слушателя изменений количества объектов
		 * @param listener слушатель
		 */		
		function addObjectsNumListener(listener:IContainerObjectsNumListener):void;
		
		/**
		 * Удалить слушателя изменений количества объектов
		 * @param listener слушатель
		 */		
		function removeObjectsNumListener(listener:IContainerObjectsNumListener):void;
		
		/**
		 * Наличие объекта в контейнере
		 * @param object объект
		 * @return наличие объекта
		 */		
		function hasObject(object:IGUIObject):Boolean;
		
		/**
		 * Наличие дочернего графического объекта
		 * @param child графический объект
		 * @return наличие объекта
		 */		
		function contains(child:DisplayObject):Boolean;
		
		function set layoutManager(manager:ILayoutManager):void;
		/**
		 * Менеджер компоновки объектов 
		 */		
		function get layoutManager():ILayoutManager;
		
		function set minSizeChanged(value:Boolean):void;
		/**
		 * Флаг актуальности минимального размера
		 */		
		function get minSizeChanged():Boolean;
		
		/**
		 * Флаг взаимосвязи размеров сторон
		 */		
		function get sidesCorrelated():Boolean;
		
		/**
		 * Список объектов контейнера 
		 */		
		function get objects():Array;
			
	}
}