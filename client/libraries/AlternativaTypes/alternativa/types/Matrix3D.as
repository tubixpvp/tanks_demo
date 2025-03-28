package alternativa.types {
	
	/**
	 * Класс Matrix3D описывает аффинное преобразование одной трёхмерной системы координат в другую.
	 * Матрица преобразования имеет вид:
	 * <table>
	 *   <tr><td><code>a b c d</code></td></tr>
	 *   <tr><td><code>e f g h</code></td></tr>
	 *   <tr><td><code>i j k l</code></td></tr>
	 *   <tr><td><code>0 0 0 1</code></td></tr>
	 * </table>
	 * 
	 * <p>
	 * Чтобы трансформировать координату <code>(x, y, z)</code> через матрицу используются следующие формулы:
	 * <table>
	 *   <tr><td><code>x' = ax + by + cz + d</code></td></tr>
	 *   <tr><td><code>y' = ex + fy + gz + h</code></td></tr>
	 *   <tr><td><code>z' = ix + jy + kz + l</code></td></tr>
	 * </table></p>
	 * 
	 * <p>
	 * С точки зрения применения трансформаци к трёхмерному объекту, матрицу можно представить как последовательность
	 * масштабирования и вращений объекта в локальной системе координат, а затем параллельного переноса начала локальной
	 * системы координат объекта (центра объекта) в родительской системе координат. Таким образом, матрица
	 * <table>
	 *   <tr><td><code>a b c</code></td></tr>
	 *   <tr><td><code>e f g</code></td></tr>
	 *   <tr><td><code>i j k</code></td></tr>
	 * </table>
	 * описывает трансформацию объекта, расположенного в начале координат, а точка <code>(d, h, l)</code> положение центра
	 * объекта или центра матрицы.</p>
	 */	
	public final class Matrix3D {
		
		public var a:Number;
		public var b:Number;
		public var c:Number;
		public var d:Number;
		public var e:Number;
		public var f:Number;
		public var g:Number;
		public var h:Number;
		public var i:Number;
		public var j:Number;
		public var k:Number;
		public var l:Number;

		/**
		 * Получение матрицы смещения.
		 * 
		 * @param deltaX смещение по оси X
		 * @param deltaY смещение по оси Y
		 * @param deltaZ смещение по оси Z
		 * 
		 * @return матрица смещения
		 */
		static public function translationMatrix(deltaX:Number = 0, deltaY:Number = 0, deltaZ:Number = 0):Matrix3D {
			return new Matrix3D(1, 0, 0, deltaX,
								0, 1, 0, deltaY,
								0, 0, 1, deltaZ);
		}

		/**
		 * Получение обратной матрицы смещения.
		 * 
		 * @param x смещение по оси X
		 * @param y смещение по оси Y
		 * @param z смещение по оси Z
		 * 
		 * @return обратная матрица смещения
		 */
		static public function inverseTranslationMatrix(x:Number = 0, y:Number = 0, z:Number = 0):Matrix3D {
			return new Matrix3D(1, 0, 0, -x,
								0, 1, 0, -y,
								0, 0, 1, -z);
		}

		/**
		 * Получение матрицы масштабирования.
		 * 
		 * @param scaleX коэффициент масштабирования по оси X
		 * @param scaleY коэффициент масштабирования по оси Y
		 * @param scaleZ коэффициент масштабирования по оси Z
		 * 
		 * @return матрица масштабирования
		 */
		static public function scaleMatrix(scaleX:Number = 1, scaleY:Number = 1, scaleZ:Number = 1):Matrix3D {
			return new Matrix3D(scaleX, 0, 0, 0,
								0, scaleY, 0, 0,
								0, 0, scaleZ, 0);
		}

		/**
		 * Получение обратной матрицы масштабирования.
		 * 
		 * @param scaleX коэффициент масштабирования по оси X
		 * @param scaleY коэффициент масштабирования по оси Y
		 * @param scaleZ коэффициент масштабирования по оси Z
		 * 
		 * @return обратная матрица масштабирования
		 */
		static public function inverseScaleMatrix(scaleX:Number = 1, scaleY:Number = 1, scaleZ:Number = 1):Matrix3D {
			return new Matrix3D(1/scaleX, 0, 0, 0,
								0, 1/scaleY, 0, 0,
								0, 0, 1/scaleZ, 0);
		}

		/**
		 * Получение матрицы поворота. Матрица является произведением вида <code>Rz &times; Ry &times; Rx</code>.
		 *  
		 * @param rotationX угол поворота в радианах вокруг оси X
		 * @param rotationY угол поворота в радианах вокруг оси Y
		 * @param rotationZ угол поворота в радианах вокруг оси Z
		 * 
		 * @return матрица поворота 
		 */
		static public function rotationMatrix(rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0):Matrix3D {
			var cosX:Number = Math.cos(rotationX);
			var sinX:Number = Math.sin(rotationX);
			var cosY:Number = Math.cos(rotationY);
			var sinY:Number = Math.sin(rotationY);
			var cosZ:Number = Math.cos(rotationZ);
			var sinZ:Number = Math.sin(rotationZ);

			var cosZsinY:Number = cosZ*sinY;
			var sinZsinY:Number = sinZ*sinY;
			
			return new Matrix3D(cosZ*cosY, cosZsinY*sinX - sinZ*cosX, cosZsinY*cosX + sinZ*sinX, 0,
								sinZ*cosY, sinZsinY*sinX + cosZ*cosX, sinZsinY*cosX - cosZ*sinX, 0,
								-sinY, cosY*sinX, cosY*cosX, 0);
		}
		
		/**
		 * Получение обратной матрицы поворота. Матрица является произведением вида
		 * <code>Rx<sup>-1</sup> &times; Ry<sup>-1</sup> &times; Rz<sup>-1</sup></code>.
		 *  
		 * @param rotationX угол поворота в радианах вокруг оси X
		 * @param rotationY угол поворота в радианах вокруг оси Y
		 * @param rotationZ угол поворота в радианах вокруг оси Z
		 * 
		 * @return обратная матрица поворота 
		 */
		static public function inverseRotationMatrix(rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0):Matrix3D {
			var cosX:Number = Math.cos(rotationX);
			var sinX:Number = Math.sin(-rotationX);
			var cosY:Number = Math.cos(rotationY);
			var sinY:Number = Math.sin(-rotationY);
			var cosZ:Number = Math.cos(rotationZ);
			var sinZ:Number = Math.sin(-rotationZ);

			var sinXsinY:Number = sinX*sinY;
			
			return new Matrix3D(cosY*cosZ, -cosY*sinZ, sinY, 0,
								cosX*sinZ + sinXsinY*cosZ, cosX*cosZ - sinXsinY*sinZ, -sinX*cosY, 0,
								sinX*sinZ - cosX*cosZ*sinY, sinX*cosZ + cosX*sinY*sinZ, cosX*cosY, 0);
		}

		/**
		 * Получение матрицы трансформации. Матрица является произведением вида <code>T &times; Rz &times; Ry &times; Rx &times; S</code>, где
		 * <code>Т</code> &mdash; матрица смещения, <code>S</code> &mdash; матрица масштаба, <code>Rx</code>,
		 * <code>Ry</code>, <code>Rz</code> &mdash; матрицы поворота вокруг соответствующих осей родительской системы
		 * координат. 
		 *  
		 * @param deltaX смещение по оси X
		 * @param deltaY смещение по оси Y
		 * @param deltaZ смещение по оси Z
		 * @param rotationX угол поворота в радианах вокруг оси X
		 * @param rotationY угол поворота в радианах вокруг оси Y
		 * @param rotationZ угол поворота в радианах вокруг оси Z
		 * @param scaleX коэффициент масштабирования по оси X
		 * @param scaleY коэффициент масштабирования по оси Y
		 * @param scaleZ коэффициент масштабирования по оси Z
		 */
		static public function transformationMatrix(deltaX:Number = 0, deltaY:Number = 0, deltaZ:Number = 0, rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0, scaleX:Number = 1, scaleY:Number = 1, scaleZ:Number = 1):Matrix3D {
			var cosX:Number = Math.cos(rotationX);
			var sinX:Number = Math.sin(rotationX);
			var cosY:Number = Math.cos(rotationY);
			
			var sinY:Number = Math.sin(rotationY);
			var cosZ:Number = Math.cos(rotationZ);
			var sinZ:Number = Math.sin(rotationZ);
			
			var cosZsinY:Number = cosZ*sinY;
			var sinZsinY:Number = sinZ*sinY;
			
			var cosYscaleX:Number = cosY*scaleX;
			var sinXscaleY:Number = sinX*scaleY;
			var cosXscaleY:Number = cosX*scaleY;
			var cosXscaleZ:Number = cosX*scaleZ;
			var sinXscaleZ:Number = sinX*scaleZ;
			
			return new Matrix3D(cosZ*cosYscaleX, cosZsinY*sinXscaleY - sinZ*cosXscaleY, cosZsinY*cosXscaleZ + sinZ*sinXscaleZ, deltaX,
								sinZ*cosYscaleX, sinZsinY*sinXscaleY + cosZ*cosXscaleY, sinZsinY*cosXscaleZ - cosZ*sinXscaleZ, deltaY,
								-sinY*scaleX, cosY*sinXscaleY, cosY*cosXscaleZ, deltaZ);
		}

		/**
		 * Получение обратной матрицы трансформации. Матрица является произведением вида
		 * <code>S<sup>-1</sup> &times; Rx<sup>-1</sup> &times; Ry<sup>-1</sup> &times; Rz<sup>-1</sup> &times; T<sup>-1</sup></code>, где
		 * <code>Т</code> &mdash; матрица смещения, <code>S</code> &mdash; матрица масштаба, <code>Rx</code>,
		 * <code>Ry</code>, <code>Rz</code> &mdash; матрицы поворота вокруг соответствующих осей родительской системы
		 * координат. 
		 * 
		 * @param deltaX смещение по оси X
		 * @param deltaY смещение по оси Y
		 * @param deltaZ смещение по оси Z
		 * @param rotationX угол поворота в радианах вокруг оси X
		 * @param rotationY угол поворота в радианах вокруг оси Y
		 * @param rotationZ угол поворота в радианах вокруг оси Z
		 * @param scaleX коэффициент масштабирования по оси X
		 * @param scaleY коэффициент масштабирования по оси Y
		 * @param scaleZ коэффициент масштабирования по оси Z
		 * @return обратная матрица трансформации
		 */
		static public function inverseTransformationMatrix(deltaX:Number = 0, deltaY:Number = 0, deltaZ:Number = 0, rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0, scaleX:Number = 1, scaleY:Number = 1, scaleZ:Number = 1):Matrix3D {

			var cosX:Number = Math.cos(-rotationX);
			var sinX:Number = Math.sin(-rotationX);
			var cosY:Number = Math.cos(-rotationY);
			var sinY:Number = Math.sin(-rotationY);
			var cosZ:Number = Math.cos(-rotationZ);
			var sinZ:Number = Math.sin(-rotationZ);

			var sinXsinY:Number = sinX*sinY;
			
			var _scaleX:Number = 1/scaleX;
			var _scaleY:Number = 1/scaleY;
			var _scaleZ:Number = 1/scaleZ;
			
			var cosYscaleX:Number = cosY*_scaleX;
			var cosXscaleY:Number = cosX*_scaleY;
			var sinXscaleZ:Number = sinX*_scaleZ;
			var cosXscaleZ:Number = cosX*_scaleZ;
			
			var ta:Number = cosZ*cosYscaleX;
			var tb:Number = -sinZ*cosYscaleX;
			var tc:Number = sinY*_scaleX;
			var te:Number = sinZ*cosXscaleY + sinXsinY*cosZ*_scaleY;
			var tf:Number = cosZ*cosXscaleY - sinXsinY*sinZ*_scaleY;
			var tg:Number = -sinX*cosY*_scaleY;
			var ti:Number = sinZ*sinXscaleZ - cosZ*sinY*cosXscaleZ;
			var tj:Number = cosZ*sinXscaleZ + sinY*sinZ*cosXscaleZ;
			var tk:Number = cosY*cosXscaleZ;
			
			return new Matrix3D(ta, tb, tc, -(ta*deltaX + tb*deltaY + tc*deltaZ),
								te, tf, tg, -(te*deltaX + tf*deltaY + tg*deltaZ),
								ti, tj, tk, -(ti*deltaX + tj*deltaY + tk*deltaZ));
		}
		
		/**
		 * Получение обратной матрицы.
		 *  
		 * @param matrix матрица, для которой вычисляется обратная
		 * @return обратная матрица
		 */
		static public function inverseMatrix(matrix:Matrix3D):Matrix3D {
			var det:Number = -matrix.c*matrix.f*matrix.i + matrix.b*matrix.g*matrix.i + matrix.c*matrix.e*matrix.j - matrix.a*matrix.g*matrix.j - matrix.b*matrix.e*matrix.k + matrix.a*matrix.f*matrix.k;

			var a:Number = (-matrix.g*matrix.j + matrix.f*matrix.k)/det;
			var b:Number = (matrix.c*matrix.j - matrix.b*matrix.k)/det;
			var c:Number = (-matrix.c*matrix.f + matrix.b*matrix.g)/det;
			var d:Number = (matrix.d*matrix.g*matrix.j - matrix.c*matrix.h*matrix.j - matrix.d*matrix.f*matrix.k + matrix.b*matrix.h*matrix.k + matrix.c*matrix.f*matrix.l - matrix.b*matrix.g*matrix.l)/det;
			var e:Number = (matrix.g*matrix.i - matrix.e*matrix.k)/det;
			var f:Number = (-matrix.c*matrix.i + matrix.a*matrix.k)/det;
			var g:Number = (matrix.c*matrix.e - matrix.a*matrix.g)/det;
			var h:Number = (matrix.c*matrix.h*matrix.i - matrix.d*matrix.g*matrix.i + matrix.d*matrix.e*matrix.k - matrix.a*matrix.h*matrix.k - matrix.c*matrix.e*matrix.l + matrix.a*matrix.g*matrix.l)/det;
			var i:Number = (-matrix.f*matrix.i + matrix.e*matrix.j)/det;
			var j:Number = (matrix.b*matrix.i - matrix.a*matrix.j)/det;
			var k:Number = (-matrix.b*matrix.e + matrix.a*matrix.f)/det;
			var l:Number = (matrix.d*matrix.f*matrix.i - matrix.b*matrix.h*matrix.i - matrix.d*matrix.e*matrix.j + matrix.a*matrix.h*matrix.j + matrix.b*matrix.e*matrix.l - matrix.a*matrix.f*matrix.l)/det;

			return new Matrix3D(a, b, c, d, e, f, g, h, i, j, k, l);
		}

		/**
		 * Произведение матриц.
		 *  
		 * @param m1 родительская матрица трансформации. Левый множитель.
		 * @param m2 дочерняя матрица трансформации. Правый множитель.
		 * @return произведение матриц
		 */
		static public function product(m1:Matrix3D, m2:Matrix3D):Matrix3D {
			return new Matrix3D(m1.a*m2.a + m1.b*m2.e + m1.c*m2.i, m1.a*m2.b + m1.b*m2.f + m1.c*m2.j, m1.a*m2.c + m1.b*m2.g + m1.c*m2.k, m1.a*m2.d + m1.b*m2.h + m1.c*m2.l + m1.d,
								m1.e*m2.a + m1.f*m2.e + m1.g*m2.i, m1.e*m2.b + m1.f*m2.f + m1.g*m2.j, m1.e*m2.c + m1.f*m2.g + m1.g*m2.k, m1.e*m2.d + m1.f*m2.h + m1.g*m2.l + m1.h,
								m1.i*m2.a + m1.j*m2.e + m1.k*m2.i, m1.i*m2.b + m1.j*m2.f + m1.k*m2.j, m1.i*m2.c + m1.j*m2.g + m1.k*m2.k, m1.i*m2.d + m1.j*m2.h + m1.k*m2.l + m1.l); 
		}

		/**
		 * Метод формирует матрицу поворота на заданный угол относительно заданной оси. 
		 * 
		 * @param axis нормализованный вектор, задающий ось, относительно которой выполняется поворот
		 * @param angle угол поворота в радианах
		 * 
		 * @return матрица поворота
		 */
		static public function axisAngleToMatrix(axis:Point3D, angle:Number = 0):Matrix3D {
			var c:Number = Math.cos(angle);
			var s:Number = Math.sin(angle);
			var t:Number = 1 - c;
			var x:Number = axis.x;
			var y:Number = axis.y;
			var z:Number = axis.z;
			
			var result:Matrix3D = new Matrix3D(
				t*x*x + c, t*x*y - z*s, t*x*z + y*s, 0,
				t*x*y + z*s, t*y*y + c, t*y*z - x*s, 0,
				t*x*z - y*s, t*y*z + x*s, t*z*z + c, 0
			);
			return result;
		}
		
		/**
		 * Создание экземпляра матрицы.
		 */
		public function Matrix3D(a:Number = 1, b:Number = 0, c:Number = 0, d:Number = 0, e:Number = 0, f:Number = 1, g:Number = 0, h:Number = 0, i:Number = 0, j:Number = 0, k:Number = 1, l:Number = 0) {
			this.a = a;
			this.b = b;
			this.c = c;
			this.d = d;
			this.e = e;
			this.f = f;
			this.g = g;
			this.h = h;
			this.i = i;
			this.j = j;
			this.k = k;
			this.l = l;
		}
		
		/**
		 * Смещение центра матрицы.
		 * 
		 * @param deltaX смещение по оси X
		 * @param deltaY смещение по оси Y
		 * @param deltaZ смещение по оси Z
		 */
		public function translate(deltaX:Number = 0, deltaY:Number = 0, deltaZ:Number = 0):void {
			d += deltaX;
			h += deltaY;
			l += deltaZ;
		}

		/**
		 * Обратное смещение центра матрицы.
		 * 
		 * @param deltaX смещение по оси X
		 * @param deltaY смещение по оси Y
		 * @param deltaZ смещение по оси Z
		 */
		public function inverseTranslate(deltaX:Number = 0, deltaY:Number = 0, deltaZ:Number = 0):void {
			d -= deltaX;
			h -= deltaY;
			l -= deltaZ;
		}

		/**
		 * Смещение центра матрицы в локальной системе координат.
		 * 
		 * @param deltaX смещение по оси X 
		 * @param deltaY смещение по оси Y
		 * @param deltaZ смещение по оси Z
		 */
		public function translateLocal(deltaX:Number = 0, deltaY:Number = 0, deltaZ:Number = 0):void {
			d += a*deltaX + b*deltaY + c*deltaZ;
			h += e*deltaX + f*deltaY + g*deltaZ;
			l += i*deltaX + j*deltaY + k*deltaZ;
		}

		/**
		 * Масштабирование матрицы.
		 *  
		 * @param sx коэффициент масштабирования по X
		 * @param sy коэффициент масштабирования по Y
		 * @param sz коэффициент масштабирования по Z
		 */
		public function scale(scaleX:Number = 1, scaleY:Number = 1, scaleZ:Number = 1):void {
			a *= scaleX;
			b *= scaleX;
			c *= scaleX;
			d *= scaleX;
			e *= scaleY;
			f *= scaleY;
			g *= scaleY;
			h *= scaleY;
			i *= scaleZ;
			j *= scaleZ; 
			k *= scaleZ;
			l *= scaleZ;
		}

		/**
		 * Обратное масштабирование матрицы.
		 *  
		 * @param sx коэффициент масштабирования по X
		 * @param sy коэффициент масштабирования по Y
		 * @param sz коэффициент масштабирования по Z
		 */
		public function inverseScale(scaleX:Number = 1, scaleY:Number = 1, scaleZ:Number = 1):void {
			var _x:Number = 1/scaleX;
			var _y:Number = 1/scaleY;
			var _z:Number = 1/scaleZ;
			a *= _x;
			b *= _x;
			c *= _x;
			d *= _x;
			e *= _y;
			f *= _y;
			g *= _y;
			h *= _y;
			i *= _z;
			j *= _z;
			k *= _z;
			l *= _z;
		}

		/**
		 * Поворот матрицы. Результат умножения матриц <code>Rz &times; Ry &times; Rx &times; M</code>, где
		 * <code>Rx</code>, <code>Ry</code>, <code>Rz</code> &mdash; матрицы поворотов относительно соответствующих
		 * осей родительской системы координат, <code>M</code> &mdash; текущая матрица.
		 * 
		 * @param rotationX угол поворота в радианах вокруг оси X
		 * @param rotationY угол поворота в радианах вокруг оси Y
		 * @param rotationZ угол поворота в радианах вокруг оси Z
		 */
		public function rotate(rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0):void {
			var cosX:Number = Math.cos(rotationX);
			var sinX:Number = Math.sin(rotationX);
			var cosY:Number = Math.cos(rotationY);
			var sinY:Number = Math.sin(rotationY);
			var cosZ:Number = Math.cos(rotationZ);
			var sinZ:Number = Math.sin(rotationZ);

			var cosZsinY:Number = cosZ*sinY;
			var sinZsinY:Number = sinZ*sinY;
			
			var ra:Number = cosZ*cosY;
			var rb:Number = cosZsinY*sinX - sinZ*cosX;
			var rc:Number = cosZsinY*cosX + sinZ*sinX;
			var re:Number = sinZ*cosY;
			var rf:Number = sinZsinY*sinX + cosZ*cosX;
			var rg:Number = sinZsinY*cosX - cosZ*sinX;
			var ri:Number = -sinY;
			var rj:Number = cosY*sinX;
			var rk:Number = cosY*cosX;
			
			var _a:Number = a;
			var _b:Number = b;
			var _c:Number = c;
			var _d:Number = d;
			var _e:Number = e;
			var _f:Number = f;
			var _g:Number = g;
			var _h:Number = h;
			var _i:Number = i;
			var _j:Number = j;
			var _k:Number = k;
			var _l:Number = l;

			a = ra*_a + rb*_e + rc*_i;
			b = ra*_b + rb*_f + rc*_j;
			c = ra*_c + rb*_g + rc*_k;
			d = ra*_d + rb*_h + rc*_l;
			e = re*_a + rf*_e + rg*_i;
			f = re*_b + rf*_f + rg*_j;
			g = re*_c + rf*_g + rg*_k;
			h = re*_d + rf*_h + rg*_l;
			i = ri*_a + rj*_e + rk*_i;
			j = ri*_b + rj*_f + rk*_j;
			k = ri*_c + rj*_g + rk*_k;
			l = ri*_d + rj*_h + rk*_l;
		}

		/**
		 * Обратный поворот матрицы. Результат умножения матриц <code>Rx<sup>-1</sup> &times; Ry<sup>-1</sup>
		 * &times; Rz<sup>-1</sup> &times; M</code>,
		 * где <code>Rx</code>, <code>Ry</code>, <code>Rz</code> &mdash; матрицы поворотов относительно
		 * соответствующих осей родительской системы координат, <code>M</code> &mdash; текущая матрица.
		 * 
		 * @param rotationX угол поворота в радианах вокруг оси X
		 * @param rotationY угол поворота в радианах вокруг оси Y
		 * @param rotationZ угол поворота в радианах вокруг оси Z
		 */
		public function inverseRotate(rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0):void {
			var cosX:Number = Math.cos(rotationX);
			var sinX:Number = Math.sin(-rotationX);
			var cosY:Number = Math.cos(rotationY);
			var sinY:Number = Math.sin(-rotationY);
			var cosZ:Number = Math.cos(rotationZ);
			var sinZ:Number = Math.sin(-rotationZ);

			var sinXsinY:Number = sinX*sinY;
			
			var ra:Number = cosY*cosZ;
			var rb:Number = -cosY*sinZ;
			var rc:Number = sinY;
			var re:Number = cosX*sinZ + sinXsinY*cosZ;
			var rf:Number = cosX*cosZ - sinXsinY*sinZ;
			var rg:Number = -sinX*cosY;
			var ri:Number = sinX*sinZ - cosX*cosZ*sinY;
			var rj:Number = sinX*cosZ + cosX*sinY*sinZ;
			var rk:Number = cosX*cosY;
			
			var _a:Number = a;
			var _b:Number = b;
			var _c:Number = c;
			var _d:Number = d;
			var _e:Number = e;
			var _f:Number = f;
			var _g:Number = g;
			var _h:Number = h;
			var _i:Number = i;
			var _j:Number = j;
			var _k:Number = k;
			var _l:Number = l;

			a = ra*_a + rb*_e + rc*_i;
			b = ra*_b + rb*_f + rc*_j;
			c = ra*_c + rb*_g + rc*_k;
			d = ra*_d + rb*_h + rc*_l;
			e = re*_a + rf*_e + rg*_i;
			f = re*_b + rf*_f + rg*_j;
			g = re*_c + rf*_g + rg*_k;
			h = re*_d + rf*_h + rg*_l;
			i = ri*_a + rj*_e + rk*_i;
			j = ri*_b + rj*_f + rk*_j;
			k = ri*_c + rj*_g + rk*_k;
			l = ri*_d + rj*_h + rk*_l;
		}

		/**
		 * Трансформация матрицы. Результат умножения матриц <code>T &times; Rz &times; Ry &times; Rx &times; S &times; M</code>,
		 * где <code>Т</code> &mdash; матрица смещения, <code>Rx</code>, <code>Ry</code>, <code>Rz</code> &mdash;
		 * матрицы поворота вокруг соответствующих осей, <code>S</code> &mdash; матрица масштабирования,
		 * <code>M</code> &mdash; текущая матрица.
		 * 
		 * @param deltaX смещение по оси X
		 * @param deltaY смещение по оси Y
		 * @param deltaZ смещение по оси Z
		 * @param rotationX угол поворота в радианах вокруг оси X
		 * @param rotationY угол поворота в радианах вокруг оси Y
		 * @param rotationZ угол поворота в радианах вокруг оси Z
		 * @param scaleX коэффициент масштабирования по оси X
		 * @param scaleY коэффициент масштабирования по оси Y
		 * @param scaleZ коэффициент масштабирования по оси Z
		 */
		public function transform(deltaX:Number = 0, deltaY:Number = 0, deltaZ:Number = 0, rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0, scaleX:Number = 1, scaleY:Number = 1, scaleZ:Number = 1):void {
			var cosX:Number = Math.cos(rotationX);
			var sinX:Number = Math.sin(rotationX);
			var cosY:Number = Math.cos(rotationY);
			
			var sinY:Number = Math.sin(rotationY);
			var cosZ:Number = Math.cos(rotationZ);
			var sinZ:Number = Math.sin(rotationZ);
			
			var cosZsinY:Number = cosZ*sinY;
			var sinZsinY:Number = sinZ*sinY;
			
			var cosYscaleX:Number = cosY*scaleX;
			var sinXscaleY:Number = sinX*scaleY;
			var cosXscaleY:Number = cosX*scaleY;
			var cosXscaleZ:Number = cosX*scaleZ;
			var sinXscaleZ:Number = sinX*scaleZ;
			
			var ta:Number = cosZ*cosYscaleX;
			var tb:Number = cosZsinY*sinXscaleY - sinZ*cosXscaleY;
			var tc:Number = cosZsinY*cosXscaleZ + sinZ*sinXscaleZ;
			var td:Number = deltaX;
			var te:Number = sinZ*cosYscaleX;
			var tf:Number = sinZsinY*sinXscaleY + cosZ*cosXscaleY;
			var tg:Number = sinZsinY*cosXscaleZ - cosZ*sinXscaleZ;
			var th:Number = deltaY;
			var ti:Number = -sinY*scaleX;
			var tj:Number = cosY*sinXscaleY;
			var tk:Number = cosY*cosXscaleZ;
			var tl:Number = deltaZ;
			
			var _a:Number = a;
			var _b:Number = b;
			var _c:Number = c;
			var _d:Number = d;
			var _e:Number = e;
			var _f:Number = f;
			var _g:Number = g;
			var _h:Number = h;
			var _i:Number = i;
			var _j:Number = j;
			var _k:Number = k;
			var _l:Number = l;

			a = ta*_a + tb*_e + tc*_i;
			b = ta*_b + tb*_f + tc*_j;
			c = ta*_c + tb*_g + tc*_k;
			d = ta*_d + tb*_h + tc*_l + td;
			e = te*_a + tf*_e + tg*_i;
			f = te*_b + tf*_f + tg*_j;
			g = te*_c + tf*_g + tg*_k;
			h = te*_d + tf*_h + tg*_l + th;
			i = ti*_a + tj*_e + tk*_i;
			j = ti*_b + tj*_f + tk*_j;
			k = ti*_c + tj*_g + tk*_k;
			l = ti*_d + tj*_h + tk*_l + tl;
		}

		/**
		 * Обратая трансформация матрицы. Результат умножения матриц <code>S<sup>-1</sup> &times; Rx<sup>-1</sup> &times; Ry<sup>-1</sup> &times;
		 * Rz<sup>-1</sup> &times; T<sup>-1</sup> &times; M</code>, где <code>Т</code> &mdash; матрица
		 * смещения, <code>S</code> &mdash; матрица масштаба, <code>Rx</code>, <code>Ry</code>, <code>Rz</code> &mdash;
		 * матрицы поворота вокруг соответствующих осей родительской системы координат, <code>M</code> &mdash; текущая матрица.
		 * 
		 * @param deltaX смещение по оси X
		 * @param deltaY смещение по оси Y
		 * @param deltaZ смещение по оси Z
		 * @param rotationX угол поворота в радианах вокруг оси X
		 * @param rotationY угол поворота в радианах вокруг оси Y
		 * @param rotationZ угол поворота в радианах вокруг оси Z
		 * @param scaleX коэффициент масштабирования по оси X
		 * @param scaleY коэффициент масштабирования по оси Y
		 * @param scaleZ коэффициент масштабирования по оси Z
		 */
		public function inverseTransform(deltaX:Number = 0, deltaY:Number = 0, deltaZ:Number = 0, rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0, scaleX:Number = 1, scaleY:Number = 1, scaleZ:Number = 1):void {
			var cosX:Number = Math.cos(rotationX);
			var sinX:Number = Math.sin(-rotationX);
			var cosY:Number = Math.cos(rotationY);
			var sinY:Number = Math.sin(-rotationY);
			var cosZ:Number = Math.cos(rotationZ);
			var sinZ:Number = Math.sin(-rotationZ);

			var sinXsinY:Number = sinX*sinY;
			
			var _scaleX:Number = 1/scaleX;
			var _scaleY:Number = 1/scaleY;
			var _scaleZ:Number = 1/scaleZ;
			
			var cosYscaleX:Number = cosY*_scaleX;
			var cosXscaleY:Number = cosX*_scaleY;
			var sinXscaleZ:Number = sinX*_scaleZ;
			var cosXscaleZ:Number = cosX*_scaleZ;
			
			var ta:Number = cosZ*cosYscaleX;
			var tb:Number = -sinZ*cosYscaleX;
			var tc:Number = sinY*_scaleX;
			var td:Number = -(ta*deltaX + tb*deltaY + tc*deltaZ);
			var te:Number = sinZ*cosXscaleY + sinXsinY*cosZ*_scaleY;
			var tf:Number = cosZ*cosXscaleY - sinXsinY*sinZ*_scaleY;
			var tg:Number = -sinX*cosY*_scaleY;
			var th:Number = -(te*deltaX + tf*deltaY + tg*deltaZ);
			var ti:Number = sinZ*sinXscaleZ - cosZ*sinY*cosXscaleZ;
			var tj:Number = cosZ*sinXscaleZ + sinY*sinZ*cosXscaleZ;
			var tk:Number = cosY*cosXscaleZ;
			var tl:Number = -(ti*deltaX + tj*deltaY + tk*deltaZ);

			var _a:Number = a;
			var _b:Number = b;
			var _c:Number = c;
			var _d:Number = d;
			var _e:Number = e;
			var _f:Number = f;
			var _g:Number = g;
			var _h:Number = h;
			var _i:Number = i;
			var _j:Number = j;
			var _k:Number = k;
			var _l:Number = l;

			a = ta*_a + tb*_e + tc*_i;
			b = ta*_b + tb*_f + tc*_j;
			c = ta*_c + tb*_g + tc*_k;
			d = ta*_d + tb*_h + tc*_l + td;
			e = te*_a + tf*_e + tg*_i;
			f = te*_b + tf*_f + tg*_j;
			g = te*_c + tf*_g + tg*_k;
			h = te*_d + tf*_h + tg*_l + th;
			i = ti*_a + tj*_e + tk*_i;
			j = ti*_b + tj*_f + tk*_j;
			k = ti*_c + tj*_g + tk*_k;
			l = ti*_d + tj*_h + tk*_l + tl;
		}
		
		/**
		 * Приведение матрицы к единичной.
		 */
		public function toIdentity():void {
			a = f =	k = 1;
			b = c = d = e = g = h = i =	j =	l = 0;
		}
		
		/**
		 * Формирование матрицы трансформации. Матрица является произведением вида <code>T &times; Rz &times; Ry &times; Rx &times; S</code>, где
		 * <code>Т</code> &mdash; матрица смещения, <code>Rx</code>,
		 * <code>Ry</code>, <code>Rz</code> &mdash; матрицы поворота вокруг соответствующих осей родительской системы
		 * координат, <code>S</code> &mdash; матрица масштабирования. 
		 *
		 * @param deltaX смещение по оси X
		 * @param deltaY смещение по оси Y
		 * @param deltaZ смещение по оси Z
		 * @param rotationX угол поворота в радианах вокруг оси X
		 * @param rotationY угол поворота в радианах вокруг оси Y
		 * @param rotationZ угол поворота в радианах вокруг оси Z
		 * @param scaleX коэффициент масштабирования по оси X
		 * @param scaleY коэффициент масштабирования по оси Y
		 * @param scaleZ коэффициент масштабирования по оси Z
		 */
		public function toTransform(deltaX:Number = 0, deltaY:Number = 0, deltaZ:Number = 0, rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0, scaleX:Number = 1, scaleY:Number = 1, scaleZ:Number = 1):void {
			var cosX:Number = Math.cos(rotationX);
			var sinX:Number = Math.sin(rotationX);
			var cosY:Number = Math.cos(rotationY);
			
			var sinY:Number = Math.sin(rotationY);
			var cosZ:Number = Math.cos(rotationZ);
			var sinZ:Number = Math.sin(rotationZ);
			
			var cosZsinY:Number = cosZ*sinY;
			var sinZsinY:Number = sinZ*sinY;
			
			var cosYscaleX:Number = cosY*scaleX;
			var sinXscaleY:Number = sinX*scaleY;
			var cosXscaleY:Number = cosX*scaleY;
			var cosXscaleZ:Number = cosX*scaleZ;
			var sinXscaleZ:Number = sinX*scaleZ;
			
			a = cosZ*cosYscaleX;
			b = cosZsinY*sinXscaleY - sinZ*cosXscaleY;
			c = cosZsinY*cosXscaleZ + sinZ*sinXscaleZ;
			d = deltaX;
			e = sinZ*cosYscaleX;
			f = sinZsinY*sinXscaleY + cosZ*cosXscaleY;
			g = sinZsinY*cosXscaleZ - cosZ*sinXscaleZ;
			h = deltaY;
			i = -sinY*scaleX;
			j = cosY*sinXscaleY;
			k = cosY*cosXscaleZ;
			l = deltaZ;
		}

		/**
		 * Установка центра матрицы. Задаются значения элементов <code>d</code>, <code>h</code>, <code>l</code>.
		 * 
		 * @param x координата центра по оси X
		 * @param y координата центра по оси Y
		 * @param z координата центра по оси Z
		 */
		public function offset(x:Number = 0, y:Number = 0, z:Number = 0):void {
			d = x;
			h = y;
			l = z;
		}
		
		/**
		 * Преобразование матрицы в обратную.
		 */
		public function invert():void {
			var _a:Number = a;
			var _b:Number = b;
			var _c:Number = c;
			var _d:Number = d;
			var _e:Number = e;
			var _f:Number = f;
			var _g:Number = g;
			var _h:Number = h;
			var _i:Number = i;
			var _j:Number = j;
			var _k:Number = k;
			var _l:Number = l;
			
			var det:Number = -_c*_f*_i + _b*_g*_i + _c*_e*_j - _a*_g*_j - _b*_e*_k + _a*_f*_k;

			a = (-_g*_j + _f*_k)/det;
			b = (_c*_j - _b*_k)/det;
			c = (-_c*_f + _b*_g)/det;
			d = (_d*_g*_j - _c*_h*_j - _d*_f*_k + _b*_h*_k + _c*_f*_l - _b*_g*_l)/det;
			e = (_g*_i - _e*_k)/det;
			f = (-_c*_i + _a*_k)/det;
			g = (_c*_e - _a*_g)/det;
			h = (_c*_h*_i - _d*_g*_i + _d*_e*_k - _a*_h*_k - _c*_e*_l + _a*_g*_l)/det;
			i = (-_f*_i + _e*_j)/det;
			j = (_b*_i - _a*_j)/det;
			k = (-_b*_e + _a*_f)/det;
			l = (_d*_f*_i - _b*_h*_i - _d*_e*_j + _a*_h*_j + _b*_e*_l - _a*_f*_l)/det;
		}		

		/**
		 * Умножение на матрицу справа (наследование трансформации от матрицы).
		 *  
		 * @param matrix матрица, от которой наследуется трансформация. Левый операнд умножения.
		 */
		public function combine(matrix:Matrix3D):void {
			var _a:Number = a;
			var _b:Number = b;
			var _c:Number = c;
			var _d:Number = d;
			var _e:Number = e;
			var _f:Number = f;
			var _g:Number = g;
			var _h:Number = h;
			var _i:Number = i;
			var _j:Number = j;
			var _k:Number = k;
			var _l:Number = l;

			a = matrix.a*_a + matrix.b*_e + matrix.c*_i;
			b = matrix.a*_b + matrix.b*_f + matrix.c*_j;
			c = matrix.a*_c + matrix.b*_g + matrix.c*_k;
			d = matrix.a*_d + matrix.b*_h + matrix.c*_l + matrix.d;
			e = matrix.e*_a + matrix.f*_e + matrix.g*_i;
			f = matrix.e*_b + matrix.f*_f + matrix.g*_j;
			g = matrix.e*_c + matrix.f*_g + matrix.g*_k;
			h = matrix.e*_d + matrix.f*_h + matrix.g*_l + matrix.h;
			i = matrix.i*_a + matrix.j*_e + matrix.k*_i;
			j = matrix.i*_b + matrix.j*_f + matrix.k*_j;
			k = matrix.i*_c + matrix.j*_g + matrix.k*_k;
			l = matrix.i*_d + matrix.j*_h + matrix.k*_l + matrix.l;
		}
		
		/**
		 * Умножение на матрицу слева (применение своей трансформации к матрице).
		 * 
		 * @param matrix матрица, к которой применяется трансформация текущей матрицы. Правый операнд умножения.
		 */
		public function inverseCombine(matrix:Matrix3D):void {
			var _a:Number = a;
			var _b:Number = b;
			var _c:Number = c;
			var _d:Number = d;
			var _e:Number = e;
			var _f:Number = f;
			var _g:Number = g;
			var _h:Number = h;
			var _i:Number = i;
			var _j:Number = j;
			var _k:Number = k;
			var _l:Number = l;

			a = _a*matrix.a + _b*matrix.e + _c*matrix.i;
			b = _a*matrix.b + _b*matrix.f + _c*matrix.j;
			c = _a*matrix.c + _b*matrix.g + _c*matrix.k;
			d = _a*matrix.d + _b*matrix.h + _c*matrix.l + _d;
			e = _e*matrix.a + _f*matrix.e + _g*matrix.i;
			f = _e*matrix.b + _f*matrix.f + _g*matrix.j;
			g = _e*matrix.c + _f*matrix.g + _g*matrix.k;
			h = _e*matrix.d + _f*matrix.h + _g*matrix.l + _h;
			i = _i*matrix.a + _j*matrix.e + _k*matrix.i;
			j = _i*matrix.b + _j*matrix.f + _k*matrix.j;
			k = _i*matrix.c + _j*matrix.g + _k*matrix.k;
			l = _i*matrix.d + _j*matrix.h + _k*matrix.l + _l;
		}
		
		/**
		 * Сравнение матриц с заданной погрешностью.
		 *  
		 * @param matrix матрица для сравнения
		 * @param threshold погрешность сравнения
		 * @return <code>true</code> если модуль разности любых соответствующих элементов матриц не превышает
		 * заданную погрешность, иначе <code>false</code>
		 */
		public function equals(matrix:Matrix3D, threshold:Number = 0):Boolean {
			var _a:Number = a - matrix.a;
			var _b:Number = b - matrix.b;
			var _c:Number = c - matrix.c;
			var _d:Number = d - matrix.d;
			var _e:Number = e - matrix.e;
			var _f:Number = f - matrix.f;
			var _g:Number = g - matrix.g;
			var _h:Number = h - matrix.h;
			var _i:Number = i - matrix.i;
			var _j:Number = j - matrix.j;
			var _k:Number = k - matrix.k;
			var _l:Number = l - matrix.l;
			_a = (_a < 0) ? -_a : _a;
			_b = (_b < 0) ? -_b : _b;
			_c = (_c < 0) ? -_c : _c;
			_d = (_d < 0) ? -_d : _d;
			_e = (_e < 0) ? -_e : _e;
			_f = (_f < 0) ? -_f : _f;
			_g = (_g < 0) ? -_g : _g;
			_h = (_h < 0) ? -_h : _h;
			_i = (_i < 0) ? -_i : _i;
			_j = (_j < 0) ? -_j : _j;
			_k = (_k < 0) ? -_k : _k;
			_l = (_l < 0) ? -_l : _l;
			return (_a <= threshold) && (_b <= threshold) && (_c <= threshold) && (_d <= threshold)	&&
				   (_e <= threshold) && (_f <= threshold) && (_g <= threshold) && (_h <= threshold) &&
				   (_i <= threshold) && (_j <= threshold) && (_k <= threshold) && (_l <= threshold);
		}
		
		/**
		 * Копирование значений указанной матрицы.
		 *  
		 * @param matrix матрица, значения которой копируются
		 */
		public function copy(matrix:Matrix3D):void {
			a = matrix.a;
			b = matrix.b;
			c = matrix.c;
			d = matrix.d;
			e = matrix.e;
			f = matrix.f;
			g = matrix.g;
			h = matrix.h;
			i = matrix.i;
			j = matrix.j;
			k = matrix.k;
			l = matrix.l;
		}
		
		/**
		 * Клонирование матрицы.
		 * 
		 * @return клон матрицы
		 */
		public function clone():Matrix3D {
			return new Matrix3D(a, b, c, d, e, f, g, h, i, j, k, l);
		}
		
		/**
		 * Строковое представление матрицы.
		 *  
		 * @return форматированная строка со значениями матрицы 
		 */
		public function toString():String {
			return "[Matrix3D " + "[" + a.toFixed(3) + " " + b.toFixed(3) + " " + c.toFixed(3) + " " + d.toFixed(3) + "] [" + e.toFixed(3) + " " + f.toFixed(3) + " " + g.toFixed(3) + " " + h.toFixed(3) + "] [" + i.toFixed(3) + " " + j.toFixed(3) + " " + k.toFixed(3) + " " + l.toFixed(3) + "]]";
		}

		/**
		 * Метод по заданной матрице поворота вычисляет углы поворотов относительно координатных осей.
		 * 
		 * @param rotations если указанное значение не равно <code>null</code>, то результат будет записан в эту переменную
		 * 
		 * @return объект, содержащий значения углов поворотов в радианах для каждой координатной оси
		 */
		public function getRotations(rotations:Point3D = null):Point3D {
			if (rotations == null) {
				rotations = new Point3D();
			}
			if (-1 < i && i < 1) {
				rotations.x = Math.atan2(j, k);
				rotations.y = -Math.asin(i);
				rotations.z = Math.atan2(e, a);
			} else {
				rotations.x = 0;
				rotations.y = 0.5*((i <= -1) ? Math.PI : -Math.PI);
				rotations.z = Math.atan2(-b, f);
			}
			return rotations;
		}

		/**
		 * Метод формирует матрицу поворота на заданный угол относительно заданной оси. 
		 * 
		 * @param axis нормализованный вектор, задающий ось, относительно которой выполняется поворот
		 * @param angle угол поворота в радианах
		 */
		public function fromAxisAngle(axis:Point3D, angle:Number = 0):void {
			var c1:Number = Math.cos(angle);
			var s:Number = Math.sin(angle);
			var t:Number = 1 - c1;
			var x:Number = axis.x;
			var y:Number = axis.y;
			var z:Number = axis.z;

			a = t*x*x + c1;
			b = t*x*y - z*s;
			c = t*x*z + y*s;
			d = 0;
				 
			e = t*x*y + z*s;
			f = t*y*y + c1;
			g = t*y*z - x*s;
			h = 0;

			i = t*x*z - y*s;
			j = t*y*z + x*s;
			k = t*z*z + c1;
			l = 0;
		}
		
		/**
		 * Умножает матрицу на скаляр.
		 * 
		 * @param multiplier множитель
		 */
		public function multByScalar(multiplier:Number):void {
			a *= multiplier;
			b *= multiplier;
			c *= multiplier;
			d *= multiplier;
			e *= multiplier;
			f *= multiplier;
			g *= multiplier;
			h *= multiplier;
			i *= multiplier;
			j *= multiplier;
			k *= multiplier;
			l *= multiplier;
		}
		
		/**
		 * Добавляет заданную матрицу к текущей.
		 * 
		 * @param m добавляема матрица
		 */
		public function add(m:Matrix3D):void {
			a += m.a;
			b += m.b;
			c += m.c;
			d += m.d;
			e += m.e;
			f += m.f;
			g += m.g;
			h += m.h;
			i += m.i;
			j += m.j;
			k += m.k;
			l += m.l;
		}
		
		/**
		 * Транспонирует матрицу.
		 */
		public function transpose():void {
			var tmp:Number = b;
			b = e;
			e = tmp;
			tmp = c;
			c = i;
			i = tmp;
			tmp = g;
			g = j;
			j = tmp;
		}
		
		/**
		 * @private
		 * @param index
		 * @param axis
		 */
		public function getAxis(index:int, axis:Point3D):void {
			switch (index) {
				case 0:
					axis.x = a;
					axis.y = e;
					axis.z = i;
					return;
				case 1:
					axis.x = b;
					axis.y = f;
					axis.z = j;
					return;
				case 2:
					axis.x = c;
					axis.y = g;
					axis.z = k;
					return;
				case 3:
					axis.x = d;
					axis.y = h;
					axis.z = l;
					return;
			}
		}
		
		/**
		 * Трансформирует заданный вектор без учёта смещения центра матрицы.
		 * 
		 * @param pin входной вектор
		 * @param pout вектор, в который записывается результат трансформации
		 */
		public function deltaTransformVector(pin:Point3D, pout:Point3D):void {
			pout.x = a*pin.x + b*pin.y + c*pin.z + d;
			pout.y = e*pin.x + f*pin.y + g*pin.z + h;
			pout.z = i*pin.x + j*pin.y + k*pin.z + l;
		}

	}
}
