package alternativa.types {

	import flash.utils.Dictionary;

	/**
	 * Множество элементов.
	 */
	dynamic public final class Set extends Dictionary {
		
		// Флаг слабых ключей
		private var weakKeys:Boolean;

		/**
		 * Создание экземпляра класса.
		 * 
		 * @param weakKeys если значение параметра равно <code>true</code>, для объектов будут использованы "слабые" ссылки.
		 * В этом случае сборщик мусора удалит объект из множества, при отсутсвии обычных ссылок на этот объект.
		 */
		public function Set(weakKeys:Boolean = false) {
			this.weakKeys = weakKeys;
			super(weakKeys);
		}

		/**
		 * Добавление объекта в множество.
		 * 
		 * @param object добавляемый объект
		 */
		public function add(object:*):void {
			this[object] = true;
		}

		/**
		 * Удаление объекта из множества.
		 * 
		 * @param object удаляемый объект
		 */
		public function remove(object:*):void {
			delete this[object];
		}

		/**
		 * Получение первого попавшегося объекта множества.
		 * 
		 * @return первый попавшийся объект
		 */
		public function peek():* {
			for (var object:* in this) {
				return object;
			}
			return null;
		}
		
		/**
		 * Получение первого попавшегося объекта и удаление его из множества.
		 *  
		 * @return первый попавшийся объект
		 */
		public function take():* {
			for (var object:* in this) {
				delete this[object];
				return object;
			}
			return null;
		}
		
		/**
		 * Получение случайного объекта множества.
		 * 
		 * @return случайно выбранный объект 
		 */
		public function any():* {
			var n:uint = 0;
			var num:uint = Math.random()*length;
			for (var object:* in this) {
				if (n == num) {
					return object;
				}
				n++;
			}
			return null;
		}

		/**
		 * Количество объектов в множестве.
		 *  
		 * @return количество объектов 
		 */
		public function get length():uint {
			var res:uint = 0;
			for (var object:* in this) {
				res++;
			}
			return res;
		}
		
		/**
		 * Проверка наличия объекта в множестве.
		 *  
		 * @param object проверяемый на наличие объект
		 * 
		 * @return <code>true</code>, если объект находится в множестве, иначе <code>false</code>
		 */
		public function has(object:*):Boolean {
			return this[object];
		}
		
		/**
		 * Проверка множества на наличие элементов.
		 * 
		 * @return <code>true</code>, если множество пусто, иначе <code>false</code>
		 */
		public function isEmpty():Boolean {
			for (var object:* in this) {
				return false;
			}
			return true;
		}
		
		/**
		 * Проверка, содержит ли множество единственный элемент.
		 * 
		 * @return <code>true</code>, если множество содержит один объект, иначе <code>false</code>
		 */
		public function isSingle():Boolean {
			var single:Boolean = false;
			for (var object:* in this) {
				if (single) {
					return false;
				}
				single = true;
			}
			return single;
		}
		
		/**
		 * Удаление всех объектов из множества.
		 */
		public function clear():void {
			for (var object:* in this) {
				delete this[object];
			}
		}
		
		/**
		 * Присоединение множества.
		 * 
		 * @param s множество, объекты которого добавляются в текущее множество
		 */
		public function concat(s:Set):void {
			for (var object:* in s) {
				this[object] = true;
			}
		}
		
		/**
		 * Вычитание множества.
		 * 
		 * @param s множество, объекты которого удаляются из текущее множества
		 */
		public function subtract(s:Set):void {
			for (var object:* in s) {
				delete this[object];
			}
		}
		
		/**
		 * Пересечение с множеством.
		 * 
		 * @param s множество, с которым выполняется пересечение. В текущем множестве остаются только те объекты, которые
		 * содержатся и в текущем множестве и в множестве <code>s</code>
		 */
		public function intersect(s:Set):void {
			var res:Set = new Set(true);
			for (var object:* in this) {
				if (s[object]) {
					res[object] = true;
				}
				delete this[object];
			}
			concat(res);
		}
		
		/**
		 * Получение объединения множеств.
		 * 
		 * @param a первое множество
		 * @param b второе множество
		 * @param weakKeys флаг слабых ключей для нового множества
		 * 
		 * @return новое множество, содержащее объекты обоих множеств  
		 */
		public static function union(a:Set, b:Set, weakKeys:Boolean = false):Set {
			var res:Set = new Set(weakKeys);
			for (var object:* in a) {
				res[object] = true;
			}
			for (object in b) {
				res[object] = true;
			}
			return res;
		}
		
		/**
		 * Получение разности множеств.
		 * 
		 * @param a множество, из которого вычитаются элементы
		 * @param b вычитаемое множество
		 * @param weakKeys флаг слабых ключей для нового множества
		 * 
		 * @return новое множество, содержащее объекты множества <code>a</code>, за исключением объектов множества <code>b</code>
		 */
		public static function difference(a:Set, b:Set, weakKeys:Boolean = false):Set {
			var res:Set = new Set(weakKeys);
			for (var object:* in a) {
				if (!b[object]) {
					res[object] = true;
				}
			}
			return res;
		}
		
		/**
		 * Получение пересечения множеств.
		 * 
		 * @param a первое множество
		 * @param b второе множество
		 * @param weakKeys флаг слабых ключей для нового множества
		 * 
		 * @return новое множество, содержащее только те объекты, которые присутствуют и в множестве <code>a</code>,
		 * и в множестве <code>b</code>
		 */
		public static function intersection(a:Set, b:Set, weakKeys:Boolean = false):Set {
			var res:Set = new Set(weakKeys);
			for (var object:* in a) {
				if (b[object]) {
					res[object] = true;
				}
			}
			return res;
		}
		
		/**
		 * Создание множества из элементов массива.
		 *  
		 * @param elements массив объектов, помещаемых в множество
		 * @param weakKeys флаг слабых ключей
		 * @return новое множество, содержащее все объекты из переданного массива
		 */
		public static function createFromArray(elements:Array, weakKeys:Boolean = false):Set {
			var res:Set = new Set(weakKeys);
			for each (var object:* in elements) {
				res[object] = true;
			}
			return res;
		}
		
		
		/**
		 * Клонирование множества.
		 * 
		 * @return новое множество, включающее все объекты данного множества 
		 */
		public function clone():Set {
			var res:Set = new Set(weakKeys);
			for (var object:* in this) {
				res[object] = true;
			}
			return res;
		}

		/**
		 * Представление множества в виде массива.
		 * 
		 * @return новый массив, заполненный объектами данного множества 
		 */
		public function toArray():Array {
			var res:Array = new Array();
			for (var object:* in this) {
				res.push(object);
			}
			return res;
		}

		/**
		 * Строковое представление множества.
		 *  
		 * @return строка, в которой через запятую перечисляются объекты множества 
		 */
		public function toString():String {
			var counter:int = 0;
			var res:String = "";
			for (var object:* in this) {
				res += "," + object;
				counter++;
			}
			return "[Set length:" + counter + (counter > 0 ? " " + res.substring(1) : "") + "]";
		}

	}
}
