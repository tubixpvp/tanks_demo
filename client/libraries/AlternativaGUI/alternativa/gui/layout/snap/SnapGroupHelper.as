package alternativa.gui.layout.snap {
	
	/**
	 * Группировщик
	 */	
	public class SnapGroupHelper {
		
		/**
		 * Сгруппированные объекты
		 */		
		private var objects:Array;
		/**
		 * Флаг включения/отключения группировки
		 */		
		private var _groupEnabled:Boolean;
		
		
		public function SnapGroupHelper() {
			_groupEnabled = true;
			objects = new Array();
		}
		
		//----- IHelper
		/**
		 * Добавит объект в список корректируемых объектов 
		 * @param object - объект, реализующий конкретный для каждого хэлпера интерфейс
		 */		
		public function addObject(object:Object):void {
			
		}
		/**
		 * Скорректировать воздействия для объектов
		 * @param objects - список объектов
		 * @param influences - список воздействий
		 * @return список скорректированных воздействий
		 */		
		public function correctInfluence(objects:Array, influences:Array):Array {
			
			return influences;
		}
		/**
		 * Сохранить воздействия для объектов
		 * @param objects - список объектов
		 * @param influences - список воздействий
		 */		
		public function saveInfluence(objects:Array, influences:Array):void {
			
		}
		
		/**
		 * Установить флаг группировки 
		 * @param value - значение флага группировки
		 * 
		 */		
		public function set groupEnabled(value:Boolean):void {
			_groupEnabled = value;
			// Уничтожение групп
			if (!_groupEnabled) {
				for (var i:int = 0; i < objects.length; i++) {
					if (objects[i] is ISnapGroupable) {
						if (ISnapGroupable(objects[i]).snapGroup != null)
							ISnapGroupable(objects[i]).snapGroup.removeObject(ISnapGroupable(objects[i]));
					}
				}
			}
		}
		
		/**
		 * Флаг группировки
		 */		
		public function get groupEnabled():Boolean {
			return _groupEnabled;
		}
		
	}
}
