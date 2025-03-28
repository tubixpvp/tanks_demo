package alternativa.physics.rigid {
	
	import alternativa.physics.*;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	
	use namespace altphysics;
	
	/**
	 * Класс описывает контакт между телами. Контакты могут составлять двунаправленный список.
	 */
	public class RigidBodyContact {
		
		private var tmpVelocityVector:Point3D = new Point3D();
		private var impulse:Point3D = new Point3D();
		
		public static var velocityLimit:Number = 1;
		
		/**
		 * Ссылка на следующий контакт в списке.
		 */
		public var next:RigidBodyContact;
		/**
		 * Ссылка на предыдущий контакт в списке.
		 */		
		public var prev:RigidBodyContact;
		/**
		 * Индекс контакта в списке.
		 */
		public var index:int;
		
		/**
		 * Первое тело, к которому относится контакт.
		 */		
		public var body1:RigidBody;
		/**
		 * Первое тело, к которому относится контакт (может быть null).
		 */		
		public var body2:RigidBody;
		/**
		 * Точка контакта.
		 */
		public var contactPoint:Point3D = new Point3D();
		/**
		 * Нормаль контакта. Нормаль направлена от второго тела к первому. В локальной системе координат контакта
		 * нормаль является базисным вектором, задающим направление оси X. 
		 */
		public var contactNormal:Point3D = new Point3D();
		/**
		 * Коэффициент взаимного трения в точке контакта.
		 */		
		public var friction:Number = 0;
		/**
		 * Коэффициент упругости удара.
		 */
		public var restitution:Number = 0;
		/**
		 * Глубина взаимного проникновения тел в точке контакта.
		 */
		public var penetration:Number;
		
		public var timeStamp:int;
		
		/**
		 * Матрица перехода из локальной системы координат контакта в мировую систему координат без компонентов параллельного переноса.
		 * Матрица задаёт базис локальной системы координат контакта.
		 */		
		altphysics var contactToWorld:Matrix3D = new Matrix3D();
		/**
		 * Относительная скорость в точке контакта. Вычисляется в методе calculateInternals(). 
		 */
		altphysics var contactVelocity:Point3D = new Point3D();
		/**
		 * Приращение скорости в точке контакта по направлению нормали, необходимое для прекращения сближения. Вычисляется в методе calculateInternals(). 
		 */
		altphysics var desiredDeltaVelocity:Number;
		/**
		 * Координаты точки контакта относительныо первого тела. Вычисляется в методе calculateInternals(). 
		 */
		altphysics var relativeContactPosition1:Point3D = new Point3D();
		/**
		 * Координаты точки контакта относительныо второго тела. Вычисляется в методе calculateInternals(). 
		 */
		altphysics var relativeContactPosition2:Point3D = new Point3D();
		
		/**
		 * 
		 * @param index
		 */
		public function RigidBodyContact(index:int) {
			this.index = index;
		}
		
		/**
		 * 
		 * @param body1
		 * @param body2
		 * @param friction
		 * @param restitution
		 */
		public function setBodyData(body1:RigidBody, body2:RigidBody, friction:Number, restitution:Number):void {
			this.body1 = body1;
			this.body2 = body2;
			this.friction = friction;
			this.restitution = restitution;
		}
		
		/**
		 * 
		 */
		public function matchAwakeState():void {
			if (body2 == null) {
				return;
			}
			
			if (body1.awake != body2.awake) {
				if (body1.awake) {
					body2.setAwake();
				} else {
					body1.setAwake();
				}
			}
		}
		
		/**
		 * Вычисляет и сохраняет базис локальной системы координат контакта.
		 */
		public function calculateContactBasis():void {
			// Нормаль является ортом X локальной системы координат
			contactToWorld.a = contactNormal.x;
			contactToWorld.e = contactNormal.y;
			contactToWorld.i = contactNormal.z;
			var nx:Number = contactNormal.x > 0 ? contactNormal.x : -contactNormal.x;
			var ny:Number = contactNormal.y > 0 ? contactNormal.y : -contactNormal.y;
			var s:Number;
			if (nx > ny) {
				// Нормаль ближе к глобальной оси X, используем ось Y для вычислений. Локальный орт Y находится как результат векторного произведения globalY x contactNormal.
				s = 1/Math.sqrt(nx*nx + contactNormal.z*contactNormal.z);
				contactToWorld.b = contactNormal.z*s;
				contactToWorld.f = 0;
				contactToWorld.j = -contactNormal.x*s;
				// Локальный орт Z находится как результат векторного произведения contactNormal x localY.
				contactToWorld.c = contactNormal.y*contactToWorld.j;
				contactToWorld.g = contactNormal.z*contactToWorld.b - contactNormal.x*contactToWorld.j;
				contactToWorld.k = -contactNormal.y*contactToWorld.b;
			} else {
				// Нормаль ближе к глобальной оси Y, используем ось X для вычислений. Локальный орт Y находится как результат векторного произведения globalX x contactNormal.
				s = 1/Math.sqrt(ny*ny + contactNormal.z*contactNormal.z);
				contactToWorld.b = 0;
				contactToWorld.f = -contactNormal.z*s;
				contactToWorld.j = contactNormal.y*s;
				// Локальный орт Z находится как результат векторного произведения contactNormal x localY.
				contactToWorld.c = contactNormal.y*contactToWorld.j - contactNormal.z*contactToWorld.f;
				contactToWorld.g = -contactNormal.x*contactToWorld.j;
				contactToWorld.k = contactNormal.x*contactToWorld.f;
			}
		}
		
		/**
		 * Вычисляет скорость точки заданного тела в точке контакта в его локальной системе координат.
		 * 
		 * @param body тело, для которого выполняются вычисления
		 * @param relativeContactPosition положение точки контакта относительно тела
		 * @param time временной шаг
		 * @param result в эту переменную записывается результат 
		 */
		public function calculateLocalVelocity(body:RigidBody, relativeContactPosition:Point3D, time:Number, result:Point3D):void {
			// Расчёт прироста скорости за последний кадр от действующих сил
			var x:Number = body.lastFrameAcceleration.x*time;
			var y:Number = body.lastFrameAcceleration.y*time;
			var z:Number = body.lastFrameAcceleration.z*time;
			// Прирост скорости в системе координат контакта
			// Убираем прирост скорости в направлении контакта
			var accVelocityY:Number = contactToWorld.b*x + contactToWorld.f*y + contactToWorld.j*z;
			var accVelocityZ:Number = contactToWorld.c*x + contactToWorld.g*y + contactToWorld.k*z;

			// Скорость точки контакта в мировой системе координат
			// Скорость за счёт вращения тела
			var rotation:Point3D = body.rotation;
			x = rotation.y*relativeContactPosition.z - rotation.z*relativeContactPosition.y + body.velocity.x;
			y = rotation.z*relativeContactPosition.x - rotation.x*relativeContactPosition.z + body.velocity.y;
			z = rotation.x*relativeContactPosition.y - rotation.y*relativeContactPosition.x + body.velocity.z;
			// Скорость точки контакта в системе координат контакта
			// Касательные компоненты прироста скорости добавляются к скорости точки контакта. В дальнейшем они либо уберутся силой трения,
			// либо уменьшатся ею.
			result.x = contactToWorld.a*x + contactToWorld.e*y + contactToWorld.i*z;
			result.y = contactToWorld.b*x + contactToWorld.f*y + contactToWorld.j*z + accVelocityY;
			result.z = contactToWorld.c*x + contactToWorld.g*y + contactToWorld.k*z + accVelocityZ;
		}
		
		/**
		 * Вычисляет и устанавливает внутреннее значение для требуемого изменения относительной скорости вдоль нормали контакта.
		 * С реакциями опоры разбираемся путём вычитания из скорости сближения прироста скорости, полученного во время последнего кадра.
		 * 
		 * @param time
		 */
		public function calculateDesiredVelocity(time:Number):void {
			// Вычисляем проекцию прироста скорости за текущий кадр на нормаль контакта. Для относительного прироста скорости, вызывающего
			// сближение объектов, значение будет отрицательным.
			var velocityFromAcc:Number = 0;
			if (body1.awake) {
				velocityFromAcc = (body1.lastFrameAcceleration.x*contactNormal.x + body1.lastFrameAcceleration.y*contactNormal.y + body1.lastFrameAcceleration.z*contactNormal.z)*time;
			}
			if (body2 != null && body2.awake) {
				velocityFromAcc -= (body2.lastFrameAcceleration.x*contactNormal.x + body2.lastFrameAcceleration.y*contactNormal.y + body2.lastFrameAcceleration.z*contactNormal.z)*time;
			}
			// Если относительная скорость вдоль нормали контакта слишком мала, игнорируем её 
			var thisRestitution:Number = restitution;
			if (contactVelocity.x > -velocityLimit && contactVelocity.x < velocityLimit) {
				thisRestitution = 0;
			}
			// Вычисляем дельту для скорости отскока, убрав влияние прироста скорости за последний кадр 
			desiredDeltaVelocity = -contactVelocity.x - thisRestitution*(contactVelocity.x - velocityFromAcc);
		}
		
		/**
		 * Расчитывает внутренние данные о контакта на основе данных о его состоянии. Вызывается до того, как будет запущен
		 * алгоритм разрешения контактов. Эта функция в нормальных условиях никогда не должна вызываться вручную.
		 *  
		 * @param time
		 */
		public function calculateInternals(time:Number):void {
			// Расчёт базиса системы координат контакта
			// === inlined calculateContactBasis();
			contactToWorld.a = contactNormal.x;
			contactToWorld.e = contactNormal.y;
			contactToWorld.i = contactNormal.z;
			var nx:Number = contactNormal.x > 0 ? contactNormal.x : -contactNormal.x;
			var ny:Number = contactNormal.y > 0 ? contactNormal.y : -contactNormal.y;
			var s:Number;
			if (nx > ny) {
				// Нормаль ближе к глобальной оси X, используем ось Y для вычислений. Локальный орт Y находится как результат векторного произведения globalY x contactNormal.
				s = 1/Math.sqrt(nx*nx + contactNormal.z*contactNormal.z);
				contactToWorld.b = contactNormal.z*s;
				contactToWorld.f = 0;
				contactToWorld.j = -contactNormal.x*s;
				// Локальный орт Z находится как результат векторного произведения contactNormal x localY.
				contactToWorld.c = contactNormal.y*contactToWorld.j;
				contactToWorld.g = contactNormal.z*contactToWorld.b - contactNormal.x*contactToWorld.j;
				contactToWorld.k = -contactNormal.y*contactToWorld.b;
			} else {
				// Нормаль ближе к глобальной оси Y, используем ось X для вычислений. Локальный орт Y находится как результат векторного произведения globalX x contactNormal.
				s = 1/Math.sqrt(ny*ny + contactNormal.z*contactNormal.z);
				contactToWorld.b = 0;
				contactToWorld.f = -contactNormal.z*s;
				contactToWorld.j = contactNormal.y*s;
				// Локальный орт Z находится как результат векторного произведения contactNormal x localY.
				contactToWorld.c = contactNormal.y*contactToWorld.j - contactNormal.z*contactToWorld.f;
				contactToWorld.g = -contactNormal.x*contactToWorld.j;
				contactToWorld.k = contactNormal.x*contactToWorld.f;
			}
			// === end inlined 
			
			// Расчёт локальной скорости в точке контакта для первого тела
			relativeContactPosition1.x = contactPoint.x - body1.position.x;
			relativeContactPosition1.y = contactPoint.y - body1.position.y;
			relativeContactPosition1.z = contactPoint.z - body1.position.z;
			calculateLocalVelocity(body1, relativeContactPosition1, time, contactVelocity);
			// Расчёт локальной скорости в точке контакта для второго тела
			if (body2 != null) {
				relativeContactPosition2.x = contactPoint.x - body2.position.x;
				relativeContactPosition2.y = contactPoint.y - body2.position.y;
				relativeContactPosition2.z = contactPoint.z - body2.position.z;
				calculateLocalVelocity(body2, relativeContactPosition2, time, tmpVelocityVector);
				// Расчёт относительной скорости в точке контакта
				contactVelocity.x -= tmpVelocityVector.x;
				contactVelocity.y -= tmpVelocityVector.y;
				contactVelocity.z -= tmpVelocityVector.z;
			}
			// Расчёт вектора изменения скорости, требуемого для разрешения контакта
			calculateDesiredVelocity(time);
		}

		/**
		 * Выполняет разделение контакта посредством импульса, пропорционально инерции тел.
		 */
		public function applyVelocityChange(velocityChange1:Point3D, velocityChange2:Point3D, rotationChange1:Point3D, rotationChange2:Point3D):void {
			var inverseInertiaTensor1:Matrix3D = body1.inverseInertiaTensorWorld;
			var inverseInertiaTensor2:Matrix3D;
			if (body2 != null) {
				inverseInertiaTensor2 = body2.inverseInertiaTensorWorld;
			}
			
			if (friction == 0) {
				calculateFrictionlessImpulse(inverseInertiaTensor1, inverseInertiaTensor2, impulse);
			} else {
				calculateFrictionImpulse(inverseInertiaTensor1, inverseInertiaTensor2, impulse);
			}
			
			// Переведём импульс в мировые координаты
			var x:Number = impulse.x;
			var y:Number = impulse.y;
			var z:Number = impulse.z;
			impulse.x = contactToWorld.a*x + contactToWorld.b*y + contactToWorld.c*z;
			impulse.y = contactToWorld.e*x + contactToWorld.f*y + contactToWorld.g*z;
			impulse.z = contactToWorld.i*x + contactToWorld.j*y + contactToWorld.k*z;
			
			// Разделим импульс на вращательную и линейную часть
			x = relativeContactPosition1.y*impulse.z - relativeContactPosition1.z*impulse.y;
			y = relativeContactPosition1.z*impulse.x - relativeContactPosition1.x*impulse.z;
			z = relativeContactPosition1.x*impulse.y - relativeContactPosition1.y*impulse.x;
			rotationChange1.x = inverseInertiaTensor1.a*x + inverseInertiaTensor1.b*y + inverseInertiaTensor1.c*z;
			rotationChange1.y = inverseInertiaTensor1.e*x + inverseInertiaTensor1.f*y + inverseInertiaTensor1.g*z;
			rotationChange1.z = inverseInertiaTensor1.i*x + inverseInertiaTensor1.j*y + inverseInertiaTensor1.k*z;
			
			velocityChange1.x = impulse.x*body1.inverseMass;
			velocityChange1.y = impulse.y*body1.inverseMass;
			velocityChange1.z = impulse.z*body1.inverseMass;
			
			body1.velocity.x += velocityChange1.x;
			body1.velocity.y += velocityChange1.y;
			body1.velocity.z += velocityChange1.z;
			
			body1.rotation.x += rotationChange1.x;
			body1.rotation.y += rotationChange1.y;
			body1.rotation.z += rotationChange1.z;
			
			if (body2 != null) {
				x = relativeContactPosition2.z*impulse.y - relativeContactPosition2.y*impulse.z;
				y = relativeContactPosition2.x*impulse.z - relativeContactPosition2.z*impulse.x;
				z = relativeContactPosition2.y*impulse.x - relativeContactPosition2.x*impulse.y;
				rotationChange2.x = inverseInertiaTensor2.a*x + inverseInertiaTensor2.b*y + inverseInertiaTensor2.c*z;
				rotationChange2.y = inverseInertiaTensor2.e*x + inverseInertiaTensor2.f*y + inverseInertiaTensor2.g*z;
				rotationChange2.z = inverseInertiaTensor2.i*x + inverseInertiaTensor2.j*y + inverseInertiaTensor2.k*z;
				
				velocityChange2.x = -impulse.x*body2.inverseMass;
				velocityChange2.y = -impulse.y*body2.inverseMass;
				velocityChange2.z = -impulse.z*body2.inverseMass;

				body2.velocity.x += velocityChange2.x;
				body2.velocity.y += velocityChange2.y;
				body2.velocity.z += velocityChange2.z;
				
				body2.rotation.x += rotationChange2.x;
				body2.rotation.y += rotationChange2.y;
				body2.rotation.z += rotationChange2.z;
			}
		}
		
		/**
		 * Вычисляет импульс, необходимый для коррекции скоростей в точке контакта в отсутствие сил трения.
		 */
		public function calculateFrictionlessImpulse(inverseInertiaTensor1:Matrix3D, inverseInertiaTensor2:Matrix3D, result:Point3D):void {
			tmpVelocityVector.x = relativeContactPosition1.y*contactNormal.z - relativeContactPosition1.z*contactNormal.y;
			tmpVelocityVector.y = relativeContactPosition1.z*contactNormal.x - relativeContactPosition1.x*contactNormal.z;
			tmpVelocityVector.z = relativeContactPosition1.x*contactNormal.y - relativeContactPosition1.y*contactNormal.x;
			
			var x:Number = inverseInertiaTensor1.a*tmpVelocityVector.x + inverseInertiaTensor1.b*tmpVelocityVector.y + inverseInertiaTensor1.c*tmpVelocityVector.z;
			var y:Number = inverseInertiaTensor1.e*tmpVelocityVector.x + inverseInertiaTensor1.f*tmpVelocityVector.y + inverseInertiaTensor1.g*tmpVelocityVector.z;
			var z:Number = inverseInertiaTensor1.i*tmpVelocityVector.x + inverseInertiaTensor1.j*tmpVelocityVector.y + inverseInertiaTensor1.k*tmpVelocityVector.z;
			
			tmpVelocityVector.x = y*relativeContactPosition1.z - z*relativeContactPosition1.y;
			tmpVelocityVector.y = z*relativeContactPosition1.x - x*relativeContactPosition1.z;
			tmpVelocityVector.z = x*relativeContactPosition1.y - y*relativeContactPosition1.x;
			
			var deltaVelocity:Number = tmpVelocityVector.x*contactNormal.x + tmpVelocityVector.y*contactNormal.y + tmpVelocityVector.z*contactNormal.z + body1.inverseMass;
			
			if (body2 != null) {
				tmpVelocityVector.x = relativeContactPosition2.y*contactNormal.z - relativeContactPosition2.z*contactNormal.y;
				tmpVelocityVector.y = relativeContactPosition2.z*contactNormal.x - relativeContactPosition2.x*contactNormal.z;
				tmpVelocityVector.z = relativeContactPosition2.x*contactNormal.y - relativeContactPosition2.y*contactNormal.x;
				
				x = inverseInertiaTensor2.a*tmpVelocityVector.x + inverseInertiaTensor2.b*tmpVelocityVector.y + inverseInertiaTensor2.c*tmpVelocityVector.z;
				y = inverseInertiaTensor2.e*tmpVelocityVector.x + inverseInertiaTensor2.f*tmpVelocityVector.y + inverseInertiaTensor2.g*tmpVelocityVector.z;
				z = inverseInertiaTensor2.i*tmpVelocityVector.x + inverseInertiaTensor2.j*tmpVelocityVector.y + inverseInertiaTensor2.k*tmpVelocityVector.z;
				
				tmpVelocityVector.x = y*relativeContactPosition2.z - z*relativeContactPosition2.y;
				tmpVelocityVector.y = z*relativeContactPosition2.x - x*relativeContactPosition2.z;
				tmpVelocityVector.z = x*relativeContactPosition2.y - y*relativeContactPosition2.x;
				
				deltaVelocity += tmpVelocityVector.x*contactNormal.x + tmpVelocityVector.y*contactNormal.y + tmpVelocityVector.z*contactNormal.z + body2.inverseMass;
			}
			
			result.x = desiredDeltaVelocity/deltaVelocity;
			result.y = 0;
			result.z = 0;
		}
		
		private var impulseToTorque:Matrix3D = new Matrix3D();
		private var deltaVelWorldMatrix:Matrix3D = new Matrix3D();
		private var deltaVelWorldMatrix2:Matrix3D = new Matrix3D();
		/**
		 * Вычисляет импульс, необходимый для коррекции скоростей в точке контакта при наличии сил трения.
		 */
		public function calculateFrictionImpulse(inverseInertiaTensor1:Matrix3D, inverseInertiaTensor2:Matrix3D, result:Point3D):void {
			var inverseMass:Number = body1.inverseMass;
			
			relativeContactPosition1.createSkewSymmetricMatrix(impulseToTorque);
			
			deltaVelWorldMatrix.copy(impulseToTorque);
			deltaVelWorldMatrix.inverseCombine(inverseInertiaTensor1);
			deltaVelWorldMatrix.inverseCombine(impulseToTorque);
			deltaVelWorldMatrix.multByScalar(-1);
			
			if (body2 != null) {
				relativeContactPosition2.createSkewSymmetricMatrix(impulseToTorque);
				deltaVelWorldMatrix2.copy(impulseToTorque);
				deltaVelWorldMatrix2.inverseCombine(inverseInertiaTensor2);
				deltaVelWorldMatrix2.inverseCombine(impulseToTorque);
				deltaVelWorldMatrix2.multByScalar(-1);
				
				deltaVelWorldMatrix.add(deltaVelWorldMatrix2);
				inverseMass += body2.inverseMass;
			}
			
			deltaVelWorldMatrix2.copy(contactToWorld);
			deltaVelWorldMatrix2.transpose();
			deltaVelWorldMatrix2.inverseCombine(deltaVelWorldMatrix);
			deltaVelWorldMatrix2.inverseCombine(contactToWorld);
			deltaVelWorldMatrix2.a += inverseMass;
			deltaVelWorldMatrix2.f += inverseMass;
			deltaVelWorldMatrix2.k += inverseMass;
			
			deltaVelWorldMatrix.copy(deltaVelWorldMatrix2);
			deltaVelWorldMatrix.invert();
			
			result.reset(desiredDeltaVelocity, -contactVelocity.y, -contactVelocity.z);
			result.transform(deltaVelWorldMatrix);
			
			var planarImpulse:Number = Math.sqrt(result.y*result.y + result.z*result.z);
			if (planarImpulse > result.x*friction) {
				result.y /= planarImpulse;
				result.z /= planarImpulse;
				result.x = desiredDeltaVelocity/(deltaVelWorldMatrix2.a + deltaVelWorldMatrix2.b*friction*result.y + deltaVelWorldMatrix2.c*friction*result.z);
				result.y *= friction*result.x;
				result.z *= friction*result.x;
			}
		}		

		private var angularInertiaWorld:Point3D = new Point3D();
 		/**
		 * Выполняет разделение контакта с учётом инертности тел.
		 */
		public function applyPositionChange(linearChange1:Point3D, linearChange2:Point3D, angularChange1:Point3D, angularChange2:Point3D, penetration:Number):void {
			var totalInertia:Number = 0;
			var angularInertia1:Number;
			var angularInertia2:Number;
			var linearInertia1:Number;
			var linearInertia2:Number;
			
			// body1
			angularInertiaWorld.x = relativeContactPosition1.y*contactNormal.z - relativeContactPosition1.z*contactNormal.y;
			angularInertiaWorld.y = relativeContactPosition1.z*contactNormal.x - relativeContactPosition1.x*contactNormal.z;
			angularInertiaWorld.z = relativeContactPosition1.x*contactNormal.y - relativeContactPosition1.y*contactNormal.x;
			var m:Matrix3D = body1.inverseInertiaTensorWorld;
			var x:Number = m.a*angularInertiaWorld.x + m.b*angularInertiaWorld.y + m.c*angularInertiaWorld.z;
			var y:Number = m.e*angularInertiaWorld.x + m.f*angularInertiaWorld.y + m.g*angularInertiaWorld.z;
			var z:Number = m.i*angularInertiaWorld.x + m.j*angularInertiaWorld.y + m.k*angularInertiaWorld.z;
			angularInertiaWorld.x = y*relativeContactPosition1.z - z*relativeContactPosition1.y;
			angularInertiaWorld.y = z*relativeContactPosition1.x - x*relativeContactPosition1.z;
			angularInertiaWorld.z = x*relativeContactPosition1.y - y*relativeContactPosition1.x;
			
			angularInertia1 = angularInertiaWorld.x*contactNormal.x + angularInertiaWorld.y*contactNormal.y + angularInertiaWorld.z*contactNormal.z;
			linearInertia1 = body1.inverseMass;
			
			totalInertia = linearInertia1 + angularInertia1;
			
			if (body2 != null) {
				angularInertiaWorld.x = relativeContactPosition2.y*contactNormal.z - relativeContactPosition2.z*contactNormal.y;
				angularInertiaWorld.y = relativeContactPosition2.z*contactNormal.x - relativeContactPosition2.x*contactNormal.z;
				angularInertiaWorld.z = relativeContactPosition2.x*contactNormal.y - relativeContactPosition2.y*contactNormal.x;
				m = body2.inverseInertiaTensorWorld;
				x = m.a*angularInertiaWorld.x + m.b*angularInertiaWorld.y + m.c*angularInertiaWorld.z;
				y = m.e*angularInertiaWorld.x + m.f*angularInertiaWorld.y + m.g*angularInertiaWorld.z;
				z = m.i*angularInertiaWorld.x + m.j*angularInertiaWorld.y + m.k*angularInertiaWorld.z;
				angularInertiaWorld.x = y*relativeContactPosition2.z - z*relativeContactPosition2.y;
				angularInertiaWorld.y = z*relativeContactPosition2.x - x*relativeContactPosition2.z;
				angularInertiaWorld.z = x*relativeContactPosition2.y - y*relativeContactPosition2.x;

				angularInertia2 = angularInertiaWorld.x*contactNormal.x + angularInertiaWorld.y*contactNormal.y + angularInertiaWorld.z*contactNormal.z;
				linearInertia2 = body2.inverseMass;

				totalInertia += linearInertia2 + angularInertia2;
			}
			
			// body1
			applyPostionChangeToBody(body1, relativeContactPosition1, angularInertia1, linearInertia1, totalInertia, 1, angularChange1, linearChange1);
			
			if (body2 != null) {
				applyPostionChangeToBody(body2, relativeContactPosition2, angularInertia2, linearInertia2, totalInertia, -1, angularChange2, linearChange2);
			}
		}
		
		private var projection:Point3D = new Point3D();
		/**
		 * 
		 * @param body
		 * @param relativeContactPosition
		 * @param angularInertia
		 * @param linearInertia
		 * @param totalInertia
		 * @param sign
		 * @param angularChange
		 * @param linearChange
		 */		
		private function applyPostionChangeToBody(body:RigidBody, relativeContactPosition:Point3D, angularInertia:Number, linearInertia:Number, totalInertia:Number, sign:Number, angularChange:Point3D, linearChange:Point3D):void {
			var angularLimit:Number = 0.2;
			var angularMove:Number = sign*penetration*angularInertia/totalInertia;
			var linearMove:Number = sign*penetration*linearInertia/totalInertia;
			
			projection.copy(contactNormal);
			projection.multiply(-relativeContactPosition.dot(contactNormal));
			projection.add(relativeContactPosition);
			
			var maxMagnitude:Number = angularLimit*projection.length;
			
			var totalMove:Number;
			if (angularMove < -maxMagnitude) {
				totalMove = angularMove + linearMove;
				angularMove = -maxMagnitude;
				linearMove = totalMove - angularMove;
			} else if (angularMove > maxMagnitude) {
				totalMove = angularMove + linearMove;
				angularMove = maxMagnitude;
				linearMove = totalMove - angularMove;
			}
			
			if (angularMove == 0) {
				angularChange.reset();
			} else {
				angularChange.copy(relativeContactPosition);
				angularChange.cross(contactNormal);
				angularChange.transform(body.inverseInertiaTensorWorld);
				angularChange.multiply(angularMove/angularInertia);
			}
			
			linearChange.copy(contactNormal);
			linearChange.multiply(linearMove);
			
			body.position.add(linearChange);
			body.orientation.addScaledVector(angularChange, 1);
			if (!body.awake) {
				body.calculateDerivedData();
			}
		}

		public function toString():String {
			return "RigidBodyContact" +
				"\n timeStamp: " + timeStamp +
				"\n  body1: " + body1.getName() + 
				"\n  body2: " + (body2 == null ? "" : body2.getName()) +
				"\n  contactPoint: " + contactPoint +
				"\n  contactNormal: " + contactNormal +
				"\n  restitution: " + restitution + 
				"\n  penetration: " + penetration + 
				"\n  friction: " + friction;
		}

	}
}
