package alternativa.types {

	import flash.geom.Point;
	
	/**
	 * Точка (радиус-вектор) в трёхмерном пространстве.
	 */	
	public final class Point3D {
		
		/**
		 * Координата X
		 */		
		public var x:Number;
		/**
		 * Координата Y
		 */		
		public var y:Number;
		/**
		 * Координата Z
		 */		
		public var z:Number;

		/**
		 * Вычисление суммы векторов.
		 * 
		 * @param a первое слагаемое
		 * @param b второе слагаемое
		 * @return вектор, являющийся суммой векторов <code>a</code> и <code>b</code>
		 */
		static public function sum(a:Point3D, b:Point3D):Point3D {
			return new Point3D(a.x + b.x, a.y + b.y, a.z + b.z);
		}
		
		/**
		 * Вычисление разности векторов.
		 * 
		 * @param a уменьшаемый вектор
		 * @param b вычитаемый вектор
		 * @return вектор <code>ab = a - b</code>
		 */
		static public function difference(a:Point3D, b:Point3D):Point3D {
			return new Point3D(a.x - b.x, a.y - b.y, a.z - b.z);
		}

		/**
		 * Вычисление скалярного произведения векторов.
		 * 
		 * @param a первый множитель
		 * @param b второй множитель
		 * @return скалярное произведение векторов <code>a</code> и <code>b</code>
		 */
		static public function dot(a:Point3D, b:Point3D):Number {
			return (a.x*b.x + a.y*b.y + a.z*b.z);
		}

		/**
		 * Вычисление скалярного произведения проекций векторов на плоскость XY.
		 * 
		 * @param a первый множитель
		 * @param b второй множитель
		 * @return скалярное произведение проекций векторов <code>a</code> и <code>b</code> на плоскость XY
		 */
		static public function dot2D(a:Point3D, b:Point3D):Number {
			return (a.x*b.x + a.y*b.y);
		}

		/**
		 * Вычисление векторного произведения.
		 * 
		 * @param a первый множитель
		 * @param b второй множитель
		 * @return векторное произведение векторов <code>a</code> и <code>b</code>
		 */
		static public function cross(a:Point3D, b:Point3D):Point3D {
			return new Point3D(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x);
		}

		/**
		 * Вычисление векторного произведения проекций векторов на плоскость XY.
		 * 
		 * @param a первый множитель
		 * @param b второй множитель
		 * @return векторное произведение проекций векторов <code>a</code> и <code>b</code> на плоскость XY
		 */
		static public function cross2D(a:Point3D, b:Point3D):Number {
			return a.x*b.y - a.y*b.x;
		}

		/**
		 * Вычисление угла между векторами.
		 * 
		 * @param p1 первый вектор
		 * @param p2 второй вектор
		 * @return значение угла между веторами в радианах
		 */
		static public function angle(p1:Point3D, p2:Point3D):Number {
			//var len:Number = p1.length*p2.length;
			var len:Number = Math.sqrt((p1.x*p1.x + p1.y*p1.y + p1.z*p1.z)*(p2.x*p2.x + p2.y*p2.y + p2.z*p2.z));
			// Если один из векторов нулевой, угол - 0 градусов
			var cos:Number = (len != 0) ? (dot(p1, p2) / len) : 1;
			return Math.acos(cos);
		}

		/**
		 * Вычисление угла между единичными векторами.
		 * 
		 * @param p1 первый вектор
		 * @param p2 второй вектор
		 * @return значение угла между веторами в радианах
		 */
		static public function angleFast(p1:Point3D, p2:Point3D):Number {
			var vdot:Number = dot(p1, p2);
			// Исправление ошибки округления
			if (Math.abs(vdot) > 1) {
				vdot = (vdot > 0) ? 1 : -1;
			}
			return Math.acos(vdot);
		}

		/**
		 * Линейная интерполяция координат. Интерполяция выполняется по формуле <code>p1 + (p2 - p1)k</code>, где
		 * точки <code>p1</code> и <code>p2</code> ограничивают отрезок, а <code>k</code> является параметром интерполяции.
		 * 
		 * @param p1 начальная точка отрезка
		 * @param p2 конечная точка отрезка
		 * @param k значение параметра
		 * 
		 * @return интерполированное значение координат
		 */		
		static public function interpolate(p1:Point3D, p2:Point3D, k:Number = 0.5):Point3D {
			return new Point3D(p1.x + (p2.x - p1.x)*k, p1.y + (p2.y - p1.y)*k, p1.z + (p2.z - p1.z)*k);
		}
		
		/**
		 * Вычисление средней точки.
		 * 
		 * @param a первая точка
		 * @param b вторая точка
		 * @param c третья точка
		 * @param d четвёртая точка
		 * @return средняя точка
		 */		
		static public function average(a:Point3D, b:Point3D = null, c:Point3D = null, d:Point3D = null):Point3D {
			if (b == null) {
				return a.clone();
			} else {
				if (c == null) {
					return new Point3D((a.x + b.x)*0.5, (a.y + b.y)*0.5, (a.z + b.z)*0.5);
				} else {
					if (d == null) {
						return new Point3D((a.x + b.x + c.x)/3, (a.y + b.y + c.y)/3, (a.z + b.z + c.z)/3);
					} else {
						return new Point3D((a.x + b.x + c.x + d.x)*0.25, (a.y + b.y + c.y + d.y)*0.25, (a.z + b.z + c.z + d.z)/0.25);
					}
				}
			}
		}
		
		/**
		 * Создание точки со случайными координатами.
		 * 
		 * @param xMin минимальное значение координаты X
		 * @param xMax максимальное значение координаты X
		 * @param yMin минимальное значение координаты Y
		 * @param yMax максимальное значение координаты Y
		 * @param zMin минимальное значение координаты Z
		 * @param zMax максимальное значение координаты Z
		 * @return точка со случайными координатами в указанных пределах
		 */		
		static public function random(xMin:Number = 0, xMax:Number = 0, yMin:Number = 0, yMax:Number = 0, zMin:Number = 0, zMax:Number = 0):Point3D {
			return new Point3D(xMin + Math.random()*(xMax - xMin), yMin + Math.random()*(yMax - yMin), zMin + Math.random()*(zMax - zMin));
		}

		/**
		 * Создание экземпляра класса.
		 * 
		 * @param x координата X
		 * @param y координата Y
		 * @param z координата Z
		 */
		public function Point3D(x:Number = 0, y:Number = 0, z:Number = 0) {
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		/**
		 * Длина вектора.
		 */
		public function get length():Number {
			return Math.sqrt(x*x + y*y + z*z);
		}

		/**
		 * @private
		 */
		public function set length(value:Number):void {
			if (x != 0 || y != 0 || z != 0) {
				var k:Number = value/length;
				x *= k;
				y *= k;
				z *= k;
			} else {
				z = value;
			}
		}

		/**
		 * Квадрат длины вектора.
		 */		
		public function get lengthSqr():Number {
			return x*x + y*y + z*z;
		}

		/**
		 * Нормализация вектора до единичной длины.
		 */
		public function normalize():void {
			if (x != 0 || y != 0 || z != 0) {
				var k:Number = Math.sqrt(x*x + y*y + z*z);
				x /= k;
				y /= k;
				z /= k;
			} else {
				z = 1;
			}
		}

		/**
		 * Сложение координат.
		 * 
		 * @param point точка, координаты которой прибавляются к собственным
		 */		
		public function add(point:Point3D):void {
			x += point.x;
			y += point.y;
			z += point.z;
		}

		/**
		 * Вычитание координат.
		 * 
		 * @param point точка, координаты которой вычитаются из собственных
		 */		
		public function subtract(point:Point3D):void {
			x -= point.x;
			y -= point.y;
			z -= point.z;
		}

		/**
		 * Умножение на скаляр
		 * @param n число, на которое умножаются координаты
		 */
		public function multiply(n:Number):void {
			x *= n;
			y *= n;
			z *= n;
		}

		/**
		 * Инвертирование вектора.
		 */
		public function invert():void {
			x = -x;
			y = -y;
			z = -z;
		}

		/**
		 * Сравнение координат точек с указанной погрешностью.
		 * 
		 * @param point точка для сравнения
		 * @param threshold погрешность сравнения
		 * @return <code>true</code> если модуль разности любых соответствующих координат точек не превышает указанную
		 * погрешность, иначе <code>false</code>
		 */
		public function equals(point:Point3D, threshold:Number = 0):Boolean {
			return (x - point.x <= threshold) && (x - point.x >= -threshold) && (y - point.y <= threshold) && (y - point.y >= -threshold) && (z - point.z <= threshold) && (z - point.z >= -threshold);
		}

		/**
		 * Трансформация точки (вектора). Новым значением координат становится результат умножения матрицы на вектор вида
		 * <code>M &times; r</code>.
		 * 
		 * @param m матрица трансформации
		 */
		public function transform(m:Matrix3D):void {
			var _x:Number = x;
			var _y:Number = y;
			var _z:Number = z;
			x = m.a*_x + m.b*_y + m.c*_z + m.d;
			y = m.e*_x + m.f*_y + m.g*_z + m.h;
			z = m.i*_x + m.j*_y + m.k*_z + m.l;
		}

		/**
		 * @ptivate
		 * Трансформация вектора направления.
		 * 
		 * @param m матрица трансформации
		 */
		public function transformOrientation(m:Matrix3D):void {
			var _x:Number = x;
			var _y:Number = y;
			var _z:Number = z;
			x = m.a*_x + m.b*_y + m.c*_z;
			y = m.e*_x + m.f*_y + m.g*_z;
			z = m.i*_x + m.j*_y + m.k*_z;
		}
		
		/**
		 * Копирование координат точки.
		 * 
		 * @param point точка, координаты которой копируются
		 */
		public function copy(point:Point3D):void {
			x = point.x;
			y = point.y;
			z = point.z;
		}

		/**
		 * Установка нулевых координат.
		 */
		public function reset(x:Number = 0, y:Number = 0, z:Number = 0):void {
			this.x = x;
			this.y = y;
			this.z = z;
		}

		/**
		 * Применение функции <code>Math.floor()</code> к координатам точки.
		 */		
		public function floor():void {
			x = Math.floor(x);
			y = Math.floor(y);
			z = Math.floor(z);
		}

		/**
		 * Округление координат точки.
		 */		
		public function round():void {
			x = Math.round(x);
			y = Math.round(y);
			z = Math.round(z);
		}
		
		/**
		 * Клонирование точки.
		 *  
		 * @return клонированная точка
		 */		
		public function clone():Point3D {
			return new Point3D(x, y, z);
		}
		
		/**
		 * Получение проекции точки на плоскость XY.
		 * 
		 * @return проекция точки на плоскость XY
		 */
		public function toPoint():Point {
			return new Point(x, y);
		}
	
		/**
		 * Строковое представление вектора. 
		 * 
		 * @return строковое представление вектора
		 */
		public function toString():String {
			return "[Point3D X: " + x.toFixed(3) + " Y:" + y.toFixed(3) + " Z:" + z.toFixed(3) + "]";
		}
		
		/**
		 * Вычисляет векторное произведение с заданным вектором и записывает результат в текущий вектор.
		 *  
		 * @param point
		 */
		public function cross(point:Point3D):void {
			var xx:Number = y*point.z - z*point.y;
			var yy:Number = z*point.x - x*point.z;
			var zz:Number = x*point.y - y*point.x;
			x = xx;
			y = yy;
			z = zz;
		}

		/**
		 * Вычисляет векторное произведение двух векторов и записывает результат в текущий вектор.
		 * 
		 * @param a первый вектор
		 * @param b второй вектор
		 */
		public function cross2(a:Point3D, b:Point3D):void {
			x = a.y*b.z - a.z*b.y;
			y = a.z*b.x - a.x*b.z;
			z = a.x*b.y - a.y*b.x;
		}

		/**
		 * Вычисляет скалярное произведение с заданным вектором.
		 * 
		 * @param point 
		 * @return скалярное произведение с заданным вектором
		 */
		public function dot(point:Point3D):Number {
			return x*point.x + y*point.y + z*point.z;
		}
		
		/**
		 * @private
		 * @param matrix
		 */
		public function transformTranspose(matrix:Matrix3D):void {
			var xx:Number = x*matrix.a + y*matrix.e + z*matrix.i;
			var yy:Number = x*matrix.b + y*matrix.f + z*matrix.j;
			var zz:Number = x*matrix.c + y*matrix.g + z*matrix.k;
			x = xx;
			y = yy;
			z = zz;
		}

		/**
		 * @private
		 * @param matrix
		 */
		public function inverseTransform(matrix:Matrix3D):void {
			x -= matrix.d;
			y -= matrix.h;
			z -= matrix.l;
			var xx:Number = x*matrix.a + y*matrix.e + z*matrix.i;
			var yy:Number = x*matrix.b + y*matrix.f + z*matrix.j;
			var zz:Number = x*matrix.c + y*matrix.g + z*matrix.k;
			x = xx;
			y = yy;
			z = zz;
		}
		
		/**
		 * @private
		 * @param matrix
		 */
		public function createSkewSymmetricMatrix(matrix:Matrix3D):void {
			matrix.a = matrix.f = matrix.k = matrix.d = matrix.h = matrix.l = 0;
			matrix.b = -z;
			matrix.c = y;
			matrix.e = z;
			matrix.g = -x;
			matrix.i = -y;
			matrix.j = x;
		}
		
		/**
		 * Вычисляет разность векторов и записывает результат в текущий вектор.
		 * 
		 * @param a уменьшаемый вектор
		 * @param b вычитаемый вектор
		 */
		public function difference(a:Point3D, b:Point3D):void {
			x = a.x - b.x;
			y = a.y - b.y;
			z = a.z - b.z;
		}

	}
}
