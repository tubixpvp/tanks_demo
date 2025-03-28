package alternativa.types {
	
	public final class Long {
		
		private var _low:int;
		private var _high:int;
		
		public function Long(low:int, high:int) {
			_low = low;
			_high = high;
		}
		
		public function get low():int {
			return _low;
		}
		public function get high():int {
			return _high;
		}
		
		public function toString():String {
			var lowString:String = _low.toString(16);
			if (_low < 0) {
				return lowString;
			}
			while (lowString.length < 6) {
				lowString = "0" + lowString;
			}
			var highString:String = "";
			if (_high > 0) {
				highString = _high.toString(16);
				while (highString.length < 6) {
					highString = "0" + highString;
				}
			}
			return highString + lowString;
		}
		
	}
}