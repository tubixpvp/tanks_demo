package alternativa.osgi.service.dump.dumper {
	import alternativa.init.OSGi;
	import alternativa.osgi.bundle.Bundle;
	
	public class BundleDumper implements IDumper {
		
		private var osgi:OSGi;
		
		public function BundleDumper(osgi:OSGi) {
			this.osgi = osgi;
		}
		
		/**
		 * Сформировать дамп
		 * @param параметры
		 */		
		public function _dump(params:Vector.<String>):String {
			var result:String = "\n";
			
			var bundles:Vector.<Bundle> = osgi.bundleList;
			for (var i:int = 0; i < bundles.length; i++) {
				result += "   bundle " + (i+1).toString() + ": " + bundles[i].name + "\n";
			}					
			result += "\n";
			return result;
		}
		
		/**
		 * Имя дампера (используемое в команде)
		 */		
		public function get name():String {
			return "bundle";
		}

	}
}