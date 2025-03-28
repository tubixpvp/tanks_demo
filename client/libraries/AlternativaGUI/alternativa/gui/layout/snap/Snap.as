package alternativa.gui.layout.snap {
	
	/**
	 * Константы для указания активных сторон магнитного объекта (<code>ISnapable</code>)
	 */	
	final public class Snap {
		
		/* 7      ...     0
		   1 1 1 1  1 1 1 1
		   | | | |  | | | |  ----- Снапинг внешних сторон
		   | | | |  | | | \_ LEFT
		   | | | |  | | \___ TOP 
		   | | | |  | \_____ RIGHT
		   | | | |	\_______ BOTTOM
		   | | | |
		   | | | |			 ----- Снапинг внутренних сторон
		   | | | \__________ LEFT
		   | | \____________ TOP 
		   | \______________ RIGHT
		   \________________ BOTTOM
		   
		   1010 - объект снапится только верхней и нижней стороной и только снаружи 
		*/
		
		//----- Маски для битовых операций
		
		/**
	 	 * Нет снапинга
		 */
		static public const NONE:int = 0;
		/**
	 	 * Снапинг всеми сторонами
		 */
		static public const FULL:int = 255;
		/**
	 	 * Снапинг всеми внешними сторонами
		 */
		static public const EXTERNAL:int = 15;   // 0000 1111
		/**
	 	 * Снапинг всеми внутренними сторонами
		 */
		static public const INTERNAL:int = 240;  // 1111 0000 
		
		// Снапинг по стороне (снаружи и внутри)
		/**
		 * Снапинг левой стороной
		 */		
		static public const LEFT:int = 17;       // 0001 0001
		/**
		 * Снапинг верхней стороной
		 */
		static public const TOP:int = 34;        // 0010 0010
		/**
		 * Снапинг правой стороной
		 */
		static public const RIGHT:int = 68;      // 0100 0100
		/**
		 * Снапинг нижней стороной
		 */
		static public const BOTTOM:int = 136;    // 1000 1000
		
		// Снапинг с конкретной стороны
		/**
		 * Снапинг внешней левой стороной
		 */		
		static public const EXT_LEFT:int = 1;    // 0000 0001
		/**
		 * Снапинг внешней верхней стороной
		 */
		static public const EXT_TOP:int = 2;     // 0000 0010
		/**
		 * Снапинг внешней правой стороной
		 */
		static public const EXT_RIGHT:int = 4;   // 0000 0100
		/**
		 * Снапинг внешней нижней стороной
		 */
		static public const EXT_BOTTOM:int = 8;  // 0000 1000
		
		/**
		 * Снапинг внутренней левой стороной
		 */
		static public const INT_LEFT:int = 16;   // 0001 0000
		/**
		 * Снапинг внутренней верхней стороной
		 */
		static public const INT_TOP:int = 32;    // 0010 0000
		/**
		 * Снапинг внутренней правой стороной
		 */
		static public const INT_RIGHT:int = 64;  // 0100 0000
		/**
		 * Снапинг внутренней нижней стороной
		 */
		static public const INT_BOTTOM:int = 128;// 1000 0000
		
		// Маски для отключения снапинга конкретной стороны
		/**
		 * Отключение снапинга внешней левой стороной
		 */
		static public const EXT_LEFT_RESET:int = 254;  // 1111 1110
		/**
		 * Отключение снапинга внешней верхней стороной
		 */
		static public const EXT_TOP_RESET:int = 253;   // 1111 1101
		/**
		 * Отключение снапинга внешней правой стороной
		 */
		static public const EXT_RIGHT_RESET:int = 251; // 1111 1011
		/**
		 * Отключение снапинга внешней нижней стороной
		 */
		static public const EXT_BOTTOM_RESET:int = 247;// 1111 0111
		
		/**
		 * Отключение снапинга внутренней левой стороной
		 */
		static public const INT_LEFT_RESET:int = 239;  // 1110 1111
		/**
		 * Отключение снапинга внутренней верхней стороной
		 */
		static public const INT_TOP_RESET:int = 223;   // 1101 1111
		/**
		 * Отключение снапинга внутренней правой стороной
		 */
		static public const INT_RIGHT_RESET:int = 191; // 1011 1111
		/**
		 * Отключение снапинга внутренней нижней стороной
		 */
		static public const INT_BOTTOM_RESET:int = 127;// 0111 1111
		
		
		/**
		 * Строковое представление для вывода в консоль
		 * @param snapEnabled битовая константа
		 * @return название маски сторон
		 */
		public static function stringOf(snapEnabled:int):String {
			var s:String;
			
			switch (snapEnabled) {
				case 0:
					s = "NONE";
					break;
				case 255:
					s = "FULL";
					break;
				case 15:
					s = "EXTERNAL";
					break;
				case 240:
					s = "INTERNAL";
					break;
				case 17:
					s = "LEFT";
					break;
				case 34:
					s = "TOP";
					break;
				case 68:
					s = "RIGHT";
					break;
				case 136:
					s = "BOTTOM";
					break;
				case 1:
					s = "EXT_LEFT";
					break;
				case 2:
					s = "EXT_TOP";
					break;
				case 4:
					s = "EXT_RIGHT";
					break;
				case 8:
					s = "EXT_BOTTOM";
					break;

				case 16:
					s = "INT_LEFT";
					break;
				case 32:
					s = "INT_TOP";
					break;
				case 64:
					s = "INT_RIGHT";
					break;
				case 128:
					s = "INT_BOTTOM";
					break;
				
				
				case 254:
					s = "EXT_LEFT_RESET";
					break;
				case 253:
					s = "EXT_TOP_RESET";
					break;
				case 251:
					s = "EXT_RIGHT_RESET";
					break;
				case 247:
					s = "EXT_BOTTOM_RESET";
					break;

				case 239:
					s = "INT_LEFT_RESET";
					break;
				case 223:
					s = "INT_TOP_RESET";
					break;
				case 191:
					s = "INT_RIGHT_RESET";
					break;
				case 127:
					s = "INT_BOTTOM_RESET";
					break;
					
				default:
					s = snapEnabled.toString(2);
					break;
			}
			return s;
		}
		
	}
}