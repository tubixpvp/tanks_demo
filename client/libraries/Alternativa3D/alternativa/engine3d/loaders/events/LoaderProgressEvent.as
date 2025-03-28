package alternativa.engine3d.loaders.events {
	import flash.events.Event;
	import flash.events.ProgressEvent;

	/**
	 * Рассылается загрузчиками для отображения прогресса загрузки.
	 * Свойства <code>bytesLoaded</code> и <code>bytesTotal</code> показывают значения для текущего загружаемого элемента.
	 */
	public class LoaderProgressEvent extends ProgressEvent {
		/**
		 * Значение свойства <code>type</code> для события <code>loadingProgress</code>.
		 * @eventType loadingProgress
		 */		
		public static const LOADING_PROGRESS:String = "loadingProgress";
		
		// Этап загрузки сцены
		private var _loadingStage:int;
		// Общее количество загружаемых элементов на текущем этапе загрузки
		private var _totalItems:int;
		// Номер элемента на текущем этапе загрузки сцены, с которым связано событие. Нумерация начинается с нуля.
		private var _currentItem:int;
		
		/**
		 * Создаёт новый экземпляр события.
		 * 
		 * @param type тип события
		 * @param loadingStage этап загрузки сцены, в качестве значения параметра могут быть использованы константы класса <code>LoadingStage</code>
		 * @param totalItems общее количество загружаемых элементов на текущем этапе загрузки
		 * @param currentItem номер элемента на текущем этапе загрузки, с которым связано событие. Нумерация начинается с нуля.
		 * @param bytesLoaded количество загруженных байтов текущего элемента
		 * @param bytesTotal общее количество байтов текущего элемента
		 * 
		 * @see alternativa.engine3d.loaders.LoadingStage
		 */
		public function LoaderProgressEvent(type:String, loadingStage:int, totalItems:int, currentItem:int, bytesLoaded:uint = 0, bytesTotal:uint = 0) {
			super(type, false, false, bytesLoaded, bytesTotal);
			_loadingStage = loadingStage;
			_totalItems = totalItems;
			_currentItem = currentItem;
		}
		
		/**
		 * Этап загрузки сцены. В качестве значения параметра могут быть использованы константы класса <code>LoadingStage</code>.
		 * 
		 * @see alternativa.engine3d.loaders.LoadingStage
		 */
		public function get loadingStage():int {
			return _loadingStage;
		}

		/**
		 * Общее количество загружаемых элементов на текущем этапе загрузки.
		 */
		public function get totalItems():int {
			return _totalItems;
		}
		
		/**
		 * Номер элемента на текущем этапе загрузки, с которым связано событие. Нумерация начинается с нуля.
		 */
		public function get currentItem():int {
			return _currentItem;
		}
		
		/**
		 * Создаёт клон объекта.
		 * 
		 * @return клонированный объект
		 */
		override public function clone():Event {
			return new LoaderProgressEvent(type, _loadingStage, _totalItems, _currentItem, bytesLoaded, bytesTotal);
		}
	
		/**
		 * Создаёт строковое представление объекта.
		 * 
		 * @return строковое представление объекта
		 */
		override public function toString():String {
			return "[LoaderProgressEvent type=\"" + type + "\", loadingStage=" + _loadingStage + ", totalItems=" + _totalItems + ", currentItem=" + _currentItem + ", bytesTotal=" + bytesTotal + ", bytesLoaded=" + bytesLoaded + "]";
		}

	}
}