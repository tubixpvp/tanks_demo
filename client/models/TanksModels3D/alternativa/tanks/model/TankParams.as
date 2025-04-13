package alternativa.tanks.model {
	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.model.general.world3d.physics.RigidBox3D;
	import alternativa.physics.altphysics;
	import alternativa.physics.rigid.RigidBody;
	import alternativa.tanks.animation.TankAnimator;
	import alternativa.tanks.gfx.Title;
	import alternativa.tanks.sfx.TankSounds;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	import alternativa.types.Quaternion;
	import alternativa.types.Texture;
	
	import flash.geom.Point;
	import alternativa.types.Long;
	import platform.models.general.world3d.Vector3d;
	
	use namespace alternativa3d;
	use namespace altphysics;
	
	/**
	 * Параметры танка.
	 */
	public class TankParams {
		public static const ALIVE:int = 0;
		public static const DEAD:int = 1;
		
		private var id:Long;
		// Параметры, хранящиеся на сервере
		private var maxHealth:int;
		private var maxSpeed:Number = 0;
		private var currentSpeed:Number = 0;
		private var acceleration:Number = 0;
		private var maxTurnSpeed:Number = 0;
		private var maxTurretSpeed:Number = 0;
		private var accuracy:Number = 1;
		public var width:Number;
		public var length:Number;
		public var height:Number;
		public var gunY:Number = 0;
		public var gunZ:Number = 0;
		
		public var boundRadius:Number = 0;
		
		// Клиентские параметры
		private var _player:Boolean;
		
		private var _health:int;
		
		private var forward:Boolean;
		private var back:Boolean;
		private var left:Boolean;
		private var right:Boolean;
		private var turretLeft:Boolean;
		private var turretRight:Boolean;
		
		public var _object3d:Object3D;
		public var turret:Mesh;
		public var hull:Mesh;
		
		private var _control:int;
		
		private var _tmpMatrix:Matrix3D = new Matrix3D();
		private var _tmpPoint:Point3D = new Point3D();
		
		public var rigidBox:RigidBox3D;
		
		private var _orientation:Point3D = new Point3D();
		private var _position:Point3D = new Point3D();
		private var _turretRotation:Number = 0;
		private var q:Quaternion = new Quaternion();
		
		private var controllable:Boolean = true;
		
		public var animator:TankAnimator;
		public var score:int;
		
		private var _normalTexture:Texture;
		private var _damagedTexture:Texture;
		
		private var _state:int;
		
		public var prevMoveState:int = 0;
		public var moveState:int = 0;
		
		public var sounds:TankSounds;
		
		private var _title:Title;
		
		/**
		 * 
		 * @param maxHealth
		 * @param maxSpeed
		 * @param maxTurretSpeed
		 * @param accuracy
		 * @param length
		 * @param width
		 * @param height
		 * @param player
		 */
		public function TankParams(id:Long, titleString:String, maxHealth:int, maxSpeed:Number, maxTurretSpeed:Number, accuracy:Number, length:Number, width:Number, height:Number, gunY:Number, gunZ:Number, player:Boolean, score:int, damagedTexture:Texture, normalTexture:Texture) {
			this.id = id;
			this.maxHealth = maxHealth;
			_health = maxHealth;
			this.maxSpeed = maxSpeed;
			this.maxTurretSpeed = maxTurretSpeed;
			this.accuracy = accuracy;
			this.width = width;
			this.height = height;
			this.length = length;
			this.gunY = gunY;
			this.gunZ = gunZ;
			this.score = score;
			acceleration = maxSpeed;
			maxTurnSpeed = 0.75*maxSpeed/width;
			boundRadius = Math.sqrt(width*width + height*height + length*length)*0.5;
			_player = player;
			_damagedTexture = damagedTexture;
			_normalTexture = normalTexture;
			_title = new Title(titleString == null ? id.toString() : titleString);
		}
		
		/**
		 * 
		 */
		public function get state():int {
			return _state;
		}
		
		/**
		 * 
		 */
		public function set state(value:int):void {
			if (value == _state) {
				return;
			}
			_state = value;
			switch (value) {
				case ALIVE:
					setTexture(_normalTexture);
					break;
				case DEAD:
					setTexture(_damagedTexture);
					break;
			}
		}
		
		/**
		 * 
		 */
		private function setTexture(texture:Texture):void {
			var surafce:Surface;
			for each (surafce in hull._surfaces) {
				(surafce.material as TextureMaterial).texture = texture;
			}
			for each (surafce in turret._surfaces) {
				(surafce.material as TextureMaterial).texture = texture;
			}
		}
		
		/**
		 * 
		 * @param position
		 * @param orientation
		 */
		public function prepareTransform(position:Vector3d, orientation:Vector3d, turretAngle:Number):void {
			_position.x = position.x;
			_position.y = position.y;
			_position.z = position.z;

			_orientation.x = orientation.x;
			_orientation.y = orientation.y;
			_orientation.z = orientation.z;
			
			_turretRotation = turretAngle;
		}
		
		/**
		 * 
		 */
		public function updateTransform():void {
			var angle:Number = _orientation.length;
			if (angle > 0) {
				_orientation.x /= angle;
				_orientation.y /= angle;
				_orientation.z /= angle;
				q.setFromAxisAngleComponents(_orientation.x, _orientation.y, _orientation.z, angle);
			} else {
				q.reset(1, 0, 0, 0);
			}
			rigidBox.body.setOrientation(q);
			rigidBox.body.setPosition(_position);
			
			turret.rotationZ = _turretRotation;
		}
		
		/**
		 * Состояние управлящих элементов.
		 */
		public function get control():int {
			return _control;
		}

		/**
		 * @private
		 */
		public function set control(value:int):void {
			_control = value;
			
			forward = (value & TankModel.FORWARD) != 0;
			back = (value & TankModel.BACK) != 0;
			left = (value & TankModel.LEFT) != 0;
			right = (value & TankModel.RIGHT) != 0;
			turretLeft = (value & TankModel.TURRET_LEFT) != 0;
			turretRight = (value & TankModel.TURRET_RIGHT) != 0;
		}

		private function getUnitRotation(body:RigidBody, vector:Point3D):void {
			vector.reset();
			if (left) {
				vector.z = 1;
			} else if (right) {
				vector.z = -1;
			}
			if (vector.z != 0) {
				vector.transformOrientation(body.transformMatrix);
			}
		}

		/**
		 * 
		 * @param time
		 * @param body
		 * @param vector
		 */
		private function getVelocity(time:Number, body:RigidBody, vector:Point3D):void {
			if (time == 0) {
				vector.reset(0, currentSpeed, 0);
				if (currentSpeed != 0) {
					body.orientation.toMatrix3D(_tmpMatrix);
					vector.transform(_tmpMatrix);
				}
				return;
			}
			var acc:Number = 0;
			if (forward || back) {
				if (forward) {
					acc = acceleration;
					if (currentSpeed < 0) {
						acc *= 3;
					}
					currentSpeed += acc*time;
					if (currentSpeed > maxSpeed) {
						currentSpeed = maxSpeed;
						acc = 0;
					}
				} else {
					acc = -acceleration;
					if (currentSpeed > 0) {
						acc *= 3;
					}
					currentSpeed += acc*time;
					if (currentSpeed < -maxSpeed) {
						currentSpeed = -maxSpeed;
						acc = 0;
					}
				}
			} else {
				if (currentSpeed < 0) {
					acc = 2*acceleration;
					currentSpeed += acc*time;
					if (currentSpeed > 0) {
						currentSpeed = 0;
						acc = 0;
					}
				} else if (currentSpeed > 0) {
					acc = -2*acceleration;
					currentSpeed += acc*time;
					if (currentSpeed < 0) {
						currentSpeed = 0;
						acc = 0;
					}
				}
			}
			
			animator.acceleration = acc;

			vector.reset(0, currentSpeed, 0);
			if (currentSpeed != 0) {
				body.orientation.toMatrix3D(_tmpMatrix);
				vector.transform(_tmpMatrix);
			}
			
			moveState = int(forward || back);
		}
		
		/**
		 * 
		 */
		private function isControllable():Boolean {
//			var counter:int = 0;
//			for (var key:* in rigidBox.boxCollisionCache) {
//				var data:RigidBoxCollisionData = key;
//				if (data.collisionNormal.z > 0.8) {
//					counter++;
//				}
//			}
//			Main.writeVarsToConsole("[TankParams::isControllable] counter: %1, normalZ: %2", counter, rigidBox.body.transformMatrix.k);
//			return (counter > 1) && (rigidBox.body.transformMatrix.k > 0.7);
			return (rigidBox.body.transformMatrix.k > 0.7);
		}
		
		/**
		 * 
		 * @param time
		 */
		public function move(time:Number):void {
			var body:RigidBody = rigidBox.body;
			body.calculateDerivedData();

			var ctrl:Boolean = isControllable();
			
			if (!ctrl) {
				if (controllable) {
					getUnitRotation(body, _tmpPoint);
					_tmpPoint.multiply(maxTurnSpeed*time);
					body.setRotation(_tmpPoint);
					
					getVelocity(time, body, _tmpPoint);
					body.setVelocity(_tmpPoint);
					
					controllable = false;
				}
				return;
			}
			controllable = true;
			
			getUnitRotation(body, _tmpPoint);
			if (_tmpPoint.length > 0) {
//				q.setFromAxisAngle(_tmpPoint.x, _tmpPoint.y, _tmpPoint.z, forward || !back ? maxTurnSpeed*time : -maxTurnSpeed*time);
				q.setFromAxisAngleComponents(_tmpPoint.x, _tmpPoint.y, _tmpPoint.z, maxTurnSpeed*time);
				q.normalize();
				q.multiply(body.orientation);
				q.normalize();
				body.setOrientation(q);
			}
			
			getVelocity(time, body, _tmpPoint);
			if (_tmpPoint.length > 0) {
				_tmpPoint.multiply(time);
				body.position.add(_tmpPoint);
			}
			
			var rotZ:Number = turret.rotationZ + (int(turretLeft) - int(turretRight))*maxTurretSpeed*time;
			rotZ %= Math.PI*2;
			turret.rotationZ = rotZ;
		}
		
		/**
		 * 
		 * @param resultPosition
		 * @param resultOrientation
		 * @param point
		 */
		public function getTransform(resultPosition:Vector3d, resultOrientation:Vector3d, point:Point):void {
			var body:RigidBody = rigidBox.body;
			resultPosition.x = body.position.x;
			resultPosition.y = body.position.y;
			resultPosition.z = body.position.z;

			body.orientation.toAxisVector(_tmpPoint);
			resultOrientation.x = _tmpPoint.x;
			resultOrientation.y = _tmpPoint.y;
			resultOrientation.z = _tmpPoint.z;
			
			// Поворот башни
			point.x = turret.rotationZ%(Math.PI*2);
		}
		
		public function get object3d():Object3D {
			return _object3d;
		}

		public function set object3d(value:Object3D):void {
			_object3d = value;
			hull = _object3d.getChildByName("hull", true) as Mesh;
			var surface:Surface = hull.surfaces.peek();
			//_normalTexture = (surface.material as TextureMaterial).texture;
			turret = _object3d.getChildByName("turret", true) as Mesh;
			setTexture(_normalTexture);
		}
		
		public function get health():int {
			return _health;
		}

		public function set health(value:int):void {
			_health = value;
		}
		
		public function get turretRotation():Number {
			return turret._rotationZ;
		}
		
		public function set turretRotation(value:Number):void {
			turret.rotationZ = value;
		}
		
		public function get player():Boolean {
			return _player;
		}

		public function set player(value:Boolean):void {
			_player = value;
		}
		
		private var titleCoords:Point3D = new Point3D();
		/**
		 * Позиционирование надписи.
		 */
		public function updateTitlePosition(cameraCoords:Point3D):void {
			titleCoords.copy(cameraCoords);
			titleCoords.subtract(rigidBox.body.position);
			var dist:Number = titleCoords.length;
			var near:Number = 2500;
			var fadeInterval:Number = 500;
			_title.material.alpha = dist <= near ? 1 : (1 - (dist - near)/fadeInterval);

			titleCoords.normalize();
			titleCoords.multiply(boundRadius);
			titleCoords.add(rigidBox.body.position);
			titleCoords.z += boundRadius;
			_title.coords = titleCoords;
		}
		
		/**
		 * 
		 */
		public function get title():Title {
			return _title;
		}
		
	}
}