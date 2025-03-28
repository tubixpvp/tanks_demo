package alternativa.iointerfaces.keyboard.keyfilter {
	import alternativa.iointerfaces.keyboard.IKeyFilter;
	
	import flash.events.KeyboardEvent;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Фильтр событий клавиатуры 
	 */	
	public class SimpleKeyFilter implements IKeyFilter {
		
		/**
		 * Список фильтруемых клавиш
		 */		
		private var _keyCode:Array;
		
		
		/**
		 * @param keyCode список кодов фильтруемых клавиш
		 */		
		public function SimpleKeyFilter(keyCode:Array) {
			_keyCode = keyCode;
		}
		
		/**
		 * Профильтровать событие клавиатуры
		 * @param e событие
		 * @return результат фильтрования
		 */	
		public function filter(e:KeyboardEvent):Boolean {
			var result:Boolean = false;
			for (var i:int = 0; i < _keyCode.length; i++) {
				if (_keyCode[i] == e.keyCode) result = true;
			}
			return result;
		}
		
		/**
		 * Список фильтруемых клавиш
		 */
		public function get keyCode():Array {
			return _keyCode;
		}
		
		/**
		 * @private 
		 */		
		public function toString():String {
			var result:String = new String();
			result+= "["+getQualifiedClassName(this)+"] " + "keyCode: " + keyCode;
			
			return result;	
		}
		
	}
}