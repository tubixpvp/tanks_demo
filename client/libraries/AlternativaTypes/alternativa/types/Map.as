package alternativa.types {

	import flash.utils.Dictionary;

	/**
	 * Ассоциативный массив, ключами которого являются объекты. Недопустимо использовать <code>undefined</code> в качестве
	 * значений элементов массива, т.к. в этом случае метод <code>hasKey()</code> может вернуть неверный результат.
	 */
	dynamic public class Map extends Dictionary {
		
		private var weakKeys:Boolean;
		
		/**
		 * Создание экземпляра класса.
		 *  
		 * @param weakKeys если значение параметра равно <code>true</code>, для ключей будут использованы "слабые" ссылки.
		 * В этом случае сборщик мусора удалит ключ из ассоциативного массива, при отсутсвии обычных ссылок на этот ключ.
		 */
		public function Map(weakKeys:Boolean = false) {
			this.weakKeys = weakKeys;
			super(weakKeys);
		}
		
		/**
		 * Добавление пары ключ-значение. Если пара с таким ключом уже существует, будет установлено новое значение.
		 * 
		 * @param key ключ
		 * @param value значение элемента. Недопустимо использовать <code>undefined</code> в качестве
	 	 * значений элементов массива, т.к. в этом случае метод <code>hasKey()</code> может вернуть неверный результат.
		 */
		public function add(key:*, value:*):void {
			this[key] = value;
		}
		
		/**
		 * Удаление объекта по ключу.
		 * 
		 * @param key ключ
		 */
		public function remove(key:*):void {
			delete this[key];
		}

		/**
		 * Получение первого попавшегося объекта.
		 * 
		 * @return первый попавшийся объект 
		 */
		public function peek():* {
			for (var key:* in this) {
				return this[key];
			}
			return null;
		}
		
		/**
		 * Получение первого попавшегося объекта и удаление его из ассоциативного массива.
		 * 
		 * @return первый попавшийся объект
		 */
		public function take():* {
			for (var key:* in this) {
				var value:* = this[key]; 
				delete this[key];
				return value;
			}
			return null;
		}
		
		/**
		 * Получение случайного объекта.
		 * 
		 * @return случайно выбранный объект 
		 */
		public function any():* {
			var n:uint = 0;
			var num:uint = Math.random()*length;
			for (var key:* in this) {
				if (n == num) {
					return this[key];
				}
				n++;
			}
			return null;
		}
		
		/**
		 * Количество элементов в ассоциативном массиве.
		 */
		public function get length():uint {
			var res:uint = 0;
			for (var key:* in this) {
				res++;
			}
			return res;
		}
		
		/**
		 * Проверка наличия ключа.
		 * 
		 * @param key проверяемый на наличие ключ
		 * @return <code>true</code> если есть элемент с этим ключом, иначе <code>false</code> 
		 */
		public function hasKey(key:*):Boolean {
			return this[key] !== undefined;
		}
		
		/**
		 * Проверка наличия значения.
		 * 
		 * @param value проверяемое на наличие значение
		 * @return <code>true</code> если найден элемент, равный <code>value</code>, иначе <code>false</code> 
		 */
		public function hasValue(value:*):Boolean {
			for (var key:* in this) {
				if (this[key] === value) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Проверка ассоциативного массива на наличие элементов.
		 * 
		 * @return <code>true</code> если массив не содержит элементов, иначе <code>false</code>
		 */
		public function isEmpty():Boolean {
			for (var key:* in this) {
				return false;
			}
			return true;
		}
		
		/**
		 * Проверка на наличие в массиве только одного элемента
		 * 
		 * @return <code>true</code> если в массиве один элемент, иначе <code>false</code>
		 */
		public function isSingle():Boolean {
			var single:Boolean = false;
			for (var key:* in this) {
				if (single) {
					return false;
				}
				single = true;
			}
			return single;
		}
		
		/**
		 * Удаление всех элементов ассоциативного массива.
		 */
		public function clear():void {
			for (var key:* in this) {
				delete this[key];
			}
		}
		
		/**
		 * Присоединение ассоциативного массива.
		 * 
		 * @param m ассоциативный массив, элементы которого добавляются в данный
		 */
		public function concat(m:Map):void {
			for (var key:* in m) {
				this[key] = m[key];
			}
		}
		
		/**
		 * Клонирование ассоциативного массива.
		 * 
		 * @return новый ассоциативный массив, содержащий все элементы данного 
		 */
		public function clone():Map {
			var res:Map = new Map(weakKeys);
			for (var key:* in this) {
				res[key] = this[key];
			}
			return res;
		}
		
		/**
		 * Представление ассоциативного массива в виде индексированного массива или ассоциативного массива на базе <code>Array</code>.
		 *  
		 * @param numeric если указано значение <code>true</code>, то осуществляется перевод в индексированный массив, иначе
		 * в ассоциативный со строковыми ключами
		 * @return новый массив, содержащий значения данного ассоциативного массива
		 */
		public function toArray(numeric:Boolean = false):Array {
			var res:Array = new Array();
			var key:*;
			if (numeric) {
				for (key in this) {
					res.push(this[key]);
				}
			} else {
				for (key in this) {
					res[key] = this[key];
				}
			}
			return res;
		}
		
		/**
		 * Представление ассоциативного массива в виде множества элементов.
		 * 
		 * @param weakKeys флаг использования "слабых" ссылок для ключей нового множества
		 * @return новое множество, объектами которого являются значения данного ассоциативного массива
		 */
		public function toSet(weakKeys:Boolean = false):Set {
			var res:Set = new Set(weakKeys);
			for each (var object:* in this) {
				res[object] = true;
			}
			return res;
		}

		/**
		 * Строковое представление ассоциативного массива.
		 * 
		 * @return строка, в которой через запятую перечисляются соответствия ключ:значение
		 */
		public function toString():String {
			var counter:int = 0;
			var res:String = "";
			for (var key:* in this) {
				res += "," + key + ":" + this[key];
				counter++;
			}
			return "[Map length:" + counter + (counter > 0 ? " " + res.substring(1) : "") + "]";
		}

	}
}
