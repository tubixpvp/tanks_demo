package alternativa.types {
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	
	public class LongFactory {
		
		private static var long:Dictionary = new Dictionary(false);
		private static var longArray:ByteArray = new ByteArray();
		
		public static function getLong(high:int, low:int):Long {
			var value:Long;
			if (long[low] != null) {
				if (long[low][high] != null) {
					value = long[low][high];
				} else {
					value = new Long(low, high);
					long[low][high] = value;
				}
			} else {
				long[low] = new Dictionary(false);
				value = new Long(low, high);
				long[low][high] = value;
			}
			return value;
		}
		
		public static function getLongByString(s:String):Long {
			var high:int = 0;
			var low:int = 0;
			while (s.length < 16) {
				s = "0" + s;
			}
			high = int("0x" + s.substr(0, 8));
			low = int("0x" + s.substr(8, 8)); 
			return getLong(high, low);
		}
		
		public static function LongToByteArray(value:Long):ByteArray {
			longArray.position = 0;
			longArray.writeInt(value.high);
			longArray.writeInt(value.low);
			longArray.position = 0;
			return longArray;
		}
		
		public static function integerToLong(value:int):Long {
			return LongFactory.getLong(0, value);
		}

	}
}