package alternativa.protocol.codec {
	import flash.utils.ByteArray;
	
	/**
	 * Битовая карта null-ов 
	 */	
	public class NullMap {
		
		/**
		 * Текущая позиция для чтения 
		 */
		private var readPosition:int;
		/**
		 * Размер карты в битах
		 */
		private var size:int;
		/**
		 * Карта в виде массива байтов
		 */
		private var map:ByteArray;
		
		/**
		 * Создание пустой карты указанного размера по указанному массиву байт 
		 * @param size размер в битах
		 * @param source массив байт 
		 */
		public function NullMap(size:int = 0, source:ByteArray = null) {
			this.map = new ByteArray();
			if (source != null) {
				this.map.writeBytes(source, 0, convertSize(size));
			}
			this.size = size;
			this.readPosition = 0;
		}
		
		/**
		 * Сброс позиции чтения в начало карты
		 */
		public function reset():void {
			this.readPosition = 0;
		}
		
		/**
		 * Установка следующего бита в указанное значение
		 * @param isNull значение
		 */
		public function addBit(isNull:Boolean):void {
			setBit(size, isNull);
			size++;
		}
		
		/**
		 * Получение следующего бита. Сдвигает позицию чтения вперед на 1.
		 * @throws ArrayIndexOutOfBoundsError если достигнут конец карты
		 */
		public function getNextBit():Boolean {
			if (readPosition >= size) {
				throw new Error("Index out of bounds: " + readPosition);
			}
			var res:Boolean = getBit(readPosition);
			readPosition++;
			
			return res;
		}
		
		/**
		 * Получение карты в виде массива байтов
		 * @return массив байт
		 */
		public function getMap():ByteArray {
			return map;
		}
		
		/**
		 * Получение размера карты в битах
		 * @return размер карты
		 */
		public function getSize():int {
			return size;
		}
		
		/**
		 * Получение бита в конкретной позиции
		 * @param position позиция
		 * @return значение бита
		 */
		private function getBit(position:int):Boolean {
			var targetByte:int = position >> 3;
			var targetBit:int = 7 ^ (position & 7);
			this.map.position = targetByte;
			return (this.map.readByte() & (1 << targetBit)) != 0;
		}
		
		/**
		 * Установка бита в конкретной позиции
		 * @param position позиция
		 * @param value значение бита
		 */
		private function setBit(position:int, value:Boolean):void {
			var targetByte:int = position >> 3;
			var targetBit:int = 7 ^ (position & 7);
			this.map.position = targetByte;
			if (value) {
				this.map.writeByte(int(this.map[targetByte] | (1 << targetBit)));
			} else {
				this.map.writeByte(int(this.map[targetByte] & (0xff ^ (1 << targetBit))));
			}
		}
		
		/**
		 * Преобразование размера карты в битах в размер карты в виде массива байтов
		 * @param sizeInBits размер в битах
		 * @return размер в байтах
		 */
		private function convertSize(sizeInBits:int):int {
			var i:int = sizeInBits >> 3;
			var add:int = (sizeInBits & 0x07) == 0 ? 0 : 1;
			return i + add;
		}
		
	}
}