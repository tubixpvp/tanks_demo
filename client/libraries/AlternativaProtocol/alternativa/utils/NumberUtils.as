package alternativa.utils {
	import flash.utils.ByteArray;
	
	
	public class NumberUtils {
		
		private static var longArray:ByteArray = new ByteArray();
		
		public static function LongToByteArray(value:Number):ByteArray {
			longArray.position = 0;
			//longArray.writeDouble(value);
			longArray.writeInt(0);
			longArray.writeInt(value);
			longArray.position = 0;
			return longArray;
		}
		
		public static function LongToString(value:Number):String {
			/*LongToByteArray(value);
			var s:String = "";
			longArray.position = 0;
			while (longArray.bytesAvailable) {
				var signs:String = longArray.readInt().toString(16);
				while (signs.length < 8) {
					signs = "0" + signs;
				}
				s += signs;
				s += " ";
			}*/			
			return value.toString();
		}
		
		public static function integerToLong(value:int):Number {
			longArray.position = 0;
			longArray.writeInt(0);
			longArray.writeInt(value);
			longArray.position = 0;
			
			return longArray.readDouble();
		}

	}
}