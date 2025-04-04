package alternativa.protocol {
	import alternativa.init.ProtocolActivator;
	import alternativa.protocol.codec.ICodec;
	import alternativa.protocol.codec.NullMap;
	import alternativa.protocol.factory.ICodecFactory;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import alternativa.osgi.service.console.IConsoleService;
	
	/**
	 * Класс для работы с протоколом 
	 */	
	public class Protocol {
		
		private static const INPLACE_MASK_FLAG:int = 0x80;
		private static const MASK_LENGTH_2_BYTES_FLAG:int = 0x40;
	
		private static const INPLACE_MASK_1_BYTES:int = 0x20;
		private static const INPLACE_MASK_3_BYTES:int = 0x60;
		private static const INPLACE_MASK_2_BYTES:int = 0x40;
		private static const MASK_LENGTH_1_BYTE:int = 0x80;
		private static const MASK_LEGTH_3_BYTE:int = 0xC00000;
		
		/**
		 * Фабрика кодеков 
		 */		
		private var codecFactory:ICodecFactory;
		/**
		 * Корневой класс для декодирования
		 */	    
		private var rootTargetClass:Class;
		
		/**
		 * @param codecFactory фабрика кодеков 
		 * @param rootCodecReference ссылка на корневой кодек
		 */		
		public function Protocol(codecFactory:ICodecFactory, rootTargetClass:Class) {
			this.codecFactory = codecFactory;
			this.rootTargetClass = rootTargetClass;
		}
		
		/**
		 * Закодировать объект
		 * @param dest писатель данных
		 * @param object объект
		 */		
		public function encode(dest:IDataOutput, object:Object):void {
			var codec:ICodec = codecFactory.getCodec(rootTargetClass);
			
			var nullMap:NullMap = new NullMap();
			
			var dataWriter:ByteArray = new ByteArray();
			codec.encode(IDataOutput(dataWriter), object, nullMap, true);
			
			var nullmapEncoded:ByteArray = encodeNullMap(nullMap);
			dataWriter.position = 0;
			//console.write("Protocol encode nullMap " + nullmapEncoded.length + "bytes", 0xff0000);
			//var map:ByteArray = nullMap.getMap();
			//map.position = 0;
			/*nullmapEncoded.position = 0;
			for (var i:int = 0; i < nullmapEncoded.length; i++) {
				console.write("		" + nullmapEncoded.readByte(), 0x666666);
			}*/
			nullmapEncoded.position = 0;
	
			dest.writeBytes(nullmapEncoded, 0, nullmapEncoded.length);
			dest.writeBytes(dataWriter, 0, dataWriter.length);
			
			dataWriter.position = 0;
			nullmapEncoded.position = 0;
				
			/*IConsoleService(ProtocolActivator.osgi.getService(IConsoleService)).writeToConsole("Protocol encode");
			IConsoleService(ProtocolActivator.osgi.getService(IConsoleService)).writeToConsole("   nullMap: ");
			while (nullmapEncoded.bytesAvailable) {
				IConsoleService(ProtocolActivator.osgi.getService(IConsoleService)).writeToConsole("   " + nullmapEncoded.readByte());
			}
			IConsoleService(ProtocolActivator.osgi.getService(IConsoleService)).writeToConsole("   data: ");
			while (dataWriter.bytesAvailable) {
				IConsoleService(ProtocolActivator.osgi.getService(IConsoleService)).writeToConsole("   " + dataWriter.readByte());
			}*/
		}
		
		/**
		 * Декодировать объект
		 * @param reader источник данных
		 * @return объект
		 */
		public function decode(reader:IDataInput):Object {
			// Получаем начальный кодек, создаем стек и помещаем корневой кодек туда
			var codec:ICodec = codecFactory.getCodec(rootTargetClass);
	
			// Создаем очередь значений и загружаем карту null-ов
			var nullMap:NullMap = decodeNullMap(reader);
			// запускаем декодирование
			return codec.decode(reader, nullMap, true);
		}
		
		/**
		 * Закодировать карту null-ов
		 * @param nullMap карта null-ов
		 * @return закодированная карта
		 */		
		private function encodeNullMap(nullMap:NullMap):ByteArray {
			var nullMapSize:int = nullMap.getSize();
			var map:ByteArray = nullMap.getMap();
			var res:ByteArray = new ByteArray();
			if (nullMapSize <= 5) {
				res.writeByte(int((map[0] & 0xFF) >>> 3));
				return res;
			} else if (nullMapSize <= 13) {
				res.writeByte(int(((map[0] & 0xFF) >>> 3) + INPLACE_MASK_1_BYTES));
				res.writeByte((((map[1] & 0xFF) >>> 3) + (map[0] << 5)));
				return res;
			} else if (nullMapSize <= 21) {
				res.writeByte(int(((map[0] & 0xFF) >>> 3) + INPLACE_MASK_2_BYTES));
				res.writeByte(int(((map[1] & 0xFF) >>> 3) + (map[0] << 5)));
				res.writeByte(int(((map[2] & 0xFF) >>> 3) + (map[1] << 5)));
				return res;
			} else if (nullMapSize <= 29) {
				res.writeByte(int(((map[0] & 0xFF) >>> 3) + INPLACE_MASK_3_BYTES));
				res.writeByte(int(((map[1] & 0xFF) >>> 3) + (map[0] << 5)));
				res.writeByte(int(((map[2] & 0xFF) >>> 3) + (map[1] << 5)));
				res.writeByte(int(((map[3] & 0xFF) >>> 3) + (map[2] << 5)));
				return res;
			} else if (nullMapSize <= 504) {
				var sizeInBytes:int = (nullMapSize >>> 3) + ((nullMapSize & 0x07) == 0 ? 0 : 1);
				var firstByte:int = int((sizeInBytes & 0xFF) + MASK_LENGTH_1_BYTE);
				res.writeByte(firstByte);
				res.writeBytes(map, 0, sizeInBytes);
				return res;
			} else if (nullMapSize <= 33554432) {
				sizeInBytes = (nullMapSize >>> 3) + ((nullMapSize & 0x07) == 0 ? 0 : 1);
				var sizeEncoded:int = sizeInBytes + MASK_LEGTH_3_BYTE;
				firstByte = int((sizeEncoded & 0xFF0000) >>> 16);
				var secondByte:int = int((sizeEncoded & 0xFF00) >>> 8);
				var thirdByte:int = int(sizeEncoded & 0xFF);
				res.writeByte(firstByte);
				res.writeByte(secondByte);
				res.writeByte(thirdByte);
				res.writeBytes(map, 0, sizeInBytes);
				return res;
			} else {
				throw new Error("NullMap overflow");
			}
		}

		/**
		 * Раскодировать карту null-ов
		 * @param reader источник данных
		 * @return карта null-ов
		 */
		private function decodeNullMap(reader:IDataInput):NullMap {
			var mask:ByteArray = new ByteArray();
			var maskLength:int;
			
			var firstByte:int = reader.readByte();
		
			var isLongNullMap:Boolean = (firstByte & INPLACE_MASK_FLAG) != 0;
			if (isLongNullMap) {
				// получаем значимую часть первого байта
				var firstByteValue:int = (firstByte & 0x3F);
		
				// в первых байтах - длина маски
				var isLength22bit:Boolean = (firstByte & MASK_LENGTH_2_BYTES_FLAG) != 0;
		
				// длина маски в байтах
				if (isLength22bit) {
					// размерность длины 22 бит
					var secondByte:int = reader.readByte();
					var thirdByte:int = reader.readByte();
					maskLength = (firstByteValue << 16) + (secondByte << 8) + (thirdByte & 0xFF);
				} else {
					// размерность длины 6 бит
					maskLength = firstByteValue;
				}
				reader.readBytes(mask, 0, maskLength);
		
				var sizeInBits:int = maskLength << 3;
				return new NullMap(sizeInBits, mask);
			} else {
				// в первых байтах - сама маска
				firstByteValue = int(firstByte << 3);
		
				maskLength = int((firstByte & 0x60) >> 5);
		
				var fourthByte:int;
				switch (maskLength) {
					case 0:
						mask.writeByte(firstByteValue);
						return new NullMap(5, mask);
					case 1:
						secondByte = reader.readByte();
						mask.writeByte(int(firstByteValue + ((secondByte & 0xFF) >>> 5)));
						mask.writeByte(int(secondByte << 3));
						return new NullMap(13, mask);
					case 2:
						secondByte = reader.readByte();
						thirdByte = reader.readByte();
						mask.writeByte(int((firstByteValue) + ((secondByte & 0xFF) >>> 5)));
						mask.writeByte(int((secondByte << 3) + ((thirdByte & 0xFF) >>> 5)));
						mask.writeByte(int(thirdByte << 3));
						return new NullMap(21, mask);
					case 3:
						secondByte = reader.readByte();
						thirdByte = reader.readByte();
						fourthByte = reader.readByte();
						mask.writeByte(int((firstByteValue) + ((secondByte & 0xFF) >>> 5)));
						mask.writeByte(int((secondByte << 3) + ((thirdByte & 0xFF) >>> 5)));
						mask.writeByte(int((thirdByte << 3) + ((fourthByte & 0xFF) >>> 5)));
						mask.writeByte(int(fourthByte << 3));
						return new NullMap(29, mask);
					default:
						// глюки
						return null;
				}
			}
			return null;
		}

	}
}