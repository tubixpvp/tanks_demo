package alternativa.engine3d.controllers {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.physics.EllipsoidCollider;
	import alternativa.types.Map;
	import alternativa.types.Point3D;
	import alternativa.utils.ObjectUtils;
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	use namespace alternativa3d;
	
	/**
	 * Базовый контроллер для изменения ориентации и положения объекта в сцене с помощью клавиатуры и мыши. В классе
	 * реализована поддержка назначения обработчиков клавиатурных команд, а также обработчики для основных команд
	 * перемещения.
	 */
	public class ObjectController {
		/**
		 * Имя действия для привязки клавиш движения вперёд.
		 */
		public static const ACTION_FORWARD:String = "ACTION_FORWARD";
		/**
		 * Имя действия для привязки клавиш движения назад.
		 */
		public static const ACTION_BACK:String = "ACTION_BACK";
		/**
		 * Имя действия для привязки клавиш движения влево.
		 */
		public static const ACTION_LEFT:String = "ACTION_LEFT";
		/**
		 * Имя действия для привязки клавиш движения вправо.
		 */
		public static const ACTION_RIGHT:String = "ACTION_RIGHT";
		/**
		 * Имя действия для привязки клавиш движения вверх.
		 */
		public static const ACTION_UP:String = "ACTION_UP";
		/**
		 * Имя действия для привязки клавиш движения вниз.
		 */
		public static const ACTION_DOWN:String = "ACTION_DOWN";
		/**
		 * Имя действия для привязки клавиш поворота вверх.
		 */
		public static const ACTION_PITCH_UP:String = "ACTION_PITCH_UP";
		/**
		 * Имя действия для привязки клавиш поворота вниз.
		 */
		public static const ACTION_PITCH_DOWN:String = "ACTION_PITCH_DOWN";
		/**
		 * Имя действия для привязки клавиш поворота налево.
		 */
		public static const ACTION_YAW_LEFT:String = "ACTION_YAW_LEFT";
		/**
		 * Имя действия для привязки клавиш поворота направо.
		 */
		public static const ACTION_YAW_RIGHT:String = "ACTION_YAW_RIGHT";
		/**
		 * Имя действия для привязки клавиш увеличения скорости.
		 */
		public static const ACTION_ACCELERATE:String = "ACTION_ACCELERATE";
		/**
		 * Имя действия для привязки клавиш активации обзора мышью.
		 */
		public static const ACTION_MOUSE_LOOK:String = "ACTION_MOUSE_LOOK";

		/**
		 * Флаг движения вперёд.
		 */
		protected var _forward:Boolean;
		/**
		 * Флаг движения назад.
		 */
		protected var _back:Boolean;
		/**
		 * Флаг движения влево.
		 */
		protected var _left:Boolean;
		/**
		 * Флаг движения вправо.
		 */
		protected var _right:Boolean;
		/**
		 * Флаг движения вверх.
		 */
		protected var _up:Boolean;
		/**
		 * Флаг движения вниз.
		 */
		protected var _down:Boolean;
		/**
		 * Флаг поворота относительно оси X в положительном направлении (взгляд вверх).
		 */
		protected var _pitchUp:Boolean;
		/**
		 * Флаг поворота относительно оси X в отрицательном направлении (взгляд вниз).
		 */
		protected var _pitchDown:Boolean;
		/**
		 * Флаг поворота относительно оси Z в положительном направлении (взгляд налево).
		 */
		protected var _yawLeft:Boolean;
		/**
		 * Флаг активности поворота относительно оси Z в отрицательном направлении (взгляд направо).
		 */
		protected var _yawRight:Boolean;
		/**
		 * Флаг активности режима ускорения.
		 */
		protected var _accelerate:Boolean;
		/**
		 * Флаг активности режима поворотов мышью. 
		 */
		protected var _mouseLookActive:Boolean;
		/**
		 * Начальные координаты мышиного курсора в режиме mouse look.
		 */
		protected var startMouseCoords:Point3D = new Point3D();
		/**
		 * Флаг активности контроллера.
		 */
		protected var _enabled:Boolean = true;
		/**
		 * Источник событий клавиатуры и мыши
		 */
		protected var _eventsSource:DisplayObject;
		/**
		 * Ассоциативный массив, связывающий коды клавиатурных клавиш с именами команд.
		 */
		protected var keyBindings:Map = new Map();
		/**
		 * Ассоциативный массив, связывающий имена команд с реализующими их функциями. Функции должны иметь вид
		 * function(value:Boolean):void. Значение параметра <code>value</code> указывает, нажата или отпущена соответсвующая команде
		 * клавиша.
		 */
		protected var actionBindings:Map = new Map();
		/**
		 * Флаг активности клавиатуры.
		 */
		protected var _keyboardEnabled:Boolean;
		/**
		 * Флаг активности мыши.
		 */
		protected var _mouseEnabled:Boolean;
		/**
		 * Общая чувствительность мыши. Коэффициент умножения чувствительности по вертикали и горизонтали.
		 */
		protected var _mouseSensitivity:Number = 1;
		/**
		 * Коэффициент чувствительности мыши по вертикали. Значение угла в радианах на один пиксель перемещения мыши по вертикали.
		 */
		protected var _mouseSensitivityY:Number = Math.PI / 360;
		/**
		 * Коэффициент чувствительности мыши по горизонтали. Значение угла в радианах на один пиксель перемещения мыши по горизонтали.
		 */
		protected var _mouseSensitivityX:Number = Math.PI / 360;
		/**
		 * Результирующий коэффициент чувствительности мыши по вертикали. Значение угла в радианах на один пиксель перемещения мыши по вертикали.
		 */ 
		protected var _mouseCoefficientY:Number = _mouseSensitivity * _mouseSensitivityY;
		/**
		 * Результирующий коэффициент чувствительности мыши по горизонтали. Значение угла в радианах на один пиксель перемещения мыши по горизонтали.
		 */
		protected var _mouseCoefficientX:Number = _mouseSensitivity * _mouseSensitivityX;
		/**
		 * Угловая скорость поворота вокруг поперечной оси в радианах за секунду.
		 */
		protected var _pitchSpeed:Number = 1;
		/**
		 * Угловая скорость поворота вокруг вертикальной оси в радианах за секунду.
		 */
		protected var _yawSpeed:Number = 1;
		/**
		 * Скорость поступательного движения в единицах за секунду.
		 */
		protected var _speed:Number = 100;
		/**
		 * Коэффициент увеличения скорости при соответствующей активной команде.
		 */
		protected var _speedMultiplier:Number = 2;
		/**
		 * Управляемый объект.
		 */
		protected var _object:Object3D;
		/**
		 * Время в секундах, прошедшее с последнего вызова метода processInput (обычно с последнего кадра).
		 */
		protected var lastFrameTime:uint;
		/**
		 * Текущие координаты контроллера.
		 */
		protected var _coords:Point3D = new Point3D();
		/**
		 * Индикатор движения объекта (перемещения или поворота) в текущем кадре.
		 */
		protected var _isMoving:Boolean;
		/**
		 * Объект для определения столкновений.
		 */
		protected var _collider:EllipsoidCollider = new EllipsoidCollider();

		/**
		 * Включение и выключение режима проверки столкновений. 
		 */
		public var checkCollisions:Boolean;
		/**
		 * Функция вида <code>function():void</code>, вызываемая при начале движения объекта. Под движением
		 * понимается изменение координат или ориентации.
		 */
		public var onStartMoving:Function;
		/**
		 * Функция вида <code>function():void</code>, вызываемая при прекращении движения объекта. Под движением
		 * понимается изменение координат или ориентации.
		 */
		public var onStopMoving:Function;

		// Вектор смещения
		private var _displacement:Point3D = new Point3D();

		/**
		 * Создаёт новый экземпляр контролллера.
		 *
		 * @param eventsSourceObject источник событий клавиатуры и мыши
		 * 
		 * @throws ArgumentError в качестве eventsSourceObject не может быть указан null
		 */
		public function ObjectController(eventsSourceObject:DisplayObject) {
			if (eventsSourceObject == null) {
				throw new ArgumentError(ObjectUtils.getClassName(this) + ": eventsSourceObject is null");
			}
			_eventsSource = eventsSourceObject;

			actionBindings[ACTION_FORWARD] = moveForward;
			actionBindings[ACTION_BACK] = moveBack;
			actionBindings[ACTION_LEFT] = moveLeft;
			actionBindings[ACTION_RIGHT] = moveRight;
			actionBindings[ACTION_UP] = moveUp;
			actionBindings[ACTION_DOWN] = moveDown;
			actionBindings[ACTION_PITCH_UP] = pitchUp;
			actionBindings[ACTION_PITCH_DOWN] = pitchDown;
			actionBindings[ACTION_YAW_LEFT] = yawLeft;
			actionBindings[ACTION_YAW_RIGHT] = yawRight;
			actionBindings[ACTION_ACCELERATE] = accelerate;
			actionBindings[ACTION_MOUSE_LOOK] = setMouseLook;
			
			keyboardEnabled = true;
			mouseEnabled = true;
		}
		
		/**
		 * Включение и выключение контроллера. Выключенный контроллер пропускает выполнение метода <code>processInput()</code>.
		 * 
		 * @default true
		 * 
		 * @see #processInput()
		 */
		public function get enabled():Boolean {
			return _enabled;
		}

		/**
		 * @private
		 */
		public function set enabled(value:Boolean):void {
			_enabled = value;
			if (_enabled) {
				if (_mouseEnabled) {
					registerMouseListeners();
				}
				if (_keyboardEnabled) {
					registerKeyboardListeners();
				}
			} else {
				if (_mouseEnabled) {
					unregisterMouseListeners();
					setMouseLook(false);
				}
				if (_keyboardEnabled) {
					unregisterKeyboardListeners();
				}
			}
		}
		
		/**
		 * Координаты контроллера. Координаты совпадают с координатами центра эллипсоида, используемого для определения
		 * столкновений. Координаты управляемого объекта могут не совпадать с координатами контроллера.
		 * 
		 * @see #setObjectCoords()
		 */
		public function get coords():Point3D {
			return _coords.clone();
		}

		/**
		 * @private
		 */
		public function set coords(value:Point3D):void {
			_coords.copy(value);
			setObjectCoords();
		}
		
		/**
		 * Чтение координат контроллера в заданную переменную.
		 * 
		 * @param point переменная, в которую записываются координаты контроллера
		 */
		public function readCoords(point:Point3D):void {
			point.copy(_coords);
		}

		/**
		 * Управляемый объект.
		 */
		public function get object():Object3D {
			return _object;
		}

		/**
		 * @private
		 * При установке объекта устанавливается сцена для коллайдера.
		 */
		public function set object(value:Object3D):void {
			_object = value;
			_collider.scene = _object == null ? null : _object.scene;
			setObjectCoords();
		}

		/**
		 * Объект, реализующий проверку столкновений для эллипсоида.
		 */
		public function get collider():EllipsoidCollider {
			return _collider;
		}
		
		/**
		 * Активация движения вперёд.
		 * 
		 * @param value <code>true</code> для начала движения, <code>false</code> для окончания
		 */
		public function moveForward(value:Boolean):void {
			_forward = value;
		}

		/**
		 * Активация движения назад.
		 * 
		 * @param value <code>true</code> для начала движения, <code>false</code> для окончания
		 */
		public function moveBack(value:Boolean):void {
			_back = value;
		}
		
		/**
		 * Активация движения влево.
		 * 
		 * @param value <code>true</code> для начала движения, <code>false</code> для окончания
		 */
		public function moveLeft(value:Boolean):void {
			_left = value;
		}

		/**
		 * Активация движения вправо.
		 * 
		 * @param value <code>true</code> для начала движения, <code>false</code> для окончания
		 */
		public function moveRight(value:Boolean):void {
			_right = value;
		}

		/**
		 * Активация движения вверх.
		 * 
		 * @param value <code>true</code> для начала движения, <code>false</code> для окончания
		 */
		public function moveUp(value:Boolean):void {
			_up = value;
		}

		/**
		 * Активация движения вниз.
		 * 
		 * @param value <code>true</code> для начала движения, <code>false</code> для окончания
		 */
		public function moveDown(value:Boolean):void {
			_down = value;
		}

		/**
		 * Активация поворота вверх.
		 * 
		 * @param value <code>true</code> для начала движения, <code>false</code> для окончания
		 */
		public function pitchUp(value:Boolean):void {
			_pitchUp = value;
		}

		/**
		 * Активация поворота вниз.
		 * 
		 * @param value <code>true</code> для начала движения, <code>false</code> для окончания
		 */
		public function pitchDown(value:Boolean):void {
			_pitchDown = value;
		}

		/**
		 * Активация поворота влево.
		 * 
		 * @param value <code>true</code> для начала движения, <code>false</code> для окончания
		 */
		public function yawLeft(value:Boolean):void {
			_yawLeft = value;
		}

		/**
		 * Активация поворота вправо.
		 * 
		 * @param value <code>true</code> для начала движения, <code>false</code> для окончания
		 */
		public function yawRight(value:Boolean):void {
			_yawRight = value;
		}
		
		/**
		 * Активация режима увеличенной скорости.
		 * 
		 * @param value <code>true</code> для включения ускорения, <code>false</code> для выключения
		 */
		public function accelerate(value:Boolean):void {
			_accelerate = value;
		}
		
		/**
		 * Угловая скорость поворота вокруг поперечной оси (радианы в секунду).
		 * 
		 * @default 1
		 */		
		public function get pitchSpeed():Number {
			return _pitchSpeed;
		}

		/**
		 * @private
		 */		
		public function set pitchSpeed(spd:Number):void {
			_pitchSpeed = spd;
		}

		/**
		 * Угловая скорость поворота вокруг вертикальной оси (радианы в секунду).
		 * 
		 * @default 1
		 */		
		public function get yawSpeed():Number {
			return _yawSpeed;
		}

		/**
		 * @private
		 */		
		public function set yawSpeed(spd:Number):void {
			_yawSpeed = spd;
		}

		/**
		 * Скорость движения в единицах за секунду. При установке отрицательного значения берётся модуль.
		 * 
		 * @default 100
		 */
		public function get speed():Number {
			return _speed;
		}

		/**
		 * @private
		 */
		public function set speed(value:Number):void {
			_speed = value < 0 ? -value : value;
		}
		
		/**
		 * Коэффициент увеличения скорости при активном действии <code>ACTION_ACCELERATE</code>.
		 * 
		 * @default 2
		 */
		public function get speedMultiplier():Number {
			return _speedMultiplier;
		}

		/**
		 * @private
		 */
		public function set speedMultiplier(value:Number):void {
			_speedMultiplier = value;
		}

		/**
		 * Чувствительность мыши &mdash; коэффициент умножения <code>mouseSensitivityX</code> и <code>mouseSensitivityY</code>.
		 * 
		 * @default 1
		 * 
		 * @see #mouseSensitivityY()
		 * @see #mouseSensitivityX()
		 */		
		public function get mouseSensitivity():Number {
			return _mouseSensitivity;
		}
		
		/**
		 * @private
		 */		
		public function set mouseSensitivity(sensitivity:Number):void {
			_mouseSensitivity = sensitivity;
			_mouseCoefficientY = _mouseSensitivity * _mouseSensitivityY;
			_mouseCoefficientX = _mouseSensitivity * _mouseSensitivityX;
		}
		
		/**
		 * Чувствительность мыши по вертикали.
		 * 
		 * @default Math.PI / 360
		 * 
		 * @see #mouseSensitivity()
		 * @see #mouseSensitivityX()
		 */		
		public function get mouseSensitivityY():Number {
			return _mouseSensitivityY;
		}

		/**
		 * @private
		 */		
		public function set mouseSensitivityY(value:Number):void {
			_mouseSensitivityY = value;
			_mouseCoefficientY = _mouseSensitivity * _mouseSensitivityY;
		}
		
		/**
		 * Чувствительность мыши по горизонтали.
		 * 
		 * @default Math.PI / 360
		 * 
		 * @see #mouseSensitivity()
		 * @see #mouseSensitivityY()
		 */		
		public function get mouseSensitivityX():Number {
			return _mouseSensitivityX;
		}
		
		/**
		 * @private
		 */		
		public function set mouseSensitivityX(value:Number):void {
			_mouseSensitivityX = value;
			_mouseCoefficientX = _mouseSensitivity * _mouseSensitivityX;
		}
		
		/**
		 * Включение/выключение режима вращения объекта мышью. При включении режима вполняется метод <code>startMouseLook()</code>,
		 * при выключении &mdash; <code>stoptMouseLook()</code>.
		 * 
		 * @see #startMouseLook()
		 * @see #stopMouseLook()
		 */
		public function setMouseLook(value:Boolean):void {
			if (_mouseLookActive != value) {
				_mouseLookActive = value;
				if (_mouseLookActive) {
					startMouseLook();
				} else {
					stopMouseLook();
				}
			}
		}
		
		/**
		 * Метод выполняет необходимые действия при включении режима вращения объекта мышью.
		 * Реализация по умолчанию записывает начальные глобальные координаты курсора мыши в переменную <code>startMouseCoords</code>.
		 * 
		 * @see #startMouseCoords
		 * @see #setMouseLook()
		 * @see #stopMouseLook()
		 */		
		protected function startMouseLook():void {
			startMouseCoords.x = _eventsSource.stage.mouseX;
			startMouseCoords.y = _eventsSource.stage.mouseY;
		}

		/**
		 * Метод выполняет необходимые действия при выключении вращения объекта мышью. Реализация по умолчанию не делает
		 * ничего.
		 * 
		 * @see #setMouseLook()
		 * @see #startMouseLook()
		 */		
		protected function stopMouseLook():void {
		}
		
		/**
		 * Метод выполняет обработку всех воздействий на объект. Если объект не установлен или свойство <code>enabled</code>
		 * равно <code>false</code>, метод не выполняется.
		 * <p>
		 * Алгоритм работы метода следующий:
		 * <ul>
		 * <li> Вычисляется время в секундах, прошедшее с последнего вызова метода (с последнего кадра). Это время считается
		 * 	длительностью текущего кадра;
		 * <li> Вызывается метод rotateObject(), который изменяет ориентацию объекта в соответствии с воздействиями;
		 * <li> Вызывается метод getDisplacement(), который вычисляет потенциальное перемещение объекта;
		 * <li> Вызывается метод applyDisplacement(), которому передаётся вектор перемещения, полученный на предыдущем шаге.
		 * Задачей метода является применение заданного вектора перемещения;
		 * <li> При необходимости вызываются обработчики начала и прекращения движения управляемого объекта; 
		 * </ul></p>
		 */
		public function processInput():void {
			if (!_enabled || _object == null) {
				return;
			}
			var frameTime:Number = getTimer() - lastFrameTime;
			// Проверка в связи с возможным багом десятого плеера, ну и вообще на всякий случай
			if (frameTime == 0) {
				return;
			}
			
			lastFrameTime += frameTime;
			if (frameTime > 100) {
				frameTime = 100;
			}
			frameTime /= 1000;
			
			rotateObject(frameTime);
			getDisplacement(frameTime, _displacement);
			applyDisplacement(frameTime, _displacement);
			
			// Обработка начала/окончания движения
			if (_object.changeRotationOrScaleOperation.queued || _object.changeCoordsOperation.queued) {
				if (!_isMoving) {
					_isMoving = true;
					if (onStartMoving != null) {
						onStartMoving.call(this);
					} 
				}
			} else {
				if (_isMoving) {
					_isMoving = false;
					if (onStopMoving != null) {
						onStopMoving.call(this);
					}
				}
			}
		}

		/**
		 * Метод выполняет поворот объекта в соответствии с имеющимися воздействиями. Реализация по умолчанию не делает ничего.
		 * 
		 * @param frameTime длительность текущего кадра в секундах 
		 */
		protected function rotateObject(frameTime:Number):void {
		}

		/**
		 * Метод вычисляет потенциальное смещение объекта за кадр. Реализация по умолчанию не делает ничего.
		 *  
		 * @param frameTime длительность текущего кадра в секундах 
		 * @param displacement в эту переменную записывается вычисленное потенциальное смещение объекта
		 */
		protected function getDisplacement(frameTime:Number, displacement:Point3D):void {
		}

		/**
		 * Метод применяет потенциальное смещение объекта. Реализация по умолчанию не делает ничего.
		 * 
		 * @param frameTime длительность текущего кадра в секундах 
		 * @param displacement смещение объекта, которое нужно обработать
		 */
		protected function applyDisplacement(frameTime:Number, displacement:Point3D):void {
		}

		/**
		 * Метод выполняет привязку клавиши к действию. Одной клавише может быть назначено только одно действие.
		 * 
		 * @param keyCode код клавиши
		 * @param action наименование действия
		 * 
		 * @see #unbindKey()
		 * @see #unbindAll()
		 */
		public function bindKey(keyCode:uint, action:String):void {
			var method:Function = actionBindings[action];
			if (method != null) {
				keyBindings[keyCode] = method;
			}
		}
		
		/**
		 * Очистка привязки клавиши.
		 * 
		 * @param keyCode код клавиши
		 * 
		 * @see #bindKey()
		 * @see #unbindAll()
		 */
		public function unbindKey(keyCode:uint):void {
			keyBindings.remove(keyCode);
		}

		/**
		 * Очистка привязки всех клавиш.
		 * 
		 * @see #bindKey()
		 * @see #unbindKey()
		 */
		public function unbindAll():void {
			keyBindings.clear();
		}
		
		/**
		 * Метод устанавливает привязки клавиш по умолчанию. Реализация по умолчанию не делает ничего.
		 * 
		 * @see #bindKey()
		 * @see #unbindKey()
		 * @see #unbindAll()
		 */
		public function setDefaultBindings():void {
		}
		
		/**
		 * Включение и выключение обработки клавиатурных событий. При включении выполняется метод <code>registerKeyboardListeners</code>,
		 * при выключении &mdash; <code>unregisterKeyboardListeners</code>.
		 * 
		 * @see #registerKeyboardListeners()
		 * @see #unregisterKeyboardListeners()
		 */
		public function get keyboardEnabled():Boolean {
			return _keyboardEnabled;
		}

		/**
		 * @private
		 */
		public function set keyboardEnabled(value:Boolean):void {
			if (_keyboardEnabled != value) {
				_keyboardEnabled = value;
				if (_keyboardEnabled) {
					if (_enabled) {
						registerKeyboardListeners();
					}
				} else {
					unregisterKeyboardListeners();
				}
			}
		}

		/**
		 * @private
		 * Запуск обработчиков клавиатурных команд.
		 */
		private function onKeyboardEvent(e:KeyboardEvent):void {
			var method:Function = keyBindings[e.keyCode];
			if (method != null) {
				method.call(this, e.type == KeyboardEvent.KEY_DOWN);
			}
		}
		
		/**
		 * Регистрация необходимых обработчиков при включении обработки клавиатурных событий.
		 * 
		 * @see #unregisterKeyboardListeners()
		 */
		protected function registerKeyboardListeners():void {
			_eventsSource.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent);
			_eventsSource.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent);
		}

		/**
		 * Удаление обработчиков при выключении обработки клавиатурных событий.
		 * 
		 * @see #registerKeyboardListeners()
		 */
		protected function unregisterKeyboardListeners():void {
			clearCommandFlags();
			_eventsSource.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent);
			_eventsSource.removeEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent);
		}
		
		/**
		 * Включение и выключение обработки мышиных событий. При включении выполняется метод <code>registerMouseListeners</code>,
		 * при выключении &mdash; <code>unregisterMouseListeners</code>.
		 * 
		 * @see #registerMouseListeners()
		 * @see #unregisterMouseListeners()
		 */
		public function get mouseEnabled():Boolean {
			return _mouseEnabled;
		}
		
		/**
		 * @private
		 */
		public function set mouseEnabled(value:Boolean):void {
			if (_mouseEnabled != value) {
				_mouseEnabled = value;
				if (_mouseEnabled) {
					if (_enabled) {
						registerMouseListeners();
					}
				} else {
					unregisterMouseListeners();
				}
			}
		}
		
		/**
		 * Регистрация необходимых обработчиков при включении обработки мышиных событий. 
		 * 
		 * @see #unregisterMouseListeners()
		 */		
		protected function registerMouseListeners():void {
			_eventsSource.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		/**
		 * Удаление используемых обработчиков при выключении обработки мышиных событий.
		 * 
		 * @see #registerMouseListeners()
		 */		
		protected function unregisterMouseListeners():void {
			_eventsSource.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_eventsSource.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * Активация mouselook
		 */		
		private function onMouseDown(e:MouseEvent):void {
			setMouseLook(true);
			_eventsSource.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * Отключение mouselook
		 */		
		private function onMouseUp(e:MouseEvent):void {
			setMouseLook(false);
			_eventsSource.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		/**
		 * Установка координат управляемого объекта в зависимости от текущих координат контроллера.
		 */
		protected function setObjectCoords():void {
			if (_object != null) {
				_object.coords = _coords;
			}
		}
		
		/**
		 * Индикатор режима увеличенной скорости.
		 */
		public function get accelerated():Boolean {
			return _accelerate;
		}
		
		/**
		 * Метод сбрасывает флаги активных команд.
		 */
		protected function clearCommandFlags():void {
			_forward = false;
			_back = false;
			_left = false;
			_right = false;
			_up = false;
			_down = false;
			_pitchUp = false;
			_pitchDown = false;
			_yawLeft = false;
			_yawRight = false;
			_accelerate = false;
			_mouseLookActive = false;
		}

	}
}
