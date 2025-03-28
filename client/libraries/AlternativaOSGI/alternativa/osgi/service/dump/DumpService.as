package alternativa.osgi.service.dump {
	import alternativa.init.OSGi;
	import alternativa.osgi.service.dump.dumper.IDumper;
	
	import flash.utils.Dictionary;
	
	/**
	 * Сервис вывода информации в консоль 
	 */	
	public class DumpService implements IDumpService {
		
		private var osgi:OSGi;
		
		private var _dumpers:Dictionary;
		private var _dumpersList:Vector.<IDumper>;
		
		
		public function DumpService(osgi:OSGi) {
			this.osgi = osgi;
			_dumpers = new Dictionary(false);
			_dumpersList = new Vector.<IDumper>();
		}
		
		/**
		 * Зарегистрировать дампера 
		 * @param dump дампер
		 * @param dumpName имя дампера
		 * 
		 */		
		public function registerDumper(dumper:Object, dumperName:String):void {
			if (_dumpers[dumperName] == null) {
				_dumpers[dumperName] = dumper;
				_dumpersList.push(dumper);
			} else {
				throw new Error("Dumper already registered");
			}
		}
		
		/**
		 * Удалить регистрацию дампера
		 * @param dumpName имя дампера
		 */		
		public function unregisterDumper(dumperName:String):void {
			_dumpersList.splice(_dumpersList.indexOf(_dumpers[dumperName]), 1);
			delete _dumpers[dumperName];
		}
		
		/**
		 * Получить дамп
		 * @param strings
		 * strings[0] - имя дампера или его номер
		 * strings[1..n] - параметры
		 * @return дамп
		 */	
		public function _dump(params:Vector.<String>):String {
			var message:String;
			if (params.length > 0) {
				var dumper:IDumper;
				if (String(params[0]).match(/^\d+$/) != null) {
					var index:int = int(params[0]) - 1;
					if (_dumpersList[index] != null) {
						dumper = IDumper(_dumpersList[index]);
						message = dumper._dump(params);
					} else {
						message = "Dumper number " + (index+1).toString() + " not founded";
					}
				} else {
					if (_dumpers[params[0]] != null) {
						dumper = IDumper(_dumpers[params.shift()]);
						message = dumper._dump(params);
					} else {
						message = "Dumper with name '" + params[0] + "' not founded";
					}
				}
			} else {
				message = "\n";
				for (var i:int = 0; i < _dumpersList.length; i++) {
					message += "   dumper " + (i+1).toString() + ": " + IDumper(_dumpersList[i]).name + "\n";
				}					
				message += "\n";
			}
			return message;
		}
		
		/**
		 * Дамперы поименно
		 */		
		public function get dumpers():Dictionary {
			return _dumpers;
		}
		/**
		 * Список зарегистрированных дамперов
		 */
		public function get dumpersList():Vector.<IDumper> {
			return _dumpersList;
		}

	}
}