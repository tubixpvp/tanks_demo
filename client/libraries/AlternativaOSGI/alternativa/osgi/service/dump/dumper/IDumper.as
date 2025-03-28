package alternativa.osgi.service.dump.dumper {

	public interface IDumper {
		
		/**
		 * Сформировать дамп
		 * @param параметры
		 */		
		function _dump(params:Vector.<String>):String;
		
		/**
		 * Имя дампера (используемое в команде)
		 */		
		function get name():String;
		
	}
}