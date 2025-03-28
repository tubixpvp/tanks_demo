package alternativa.utils {

	/**
	 * Утилиты для работы с текстом.
	 */	
	public final class TextUtils {

		/**
		 * Вставка переменных в строку.
		 *   
		 * @param str строка, в которой переменные должны быть обозначены в виде <code>%i, i=1..n</code>
		 * @param vars переменные в порядке их появления в строке
		 * 
		 * @return новая строка, в которой все вхождения шаблонов вида <code>%i</code> заменены на строковые значения
		 * соответствующих параметров.
		 */
		public static function insertVars(str:String, ... vars):String {
			var res:String = str;
			for (var i:int = 1; i <= vars.length; i++) {
				res = res.replace("%"+i.toString(), vars[i-1]);
			}
			return res;
		}

	}
}
