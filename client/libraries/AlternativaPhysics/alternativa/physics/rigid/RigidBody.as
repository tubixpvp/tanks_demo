package alternativa.physics.rigid {
	
	import alternativa.physics.altphysics;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	import alternativa.types.Quaternion;
	
	use namespace altphysics;
	
	/**
	 * Класс представляет твёрдое тело.
	 */
	public class RigidBody {

		private var angularAcceleration:Point3D = new Point3D();
		private var motionThreshold:Number = 0.1;
		private var motionThreshold2:Number = 2*motionThreshold;
		private var baseBias:Number = 0.8;
		private var name:String;

		public var next:RigidBody;
		public var prev:RigidBody;
		
		altphysics var mass:Number;
		altphysics var inverseMass:Number;
		altphysics var inverseInertiaTensor:Matrix3D = new Matrix3D();

		altphysics var linearDamping:Number = 0.95;
		altphysics var angularDamping:Number = 0.95;
		altphysics var awake:Boolean = true;
		altphysics var canSleep:Boolean = true;

		altphysics var acceleration:Point3D = new Point3D();
		altphysics var angularVelocity:Point3D = new Point3D();

		altphysics var position:Point3D = new Point3D();
		altphysics var orientation:Quaternion = new Quaternion(1, 0, 0, 0);
		altphysics var velocity:Point3D = new Point3D();
		altphysics var rotation:Point3D = new Point3D();
		altphysics var lastFrameAcceleration:Point3D = new Point3D();

		altphysics var transformMatrix:Matrix3D = new Matrix3D();
		altphysics var inverseInertiaTensorWorld:Matrix3D = new Matrix3D();

		altphysics var forceAccum:Point3D = new Point3D();
		altphysics var torqueAccum:Point3D = new Point3D();
		altphysics var motion:Number = 10;
		
		/**
		 * Создаёт новый экзепляр твёрдого тела.
		 * 
		 * @param inverseMass величина, обратная массе тела. Значение 0 указывает, что тело имеет имеет бесконечную массу и момент инерции.
		 * @param inverseInertiaTensor обратный тензор момента инерции тела. Значение <code>null</code> указывает, что тело имеет бесконечную массу и момент инерции.
		 */
		public function RigidBody(inverseMass:Number = 1, inverseInertiaTensor:Matrix3D = null) {
			if (inverseMass == 0 || inverseInertiaTensor == null) {
				setInfinteMass();
			} else {
				this.inverseMass = inverseMass;
				this.mass = 1/inverseMass;
				this.inverseInertiaTensor.copy(inverseInertiaTensor);
			}
		}
		
		/**
		 * @return имя тела
		 */
		public function getName():String {
			return name;
		}
		
		/**
		 * Устанавливает имя тела.
		 * 
		 * @param value имя тела
		 */
		public function setName(value:String):void {
			name = value;
		}

		/**
		 * Предельное количество движения, ниже которого тело усыпляеся.
		 */
		public function getMotionThreshold():Number {
			return motionThreshold;
		}

		/**
		 * @private
		 */
		public function setMotionThreshold(value:Number):void {
			motionThreshold = value;
			motionThreshold2 = value*2;
		}

		/**
		 * 
		 * @param value
		 */		
		public function setBaseBias(value:Number):void {
			baseBias = value;
		}

		/**
		 * 
		 * @param value
		 */
		public function getBaseBias():Number {
			return baseBias;
		}

		/**
		 * 
		 */
		public function getMass():Number {
			return mass;
		}

		/**
		 * 
		 */
		public function setMass(value:Number):void {
			if (value <= 0) {
				inverseMass = 0;
				mass = 0;
			} else {
				mass = value;
				inverseMass = 1/value;
			}
		}
		
		/**
		 * 
		 */
		public function getInverseMass():Number {
			return inverseMass;
		}
		
		/**
		 * @private
		 */
		public function setInverseMass(value:Number):void {
			if (value > 0) {
				inverseMass = value;
				mass = 1/value;
			} else {
				inverseMass = 0;
				mass = 0;
			}
		}
		
		/**
		 * 
		 * @param m
		 */
		public function setIntertiaTensor(intertiaTensor:Matrix3D):void {
			inverseInertiaTensor.copy(intertiaTensor);
			inverseInertiaTensor.invert();
		}
		
		/**
		 * 
		 * @param intertiaTensor
		 */
		public function getIntertiaTensor(intertiaTensor:Matrix3D):void {
			intertiaTensor.copy(inverseInertiaTensor);
			intertiaTensor.invert();
		}

		/**
		 * 
		 * @param inverseInertiaTensor
		 */
		public function setInverseIntertiaTensor(inverseInertiaTensor:Matrix3D):void {
			this.inverseInertiaTensor.copy(inverseInertiaTensor);
		}

		/**
		 * 
		 * @param inverseInertiaTensor
		 */
		public function getInverseIntertiaTensor(inverseInertiaTensor:Matrix3D):void {
			inverseInertiaTensor.copy(this.inverseInertiaTensor);
		}
		
		/**
		 * 
		 */
		public function setInfinteMass():void {
			inverseMass = 0;
			mass = 0;
			inverseInertiaTensor.toIdentity();
			inverseInertiaTensor.a = inverseInertiaTensor.f = inverseInertiaTensor.k = 0;
		}
		
		/**
		 * 
		 * @param linearDamping
		 * @param angularDamping
		 */
		public function setDamping(linearDamping:Number, angularDamping:Number):void {
			this.linearDamping = linearDamping;
			this.angularDamping = angularDamping;
		}
		
		/**
		 * 
		 * @param value
		 */
		public function setLinearDamping(value:Number):void {
			linearDamping = value;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function getLinearDamping():Number {
			return linearDamping;
		}

		/**
		 * 
		 * @param value
		 */
		public function setAngularDamping(value:Number):void {
			angularDamping = value;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function getAngularDamping():Number {
			return angularDamping;
		}

		/**
		 * 
		 * @param position
		 */		
		public function setPosition(position:Point3D):void {
			this.position.x = position.x;
			this.position.y = position.y;
			this.position.z = position.z;
		}
		
		/**
		 * 
		 * @param x
		 * @param y
		 * @param z
		 */
		public function setPositionComponents(x:Number, y:Number, z:Number):void {
			position.x = x;
			position.y = y;
			position.z = z;
		}
		
		/**
		 * 
		 * @param position
		 */
		public function getPosition(position:Point3D):void {
			position.x = this.position.x;
			position.y = this.position.y;
			position.z = this.position.z;
		}

		/**
		 * 
		 * @param orientation
		 */
		public function setOrientation(orientation:Quaternion):void {
			this.orientation.copy(orientation);
			this.orientation.normalize();
		}
		
		/**
		 * 
		 * @param r
		 * @param i
		 * @param j
		 * @param k
		 */
		public function setOrientationComponents(w:Number, x:Number, y:Number, z:Number):void {
			orientation.reset(w, x, y, z);
			orientation.normalize();
		}

		/**
		 * 
		 * @param orientation
		 */
		public function getOrientation(orientation:Quaternion):void {
			orientation.copy(this.orientation);
		}

		/**
		 * 
		 * @param matrix
		 */
		public function getTransformMatrix(matrix:Matrix3D):void {
			matrix.copy(transformMatrix);
		}
		
		/**
		 * 
		 * @param velocity
		 */
		public function setVelocity(velocity:Point3D):void {
			this.velocity.copy(velocity);
		}

		/**
		 * 
		 * @param x
		 * @param y
		 * @param z
		 */
		public function setVelocityComponents(x:Number, y:Number, z:Number):void {
			velocity.reset(x, y, z);
		}
		
		/**
		 * 
		 * @param velocity
		 */
		public function getVelocity(velocity:Point3D):void {
			velocity.copy(this.velocity);
		}
		
		/**
		 * 
		 * @param acceleration
		 * 
		 */
		public function setAcceleration(acceleration:Point3D):void {
			this.acceleration.copy(acceleration);
		}
			
		/**
		 * 
		 * @param x
		 * @param y
		 * @param z
		 * 
		 */
		public function setAccelerationComponents(x:Number, y:Number, z:Number):void {
			acceleration.reset(x, y, z);
		}

		/**
		 * 
		 * @param acceleration
		 * 
		 */
		public function getAcceleration(acceleration:Point3D):void {
			acceleration.copy(this.acceleration);
		}
		
		/**
		 * 
		 * @param rotation
		 * 
		 */
		public function setRotation(rotation:Point3D):void {
			this.rotation.copy(rotation);
		}

		/**
		 * 
		 * @param x
		 * @param y
		 * @param z
		 * 
		 */
		public function setRotationComponents(x:Number, y:Number, z:Number):void {
			rotation.reset(x, y, z);
		}
		
		/**
		 * 
		 * @param rotation
		 * 
		 */
		public function addRotation(deltaRotation:Point3D):void {
			rotation.add(deltaRotation);
		}
		
		/**
		 * 
		 * @param rotation
		 * 
		 */
		public function getRotation(rotation:Point3D):void {
			rotation.copy(this.rotation);
		}
		
		/**
		 * 
		 * @param angularVelocity
		 */
		public function setAngularVelocity(angularVelocity:Point3D):void {
			this.angularVelocity.x = angularVelocity.x;
			this.angularVelocity.y = angularVelocity.y;
			this.angularVelocity.z = angularVelocity.z;
		}

		/**
		 * 
		 * @param x
		 * @param y
		 * @param z
		 */
		public function setAngularVelocityComponents(x:Number, y:Number, z:Number):void {
			angularVelocity.x = x;
			angularVelocity.y = y;
			angularVelocity.z = z;
		}

		/**
		 * 
		 * @param awake
		 */
		public function setAwake(awake:Boolean = true):void {
			this.awake = awake;
			if (awake) {
				motion = motionThreshold2;
			} else {
				velocity.x = 0;
				velocity.y = 0;
				velocity.z = 0;
				
				rotation.x = 0;
				rotation.y = 0;
				rotation.z = 0;
			}
		}
		
		/**
		 * 
		 * @return 
		 */
		public function isAwake():Boolean {
			return awake;
		}

		/**
		 * 
		 * @param canSleep
		 */
		public function setCanSleep(canSleep:Boolean = true):void {
			this.canSleep = canSleep;
			if (!canSleep && !awake) {
				setAwake();
			}
		}
		
		/**
		 * 
		 * @return 
		 */
		public function isCanSleep():Boolean {
			return canSleep;
		}

		/**
		 * Добавляет глобальную силу, приложенную к центру масс тела.
		 * 
		 * @param force вектор силы в глобальной системе координат
		 */
		public function addForce(force:Point3D):void {
			forceAccum.x += force.x;
			forceAccum.y += force.y;
			forceAccum.z += force.z;
			setAwake();
		}

		/**
		 * 
		 * @param force
		 */
		public function addForceComponents(x:Number, y:Number, z:Number):void {
			forceAccum.x += x;
			forceAccum.y += y;
			forceAccum.z += z;
			setAwake();
		}
		
		/**
		 * Добавляет глобальную силу, приложенную к заданной локальной точке тела.
		 * 
		 * @param force вектор силы в глобальной системе координат
		 * @param localPoint локальные координаты точки приложения силы
		 */
		public function addForceAtLocalPoint(force:Point3D, localPoint:Point3D):void {
			forceAccum.x += force.x;
			forceAccum.y += force.y;
			forceAccum.z += force.z;
			// Трансформация локальных координат в глобальные
			var x:Number = transformMatrix.a*localPoint.x + transformMatrix.b*localPoint.y + transformMatrix.c*localPoint.z;
			var y:Number = transformMatrix.e*localPoint.x + transformMatrix.f*localPoint.y + transformMatrix.g*localPoint.z;
			var z:Number = transformMatrix.i*localPoint.x + transformMatrix.j*localPoint.y + transformMatrix.k*localPoint.z;
			torqueAccum.x += y*force.z - z*force.y;
			torqueAccum.y += z*force.x - x*force.z;
			torqueAccum.z += x*force.y - y*force.x;
			setAwake();
		}

		/**
		 * Добавляет глобальную силу, приложенную к заданной точке тела, выраженной в глобальных координатах.
		 * 
		 * @param force вектор силы в глобальной системе координат
		 * @param point глобальные координаты точки приложения силы
		 */
		public function addForceAtPoint(force:Point3D, point:Point3D):void {
			forceAccum.x += force.x;
			forceAccum.y += force.y;
			forceAccum.z += force.z;
			var x:Number = point.x - position.x;
			var y:Number = point.y - position.y;
			var z:Number = point.z - position.z;
			torqueAccum.x += y*force.z - z*force.y;
			torqueAccum.y += z*force.x - x*force.z;
			torqueAccum.z += x*force.y - y*force.x;
			setAwake();
		}
		
		/**
		 * Добавляет локальную силу, приложенную в заданной локальной точке тела.
		 * 
		 * @param localForce вектор локальной силы
		 * @param localPoint локальные координаты точки приложения силы
		 */
		public function addLocalForce(localForce:Point3D, localPoint:Point3D):void {
			// Трансформация локального вектора силы в глобальный
			var globalForceX:Number = transformMatrix.a*localForce.x + transformMatrix.b*localForce.y + transformMatrix.c*localForce.z;
			var globalForceY:Number = transformMatrix.e*localForce.x + transformMatrix.f*localForce.y + transformMatrix.g*localForce.z;
			var globalForceZ:Number = transformMatrix.i*localForce.x + transformMatrix.j*localForce.y + transformMatrix.k*localForce.z;
			forceAccum.x += globalForceX;
			forceAccum.y += globalForceY;
			forceAccum.z += globalForceZ;
			// Получение глобального вектора плеча силы
			var globalPointX:Number = transformMatrix.a*localPoint.x + transformMatrix.b*localPoint.y + transformMatrix.c*localPoint.z;
			var globalPointY:Number = transformMatrix.e*localPoint.x + transformMatrix.f*localPoint.y + transformMatrix.g*localPoint.z;
			var globalPointZ:Number = transformMatrix.i*localPoint.x + transformMatrix.j*localPoint.y + transformMatrix.k*localPoint.z;
			// Приращение момента силы
			torqueAccum.x += globalPointY*globalForceZ - globalPointZ*globalForceY;
			torqueAccum.y += globalPointZ*globalForceX - globalPointX*globalForceZ;
			torqueAccum.z += globalPointX*globalForceY - globalPointY*globalForceX;
			setAwake();
		}

		/**
		 * Добавляет момент силы.
		 * 
		 * @param torque вектор момента силы
		 */
		public function addTorque(torque:Point3D):void {
			torqueAccum.x += torque.x;
			torqueAccum.y += torque.y;
			torqueAccum.z += torque.z;
			setAwake();
		}

		/**
		 * Добавляет момент силы, заданный покомпонентно.
		 */
		public function addTorqueComponents(x:Number, y:Number, z:Number):void {
			torqueAccum.x += x;
			torqueAccum.y += y;
			torqueAccum.z += z;
			setAwake();
		}
				
		/**
		 * Вычисляет векторные параметры тела в глобальной системе координат.
		 */
		public function calculateDerivedData():void {
			// inlined position.normalize()
			var d:Number = orientation.w*orientation.w + orientation.x*orientation.x + orientation.y*orientation.y + orientation.z*orientation.z;
			if (d == 0) {
				orientation.w = 1;
			} else {
				d = 1/Math.sqrt(d);
				orientation.w *= d;
				orientation.x *= d;
				orientation.y *= d;
				orientation.z *= d;
			}
			// Вычисление глобальной матрицы трансформации
			orientation.toMatrix3D(transformMatrix);
			transformMatrix.d = position.x;
			transformMatrix.h = position.y;
			transformMatrix.l = position.z;
			// Расчёт обратного тензора инерции в мировых координатах
			var a:Number = transformMatrix.a*inverseInertiaTensor.a + transformMatrix.b*inverseInertiaTensor.e + transformMatrix.c*inverseInertiaTensor.i;
			var b:Number = transformMatrix.a*inverseInertiaTensor.b + transformMatrix.b*inverseInertiaTensor.f + transformMatrix.c*inverseInertiaTensor.j;
			var c:Number = transformMatrix.a*inverseInertiaTensor.c + transformMatrix.b*inverseInertiaTensor.g + transformMatrix.c*inverseInertiaTensor.k;
			var e:Number = transformMatrix.e*inverseInertiaTensor.a + transformMatrix.f*inverseInertiaTensor.e + transformMatrix.g*inverseInertiaTensor.i;
			var f:Number = transformMatrix.e*inverseInertiaTensor.b + transformMatrix.f*inverseInertiaTensor.f + transformMatrix.g*inverseInertiaTensor.j;
			var g:Number = transformMatrix.e*inverseInertiaTensor.c + transformMatrix.f*inverseInertiaTensor.g + transformMatrix.g*inverseInertiaTensor.k;
			var i:Number = transformMatrix.i*inverseInertiaTensor.a + transformMatrix.j*inverseInertiaTensor.e + transformMatrix.k*inverseInertiaTensor.i;
			var j:Number = transformMatrix.i*inverseInertiaTensor.b + transformMatrix.j*inverseInertiaTensor.f + transformMatrix.k*inverseInertiaTensor.j;
			var k:Number = transformMatrix.i*inverseInertiaTensor.c + transformMatrix.j*inverseInertiaTensor.g + transformMatrix.k*inverseInertiaTensor.k;
			// Здесь подразумевается, что матрица трансформации тела не содержит масштабирования
			// Произведение [transformMatrix*inverseInertiaTensor]*transpose(transformMatrix)
			inverseInertiaTensorWorld.a = a*transformMatrix.a + b*transformMatrix.b + c*transformMatrix.c;
			inverseInertiaTensorWorld.b = a*transformMatrix.e + b*transformMatrix.f + c*transformMatrix.g;
			inverseInertiaTensorWorld.c = a*transformMatrix.i + b*transformMatrix.j + c*transformMatrix.k;
			inverseInertiaTensorWorld.e = e*transformMatrix.a + f*transformMatrix.b + g*transformMatrix.c;
			inverseInertiaTensorWorld.f = e*transformMatrix.e + f*transformMatrix.f + g*transformMatrix.g;
			inverseInertiaTensorWorld.g = e*transformMatrix.i + f*transformMatrix.j + g*transformMatrix.k;
			inverseInertiaTensorWorld.i = i*transformMatrix.a + j*transformMatrix.b + k*transformMatrix.c;
			inverseInertiaTensorWorld.j = i*transformMatrix.e + j*transformMatrix.f + k*transformMatrix.g;
			inverseInertiaTensorWorld.k = i*transformMatrix.i + j*transformMatrix.j + k*transformMatrix.k;
		}
		
		/**
		 * Интегрирует динамические характеристики и обновляет параметры состояния тела.
		 * 
		 * @param time временной шаг интегрирования
		 */
		public function integrate(time:Number):void {
			if (!awake) {
				return;
			}

			lastFrameAcceleration.x = acceleration.x + forceAccum.x*inverseMass;
			lastFrameAcceleration.y = acceleration.y + forceAccum.y*inverseMass;
			lastFrameAcceleration.z = acceleration.z + forceAccum.z*inverseMass;
			// angularAcceleration = inverseInertiaTensorWorld*torqueAccum
			angularAcceleration.x = inverseInertiaTensorWorld.a*torqueAccum.x + inverseInertiaTensorWorld.b*torqueAccum.y + inverseInertiaTensorWorld.c*torqueAccum.z;
			angularAcceleration.y = inverseInertiaTensorWorld.e*torqueAccum.x + inverseInertiaTensorWorld.f*torqueAccum.y + inverseInertiaTensorWorld.g*torqueAccum.z;
			angularAcceleration.z = inverseInertiaTensorWorld.i*torqueAccum.x + inverseInertiaTensorWorld.j*torqueAccum.y + inverseInertiaTensorWorld.k*torqueAccum.z;
			
			var d:Number = Math.pow(linearDamping, time);
			var dtime:Number = d*time;
			
			velocity.x += lastFrameAcceleration.x*dtime;
			velocity.y += lastFrameAcceleration.y*dtime;
			velocity.z += lastFrameAcceleration.z*dtime;
			
			rotation.x += angularAcceleration.x*dtime;
			rotation.y += angularAcceleration.y*dtime;
			rotation.z += angularAcceleration.z*dtime;

			rotation.x += angularVelocity.x*time;
			rotation.y += angularVelocity.y*time;
			rotation.z += angularVelocity.z*time;
			
			position.x += velocity.x*time;
			position.y += velocity.y*time;
			position.z += velocity.z*time;
			
			orientation.addScaledVector(rotation, time);
			
			// TODO: Нужно ли двойное уменьшение скоростей?
			velocity.x *= d;
			velocity.y *= d;
			velocity.z *= d;
			
			rotation.x *= d;
			rotation.y *= d;
			rotation.z *= d;
			
			calculateDerivedData();
			// inlined clearAccumulators()
			forceAccum.x = 0;
			forceAccum.y = 0;
			forceAccum.z = 0;
			torqueAccum.x = 0;
			torqueAccum.y = 0;
			torqueAccum.z = 0;
			
			// Усыпление тела при необходимости
			if (canSleep) {
				var currentMotion:Number = velocity.x*velocity.x + velocity.y*velocity.y + velocity.z*velocity.z +
					rotation.x*rotation.x + rotation.y*rotation.y + rotation.z*rotation.z;
				var bias:Number = Math.pow(baseBias, time);
				motion = bias*motion + (1 - bias)*currentMotion;
//				trace("[RigidBody::integrate]", name, "motion", motion, "motionEpsilon", motionEpsilon);
				if (motion < motionThreshold) {
					setAwake(false);
				} else {
					if (motion > motionThreshold2) {
						motion = motionThreshold2;
					}
				}
			}
		}
		
		/**
		 * 
		 */
		public function clearAccumulators():void {
			forceAccum.x = 0;
			forceAccum.y = 0;
			forceAccum.z = 0;
			torqueAccum.x = 0;
			torqueAccum.y = 0;
			torqueAccum.z = 0;
		}
		
	}
}