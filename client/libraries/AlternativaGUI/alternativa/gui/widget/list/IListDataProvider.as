package alternativa.gui.widget.list {
	
	public interface IListDataProvider {
		
		/**
		 * Получить данные дочерних элементов
		 * @param item родительский элемент (для списка null)
		 * @param startPos индекс первого элмента
		 * @param num количество считываемых элементов
		 * @return данные для элементов
		 */		
		function getItemsData(item:Object, startPos:int, num:int):Array;
		
		/**
		 * Получить количество дочерних элементов
		 * @param item родительский элемент (для списка null)
		 * @return количество элементов
		 */
		function getItemsNum(item:Object):int;
			
	}
	
}