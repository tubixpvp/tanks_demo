package alternativa.utils {

	import flash.geom.Point;
	
	/**
	 * Математические утилиты и константы. Все векторные операции выполняются на плоскости.
	 */	
	public final class MathUtils {
		/**
		 * Коэффициент пересчёта градусов в радианы.
		 */		
		static private const toRad:Number = Math.PI/180;
		/**
		 * Коэффициент пересчёта радиан в градусы.
		 */		
		static private const toDeg:Number = 180/Math.PI;
		/**
		 * Угол в 1 градус, выраженный в радианах.
		 */		
		static public const DEG1:Number = toRad;
		/**
		 * Угол в 5 градусов, выраженный в радианах.
		 */		
		static public const DEG5:Number = Math.PI/36;
		/**
		 * Угол в 10 градусов, выраженный в радианах.
		 */
		static public const DEG10:Number = Math.PI/18;
		/**
		 * Угол в 30 градусов, выраженный в радианах.
		 */
		static public const DEG30:Number = Math.PI/6;
		/**
		 * Угол в 45 градусов, выраженный в радианах.
		 */
		static public const DEG45:Number = Math.PI/4;
		/**
		 * Угол в 60 градусов, выраженный в радианах.
		 */
		static public const DEG60:Number = Math.PI/3;
		/**
		 * Угол в 90 градусов, выраженный в радианах.
		 */
		static public const DEG90:Number = Math.PI/2;
		/**
		 * Угол в 180 градусов, выраженный в радианах.
		 */
		static public const DEG180:Number = Math.PI;
		/**
		 * Угол в 360 градусов, выраженный в радианах.
		 */
		static public const DEG360:Number = Math.PI + Math.PI;

		/**
		 * Преобразование из градусов в радианы.
		 * 
		 * @param angle угол, заданный в градусах
		 * 
		 * @return значение угла в радианах
		 */		
		static public function toRadian(angle:Number):Number {
			return angle * toRad;
		}
		
		/**
		 * Преобразование из радиан в градусы.
		 * 
		 * @param angle угол, заданный в радианах
		 * 
		 * @return значение угла в градусах
		 */		
		static public function toDegree(angle:Number):Number {
			return angle * toDeg;
		}
		
		/**
		 * Перевод значения угла в пределы -180..180 градусов
		 * 
		 * @param angle угол
		 * 
		 * @return эквивалент заданного угла, лежащий в пределах -180..180 градусов
		 */		
		static public function limitAngle(angle:Number):Number {
			var res:Number = angle % DEG360;
			res = (res > 0) ? ((res > DEG180) ? (res - DEG360) : res) : ((res < -DEG180) ? (res + DEG360) : res);
			return res;
		}
		
		/**
		 * Нахождение минимальной разницы углов. Углы должны быть лимитированы пределами -180..180 градусов.
		 * 
		 * @param a первый угол
		 * @param b второй угол
		 * 
		 * @return минимальная разница углов
		 */		
		static public function deltaAngle(a:Number, b:Number):Number {
			var delta:Number = b - a;
			if (delta > DEG180) {
				return delta - DEG360;
			} else {
				if (delta < -DEG180) {
					return delta + DEG360;
				} else {
					return delta;
				}
			}
		}
		
		/**
		 * Получение случайного числа.
		 *  
		 * @param a начало интервала
		 * @param b конец интервала
		 * 
		 * @return случайное число в интервале <code>[0, 1]</code>, если не задан параметр <code>a</code>, случайное число
		 * в интервале <code>[0, a]</code>, если не задан параметр <code>b</code>, случайное число в интервале
		 * <code>[a, b]</code>, если заданы оба параметра.
		 */		
		static public function random(a:Number = NaN, b:Number = NaN):Number {
			if (isNaN(a)) {
				return Math.random();
			} else {
				if (isNaN(b)) {
					return Math.random()*a;
				} else {
					return Math.random()*(b - a) + a;
				}
			}
		}
		
		/**
		 * Получение случайного значения угла в интервале 0..360 градусов.
		 * 
		 * @return случайное значение угла в интервале 0..360 градусов
		 */		
		static public function randomAngle():Number {
			return Math.random()*DEG360;
		}
		
		/**
		 * Сравнение чисел с заданной погрешностью.
		 * 
		 * @param a первое число
		 * @param b второе число
		 * @param threshold погрешность
		 * 
		 * @return <code>true</code>, если модуль разности чисел не превышает заданную погрешность, иначе <code>false</code>
		 */		
		static public function equals(a:Number, b:Number, threshold:Number = 0):Boolean {
			return (b - a <= threshold) && (b - a >= -threshold);
		}
				
		/**
		 * Расстояние от точки до прямой, заданной двумя точками.
		 * 
		 * @param first первая точка прямой
		 * @param second вторая точка прямой
		 * @param point точка, для которой расчитывается расстояние
		 * 
		 * @return расстояние до прямой
		 */				
		static public function segmentDistance(first:Point, second:Point, point:Point):Number {
			// Вектор ребра
			var dx:Number = second.x - first.x;
			var dy:Number = second.y - first.y;
			
			// Вектор точки
			var px:Number = point.x - first.x;
			var py:Number = point.y - first.y;
			
			// Векторное произведение (площадь параллелограмма) поделить на длину ребра 
			return (dx*py - dy*px)/Math.sqrt(dx*dx + dy*dy);
		}
		
		/**
		 * Проверка нахождения точки внутри треугольника.
		 * 
		 * @param a первая точка треугольника
		 * @param b вторая точка треугольника
		 * @param c третья точка треугольника 
		 * @param point проверяемая точка
		 * 
		 * @return <code>true</code>, если точка принадлежит треугольнику, иначе <code>false</code>
		 */		
		static public function triangleHasPoint(a:Point, b:Point, c:Point, point:Point):Boolean {
			if (vectorCross(c.subtract(a), point.subtract(a)) <= 0) {
				if (vectorCross(b.subtract(c), point.subtract(c)) <= 0) {
					if (vectorCross(a.subtract(b), point.subtract(b)) <= 0) {
						return true;
					} else {
						return false;
					}
				} else {
					return false;
				}
			} else {
				return false;
			}
		}
		
		/**
		 * Вычисление векторного произведения.
		 * 
		 * @param a первый вектор
		 * @param b второй вектор
		 * 
		 * @return векторное произведение <code>a &times; b</code>
		 */		
		static public function vectorCross(a:Point, b:Point):Number {
			return a.x*b.y - a.y*b.x;
		}

		/**
		 * Вычисление скалярного произведения векторов.
		 * 
		 * @param a первый вектор
		 * @param b второй вектор
		 * 
		 * @return скалярное произведение векторов
		 */		
		static public function vectorDot(a:Point, b:Point):Number {
			return a.x*b.x + a.y*b.y;
		}
		
		/**
		 * Вычисление угла между векторами.
		 * 
		 * @param a первый вектор
		 * @param b второй вектор
		 * 
		 * @return угол между векторами
		 */		
		static public function vectorAngle(a:Point, b:Point):Number {
			var len:Number = a.length*b.length;
			// Если один из векторов нулевой, угол - 0 градусов
			var cos:Number = (len != 0) ? (vectorDot(a, b) / len) : 1;
			return Math.acos(cos);
		}
		
		/**
		 * Вычисление угла между единичными векторами.
		 * 
		 * @param a первый единичный вектор
		 * @param b второй единичный вектор
		 * 
		 * @return угол между векторами
		 */		
		static public function vectorAngleFast(a:Point, b:Point):Number {
			var dot:Number = vectorDot(a, b);
			// Исправление ошибки округления
			if (Math.abs(dot) > 1) {
				dot = (dot > 0) ? 1 : -1;
			}			
			return Math.acos(dot);
		}

	}
}
