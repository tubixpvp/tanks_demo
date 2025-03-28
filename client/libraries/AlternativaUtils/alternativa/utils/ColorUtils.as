package alternativa.utils {
	
	/**
	 * Утилиты и константы для работы с цветом. Цвет представляется целым 24-битным беззнаковым числом вида 0xRRGGBB.
	 */	
	public class ColorUtils {

		static public const BLACK:uint = 0x000000;
		static public const RED:uint = 0x7F0000;
		static public const GREEN:uint = 0x007F00;
		static public const BLUE:uint = 0x00007F;
		static public const BROWN:uint = 0x7F7F00;
		static public const CYAN:uint = 0x007F7F;
		static public const MAGENTA:uint = 0x7F007F;
		static public const GRAY:uint = 0x7F7F7F;
		static public const LIGHT_RED:uint = 0xFF0000;
		static public const LIGHT_GREEN:uint = 0x00FF00;
		static public const LIGHT_BLUE:uint = 0x0000FF;
		static public const YELLOW:uint = 0xFFFF00;
		static public const LIGHT_CYAN:uint = 0x00FFFF;
		static public const LIGHT_MAGENTA:uint = 0xFF00FF;
		static public const WHITE:uint = 0xFFFFFF;

		/**
		 * Покомпонентное сложение цветов.
		 *  
		 * @param a первый цвет
		 * @param b второй цвет
		 * 
		 * @return покомпонентная сумма цветов
		 */
		static public function sum(a:uint, b:uint):uint {
			var red:int = (a & 0xFF0000) + (b & 0xFF0000); 
			var green:int = (a & 0xFF00) + (b & 0xFF00); 
			var blue:int = (a & 0xFF) + (b & 0xFF);
			return ((red >>> 24) ? 0xFF0000 : red) + ((green >>> 16) ? 0xFF00 : green) + ((blue >>> 8) ? 0xFF : blue); 
		}

		/**
		 * Покомпонентное вычитание цветов.
		 *  
		 * @param a уменьшаемый цвет
		 * @param b вычитаемый цвет
		 * 
		 * @return покомпонентная разность цветов
		 */
		static public function difference(a:uint, b:uint):uint {
			var red:int = (a & 0xFF0000) - (b & 0xFF0000); 
			var green:int = (a & 0xFF00) - (b & 0xFF00); 
			var blue:int = (a & 0xFF) - (b & 0xFF);
			return ((red < 0) ? 0 : red) + ((green < 0) ? 0 : green) + ((blue < 0) ? 0 : blue); 
		}

		/**
		 * Покомпонентное умножение цвета.
		 *  
		 * @param color цвет
		 * @param multiplier множитель
		 * 
		 * @return результат покомпонентного умножения цвета
		 */
		static public function multiply(color:uint, multiplier:Number):uint {
			var red:int = ((color & 0xFF0000) >>> 16) * multiplier;
			var green:int = ((color & 0xFF00) >>> 8) * multiplier;
			var blue:int = (color & 0xFF) * multiplier;
			return rgb(red, green, blue); 
		}
		
		/**
		 * Покомпонентная линейная интерполяция цвета. Интерполяция выполняется по формуле
		 * <code>a + (b - a)k</code>, где <code>a</code> и <code>b</code> ограничивают цветовой интервал, а <code>k</code>
		 * является параметром интерполяции.
		 * 
		 * @param a начало цветового интервала
		 * @param b конец цветового интервала
		 * @param k параметр интерполяции
		 * 
		 * @return интерполированное значение цвета
		 */		
		static public function interpolate(a:uint, b:uint, k:Number = 0.5):uint {
			var red:int = (a & 0xFF0000) >>> 16;
			red += (((b & 0xFF0000) >>> 16) - red) * k;
			var green:int = (a & 0xFF00) >>> 8;
			green += (((b & 0xFF00) >>> 8) - green) * k;
			var blue:int = a & 0xFF;
			blue += ((b & 0xFF) - blue) * k;
			return rgb(red, green, blue); 
		}
		
		/**
		 * Формирование случайного цвета, значения каналов которого лежат в заданных пределах.
		 * 
		 * @param redMin минимум для красного канала
		 * @param redMax максимум для красного канала
		 * @param greenMin минимум для зелёного канала
		 * @param greenMax максимум для зелёного канала
		 * @param blueMin минимум для синего канала
		 * @param blueMax максимум для синего канала
		 * 
		 * @return случайный цвет
		 */
		static public function random(redMin:uint = 0, redMax:uint = 255, greenMin:uint = 0, greenMax:uint = 255, blueMin:uint = 0, blueMax:uint = 255):uint {
			return rgb(MathUtils.random(redMin, redMax), MathUtils.random(greenMin, greenMax), MathUtils.random(blueMin, blueMax));
		}
		
		/**
		 * Формирование цвета по трём каналам.
		 *  
		 * @param red значение красного канала
		 * @param green значение зелёного канала
		 * @param blue значение синего канала
		 * 
		 * @return сформированный цвет
		 */		
		static public function rgb(red:int, green:int, blue:int):uint {
			return ((red < 0) ? 0 : ((red >>> 8) ? 0xFF0000 : (red << 16))) + ((green < 0) ? 0 : ((green >>> 8) ? 0xFF00 : (green << 8))) + ((blue < 0) ? 0 : ((blue >>> 8) ? 0xFF : blue)); 
		}

		/**
		 * Получение значения красного канала цвета.
		 *    
		 * @param color цвет
		 * 
		 * @return значение красного канала цвета
		 */
		static public function red(color:uint):uint {
			return (color & 0xFF0000) >>> 16; 
		}

		/**
		 * Получение значения зелёного канала цвета.
		 *    
		 * @param color цвет
		 * 
		 * @return значение зелёного канала цвета
		 */
		static public function green(color:uint):uint {
			return (color & 0xFF00) >>> 8; 
		}

		/**
		 * Получение значения синего канала цвета.
		 *    
		 * @param color цвет
		 * 
		 * @return значение синего канала цвета
		 */
		static public function blue(color:uint):uint {
			return color & 0xFF; 
		}

	}
}
