package alternativa.iointerfaces.keyboard.keyfilter {
	import alternativa.init.IOInterfaces;
	import alternativa.iointerfaces.focus.IFocus;
	import alternativa.iointerfaces.keyboard.IKeyFilter;
	
	import flash.events.KeyboardEvent;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Фильтр событий клавиатуры, проверяющий кроме фильтруемых клавиш в фокусе ли нужный объект
	 */
	public class FocusKeyFilter implements IKeyFilter {
		
		/**
		 * Объект, который должен быть в фокусе 
		 */		
		private var focusObject:IFocus;
		/**
		 * Фильтр событий клавиатуры
		 */
		private var keyFilter:IKeyFilter;
		
		
		/**
		 * @param focusObject объект, который должен быть в фокусе
		 * @param keyFilter фильтр событий клавиатуры
		 */		
		public function FocusKeyFilter(focusObject:IFocus, keyFilter:IKeyFilter) {
			this.focusObject = focusObject;
			this.keyFilter = keyFilter;
		}
		
		/**
		 * Профильтровать событие клавиатуры
		 * @param e событие
		 * @return результат фильтрования
		 */	
		public function filter(e:KeyboardEvent):Boolean {
			return ((focusObject == IOInterfaces.focusManager.focused) && keyFilter.filter(e));
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