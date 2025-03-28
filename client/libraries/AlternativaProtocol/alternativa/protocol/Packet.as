package alternativa.protocol {
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	
	/**
	 * Класс для работы с пакетами данных 
	 */	
	public class Packet	{
		
		/**
		 * Пакеты, больше данного размера обязательно сжимаются
		 */		
		private static const ZIP_PACKET_SIZE_DELIMITER:int = 2000;
		/**
		 * Максимальный размер передаваемых данных 
		 */		
		private static const MAXIMUM_DATA_LENGTH:int = 2147483647;
	    /**
	     * 
	     */		
	    private static const LONG_SIZE_DELIMITER:int = 16384;
	    /**
	     * Флаг упаковки. Указывается, если флаг длины пакета - 0
	     */	
	    private static const ZIPPED_FLAG:int = int(0x40);
	    /**
	     * Флаг размера длины пакета.
	     * 0 - длина пакета содержится в оставшихся 6-ти битах флагового байта и последующем байте (всего 14 бит), вторым битом указан признак упаковки
	     * 1 - длина пакета содержится в оставшихся 7-ти битах флагового байта и последующих 3-х байтах (всего 31 бит). Признак упаковки принимется равным true
	     */	    
	    private static const LENGTH_FLAG:int = int(0x80);
		
		
		public function Packet() {}
		
		
		private function wrap(src:IDataInput, dst:IDataOutput, zipped:Boolean):void {
			// вычитываем данные из источника
	    	var toWrap:ByteArray = new ByteArray();
	    	while (src.bytesAvailable) {
                toWrap.writeByte(src.readByte());
	    	}
	    	toWrap.position = 0;
	    	var longSize:Boolean = isLongSize(toWrap);
	    	if (!zipped && longSize) {
	    		zipped = true;
	    	} 
			if (zipped) {
				toWrap.compress();
			}
			var length:int = toWrap.length;
		
			if (length > MAXIMUM_DATA_LENGTH) {
			    throw new Error("Packet size too big(" + length + ")");
			}
			
			if (longSize) {
			    var sizeToWrite:int = length + (LENGTH_FLAG << 24);
			    dst.writeInt(sizeToWrite);
			} else {
			    var hiByte:int = int(((length & 0xFF00) >> 8) + (zipped ? ZIPPED_FLAG : 0));
			    var loByte:int = int(length & 0xFF);
			    dst.writeByte(hiByte);
			    dst.writeByte(loByte);
			}
			dst.writeBytes(toWrap, 0, length);
		}
		
		/**
	     * Завернуть пакет данных.
	     * @param src источник данных
	     * @param dst писатель данных
	     */
	    public function wrapPacket(src:IDataInput, dst:IDataOutput):void {
	    	wrap(src, dst, determineZipped(src));
	    }
	    /**
	     * Завернуть пакет данных со сжатием.
	     * @param src источник данных
	     * @param dst писатель данных
	     */
	    public function wrapZippedPacket(src:IDataInput, dst:IDataOutput):void {
	    	wrap(src, dst, true);
	    }
	    /**
	     * Завернуть пакет данных без сжатия.
	     * @param src источник данных
	     * @param dst писатель данных
	     */
	    public function wrapUnzippedPacket(src:IDataInput, dst:IDataOutput):void {
	    	wrap(src, dst, false);
	    }
	    
	    /**
	     * Развернуть пакет данных.
	     * @param src читатель данных, источник
	     * @param dst писатель данных, назначение
	     * @return байтбуфер с результатом
	     */
	    public function unwrapPacket(src:IDataInput, dst:IDataOutput):Boolean {
	    	var result:Boolean = false;
	    	
	    	if (src.bytesAvailable >= 2) {
				// получаем байт флага
				var flagByte:int = src.readByte();
				
				// определяем размерность длины пакета
				var longSize:Boolean = (flagByte & LENGTH_FLAG) != 0;
				
				// определяем длину пакета
				var isZipped:Boolean;
				var packetSize:int;
				var readPacket:Boolean = true;
				
				if (src.bytesAvailable >= 1) {
					if (longSize) {
						if (src.bytesAvailable >= 3) {
						    // большие пакеты - всегда запакованы
						    isZipped = true;
						    var hiByte:int = (flagByte ^ LENGTH_FLAG) << 24;
						    var middleByte:int = (src.readByte() & 0xFF) << 16;
						    var loByte:int = (src.readByte() & 0xFF) << 8;
						    var loByte2:int = (src.readByte() & 0xFF);
						    packetSize = hiByte + middleByte + loByte + loByte2;
						} else {
							readPacket = false;
						}
					} else {
					    // извлекаем признак запакованности
					    isZipped = (flagByte & ZIPPED_FLAG) != 0;
					   	hiByte = (flagByte & 0x3F) << 8;
					    loByte = (src.readByte() & 0xFF);
					    packetSize = hiByte + loByte;
					}
					if (src.bytesAvailable < packetSize) {
						readPacket = false;
					}
					
			    	// вычитываем данные из источника
			    	if (readPacket) {
			    		var toUnwrap:ByteArray = new ByteArray();
			    		
				    	for (var i:int = 0; i < packetSize; i++) {
				    		toUnwrap.writeByte(src.readByte());
				    	}
						if (isZipped) {
						   toUnwrap.uncompress();
						} 
						dst.writeBytes(toUnwrap, 0, toUnwrap.length);
						
						result = true;
			    	} 
		  		}
	    	}
	    	return result;
	    	//throw new IOError("Data reading error: expected " + packetSize + " bytes, but actually got: " + src.bytesAvailable);
	    }
		
		
		private function isLongSize(reader:IDataInput):Boolean {
			return (reader.bytesAvailable >= LONG_SIZE_DELIMITER || reader.bytesAvailable == -1);
	    }
	
	    private function determineZipped(reader:IDataInput):Boolean {
			return (reader.bytesAvailable == -1 || reader.bytesAvailable > ZIP_PACKET_SIZE_DELIMITER);
	    }

	}
}