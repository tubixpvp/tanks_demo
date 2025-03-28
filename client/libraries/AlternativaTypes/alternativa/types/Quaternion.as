package alternativa.types {

	/**
	 * @private
	 */
	public class Quaternion {

		public var w:Number;
		public var x:Number;
		public var y:Number;
		public var z:Number;

		public static function multiply(q1:Quaternion, q2:Quaternion, result:Quaternion):void {
			result.w = q1.w*q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z;
			result.x = q1.w*q2.x + q1.x*q2.w + q1.y*q2.z - q1.z*q2.y;
			result.y = q1.w*q2.y + q1.y*q2.w + q1.z*q2.x - q1.x*q2.z;
			result.z = q1.w*q2.z + q1.z*q2.w + q1.x*q2.y - q1.y*q2.x;
		}

		public static function createFromAxisAngle(axis:Point3D, angle:Number):Quaternion {
			var q:Quaternion = new Quaternion();
			q.setFromAxisAngle(axis, angle);
			return q;
		}

		public static function createFromAxisAngleComponents(x:Number, y:Number, z:Number, angle:Number):Quaternion {
			var q:Quaternion = new Quaternion();
			q.setFromAxisAngleComponents(x, y, z, angle);
			return q;
		}

		/**
		 * Сферическая интерполяция кватерниона. 
		 * 
		 * @param q1 начальный кватернион
		 * @param q2 конечный кватернион
		 * @param t значение параметра
		 *
		 * @return интерполированный кватернион
		 */
		static public function slerp(q1:Quaternion, q2:Quaternion, t:Number = 0.5):Quaternion {
			// Взято с http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/slerp/
			var quaternion:Quaternion = new Quaternion();
			// Calculate angle between them.
			var cosHalfTheta:Number = q1.w*q2.w + q1.x*q2.x + q1.y*q2.y + q1.z*q2.z;
			// Разворот второго кватерниона в случае разнонаправленности 
			if (cosHalfTheta < 0) {
				q2.w = -q2.w;
				q2.x = -q2.x;
				q2.y = -q2.y;
				q2.z = -q2.z; 
				cosHalfTheta = -cosHalfTheta; 
			}
			// if qa=qb or qa=-qb then theta = 0 and we can return qa
			if (cosHalfTheta >= 1.0){
				quaternion.w = q1.w;
				quaternion.x = q1.x;
				quaternion.y = q1.y;
				quaternion.z = q1.z;
				return quaternion;
			}
			// Calculate temporary values.
			var halfTheta:Number = Math.acos(cosHalfTheta);
			var sinHalfTheta:Number = Math.sqrt(1.0 - cosHalfTheta*cosHalfTheta);
			// if theta = 180 degrees then result is not fully defined
			// we could rotate around any axis normal to qa or qb
			if (sinHalfTheta < 0.0001 && sinHalfTheta > -0.0001){
				quaternion.w = (q1.w*0.5 + q2.w*0.5);
				quaternion.x = (q1.x*0.5 + q2.x*0.5);
				quaternion.y = (q1.y*0.5 + q2.y*0.5);
				quaternion.z = (q1.z*0.5 + q2.z*0.5);
				return quaternion;
			}
			var ratioA:Number = Math.sin((1 - t)*halfTheta)/sinHalfTheta;
			var ratioB:Number = Math.sin(t*halfTheta)/sinHalfTheta; 
			//calculate Quaternion.
			quaternion.w = (q1.w*ratioA + q2.w*ratioB);
			quaternion.x = (q1.x*ratioA + q2.x*ratioB);
			quaternion.y = (q1.y*ratioA + q2.y*ratioB);
			quaternion.z = (q1.z*ratioA + q2.z*ratioB);
			return quaternion;
		}

		public function Quaternion(w:Number = 1, x:Number = 0, y:Number = 0, z:Number = 0) {
			this.w = w;
			this.x = x;
			this.y = y;
			this.z = z;
		}

		public function reset(w:Number = 1, x:Number = 0, y:Number = 0, z:Number = 0):void {
			this.w = w;
			this.x = x;
			this.y = y;
			this.z = z;
		}

		public function normalize():void {
			var d:Number = w*w + x*x + y*y + z*z;
			if (d == 0) {
				w = 1;
				return;
			}
			d = 1/Math.sqrt(d);
			w *= d;
			x *= d;
			y *= d;
			z *= d;
		}

		/**
		 * Умножает на указанный кватернион слева (this*q).
		 *  
		 * @param q множитель
		 */
		public function multiply(q:Quaternion):void {
			var ww:Number = w*q.w - x*q.x - y*q.y - z*q.z;
			var xx:Number = w*q.x + x*q.w + y*q.z - z*q.y;
			var yy:Number = w*q.y + y*q.w + z*q.x - x*q.z;
			var zz:Number = w*q.z + z*q.w + x*q.y - y*q.x;
			w = ww;
			x = xx;
			y = yy;
			z = zz;
		}

		/**
		 * Умножает на указанный кватернион справа (q*this).
		 *  
		 * @param q множитель
		 */
		public function multiplyRight(q:Quaternion):void {
			var ww:Number = q.w*w - q.x*x - q.y*y - q.z*z;
			var xx:Number = q.w*x + q.x*w + q.y*z - q.z*y;
			var yy:Number = q.w*y + q.y*w + q.z*x - q.x*z;
			var zz:Number = q.w*z + q.z*w + q.x*y - q.y*x;
			w = ww;
			x = xx;
			y = yy;
			z = zz;
		}

		public function rotateByVector(vector:Point3D):void {
			var ww:Number = -vector.x*x - vector.y*y - vector.z*z;
			var xx:Number = vector.x*w + vector.y*z - vector.z*y;
			var yy:Number = vector.y*w + vector.z*x - vector.x*z;
			var zz:Number = vector.z*w + vector.x*y - vector.y*x;
			w = ww;
			x = xx;
			y = yy;
			z = zz;
		}

		public function addScaledVector(vector:Point3D, scale:Number):void {
			var vx:Number = vector.x*scale;
			var vy:Number = vector.y*scale;
			var vz:Number = vector.z*scale;
			var ww:Number = -x*vx - y*vy - z*vz;
			var xx:Number = vx*w + vy*z - vz*y;
			var yy:Number = vy*w + vz*x - vx*z;
			var zz:Number = vz*w + vx*y - vy*x;
			w += 0.5*ww;
			x += 0.5*xx;
			y += 0.5*yy;
			z += 0.5*zz;
		}

		public function copy(q:Quaternion):void {
			w = q.w;
			x = q.x;
			y = q.y;
			z = q.z;
		}

		public function clone():Quaternion {
			return new Quaternion(w, x, y, z);
		}

		public function toMatrix3D(matrix:Matrix3D):void {
			var qi2:Number = 2*x*x;
			var qj2:Number = 2*y*y;
			var qk2:Number = 2*z*z;
			var qij:Number = 2*x*y;
			var qjk:Number = 2*y*z;
			var qki:Number = 2*z*x;
			var qri:Number = 2*w*x;
			var qrj:Number = 2*w*y;
			var qrk:Number = 2*w*z;
			
			matrix.a = 1 - qj2 - qk2;
			matrix.b = qij - qrk;
			matrix.c = qki + qrj;
			matrix.d = 0;
			
			matrix.e = qij + qrk;
			matrix.f = 1 - qi2 - qk2;
			matrix.g = qjk - qri;
			matrix.h = 0;
			
			matrix.i = qki - qrj;
			matrix.j = qjk + qri;
			matrix.k = 1 - qi2 - qj2;
			matrix.l = 0;
		}

		public function get length():Number {
			return Math.sqrt(w*w + x*x + y*y + z*z);
		}

		public function get length2():Number {
			return w*w + x*x + y*y + z*z;
		}

		public function toString():String {
			return "[" + w + ", " + x + ", " + y + ", " + z + "]";
		}

		public function setFromAxisAngle(axis:Point3D, angle:Number):void {
			w = Math.cos(0.5*angle);
			var coeff:Number = 1/Math.sqrt(axis.x*axis.x + axis.y*axis.y + axis.z*axis.z);
			var sin:Number = Math.sin(0.5*angle);
			x = axis.x*sin*coeff;
			y = axis.y*sin*coeff;
			z = axis.z*sin*coeff;
		}

		public function setFromAxisAngleComponents(x:Number, y:Number, z:Number, angle:Number):void {
			w = Math.cos(0.5*angle);
			var coeff:Number = 1/Math.sqrt(x*x + y*y + z*z);
			var sin:Number = Math.sin(0.5*angle);
			this.x = x*sin*coeff;
			this.y = y*sin*coeff;
			this.z = z*sin*coeff;
		}
		
		/**
		 * 
		 * @param vector
		 */
		public function toAxisVector(vector:Point3D):void {
			if (w < -1 || w > 1) {
				normalize();
			}
			if (w > -1 && w < 1) {
				if (w == 0) {
					vector.x = x;
					vector.y = y;
					vector.z = z;
				} else {
					var angle:Number = 2*Math.acos(w);
					var coeff:Number = 1/Math.sqrt(1 - w*w);
					vector.x = x*coeff*angle;
					vector.y = y*coeff*angle;
					vector.z = z*coeff*angle;
				}
			} else {
				vector.x = 0;
				vector.y = 0;
				vector.z = 0;
			}
		}
		
		/**
		 * 
		 * @param rotations
		 */
		public function getEulerAngles(rotations:Point3D = null):Point3D {
			var qi2:Number = 2*x*x;
			var qj2:Number = 2*y*y;
			var qk2:Number = 2*z*z;
			var qij:Number = 2*x*y;
			var qjk:Number = 2*y*z;
			var qki:Number = 2*z*x;
			var qri:Number = 2*w*x;
			var qrj:Number = 2*w*y;
			var qrk:Number = 2*w*z;

			var aa:Number = 1 - qj2 - qk2;
			var bb:Number = qij - qrk;
			var ee:Number = qij + qrk;
			var ff:Number = 1 - qi2 - qk2;
			var ii:Number = qki - qrj;
			var jj:Number = qjk + qri;
			var kk:Number = 1 - qi2 - qj2;

			if (-1 < ii && ii < 1) {
				if (rotations == null) {
					rotations = new Point3D(Math.atan2(jj, kk), -Math.asin(ii), Math.atan2(ee, aa)); 
				} else {
					rotations.x = Math.atan2(jj, kk);
					rotations.y = -Math.asin(ii);
					rotations.z = Math.atan2(ee, aa);
				}
			} else {
				if (rotations == null) {
					rotations = new Point3D(0, 0.5*((ii <= -1) ? Math.PI : -Math.PI), Math.atan2(-bb, ff)); 
				} else {
					rotations.x = 0;
					rotations.y = 0.5*((ii <= -1) ? Math.PI : -Math.PI);
					rotations.z = Math.atan2(-bb, ff);
				}
			}
			return rotations;
		}
		
		/**
		 * 
		 */
		public function conjugate():void {
			x = -x;
			y = -y;
			z = -z;
		}

		/**
		 * Выполняет линейную интерполяцию.
		 * 
		 * @param q1 начало отрезка
		 * @param q2 конец отрезка
		 * @param t время, обычно задаётся в интервале [0, 1]
		 */
		public function nlerp(q1:Quaternion, q2:Quaternion, t:Number):void {
			var t1:Number = 1 - t;
			w = q1.w*t1 + q2.w*t;
			x = q1.x*t1 + q2.x*t;
			y = q1.y*t1 + q2.y*t;
			z = q1.z*t1 + q2.z*t;
			normalize();
		}

	}
}
