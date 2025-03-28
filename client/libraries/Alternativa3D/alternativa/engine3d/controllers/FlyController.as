package alternativa.engine3d.controllers {
	
	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	import alternativa.utils.KeyboardUtils;
	import alternativa.utils.MathUtils;
	
	import flash.display.DisplayObject;
	
	use namespace alternativa3d;

	/**
	 * Контроллер, реализующий управление объектом, находящимся в корневом объекте сцены, подобно управлению летательным аппаратом.
	 * Повороты выполняются вокруг локальных осей объекта, собственные ускорения действуют вдоль локальных осей.
	 * 
	 * <p>Соответствия локальных осей для объектов, не являющихся камерой:
	 * <table border="1" style="border-collapse: collapse">
	 * <tr>
	 * <th>Ось</th><th>Направление</th><th>Поворот</th>
	 * </tr>
	 * <tr>
	 * <td>X</td><td>Вправо</td><td>Тангаж</td>
	 * </tr>
	 * <tr>
	 * <td>Y</td><td>Вперёд</td><td>Крен</td>
	 * </tr>
	 * <tr>
	 * <td>Z</td><td>Вверх</td><td>Рысканье</td>
	 * </tr>
	 * </table></p>
	 *  
	 * <p>Соответствия локальных осей для объектов, являющихся камерой:
	 * <table border="1" style="border-collapse: collapse">
	 * <tr>
	 * <th>Ось</th><th>Направление</th><th>Поворот</th>
	 * </tr>
	 * <tr>
	 * <td>X</td><td>Вправо</td><td>Тангаж</td>
	 * </tr>
	 * <tr>
	 * <td>Y</td><td>Вниз</td><td>Рысканье</td>
	 * </tr>
	 * <tr>
	 * <td>Z</td><td>Вперёд</td><td>Крен</td>
	 * </tr>
	 * </table></p>
	 * <p>
	 * Поворот мышью реализован следующим образом: в момент активации режима поворота (нажата левая кнопка мыши или
	 * соответствующая кнопка на клавиатуре) текущее положение курсора становится точкой, относительно которой определяются
	 * дальнейшие отклонения. Отклонение курсора по вертикали в пикселях, умноженное на коэффициент чувствительности мыши
	 * по вертикали даёт угловую скорость по тангажу. Отклонение курсора по горизонтали в пикселях, умноженное на коэффициент
	 * чувствительности мыши по горизонтали даёт угловую скорость по крену.
	 * </p>
	 */
	public class FlyController extends ObjectController {
		/**
		 * Имя действия для привязки клавиш поворота по крену влево.
		 */
		public static const ACTION_ROLL_LEFT:String = "ACTION_ROLL_LEFT";
		/**
		 * Имя действия для привязки клавиш поворота по крену вправо.
		 */
		public static const ACTION_ROLL_RIGHT:String = "ACTION_ROLL_RIGHT";
		
		private var _rollLeft:Boolean;
		private var _rollRight:Boolean;
		
		private var _rollSpeed:Number = 1;
		
		private var rotations:Point3D;
		private var rollMatrix:Matrix3D = new Matrix3D();
		private var transformation:Matrix3D = new Matrix3D();
		private var axis:Point3D = new Point3D();
		
		private var velocity:Point3D = new Point3D();
		private var displacement:Point3D = new Point3D();
		private var destination:Point3D = new Point3D();
		private var deltaVelocity:Point3D = new Point3D();
		private var accelerationVector:Point3D = new Point3D();
		private var currentTransform:Matrix3D = new Matrix3D();
		
		private var _currentSpeed:Number = 1;
		/**
		 * Текущие координаты мышиного курсора в режиме mouse look.
		 */
		private var currentMouseCoords:Point3D = new Point3D();

		/**
		 * Модуль вектора ускорния, получаемого от команд движения. 
		 */
		public var acceleration:Number = 1000;
		/**
		 * Модуль вектора замедляющего ускорения.
		 */
		public var deceleration:Number = 50;
		/**
		 * Погрешность определения скорости. Скорость приравнивается к нулю, если её модуль не превышает заданного значения.
		 */
		public var speedThreshold:Number = 1;
		/**
		 * Переключение инерционного режима. В инерционном режиме отсутствует замедляющее ускорение, в результате чего вектор
		 * скорости объекта остаётся постоянным, если нет управляющих воздействий. При выключенном инерционном режиме к объекту
		 * прикладывается замедляющее ускорение. 
		 */
		public var inertialMode:Boolean;
		
		/**
		 * Создаёт новый экземпляр контролллера.
		 *
		 * @param eventsSourceObject источник событий клавиатуры и мыши
		 * 
		 * @throws ArgumentError в качестве eventsSourceObject не может быть указан null
		 */
		public function FlyController(eventsSourceObject:DisplayObject) {
			super(eventsSourceObject);

			actionBindings[ACTION_ROLL_LEFT] = rollLeft;
			actionBindings[ACTION_ROLL_RIGHT] = rollRight;
		}
		
		/**
		 * Текущая скорость движения.
		 */
		public function get currentSpeed():Number {
			return _currentSpeed;
		}
		
		/**
		 * Активация вращения по крену влево.
		 */
		public function rollLeft(value:Boolean):void {
			_rollLeft = value;
		}

		/**
		 * Активация вращения по крену вправо.
		 */
		public function rollRight(value:Boolean):void {
			_rollRight = value;
		}
		
		/**
		 * Установка привязки клавиш по умолчанию. Данный метод очищает все существующие привязки клавиш и устанавливает следующие:
		 * <table border="1" style="border-collapse: collapse">
		 * <tr><th>Клавиша</th><th>Действие</th></tr>
		 * <tr><td>W</td><td>ACTION_FORWARD</td></tr>
		 * <tr><td>S</td><td>ACTION_BACK</td></tr>
		 * <tr><td>A</td><td>ACTION_LEFT</td></tr>
		 * <tr><td>D</td><td>ACTION_RIGHT</td></tr>
		 * <tr><td>SPACE</td><td>ACTION_UP</td></tr>
		 * <tr><td>Z</td><td>ACTION_DOWN</td></tr>
		 * <tr><td>UP</td><td>ACTION_PITCH_UP</td></tr>
		 * <tr><td>DOWN</td><td>ACTION_PITCH_DOWN</td></tr>
		 * <tr><td>LEFT</td><td>ACTION_ROLL_LEFT</td></tr>
		 * <tr><td>RIGHT</td><td>ACTION_ROLL_RIGHT</td></tr>
		 * <tr><td>Q</td><td>ACTION_YAW_LEFT</td></tr>
		 * <tr><td>E</td><td>ACTION_YAW_RIGHT</td></tr>
		 * <tr><td>M</td><td>ACTION_MOUSE_LOOK</td></tr>
		 * </table>
		 */
		override public function setDefaultBindings():void {
			unbindAll();
			bindKey(KeyboardUtils.W, ACTION_FORWARD);
			bindKey(KeyboardUtils.S, ACTION_BACK);
			bindKey(KeyboardUtils.A, ACTION_LEFT);
			bindKey(KeyboardUtils.D, ACTION_RIGHT);
			bindKey(KeyboardUtils.SPACE, ACTION_UP);
			bindKey(KeyboardUtils.Z, ACTION_DOWN);
			bindKey(KeyboardUtils.UP, ACTION_PITCH_UP);
			bindKey(KeyboardUtils.DOWN, ACTION_PITCH_DOWN);
			bindKey(KeyboardUtils.LEFT, ACTION_ROLL_LEFT);
			bindKey(KeyboardUtils.RIGHT, ACTION_ROLL_RIGHT);
			bindKey(KeyboardUtils.Q, ACTION_YAW_LEFT);
			bindKey(KeyboardUtils.E, ACTION_YAW_RIGHT);
			bindKey(KeyboardUtils.M, ACTION_MOUSE_LOOK);
		}
		
		/**
		 * Метод выполняет поворот объекта относительно локальных осей в соответствии с имеющимися воздействиями.
		 * 
		 * @param frameTime длительность текущего кадра в секундах 
		 */
		override protected function rotateObject(frameTime:Number):void {
			var transformation:Matrix3D = _object._transformation;
			if (_mouseLookActive) {
				currentMouseCoords.x = _eventsSource.stage.mouseX;
				currentMouseCoords.y = _eventsSource.stage.mouseY;
				if (!currentMouseCoords.equals(startMouseCoords)) {
					var deltaYaw:Number = (currentMouseCoords.x - startMouseCoords.x) * _mouseCoefficientX;
					if (_object is Camera3D) {
						axis.x = transformation.c;
						axis.y = transformation.g;
						axis.z = transformation.k;
					} else {
						axis.x = transformation.b;
						axis.y = transformation.f;
						axis.z = transformation.j;
					}
					
					rotateObjectAroundAxis(axis, deltaYaw * frameTime);

					currentTransform.toTransform(0, 0, 0, _object.rotationX, _object.rotationY, _object.rotationZ, 1, 1, 1);
					var deltaPitch:Number = (startMouseCoords.y - currentMouseCoords.y) * _mouseCoefficientY;
					axis.x = currentTransform.a;
					axis.y = currentTransform.e;
					axis.z = currentTransform.i;

					rotateObjectAroundAxis(axis, deltaPitch * frameTime);
				}
			}

			// Поворот относительно продольной оси (крен, roll)
			if (_rollLeft) {
				if (_object is Camera3D) {
					axis.x = transformation.c;
					axis.y = transformation.g;
					axis.z = transformation.k;
				} else {
					axis.x = transformation.b;
					axis.y = transformation.f;
					axis.z = transformation.j;
				}
				rotateObjectAroundAxis(axis, -_rollSpeed * frameTime);
			} else if (_rollRight) {
				if (_object is Camera3D) {
					axis.x = transformation.c;
					axis.y = transformation.g;
					axis.z = transformation.k;
				} else {
					axis.x = transformation.b;
					axis.y = transformation.f;
					axis.z = transformation.j;
				}
				rotateObjectAroundAxis(axis, _rollSpeed * frameTime);
			}
			
			// Поворот относительно поперечной оси (тангаж, pitch)
			if (_pitchUp) {
				axis.x = transformation.a;
				axis.y = transformation.e;
				axis.z = transformation.i;
				rotateObjectAroundAxis(axis, _pitchSpeed * frameTime);
			} else if (_pitchDown) {
				axis.x = transformation.a;
				axis.y = transformation.e;
				axis.z = transformation.i;
				rotateObjectAroundAxis(axis, -_pitchSpeed * frameTime);
			}

			// Поворот относительно вертикальной оси (рысканье, yaw)
			if (_yawRight) {
				if (_object is Camera3D) {
					axis.x = transformation.b;
					axis.y = transformation.f;
					axis.z = transformation.j;
					rotateObjectAroundAxis(axis, _yawSpeed * frameTime);
				} else {
					axis.x = transformation.c;
					axis.y = transformation.g;
					axis.z = transformation.k;
					rotateObjectAroundAxis(axis, -_yawSpeed * frameTime);
				}
			} else if (_yawLeft) {
				if (_object is Camera3D) {
					axis.x = transformation.b;
					axis.y = transformation.f;
					axis.z = transformation.j;
					rotateObjectAroundAxis(axis, -_yawSpeed * frameTime);
				} else {
					axis.x = transformation.c;
					axis.y = transformation.g;
					axis.z = transformation.k;
					rotateObjectAroundAxis(axis, _yawSpeed * frameTime);
				}
			}
		}
		
		/**
		 * Метод вычисляет вектор потенциального смещения эллипсоида.
		 * 
		 * @param frameTime длительность текущего кадра в секундах 
		 * @param displacement в эту переменную записывается вычисленное потенциальное смещение объекта
		 */
		override protected function getDisplacement(frameTime:Number, displacement:Point3D):void {
			// Движение вперед-назад
			accelerationVector.x = 0;
			accelerationVector.y = 0;
			accelerationVector.z = 0;
			if (_forward) {
				accelerationVector.y = 1;
			} else if (_back) {
				accelerationVector.y = -1;
			}
			// Движение влево-вправо
			if (_right) {
				accelerationVector.x = 1;
			} else if (_left) {
				accelerationVector.x = -1;
			}
			// Движение ввверх-вниз
			if (_up) {
				accelerationVector.z = 1;
			} else if (_down) {
				accelerationVector.z = -1;
			}
			
			var speedLoss:Number;
			var len:Number;
			
			if (accelerationVector.x != 0 || accelerationVector.y != 0 || accelerationVector.z != 0) {
				// Управление активно
				if (_object is Camera3D) {
					var tmp:Number = accelerationVector.z;
					accelerationVector.z = accelerationVector.y;
					accelerationVector.y = -tmp;
				}
				accelerationVector.normalize();
				accelerationVector.x *= acceleration;
				accelerationVector.y *= acceleration;
				accelerationVector.z *= acceleration;
				currentTransform.toTransform(0, 0, 0, _object.rotationX, _object.rotationY, _object.rotationZ, 1, 1, 1);
				accelerationVector.transform(currentTransform);
				deltaVelocity.x = accelerationVector.x;
				deltaVelocity.y = accelerationVector.y;
				deltaVelocity.z = accelerationVector.z;
				deltaVelocity.x *= frameTime;
				deltaVelocity.y *= frameTime;
				deltaVelocity.z *= frameTime;

				if (!inertialMode) {
					speedLoss = deceleration * frameTime;
					var dot:Number = Point3D.dot(velocity, accelerationVector);
					if (dot > 0) {
						len = accelerationVector.length;
						var x:Number = accelerationVector.x / len;
						var y:Number = accelerationVector.y / len;
						var z:Number = accelerationVector.z / len;
						len = dot / len;
						x = velocity.x - len * x;
						y = velocity.y - len * y;
						z = velocity.z - len * z;
						len = Math.sqrt(x*x + y*y + z*z);
						if (len > speedLoss) {
							x *= speedLoss / len;
							y *= speedLoss / len;
							z *= speedLoss / len;
						}
						velocity.x -= x;
						velocity.y -= y;
						velocity.z -= z;
					} else {
						len = velocity.length;
						velocity.length = (len > speedLoss) ? (len - speedLoss) : 0;
					}
				}

				velocity.x += deltaVelocity.x;
				velocity.y += deltaVelocity.y;
				velocity.z += deltaVelocity.z;

				if (velocity.length > _speed) {
					velocity.length = _speed;
				}
			} else {
				// Управление неактивно
				if (!inertialMode) {
					speedLoss = deceleration * frameTime;
					len = velocity.length;
					velocity.length = (len > speedLoss) ? (len - speedLoss) : 0;
				}
			}
			
			displacement.x = velocity.x * frameTime;
			displacement.y = velocity.y * frameTime;
			displacement.z = velocity.z * frameTime;
		}
		
		/**
		 * Метод применяет потенциальный вектор смещения к эллипсоиду с учётом столкновений с геометрией сцены, если включён
		 * соотвествующий режим.
		 *   
		 * @param frameTime время кадра в секундах
		 * @param displacement векотр потенциального смещения эллипсоида
		 */
		override protected function applyDisplacement(frameTime:Number, displacement:Point3D):void {
			if (checkCollisions) {
				_collider.calculateDestination(_coords, displacement, destination);

				displacement.x = destination.x - _coords.x;
				displacement.y = destination.y - _coords.y;
				displacement.z = destination.z - _coords.z;
			} else {
				destination.x = _coords.x + displacement.x;
				destination.y = _coords.y + displacement.y;
				destination.z = _coords.z + displacement.z;
			}

			velocity.x = displacement.x / frameTime;
			velocity.y = displacement.y / frameTime;
			velocity.z = displacement.z / frameTime;

			_coords.x = destination.x;
			_coords.y = destination.y;
			_coords.z = destination.z;
			setObjectCoords();
			
			var len:Number = Math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y + velocity.z * velocity.z);
			if (len < speedThreshold) {
				velocity.x = 0;
				velocity.y = 0;
				velocity.z = 0;
				_currentSpeed = 0;
			} else {
				_currentSpeed = len;
			}
		}

		/**
		 * Поворот объекта вокруг заданной оси.
		 * 
		 * @param axis
		 * @param angle
		 */		
		private function rotateObjectAroundAxis(axis:Point3D, angle:Number):void {
			transformation.toTransform(0, 0, 0, _object.rotationX, _object.rotationY, _object.rotationZ, 1, 1, 1);
			rollMatrix.fromAxisAngle(axis, angle);
			rollMatrix.inverseCombine(transformation);
			rotations = rollMatrix.getRotations(rotations);
			_object.rotationX = rotations.x;
			_object.rotationY = rotations.y;
			_object.rotationZ = rotations.z;
		}

		/**
		 * Направление объекта на точку. В результате работы метода локальная ось объекта, соответствующая направлению "вперёд"
		 * будет направлена на указанную точку, а угол поворота вокруг этой оси будет равен нулю.
		 * 
		 * @param point координаты точки, на которую должен быть направлен объект
		 */
		public function lookAt(point:Point3D):void {
			if (_object == null) {
				return;
			}
			var dx:Number = point.x - _object.x;
			var dy:Number = point.y - _object.y;
			var dz:Number = point.z - _object.z;
			_object.rotationX = Math.atan2(dz, Math.sqrt(dx * dx + dy * dy)) - (_object is Camera3D ? MathUtils.DEG90 : 0);
			_object.rotationY = 0;
			_object.rotationZ = -Math.atan2(dx, dy);
		}

		/**
		 * @inheritDoc
		 */
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			if (!value) {
				velocity.reset();
				_currentSpeed = 0;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function clearCommandFlags():void {
			super.clearCommandFlags();
			_rollLeft = false;
			_rollRight = false;
		}

	}
}
