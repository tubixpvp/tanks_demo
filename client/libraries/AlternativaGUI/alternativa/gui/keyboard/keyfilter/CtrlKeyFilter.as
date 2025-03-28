package alternativa.gui.keyboard.keyfilter {
	import alternativa.gui.keyboard.IKeyFilter;
	
	import flash.events.KeyboardEvent;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Фильтр событий клавиатуры, проверяющий кроме фильтруемых клавиш нажатие ctrl
	 */
	public class CtrlKeyFilter implements IKeyFilter {
		
		/**
		 * Фильтр событий клавиатуры
		 */
		private var keyFilter:IKeyFilter;
		
		
		/**
		 * @param keyFilter фильтр событий клавиатуры
		 */		
		public function CtrlKeyFilter(keyFilter:IKeyFilter) {
			this.keyFilter = keyFilter;
		}
		
		/**
		 * Профильтровать событие клавиатуры
		 * @param e событие
		 * @return результат фильтрования
		 */	
		public function filter(e:KeyboardEvent):Boolean {
			return (e.ctrlKey && keyFilter.filter(e));
		}
		
		/**
		 * Список фильтруемых клавиш
		 */
		public function get keyCode():Array {
			return keyFilter.keyCode;
		}
		
		/**
		 * @private
		 */
		public function toString():String {
			var result:String = new String();
			result+= "["+getQualifiedClassName(this)+"] " + "keyFilter: " + keyFilter;
			
			return result;	
		}
		
	}
}