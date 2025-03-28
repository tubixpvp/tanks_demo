package alternativa.osgi.service.dump.dumper {
	import __AS3__.vec.Vector;
	
	import alternativa.init.OSGi;
	
	public class ServiceDumper implements IDumper {
		
		private var osgi:OSGi;
		
		public function ServiceDumper(osgi:OSGi) {
			this.osgi = osgi;
		}
		
		/**
		 * Сформировать дамп
		 * @param параметры
		 */		
		public function _dump(params:Vector.<String>):String {
			var result:String = "\n";
			
			var services:Vector.<Object> = osgi.serviceList;
			for (var i:int = 0; i < services.length; i++) {
				result += "   service " + (i+1).toString() + ": " + services[i] + "\n";
			}					
			result += "\n";
			return result;
		}
		
		/**
		 * Имя дампера (используемое в команде)
		 */		
		public function get name():String {
			return "service";
		}
		
	}
}