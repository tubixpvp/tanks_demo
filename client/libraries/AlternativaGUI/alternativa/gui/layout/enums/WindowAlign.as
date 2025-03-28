package alternativa.gui.layout.enums {
	
	/**
	 * Константы для задания выравнивания окон в оконном контейнере
	 */
	final public class WindowAlign {
		
		/* 5    ...   0
		   1 1 1  1 1 1
		   | | |  | | |
		   | | |  | | \_ TOP
		   | | |  | \___ MIDDLE 
		   | | |  \_____ BOTTOM 
		   | | |
		   | | \________ LEFT
		   | \__________ CENTER
		   \____________ RIGHT
		   
		   1001 - TOP_LEFT
		*/
		
		/**
	 	 * Нет выравнивания
	 	 */
		static public const NONE:int = 0;
		
		/**
	 	 * В верхнем левом углу
	 	 */
		static public const TOP_LEFT:int = 9;
		
		/**
	 	 * Вверху по центру
	 	 */
		static public const TOP_CENTER:int = 17;
		
		/**
	 	 * В верхнем правом углу
	 	 */
		static public const TOP_RIGHT:int = 33;
		
		/**
	 	 * По середине (по вертикали) слева
	 	 */
		static public const MIDDLE_LEFT:int = 10;
		
		/**
	 	 * По середине (по вертикали) по центру
	 	 */
		static public const MIDDLE_CENTER:int = 18;
		
		/**
	 	 * По середине (по вертикали) справа
	 	 */
		static public const MIDDLE_RIGHT:int = 34;
		
		/**
	 	 * В нижнем левом углу
	 	 */
		static public const BOTTOM_LEFT:int = 12;
		
		/**
	 	 * Внизу по центру
	 	 */
		static public const BOTTOM_CENTER:int = 20;
		
		/**
	 	 * В нижнем правом углу
	 	 */
		static public const BOTTOM_RIGHT:int = 36;
		
		/**
		 * Маска по верху
		 */		
		static public const TOP_MASK:int = 1;
		/**
		 * Маска по середине (по вертикали)
		 */
		static public const MIDDLE_MASK:int = 2;
		/**
		 * Маска по низу
		 */
		static public const BOTTOM_MASK:int = 4;
		/**
		 * Маска по левой стороне
		 */
		static public const LEFT_MASK:int = 8;
		/**
		 * Маска по центру
		 */
		static public const CENTER_MASK:int = 16;
		/**
		 * Маска по правой стороне
		 */
		static public const RIGHT_MASK:int = 32;
		
		
		/**
		 * Строковое представление для вывода в консоль
		 * @param align цифровая константа
		 * @return название выравнивания
		 */		
		public static function stringOf(align:int):String {
			var s:String;
			
			switch (align) {
				case 0:
					s = "NONE";
					break;
				case 9:
					s = "TOP_LEFT";
					break;
				case 17:
					s = "TOP_CENTER";
					break;
				case 33:
					s = "TOP_RIGHT";
					break;
				case 10:
					s = "MIDDLE_LEFT";
					break;
				case 18:
					s = "MIDDLE_CENTER";
					break;
				case 34:
					s = "MIDDLE_RIGHT";
					break;
				case 12:
					s = "BOTTOM_LEFT";
					break;
				case 20:
					s = "BOTTOM_CENTER";
					break;
				case 36:
					s = "BOTTOM_RIGHT";
					break;
			}
			return s;
		}
		
		
	}
}