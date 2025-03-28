package alternativa.osgi.service.dump {
	import __AS3__.vec.Vector;
	
	import alternativa.osgi.service.dump.dumper.IDumper;
	
	import flash.utils.Dictionary;
	
	
	public interface IDumpService {
		
		/**
		 * Зарегистрировать дампера 
		 * @param dump дампер
		 * @param dumpName имя дампера
		 * 
		 */		
		function registerDumper(dumper:Object, dumperName:String):void;
		
		/**
		 * Удалить регистрацию дампера
		 * @param dumpName имя дампера
		 */		
		function unregisterDumper(dumperName:String):void;
		
		/**
		 * Получить дамп
		 * @param strings
		 * strings[0] - имя дампера
		 * strings[1..n] - параметры
		 * @return дамп
		 */	
		function _dump(params:Vector.<String>):String;
		
		/**
		 * Дамперы поименно
		 */		
		function get dumpers():Dictionary;
		
		/**
		 * Список зарегистрированных дамперов
		 */		
		function get dumpersList():Vector.<IDumper>;
		
	}
	
}