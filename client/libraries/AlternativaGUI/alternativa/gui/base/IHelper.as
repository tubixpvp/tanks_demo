package alternativa.gui.base {
	
	/**
	 * Интерфейс корректировщика воздействий, обрабатываемых менеджером (<code>IManager</code>) 
	 */
	public interface IHelper {
		
		/**
		 * Добавить объект в список корректируемых объектов 
		 * @param object объект, реализующий конкретный для каждого хэлпера интерфейс
		 */		
		function addObject(object:Object):void;
		
		/**
		 * Удалить объект из списка корректируемых объектов 
		 * @param object удаляемый объект
		 */		
		function removeObject(object:Object):void;
		
		/**
		 * Скорректировать воздействия для объектов
		 * @param objects объекты
		 * @param influences воздействия
		 * @return скорректированные воздействия
		 */		
		function correctInfluence(objects:Array, influences:Array):Array;
			
		/**
		 * Сохранить воздействия для объектов
		 * @param objects объекты
		 * @param influences воздействия
		 */		
		function saveInfluence(objects:Array, influences:Array):void;
		
	}
	
}