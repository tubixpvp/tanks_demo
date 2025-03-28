package alternativa.utils {

	/**
	 * Класс содержит функции конвертирования единиц измерения.
	 */		
	public class UnitsConverter {

		/**
		 * Миллиметры. 
		 */		
		public static const MILLIMETERS:Number = 1;
		/**
		 * Сантиметры.
		 */		
		public static const CENTIMETERS:Number = 10;
		/**
		 * Дюймы.
		 */		
		public static const INCHES:Number = 25.4;
		/**
		 * Футы.
		 */		
		public static const FEET:Number = 304.8;
		/**
		 * Метры.
		 */		
		public static const METERS:Number = 1000;
		/**
		 * Километры.
		 */		
		public static const KILOMETERS:Number = 1000000;

		/**
		 * Преобразует заданное значение из одних единиц измерения в другие.
		 * 
		 * @param value значение для конвертации
		 * @param sourceUnits исходные единицы измерения. Для задания значения следует использовать константы класса.
		 * @param targetUnits единицы измерения, в которые конвертируется значение. Для задания значения следует использовать константы класса.
		 * @return значение в новых единицах измерения 
		 */
		public static function convert(value:Number, sourceUnits:Number, targetUnits:Number):Number {
			return value*sourceUnits/targetUnits;
		}

		/**
		 * Вычисляет коэффициент преобразования единиц измерения.
		 * 
		 * @param sourceUnits исходные единицы измерения. Для задания значения следует использовать константы класса.
		 * @param targetUnits новые единицы измерения. Для задания значения следует использовать константы класса.
		 * 
		 * @return коэффициент преобразования единиц измерения
		 */
		public static function getConversionCoefficient(sourceUnits:Number, targetUnits:Number):Number {
			return sourceUnits/targetUnits;
		}

	}
}
