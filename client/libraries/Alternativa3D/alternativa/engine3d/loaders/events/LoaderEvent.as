package alternativa.engine3d.loaders.events {
	import flash.events.Event;

	/**
	 * Рассылается загрузчиками на различных этапах загрузки.
	 */
	public class LoaderEvent extends Event {
		/**
		 * Значение свойства <code>type</code> для события <code>loadingStart</code>.
		 * @eventType loadingStart
		 */		
		public static const LOADING_START:String = "loadingStart";
		/**
		 * Значение свойства <code>type</code> для события <code>loadingComplete</code>.
		 * @eventType loadingComplete
		 */		
		public static const LOADING_COMPLETE:String = "loadingComplete";
		
		// Этап загрузки
		private var _loadingStage:int;
		
		/**
		 * Создаёт новый экземпляр объекта.
		 * 
		 * @param type тип события
		 * @param loadingStage этап загрузки
		 */
		public function LoaderEvent(type:String, loadingStage:int) {
			super(type);
			_loadingStage = loadingStage;
		}
		
		/**
		 * Этап загрузки. Может принимать значения констант, описанных в классе <code>LoadingStage</code>.
		 * 
		 * @see alternativa.engine3d.loaders.LoadingStage
		 */
		public function get loadingStage():int {
			return _loadingStage;
		}
		
		/**
		 * Создаёт клон объекта.
		 * 
		 * @return клонированный объект
		 */
		override public function clone():Event {
			return new LoaderEvent(type, _loadingStage);
		}
		
		/**
		 * Создаёт строковое представление объекта.
		 * 
		 * @return строковое представление объекта
		 */
		override public function toString():String {
			return "[LoaderEvent type=\"" + type + "\", loadingStage=" + _loadingStage + "]";
		}
	}
}