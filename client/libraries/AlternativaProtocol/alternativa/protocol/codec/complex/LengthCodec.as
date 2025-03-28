package alternativa.protocol.codec.complex {
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	
	/**
	 * Вспомогательный класс для кодирования/декодирования длины массивов/строк 
	 */	
	public class LengthCodec {
		
		public static function encodeLength(dest:IDataOutput, length:int):void {
			if (length < 0) {
			    throw new Error("Length is incorrect (" + length +")");
			} else if (length < 128) {
			    dest.writeByte(int(length & 0x7F));
			} else if (length < 16384) {
			    var tmp:Number = (length & 0x3FFF) + 0x8000;
			    dest.writeByte(int((tmp & 0xFF00) >> 8));
			    dest.writeByte(int(tmp & 0xFF));
			} else if (length < 4194304) {
			    tmp = (length & 0x3FFFFF) + 0xC00000;
			    dest.writeByte(int((tmp & 0xFF0000) >> 16));
			    dest.writeByte(int((tmp & 0xFF00) >> 8));
			    dest.writeByte(int(tmp & 0xFF));
			} else {
			    throw new Error("Length is incorrect (" + length +")");
			}
	    }
	    
	    public static function decodeLength(reader:IDataInput):int {
			var firstByte:int = reader.readByte();
		
			var singleByte:Boolean = ((firstByte & 0x80) == 0);
			if (singleByte) {
			    return firstByte;
			} else {
			    var secondByte:int = reader.readByte();
			    var doubleByte:Boolean = (firstByte & 0x40) == 0;
			    if (doubleByte) {
					return ((firstByte & 0x3F) << 8) + (secondByte & 0xFF);
			    } else {
					var thirdByte:int = reader.readByte();
					return ((firstByte & 0x3F) << 16) + (secondByte << 8) + (thirdByte & 0xFF);
			    }
			}
	    }

	}
}