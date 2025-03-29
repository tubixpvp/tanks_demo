package alternativa.gui.base {
	
	/**
	 * Интерфейс менеджера, управляющего определёнными параметрами группы объектов
	 */
	public interface IManager {
		
		/**
		 * Обработать воздействия на объекты
		 * @param objects объекты
		 * @param influences воздействия
		 */
		function handleInfluences(objects:Array, influences:Array):void;
		
		/**
		 * Добавить хэлпер для корректировки воздействий 
		 * @param helper корректировщик воздействий
		 */		
		function addHelper(helper:IHelper):void;
			
	}
}