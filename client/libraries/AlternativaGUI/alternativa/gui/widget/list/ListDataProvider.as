package alternativa.gui.widget.list {
	
	/**
	 * Данные элементов списка
	 */	
	public class ListDataProvider implements IListDataProvider {
		
		/**
		 * Количество элементов списка
		 */		
		private var _itemsNum:int;
		/**
		 * Данные элементов списка
		 */		
		private var _itemsData:Array;
		
		
		/**
		 * @param itemsData массив данных элементов списка
		 */				
		public function ListDataProvider(itemsData:Array) {
			_itemsNum = itemsData.length;
			_itemsData = itemsData;
		}
		
		/**
		 * Получить данные дочерних элементов
		 * @param item родительский элемент (для списка null)
		 * @param startPos индекс первого элмента
		 * @param num количество считываемых элементов
		 * @return данные для элементов
		 */		
		public function getItemsData(item:Object, startPos:int, num:int):Array {
			var items:Array = new Array();
			for (var i:int = startPos; i < startPos + num; i++) {
				items.push(_itemsData[i]);
			}
			return items;
		}
		
		/**
		 * Получить количество дочерних элементов
		 * @param item родительский элемент (для списка null)
		 * @return количество элементов
		 */
		public function getItemsNum(item:Object):int {
			return _itemsNum;
		}
		
	}
}