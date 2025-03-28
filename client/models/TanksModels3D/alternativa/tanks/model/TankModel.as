package alternativa.tanks.model {
	import alternativa.engine3d.*;
	import alternativa.engine3d.controllers.ObjectController;
	import alternativa.engine3d.controllers.WalkController;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.display.View;
	import alternativa.engine3d.physics.Collision;
	import alternativa.engine3d.physics.CollisionSetMode;
	import alternativa.engine3d.physics.EllipsoidCollider;
	import alternativa.init.Main;
	import alternativa.model.IObjectLoadListener;
	import alternativa.model.general.child.IChild;
	import alternativa.model.general.parent.IParent;
	import alternativa.model.general.world3d.IObject3DListener;
	import alternativa.model.general.world3d.IPhysicsObject;
	import alternativa.model.general.world3d.view3d.IView3DModel;
	import alternativa.object.ClientObject;
	import alternativa.physics.altphysics;
	import alternativa.resource.SoundResource;
	import alternativa.resource.TextureResource;
	import alternativa.tanks.animation.TankAnimator;
	import alternativa.tanks.gfx.ExplosionSprite;
	import alternativa.tanks.gfx.Shot;
	import alternativa.tanks.sfx.Sound3D;
	import alternativa.tanks.sfx.TankSounds;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	import alternativa.types.Set;
	import alternativa.utils.KeyboardUtils;
	import alternativa.utils.MathUtils;
	import alternativa.utils.TextUtils;
	
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import alternativa.types.Long;
	import alternativa.types.LongFactory;
	import platform.models.general.world3d.Vector3d;
	
	import projects.tanks.models.tank.TankModelBase;
	import projects.tanks.models.tank.ITankModelBase;
	
	use namespace alternativa3d;
	use namespace altphysics;

	/**
	 * Модель поведения танка.
	 */
	public class TankModel extends TankModelBase implements ITankModelBase, IObjectLoadListener, ITankParams, IObject3DListener {
		// Константы управления
		public static const FORWARD:int = 1;
		public static const BACK:int = 2;
		public static const LEFT:int = 4;
		public static const RIGHT:int = 8;
		public static const TURRET_LEFT:int = 16;
		public static const TURRET_RIGHT:int = 32;
		
		public static const SHOT_SOUND_ID:Long = LongFactory.integerToLong(75);
		public static const EXPLOSION_SOUND_ID:Long = LongFactory.integerToLong(76);
		public static const ENGINESTART_SOUND_ID:Long = LongFactory.integerToLong(77);
		public static const ENGINEIDLE_SOUND_ID:Long = LongFactory.integerToLong(78);
		public static const STARTMOVING_SOUND_ID:Long = LongFactory.integerToLong(79);
		public static const MOVE_SOUND_ID:Long = LongFactory.integerToLong(86);
		public static const ENDMOVING_SOUND_ID:Long = LongFactory.integerToLong(87);
		
		private static const EMPTY_TARGET_ID:Long = LongFactory.getLong(0,0);
		private static const GUN_COOLDOWN:int = 2000;

		private var shotSound3D:Sound3D;
		private var explosionSound3D:Sound3D;
		
		private const correctionInterval:int = 2000;
		private const cameraHeight:Number = 800;

		private var timerDelay:uint = uint(1000/30);
		
		private var view:View;
		private var controller:WalkController;

		private var position:Vector3d = new Vector3d();
		private var orientation:Vector3d = new Vector3d();
		/**
		 * Танки на поле боя.
		 */		
		private var tanksRegistry:Dictionary = new Dictionary();
		/**
		 * Количество загруженных танков.
		 */		
		private var tanksCount:int;
		/**
		 * Объект танка игрока.
		 */
		private var playerClientObject:ClientObject;
		/**
		 * Параметры танка игрока.
		 */
		private var playerTankParams:TankParams;
		/**
		 * Таймер, по событию которого обрабатываются игровые события (двигаются танки, запускаются спецэффекты...).
		 */
		private var timer:Timer;
		
		private var controlForward:int;
		private var controlBack:int;
		private var controlLeft:int;
		private var controlRight:int;
		private var controlTurretLeft:int;
		private var controlTurretRight:int;
		
		private var lastTime:uint;
		private var canFire:Boolean = true;
		
		// Детектор столкновений для снарядов
		private var collider:EllipsoidCollider = new EllipsoidCollider(null, 0.5, 0.5, 0.5);
		// Множество для указания геометрии сцены в качестве объектов для расчёта столкновений снарядов
		private var collisionSet:Set = new Set();
		// Переменная для записи информации о столкновении снарядов
		private var collision:Collision = new Collision();
		
		private var moveCommandTimerId:int = -1;
		
		private var cameraTracker:CameraTracker;
		
		/**
		 * 
		 */
		public function TankModel()	{
			super();
			cameraTracker = new CameraTracker(4*MathUtils.DEG10, 1200, 100, MathUtils.DEG30, 2*MathUtils.DEG10, MathUtils.DEG10);
		}
		
		/**
		 * Инициализирует модель для заданного объекта.
		 * 
		 * @param clientObject
		 * @param armor
		 * @param control
		 * @param forward
		 * @param position
		 * @param selfTank
		 * @param speed
		 * @param turretAngle
		 * @param up
		 */
		public function initObject(clientObject:ClientObject, accuracy:Number, control:int, damagedTextureId:Long, gunY:Number, gunZ:Number, h:Number, health:int, l:Number, name:String, orientation:Vector3d, position:Vector3d, score:int, selfTank:Boolean, speed:Number, turretAngle:Number, turretSpeed:Number, w:Number):void {
			Main.writeToConsole(TextUtils.insertVars("[TankModel.initData] id %1", clientObject.id));

			var textureResource:TextureResource = Main.resourceRegister.getResource(damagedTextureId) as TextureResource;
			var tankParams:TankParams = new TankParams(clientObject.id, name, health, speed, turretSpeed, accuracy, l, w, h, gunY, gunZ, selfTank, score, textureResource.data);
			
			var engineIdleSound:Sound = (Main.resourceRegister.getResource(ENGINEIDLE_SOUND_ID) as SoundResource).sound;
			var startMovingSound:Sound = (Main.resourceRegister.getResource(STARTMOVING_SOUND_ID) as SoundResource).sound;
			var moveSound:Sound = (Main.resourceRegister.getResource(MOVE_SOUND_ID) as SoundResource).sound;
			
			tankParams.sounds = new TankSounds(engineIdleSound, startMovingSound, moveSound);
			
			// Вносим танк в реестр танков
			tanksRegistry[clientObject] = tankParams;
			tanksCount++;
			// Начальное состояние управления
			tankParams.control = control;
			// Предварительная установка положения танка. Окончательная установка значений будет произведена в обработчике
			// загрузки 3д-объекта, когда будет доступно физическое представление.
			tankParams.prepareTransform(position, orientation, turretAngle);
			// Запоминаем параметры танка игрока для быстрого доступа и идентификации
			if (selfTank) {
				playerClientObject = clientObject;
				playerTankParams = tankParams;
			}
			// Сохраняем параметры модели
			clientObject.putParams(TankModelBase, tankParams);
			
			if (shotSound3D == null) {
				initSounds();
			}
		}
		
		/**
		 * 
		 */
		private function initSounds():void {
			shotSound3D = new Sound3D((Main.resourceRegister.getResource(SHOT_SOUND_ID) as SoundResource).sound, 500, 1500, 10, 10);
			explosionSound3D = new Sound3D((Main.resourceRegister.getResource(EXPLOSION_SOUND_ID) as SoundResource).sound, 500, 1500, 10, 15);
//			engineStartSound = (Main.resourceRegister.getResource(ENGINESTART_SOUND_ID) as SoundResource).sound;
//			engineIdleSound = (Main.resourceRegister.getResource(ENGINEIDLE_SOUND_ID) as SoundResource).sound;
//			startMovingSound = (Main.resourceRegister.getResource(STARTMOVING_SOUND_ID) as SoundResource).sound;
//			endMovingSound = (Main.resourceRegister.getResource(ENDMOVING_SOUND_ID) as SoundResource).sound;
//			moveSound = (Main.resourceRegister.getResource(MOVE_SOUND_ID) as SoundResource).sound;
		}
		
		/**
		 * 
		 */
		private function initTimer():void {
			timer = new Timer(timerDelay);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			lastTime = getTimer();
		}
		
		/**
		 * Реализует тело основного цикла обработки поведения танков.
		 */
		private function onTimer(e:TimerEvent):void {
			var time:Number = lastTime;
			lastTime = getTimer();
			time = 0.001*(lastTime - time);
			// Обработка танков на сцене
			for (var key:* in tanksRegistry) {
				var tankParams:TankParams = tanksRegistry[key];
				tankParams.move(time);
				tankParams.animator.intergrate(time);
				tankParams.sounds.setState(tankParams.moveState);
				view.camera._transformation.getAxis(0, soundNormal);
				tankParams.sounds.currentSound3D.checkVolume(view.camera.globalCoords, tankParams.rigidBox.body.position, soundNormal);
				tankParams.updateTitlePosition(view.camera.globalCoords);
			}
			controller.processInput();
			if (playerTankParams != null) {
				cameraTracker.track(view.camera, playerTankParams.turret, time);
				if (playerTankParams.rigidBox.body.position.z < -300 && playerTankParams.state == TankParams.ALIVE) {
					playerTankParams.state = TankParams.DEAD;
					suicideCommand(playerClientObject, 2);
				}
			}
		}
		
		/**
		 * 
		 */
		public function objectLoaded(object:ClientObject):void {
			// Получаем ссылку на вьюпорт
			if (view == null) {
				Main.loadingProgress.closeLoadingWindow();
				Main.loadingProgress.lockLoadingWindow();
				Main.writeToConsole("[TankModel::objectLoaded] saving view by object " + object.id);
				var childModel:IChild = Main.modelsRegister.getModelForObject(object, IChild) as IChild;
				var parent:ClientObject = childModel.getParent(object);
				if (parent == null) {
					// КОСТЫЛЬ!!!
					return;
				} 
				var parentModel:IParent = Main.modelsRegister.getModelForObject(parent, IParent) as IParent;
				var children:Array = parentModel.getChildren(parent);
				for each (var child:ClientObject in children) {
					var viewModel:IView3DModel = Main.modelsRegister.getModelForObject(child, IView3DModel) as IView3DModel;
					if (viewModel != null) {
						Main.writeToConsole("[TankModel::objectLoaded] view saved");
						view = viewModel.getParams(child).view;
						
						controller = new WalkController(Main.backgroundLayer.stage);
//						controller.object = view.camera;
						controller.coords = new Point3D(0, 0, cameraHeight);
						controller.lookAt(new Point3D(0, Math.tan(MathUtils.DEG60)*cameraHeight, 0));
						controller.speed = 300;
						controller.bindKey(KeyboardUtils.W, ObjectController.ACTION_FORWARD);
						controller.bindKey(KeyboardUtils.A, ObjectController.ACTION_LEFT);
						controller.bindKey(KeyboardUtils.S, ObjectController.ACTION_BACK);
						controller.bindKey(KeyboardUtils.D, ObjectController.ACTION_RIGHT);
						controller.bindKey(KeyboardUtils.Q, ObjectController.ACTION_YAW_LEFT);
						controller.bindKey(KeyboardUtils.E, ObjectController.ACTION_YAW_RIGHT);
						controller.mouseEnabled = false;
						
						// Установка сцены для коллайдера снарядов
						collider.scene = view.camera.scene;
						//
						var map:Object3D = view.camera.scene.root.getChildByName("map");
						if (map != null) {
							view.camera.scene.splitAnalysis = false;
							forEachObject(map, addToCollisionSet);
							collider.collisionSet = collisionSet;
							collider.collisionSetMode = CollisionSetMode.INCLUDE;
						}
						break;
					}
				}
			}
		}
		
		/**
		 * 
		 * @param object
		 * @param func
		 */
		private function forEachObject(object:Object3D, func:Function):void {
			func.call(this, object);
			for (var child:* in object.children) {
				forEachObject(child, func);
			}
		}
		
		/**
		 * 
		 */
		private function addToCollisionSet(object:Object3D):void {
			collisionSet.add(object);
		}
			
		/**
		 * 
		 */
		public function objectUnloaded(clientObject:ClientObject):void {
			Main.writeVarsToConsole("[TankModel::objectUnloaded] %1", clientObject.id);
			if (tanksRegistry[clientObject] != null) {
				if (clientObject == playerClientObject) {
					// Удаление информации о танке игрока
					if (moveCommandTimerId > -1) {
						clearInterval(moveCommandTimerId);
					}
					playerClientObject = null;
					playerTankParams = null;
					Main.backgroundLayer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
					Main.backgroundLayer.stage.removeEventListener(KeyboardEvent.KEY_UP, onKey);
				}

				var tankParams:TankParams = tanksRegistry[clientObject];
				tankParams.title.scene.root.removeChild(tankParams.title);

				// Удаление танка из реестра
				delete tanksRegistry[clientObject];
				tanksCount--;
				if (tanksCount == 0) {
					// Если танков не осталось, останавливаем таймер
					timer.stop();
					timer = null;
					view = null;
				}
			}
		}
		
		/**
		 * Вызывается при получении от сервера сообщения об изменении управляющих воздействий на танк. Танку задаются указанные координаты и
		 * положение в пространстве, угол поворота башни и новое состояние органов управления.
		 */
		public function move(clientObject:ClientObject = null, position:Vector3d = null, orientation:Vector3d = null, turretAngle:Number = 0, control:int = 0, timer:int = 0):void {
			if (clientObject != playerClientObject) {
				var time:uint = getTimer();
				var tankParams:TankParams = tanksRegistry[clientObject];
				if (tankParams == null) {
					Main.writeToConsole("[ERROR][TankModel::move] tank data not found");
					// TODO: Выяснить причину получения команды для удалённого объекта
					return;
				}
				tankParams.control = control;
				tankParams.prepareTransform(position, orientation, turretAngle);
				tankParams.updateTransform();
			}
		}

		/**
		 * 
		 */
		private function onKey(e:KeyboardEvent):void {
			if (playerTankParams.health <= 0) {
				return;
			}
			switch (e.keyCode) {
				case KeyboardUtils.UP:
					controlForward = e.type == KeyboardEvent.KEY_DOWN ? FORWARD : 0;
					updateControlState();
					break;
				case KeyboardUtils.DOWN:
					controlBack = e.type == KeyboardEvent.KEY_DOWN ? BACK : 0;
					updateControlState();
					break;
				case KeyboardUtils.LEFT:
					controlLeft = e.type == KeyboardEvent.KEY_DOWN ? LEFT : 0;
					updateControlState();
					break;
				case KeyboardUtils.RIGHT:
					controlRight = e.type == KeyboardEvent.KEY_DOWN ? RIGHT : 0;
					updateControlState();
					break;
				case KeyboardUtils.Z:
					controlTurretLeft = e.type == KeyboardEvent.KEY_DOWN ? TURRET_LEFT : 0;
					updateControlState();
					break;
				case KeyboardUtils.X:
					controlTurretRight = e.type == KeyboardEvent.KEY_DOWN ? TURRET_RIGHT : 0;
					updateControlState();
					break;
				case KeyboardUtils.SPACE:
					fireGun();
					break;
				case KeyboardUtils.DELETE:
					suicideCommand(playerClientObject, 1);
					break;
			}
		}

		private var targetsArray:Array = new Array();
		private var targetsSet:Dictionary = new Dictionary();
		
		private var sinAngleUp:Number = Math.sin(MathUtils.toRadian(30));
		private var sinAngleDown:Number = Math.sin(MathUtils.toRadian(10));

		/**
		 * Выстрел из орудия.
		 */
		private function fireGun():void {
			if (playerTankParams.health <=0) {
				return;
			}
//			Main.writeVarsToConsole("[TankModel.fireGun] %1", canFire);
			if (!canFire) {
				// Орудие не готово к стрельбе
				return;
			}
			canFire = false;
			setTimeout(resetGun, GUN_COOLDOWN);
			
			var m:Matrix3D = playerTankParams.turret._transformation;
			// Координаты точки вылета снаряда
			var gunCoords:Point3D = new Point3D(m.d, m.h, m.l);
//			gunCoords.x += m.b*playerTankParams.gunY + m.c*playerTankParams.gunZ;
//			gunCoords.y += m.f*playerTankParams.gunY + m.g*playerTankParams.gunZ;
//			gunCoords.z += m.j*playerTankParams.gunY + m.k*playerTankParams.gunZ;
			// Направление полёта снаряда
			var gunDirection:Point3D = new Point3D(m.b, m.f, m.j);
//			Main.writeVarsToConsole("[TankModel.fireGun] hull matrix %1", playerTankParams._object3d._transformation);
//			Main.writeVarsToConsole("[TankModel.fireGun] turret matrix %1", playerTankParams.turret._transformation);
//			Main.writeVarsToConsole("[TankModel.fireGun] gunVector: %1, length: %2", gunVector, gunVector.length);
//			var rightVector:Point3D = new Point3D(m.a, m.e, m.i);
			// Находим вертикальную плоскость полёта снаряда
			var planeNormal:Point3D = new Point3D(gunDirection.y, -gunDirection.x, 0);
			planeNormal.normalize();
			var planeOffset:Number = planeNormal.x*m.d + planeNormal.y*m.h;
//			Main.writeVarsToConsole("[TankModel.fireGun] plane offset %1, plane normal %2", planeOffset, planeNormal);
			// Находим потенциальных трупов
			var targetsCount:int = findPotentialTargets(planeNormal, planeOffset, gunCoords, gunDirection);
//			Main.writeVarsToConsole("[TankModel.fireGun] %1 potential targets found", targetsNumber);
			var targetObject:ClientObject = null;
			var vector:Vector3d = new Vector3d(); 
			if (targetsCount > 0) {
				// Отсекаем тех, кто выше и ниже сектора стрельбы
				targetsCount = findReachableTargets(gunCoords, gunDirection, planeNormal);
				if (targetsCount > 0) {
					targetObject = getFirstVisibleTarget(gunCoords, vector);
				}
			} 
			if (targetsCount == 0) {
				var k:Number = 10000;
				var displacement:Point3D = new Point3D(gunDirection.x*k, gunDirection.y*k, gunDirection.z*k);
//				Main.writeVarsToConsole("[TankModel.fireGun] calculating impact position, source coords: %1, displacement: %2", gunCoords, displacement);
				if (!collider.getCollision(gunCoords, displacement, collision)) {
					vector.x = gunCoords.x + displacement.x;
					vector.y = gunCoords.y + displacement.y;
					vector.x = gunCoords.x + displacement.x;
				} else {
					vector.x = collision.point.x;
					vector.y = collision.point.y;
					vector.z = collision.point.z;
				}
			}
			
//			Main.writeVarsToConsole("[TankModel.fireGun] impact position (%1, %2, %3), target id (%4)", vector.x, vector.y, vector.z, targetObject == null ? EMPTY_TARGET_ID : targetObject.id);
			if (targetObject == null) {
				// Не попали в танк
				fireCommand(playerClientObject, vector, EMPTY_TARGET_ID);
			} else {
				// Попали в танк
				fireCommand(playerClientObject, vector, targetObject.id);
			}
		}
		
		private function resetGun():void {
			canFire = true;
		}
		
		/**
		 * 
		 * @param planeNormal
		 * @param planeOffset
		 * @return 
		 */
		private function findPotentialTargets(planeNormal:Point3D, planeOffset:Number, gunCoords:Point3D, gunDirection:Point3D):int {
			var counter:int = 0;
			for (var key:* in tanksRegistry) {
				var clientObject:ClientObject = key;
				if (clientObject == playerClientObject) {
					continue;
				}
				var tankParams:TankParams = tanksRegistry[key];
				var pos:Point3D = tankParams.rigidBox.body.position;
				
				if ((pos.x - gunCoords.x)*gunDirection.x + (pos.y - gunCoords.y)*gunDirection.y + (pos.z - gunCoords.z)*gunDirection.z < 0) {
					// Пропускаем цели позади танка
					continue;
				}
				
				var targetCoords:Point3D = pos.clone();
				var d:Number = planeNormal.dot(targetCoords) - planeOffset;
				if (d < tankParams.boundRadius && d > -tankParams.boundRadius) {
					counter++;
					targetCoords.x -= planeNormal.x*d;
					targetCoords.y -= planeNormal.y*d;
					targetCoords.z -= planeNormal.z*d;
					targetsSet[clientObject] = targetCoords;
				}
			}
			return counter;
		}
		
		/**
		 * 
		 * @param playerCoords
		 * @param gunVector
		 * @param rightVector
		 * @return 
		 */
		private function findReachableTargets(gunCoords:Point3D, gunVector:Point3D, normal:Point3D):int {
			var toTarget:Point3D = new Point3D();
			var targetCoords:Point3D;
			for (var key:* in targetsSet) {
				targetCoords = targetsSet[key];
				toTarget.difference(targetCoords, gunCoords);
				var distance:Number = toTarget.length;
				toTarget.normalize();
				toTarget.cross(gunVector);
				var sin:Number = toTarget.length;
				var dot:Number = normal.dot(toTarget);
				if ((dot < 0 && sin < sinAngleUp) || (dot > 0 && sin < sinAngleDown)) {
					targetsArray.push(TargetInfo.create(distance, key, targetCoords));
				}
				delete targetsSet[key];
			}
			return targetsArray.length;
		}
		
		/**
		 * 
		 * @param fireSource
		 * @return 
		 */
		private function getFirstVisibleTarget(fireSource:Point3D, vector:Vector3d):ClientObject {
			// Сортировка находящихся в секторе стрельбы
			targetsArray.sortOn("distance", Array.NUMERIC | Array.DESCENDING);
			// Перебор целей в секторе поражения, начиная с ближайшей, пока не будет найдена цель в прямой видимости или цели не кончатся
			var displacement:Point3D = new Point3D();
			var targetInfo:TargetInfo;
			var first:Boolean = true;
			while ((targetInfo = targetsArray.pop()) != null) {
				displacement.difference(targetInfo.coords, fireSource);
				if (collider.getCollision(fireSource, displacement, collision)) {
					// Танк закрыт препятствием, для первого танка запоминаем точку столкновения снаряда с препятствием
					if (first) {
						first = false;
						vector.x = collision.point.x;
						vector.y = collision.point.y;
						vector.z = collision.point.z;
					}
				} else {
					// Снаряд попал в танк
					targetsArray.length = 0;
					vector.x = targetInfo.coords.x;
					vector.y = targetInfo.coords.y;
					vector.z = targetInfo.coords.z;
					return targetInfo.clientObject;
				}
			}
			
			return null;
		}
		
		/**
		 * 
		 */		
		private function updateControlState():void {
			var control:int = controlForward | controlBack | controlLeft | controlRight | controlTurretLeft | controlTurretRight;
			if (playerTankParams.control != control) {
				sendMoveCommand(control);
			}
		}
		
		private var turretAngle:Point = new Point();
		/**
		 * 
		 */
		private function sendMoveCommand(control:uint):void {
			if (moveCommandTimerId != -1) {
				clearInterval(moveCommandTimerId);
				moveCommandTimerId = -1;
			}
			playerTankParams.getTransform(position, orientation, turretAngle);
			playerTankParams.control = control;
			moveCommand(playerClientObject, position, orientation, turretAngle.x, control, 0);
			moveCommandTimerId = setInterval(sendCorrection, correctionInterval);
		}
		
		/**
		 * 
		 */
		private function sendCorrection():void {
			playerTankParams.getTransform(position, orientation, turretAngle);
			moveCommand(playerClientObject, position, orientation, turretAngle.x, playerTankParams.control, 0);
		}
		
		
		private var soundNormal:Point3D = new Point3D();
		/**
		 * 
		 */
		private function showShot(clientObject:ClientObject):void {
			var tankParams:TankParams = tanksRegistry[clientObject];
			var turret:Object3D = tankParams.turret;
			var coords:Point3D = new Point3D();
			turret._transformation.getAxis(3, coords);
			var dir:Point3D = new Point3D();
			var axisZ:Point3D = new Point3D();
			turret._transformation.getAxis(1, dir);
			turret._transformation.getAxis(2, axisZ);
			coords.x += dir.x*tankParams.gunY + axisZ.x*tankParams.gunZ;
			coords.y += dir.y*tankParams.gunY + axisZ.y*tankParams.gunZ;;
			coords.z += dir.z*tankParams.gunY + axisZ.z*tankParams.gunZ;;
			var shot:Shot = new Shot(20, 70);
			shot.coords = coords;
			shot.align(dir, view.camera);
			view.camera.scene.root.addChild(shot);
			shot.startTimer();
			shot.mobility = 10000;
			
			view.camera._transformation.getAxis(0, soundNormal);
			shotSound3D.play(1);
			shotSound3D.checkVolume(view.camera.globalCoords, coords, soundNormal);
		}
		
		/**
		 * 
		 * @param clientObject
		 * @param targetPosition
		 * @param targetTankId
		 */	
		public function fire(clientObject:ClientObject, targetPosition:Vector3d, targetTankId:Long):void {
			var tankParams:TankParams = tanksRegistry[clientObject];
			tankParams.animator.startShotFeedbackAnimation();
			showShot(clientObject);
			showExplosion(targetPosition, targetTankId == EMPTY_TARGET_ID ? null : clientObject.register.getObject(targetTankId));
		}
		
		/**
		 * 
		 * @param point
		 */		
		private function showExplosion(point:Vector3d, targetObject:ClientObject):void {
			var toCamera:Point3D = view.camera.coords;
			toCamera.x -= point.x;
			toCamera.y -= point.y;
			toCamera.z -= point.z;
			toCamera.normalize();
			if (targetObject != null) {
				var tankParams:TankParams = tanksRegistry[targetObject];
				Main.writeVarsToConsole("[TankModel::showExplosion] (%1, %2, %3) translated by %4x%5", point.x, point.y, point.z, toCamera, tankParams.boundRadius*1.5);
				point.x += toCamera.x*tankParams.boundRadius*1.5;
				point.y += toCamera.y*tankParams.boundRadius*1.5;
				point.z += toCamera.z*tankParams.boundRadius*1.5;
			}
			var explosion:ExplosionSprite = new ExplosionSprite(toCamera);
			explosion.x = point.x;
			explosion.y = point.y;
			explosion.z = point.z;
			view.camera.scene.root.addChild(explosion);
			explosion.startAnimation();

			var explosionPoint:Point3D = new Point3D(point.x, point.y, point.z);
			explosionPoints.push(explosionPoint);
			
			setTimeout(playExplosionSound, 100);
		}
		
		private var explosionPoints:Array = new Array();
		
		/**
		 * 
		 */
		private function playExplosionSound():void {
			explosionSound3D.play(1);
			view.camera._transformation.getAxis(0, soundNormal);
			var explosionPoint:Point3D = explosionPoints.shift(); 
			explosionSound3D.checkVolume(view.camera.globalCoords, explosionPoint, soundNormal);
		}
		
		/**
		 * 
		 * @param clientObject
		 * @param newHealth
		 */			
		public function changeHealth(clientObject:ClientObject, newHealth:int):void {
			var tankParams:TankParams = tanksRegistry[clientObject];
			tankParams.health = newHealth;
			if (clientObject == playerClientObject && newHealth <= 0) {
				controlBack = controlForward = controlLeft = controlRight = controlTurretLeft = controlTurretRight = 0;
				updateControlState();
			}
		}

		/**
		 * 
		 * @param clientObject
		 */		
		public function kill(clientObject:ClientObject):void {
			Main.writeVarsToConsole("[TankModel.kill] object %1", clientObject.id);
			var tankParams:TankParams = tanksRegistry[clientObject];
			tankParams.animator.animateDeath();
			tankParams.state = TankParams.DEAD;
			tankParams.sounds.setState(0);
		}
		
		/**
		 * 
		 * @param clientObject
		 * @param position
		 * @param forward
		 * @param up
		 * @param turretAngle
		 */
		public function respawn(clientObject:ClientObject, position:Vector3d, orientation:Vector3d, turretAngle:Number):void {
			Main.writeVarsToConsole("[TankModel.respawn] object %1, position [%2, %3, %4], orientation [%5, %6, %7], turret angle [%8]", clientObject.id, position.x, position.y, position.z, orientation.x, orientation.y, orientation.z, turretAngle);
			var tankParams:TankParams = tanksRegistry[clientObject];
			tankParams.rigidBox.body.setRotationComponents(0, 0, 0);
			tankParams.rigidBox.body.setVelocityComponents(0, 0, 0);
			tankParams.prepareTransform(position, orientation, turretAngle);
			tankParams.updateTransform();
			if (clientObject == playerClientObject) {
//				relocateCamera();
				cameraTracker.reset(view.camera, playerTankParams.turret);
			}
			tankParams.state = TankParams.ALIVE;
		}
		
		/**
		 * 
		 */
		private function relocateCamera():void {
			var pos:Point3D = new Point3D();
			playerTankParams.rigidBox.body.getPosition(pos);
			pos.z = cameraHeight;
			controller.coords = pos;
		}

		/**
		 * 
		 * @param object
		 * @return 
		 */
		public function getTankParams(clientObject:ClientObject):TankParams {
			return tanksRegistry[clientObject];
		}
	
		/**
		 * Устанавливает начальные параметры физического представления после загрузки A3D модели.
		 */
		public function object3DLoaded(clientObject:ClientObject, clientObject3D:ClientObject, object3d:Object3D):void {
			var tankParams:TankParams = tanksRegistry[clientObject];
			if (tankParams == null) {
				// TODO: Убрать костыль когда будет решена проблема с загрузкой предков-пустышек
				return;
			}
			// Параметры 3д-модели
			
			object3d.mobility = 100;
			tankParams.object3d = object3d;
			// Получаем данные о физической модели
			var physicsInterface:IPhysicsObject = Main.modelsRegister.getModelForObject(clientObject, IPhysicsObject) as IPhysicsObject;
			tankParams.rigidBox = physicsInterface.getRigidBox3D(clientObject);
			tankParams.rigidBox.setParams(tankParams.width, tankParams.length, tankParams.height, 1000);
			tankParams.rigidBox.setPivot(new Point3D(0, 0, -tankParams.height*0.5 + 4));
			tankParams.rigidBox.animator = tankParams.animator = new TankAnimator(tankParams);
			object3d.scene.root.addChild(tankParams.title);
			
			// Обновление положения
			tankParams.updateTransform();
			// Запуск таймера при загрузке первого танка
			if (tanksCount == 1) {
				initTimer();
			}
			// Установка обработчика клавиатуры для танка игрока
			if (clientObject == playerClientObject) {
//				relocateCamera();
				cameraTracker.reset(view.camera, playerTankParams.turret);
				Main.backgroundLayer.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
				Main.backgroundLayer.stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
			}
		}
		
		/**
		 * 
		 * @param clientObject
		 * @param clientObject3D
		 * @param object3d
		 */
		public function object3DUnloaded(clientObject:ClientObject, clientObject3D:ClientObject, object3d:Object3D):void {
		}
	
		public function freeMove(clientObject:ClientObject, position:Vector3d, orientation:Vector3d, velocity:Vector3d, rotation:Vector3d):void	{
			
		}
		
	}
}	