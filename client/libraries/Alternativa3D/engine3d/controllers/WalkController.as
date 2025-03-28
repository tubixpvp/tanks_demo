package alternativa.engine3d.controllers {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.physics.Collision;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	import alternativa.utils.KeyboardUtils;
	import alternativa.utils.MathUtils;
	
	import flash.display.DisplayObject;
	
	use namespace alternativa3d;
	
	/**
	 * Контроллер, реализующий управление движением объекта, находящегося в системе координат корневого объекта сцены. 
	 * 
	 * <p>Контроллер предоставляет два режима движения: режим ходьбы с учётом силы тяжести и режим полёта, в котором сила
	 * тяжести не учитывается. В обоих режимах может быть включена проверка столкновений с объектами сцены. Если проверка
	 * столкновений отключена, то в режиме ходьбы сила тяжести также игнорируется и дополнительно появляется возможность
	 * движения по вертикали.</p>
	 * 
	 * <p>Для всех объектов, за исключением <code>Camera3D</code>, направлением "вперёд" считается направление его оси
	 * <code>Y</code>, направлением "вверх" &mdash; направление оси <code>Z</code>. Для объектов класса
	 * <code>Camera3D</code> направление "вперёд" совпадает с направлением локальной оси <code>Z</code>, а направление
	 * "вверх" противоположно направлению локальной оси <code>Y</code>.</p>
	 * 
	 * <p>Вне зависимости от того, включена проверка столкновений или нет, координаты при перемещении расчитываются для
	 * эллипсоида, параметры которого устанавливаются через свойство <code>collider</code>. Координаты управляемого
	 * объекта вычисляются исходя из положения центра эллипсоида и положения объекта на вертикальной оси эллипсоида,
	 * задаваемого параметром <code>objectZPosition</code>.</p>
	 * 
	 * <p>Команда <code>ACTION_UP</code> в режиме ходьбы при ненулевой гравитации вызывает прыжок, в остальных случаях
	 * происходит движение вверх.</p>
	 */	
	public class WalkController extends ObjectController {
		/**
		 * Величина ускорения свободного падения. При положительном значении сила тяжести направлена против оси Z,
		 * при отрицательном &mdash; по оси Z.
		 */
		public var gravity:Number = 0;
		/**
		 * Вертикальная скорость прыжка.
		 */
		public var jumpSpeed:Number = 0;
		/**
		 * Объект, на котором стоит эллипсоид при ненулевой гравитации.
		 */
		private var _groundMesh:Mesh;
		/**
		 * Погрешность определения скорости. В режиме полёта или в режиме ходьбы при нахождении на поверхности
		 * скорость приравнивается к нулю, если её модуль не превышает заданного значения.
		 */
		public var speedThreshold:Number = 1;

		/**
		 * Ограничение поворота объекта по поперечной оси
		 * 
		 * @default Math.PI / 2
		 * 
		 * @see minPitch
		 */
		public var maxPitch:Number = 0.5*Math.PI;

		/**
		 * Ограничение поворота объекта по поперечной оси
		 * 
		 * @default -Math.PI / 2
		 * 
		 * @see maxPitch
		 */
		public var minPitch:Number = -0.5*Math.PI;

		// Коэффициент эффективности управления перемещением при нахождении в воздухе в режиме ходьбы и нулевой гравитации.
		private var _airControlCoefficient:Number = 1;

		private var _currentSpeed:Number = 0;

		private var minGroundCos:Number = Math.cos(MathUtils.toRadian(70));

		private var destination:Point3D = new Point3D();
		private var collision:Collision = new Collision();

		private var _objectZPosition:Number = 0.5;
		private var _flyMode:Boolean;
		private	var _onGround:Boolean;
		private var _jumpLocked:Boolean;

		private var velocity:Point3D = new Point3D();
		private var tmpVelocity:Point3D = new Point3D();

		private var controlsActive:Boolean;

		private var inJump:Boolean;
		private var startRotX:Number;
		private var startRotZ:Number;

		// Координаты мышиного курсора в режиме mouse look в предыдущем кадре.
		private var prevMouseCoords:Point3D = new Point3D();
		// Текущие координаты мышиного курсора в режиме mouse look.
		private var currentMouseCoords:Point3D = new Point3D();

		/**
		 * Создаёт новый экземпляр контролллера.
		 *
		 * @param eventsSourceObject источник событий клавиатуры и мыши
		 * @param object управляемый объект
		 * 
		 * @throws ArgumentError в качестве eventsSourceObject не может быть указан null
		 */
		public function WalkController(eventSourceObject:DisplayObject, object:Object3D = null) {
			super(eventSourceObject);
			this.object = object;
		}

		/**
		 * Объект, на котором стоит эллипсоид при ненулевой гравитации.
		 */
		public function get groundMesh():Mesh {
			return _groundMesh;
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
			_object.rotationX = Math.atan2(dz, Math.sqrt(dx*dx + dy*dy)) - (_object is Camera3D ? MathUtils.DEG90 : 0);
			_object.rotationY = 0;
			_object.rotationZ = -Math.atan2(dx, dy);
		}

		/**
		 * Коэффициент эффективности управления перемещением в режиме ходьбы при нахождении в воздухе и ненулевой гравитации.
		 * Значение 0 обозначает полное отсутствие контроля, значение 1 указывает, что управление так же эффективно, как при
		 * нахождении на поверхности.
		 *
		 * @default 1
		 */
		public function get airControlCoefficient():Number {
			return _airControlCoefficient;
		}

		/**
		 *@ private
		 */
		public function set airControlCoefficient(value:Number):void {
			_airControlCoefficient = value > 0 ? value : -value;
		}
		
		/**
		 * Максимальный угол наклона поверхности в радианах, на которой возможен прыжок и на которой объект стоит на месте
		 * в отсутствие управляющих воздействий. Если угол наклона поверхности превышает заданное значение, свойство
		 * <code>onGround</code> будет иметь значение <code>false</code>.
		 *
		 * @see #onGround
		 */
		public function get maxGroundAngle():Number {
			return Math.acos(minGroundCos); 
		}
			
		/**
		 * @private
		 */
		public function set maxGroundAngle(value:Number):void {
			minGroundCos = Math.cos(value);
		}
		
		/**
		 * Положение управляемого объекта на оси Z эллипсоида. Значение 0 указывает положение в нижней точке эллипсоида,
		 * значение 1 — положение в верхней точке эллипсоида.
		 */
		public function get objectZPosition():Number {
			return _objectZPosition;
		}

		/**
		 * @private
		 */		
		public function set objectZPosition(value:Number):void {
			_objectZPosition = value;
			setObjectCoords();
		}
		
		/**
		 * Включение и выключение режима полёта.
		 *
		 * @default false
		 */		
		public function get flyMode():Boolean {
			return _flyMode;
		}

		/**
		*@private
		 */		
		public function set flyMode(value:Boolean):void {
			_flyMode = value;
		}
		
		/**
		 * Индикатор положения эллипсоида на поверхности в режиме ходьбы. Считается, что эллипсоид находится на поверхности,
		 * если угол наклона поверхности под ним не превышает заданного свойством <code>maxGroundAngle</code> значения.
		 *
		 * @see #maxGroundAngle 
		 */
		public function get onGround():Boolean {
			return _onGround;
		}

		/**
		 * Модуль текущей скорости.
		 */
		public function get currentSpeed():Number {
			return _currentSpeed;
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
		 * <tr><td>SHIFT</td><td>ACTION_ACCELERATE</td></tr>
		 * <tr><td>UP</td><td>ACTION_PITCH_UP</td></tr>
		 * <tr><td>DOWN</td><td>ACTION_PITCH_DOWN</td></tr>
		 * <tr><td>LEFT</td><td>ACTION_YAW_LEFT</td></tr>
		 * <tr><td>RIGHT</td><td>ACTION_YAW_RIGHT</td></tr>
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
			bindKey(KeyboardUtils.LEFT, ACTION_YAW_LEFT);
			bindKey(KeyboardUtils.RIGHT, ACTION_YAW_RIGHT);
			bindKey(KeyboardUtils.SHIFT, ACTION_ACCELERATE);
			bindKey(KeyboardUtils.M, ACTION_MOUSE_LOOK);
		}

		/**
		 * Метод выполняет поворот объекта в соответствии с имеющимися воздействиями. Взгляд вверх и вниз ограничен
		 * промежутком [minPitch, maxPitch] от горизонтали.
		 *
		 * @param frameTime длительность текущего кадра в секундах 
		 * 
		 * @see minPitch
		 * @see maxPitch
		 */
		override protected function rotateObject(frameTime:Number):void {
			// Mouse look
			var rotX:Number;
			if (_mouseLookActive) {
				prevMouseCoords.copy(currentMouseCoords);
				currentMouseCoords.x = _eventsSource.stage.mouseX;
				currentMouseCoords.y = _eventsSource.stage.mouseY;
				if (!prevMouseCoords.equals(currentMouseCoords)) {
					_object.rotationZ = startRotZ + (startMouseCoords.x - currentMouseCoords.x)*_mouseCoefficientX;
					rotX = startRotX + (startMouseCoords.y - currentMouseCoords.y)*_mouseCoefficientY;
					if (_object is Camera3D) {
						// Коррекция поворота для камеры
						_object.rotationX = ((rotX > maxPitch) ? maxPitch : (rotX < minPitch) ? minPitch : rotX) - MathUtils.DEG90;
					} else {
						_object.rotationX = (rotX > maxPitch) ? maxPitch : (rotX < minPitch) ? minPitch : rotX;
					}
				}
			}
			
			// Повороты влево-вправо
			if (_yawLeft) {
				_object.rotationZ += _yawSpeed*frameTime;
			} else if (_yawRight) {
				_object.rotationZ -= _yawSpeed*frameTime;
			}
			// Взгляд вверх-вниз
			rotX = NaN;
			if (_pitchUp) {
				rotX = _object.rotationX + _pitchSpeed*frameTime;
			} else if (_pitchDown) {
				rotX = _object.rotationX - _pitchSpeed*frameTime;
			}
			if (!isNaN(rotX)) {
				if (_object is Camera3D) {
					// Коррекция поворота для камеры
					_object.rotationX = (rotX > 0) ? 0 : (rotX < -Math.PI) ? -Math.PI : rotX;
				} else {
					_object.rotationX = (rotX > MathUtils.DEG90) ? MathUtils.DEG90 : (rotX < -MathUtils.DEG90) ? -MathUtils.DEG90 : rotX;
				}
			}
		}

		/**
		 * Метод вычисляет вектор потенциального смещения эллипсоида, учитывая режим перемещения, команды перемещения и силу тяжести.
		 *
		 * @param frameTime длительность текущего кадра в секундах 
		 * @param displacement в эту переменную записывается вычисленное потенциальное смещение объекта
		 */
		override protected function getDisplacement(frameTime:Number, displacement:Point3D):void {
			var cos:Number = 0;
			if (checkCollisions && !_flyMode) {
				// Проверка наличия под ногами поверхности
				displacement.x = 0;
				displacement.y = 0;
				displacement.z = - 0.5*gravity*frameTime*frameTime;
				if (_collider.getCollision(_coords, displacement, collision)) {
					cos = collision.normal.z;
					_groundMesh = collision.face._mesh;
				} else {
					_groundMesh = null;
				}
			}
			_onGround = cos > minGroundCos;
			
			if (_onGround && inJump) {
				inJump = false;
				if (!_up) {
					_jumpLocked = false;
				}
			}
			
			var len:Number;
			var x:Number;
			var y:Number;
			var z:Number;

			// При наличии управляющих воздействий расчитывается приращение скорости 
			controlsActive = _forward || _back || _right || _left;
			if (flyMode || gravity == 0) {
				controlsActive ||= _up || _down;
			} else {
				
			}
			if (controlsActive) {
				if (_flyMode) {
					tmpVelocity.x = 0;
					tmpVelocity.y = 0;
					tmpVelocity.z = 0;
					// Режим полёта, ускорения направлены вдоль локальных осей
					// Ускорение вперёд-назад
					if (_forward) {
						tmpVelocity.y = 1;
					} else if (_back) {
						tmpVelocity.y = -1;
					}
					// Ускорение влево-вправо
					if (_right) {
						tmpVelocity.x = 1;
					} else if (_left) {
						tmpVelocity.x = -1;
					}
					// Ускорение вверх-вниз
					if (_up) {
						tmpVelocity.z = 1;
					} else if (_down) {
						tmpVelocity.z = -1;
					}
					var matrix:Matrix3D = _object._transformation;
					x = tmpVelocity.x;
					if (_object is Camera3D) {
						y = -tmpVelocity.z;
						z = tmpVelocity.y;
					} else {
						y = tmpVelocity.y;
						z = tmpVelocity.z;
					}
					// Поворот вектора из локальной системы координат объекта в глобальную
					velocity.x += (x*matrix.a + y*matrix.b + z*matrix.c)*_speed;
					velocity.y += (x*matrix.e + y*matrix.f + z*matrix.g)*_speed;
					velocity.z += (x*matrix.i + y*matrix.j + z*matrix.k)*_speed;
				} else {
					
					// Режим хождения, ускорения вперёд-назад-влево-вправо лежат в глобальной плоскости XY, вверх-вниз направлены вдоль глобальной оси Z
					var heading:Number = _object.rotationZ;
					var headingCos:Number = Math.cos(heading);
					var headingSin:Number = Math.sin(heading);
					
					var spd:Number = _speed;
					if (gravity != 0 && !_onGround) {
						spd *= _airControlCoefficient;
					}
					
					// Вперёд-назад
					if (_forward) {
						velocity.x -= spd*headingSin;
						velocity.y += spd*headingCos;
					} else if (_back) {
						velocity.x += spd*headingSin;
						velocity.y -= spd*headingCos;
					}
					// Влево-вправо
					if (_right) {
						velocity.x += spd*headingCos;
						velocity.y += spd*headingSin;
					} else if (_left) {
						velocity.x -= spd*headingCos;
						velocity.y -= spd*headingSin;
					}
					if (gravity == 0) {
						// Ускорение вверх-вниз
						if (_up) {
							velocity.z += _speed;
						} else if (_down) {
							velocity.z -= _speed;
						}
					}
				}
			} else {
				// Управление неактивно, замедление движения
				len = 1/Math.pow(3, frameTime*10);
				if (_flyMode || gravity == 0) {
					velocity.x *= len;
					velocity.y *= len;
					velocity.z *= len;
				} else {
					if (_onGround) {
						velocity.x *= len;
						velocity.y *= len;
						if (velocity.z < 0) {
							velocity.z *= len;
						}
					} else {
						if (cos > 0 && velocity.z > 0) {
							velocity.z = 0;
						}
					}
				}
			}
			// Прыжок
			if (_onGround && _up && !inJump && !_jumpLocked) {
				velocity.z = jumpSpeed;
				inJump = true;
				_onGround = false;
				_jumpLocked = true;
				cos = 0;
			}
			// В режиме ходьбы добавляется ускорение свободного падения, если находимся не на ровной поверхности
			if (!(_flyMode || _onGround)) {
				velocity.z -= gravity*frameTime;
			}
			
			// Ограничение скорости
			var max:Number = _accelerate ? _speed*_speedMultiplier : _speed;
			if (_flyMode || gravity == 0) {
				len = velocity.length;
				if (len > max) {
					velocity.length = max;
				}
			} else {
				len = Math.sqrt(velocity.x*velocity.x + velocity.y*velocity.y);
				if (len > max) {
					velocity.x *= max/len;
					velocity.y *= max/len;
				}
				if (cos > 0 && velocity.z > 0) {
					velocity.z = 0;
				}
			}

			// Cмещение за кадр
			displacement.x = velocity.x*frameTime;
			displacement.y = velocity.y*frameTime;
			displacement.z = velocity.z*frameTime;
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

			velocity.x = displacement.x/frameTime;
			velocity.y = displacement.y/frameTime;
			velocity.z = displacement.z/frameTime;

			_coords.x = destination.x;
			_coords.y = destination.y;
			_coords.z = destination.z;
			setObjectCoords();
			
			var len:Number = Math.sqrt(velocity.x*velocity.x + velocity.y*velocity.y + velocity.z*velocity.z);
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
		 * Метод устанавливает координаты управляемого объекта в зависимости от параметра <code>objectZPosition</code>.
		 *
		 * @see #objectZPosition
		 */
		override protected function setObjectCoords():void {
			if (_object != null) {
				_object.x = _coords.x;
				_object.y = _coords.y;
				_object.z = _coords.z + (2*_objectZPosition - 1)*_collider.radiusZ;
			}
		}
		
		/**
		 * Метод выполняет необходимые действия при включении вращения объекта мышью.
		 */		
		override protected function startMouseLook():void {
			super.startMouseLook();
			startRotX = _object is Camera3D ? _object.rotationX + MathUtils.DEG90 : _object.rotationX;
			startRotZ = _object.rotationZ;
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
		override public function moveUp(value:Boolean):void {
			super.moveUp(value);
			if (!inJump && !value) {
				_jumpLocked = false;
			}
		}
	}
}