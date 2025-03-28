package alternativa.tanks.animation {
	
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Object3D;
	import alternativa.init.Main;
	import alternativa.model.general.world3d.physics.IObjectAnimator;
	import alternativa.physics.altphysics;
	import alternativa.physics.rigid.RigidBody;
	import alternativa.tanks.model.TankParams;
	import alternativa.types.Point3D;
	import alternativa.types.Quaternion;

	use namespace alternativa3d;
	use namespace altphysics;

	public class TankAnimator implements IObjectAnimator {
		
		private var tankParams:TankParams;
		
		private var shotAngleSpeedForward:Number = Math.PI/4;
		private var shotAngleSpeedBack:Number = Math.PI/6;
		private var shotFeedbackSpeed:Number = 0;
		private var shotAngle:Number = 0;
		private var shotMaxAngle:Number;
		private var shotMaxAngle1:Number = Math.PI/180;
		private var shotMaxAngle2:Number = Math.PI/180*4;

		private var axis1:Point3D = new Point3D();
		private var axis2:Point3D = new Point3D();

		private var q1:Quaternion = new Quaternion();
		private var q2:Quaternion = new Quaternion();
		
		public var acceleration:Number = 0;
		private var accAngle:Number = 0;
		private var maxAccAngle:Number = Math.PI/180*4;
		
		public function TankAnimator(tankParams:TankParams) {
			this.tankParams = tankParams;
		}

		public function animateObject(object:Object3D, body:RigidBody):void {
			if (accAngle != 0 || shotAngle != 0) {
				if (accAngle != 0) {
					body.getOrientation(q1);
					q2.setFromAxisAngleComponents(body.transformMatrix.a, body.transformMatrix.e, body.transformMatrix.i, accAngle);
					q2.multiply(q1);
				} else {
					body.getOrientation(q2);
				}
				if (shotAngle != 0) {
					tankParams.turret._transformation.getAxis(0, axis1);
					q1.setFromAxisAngleComponents(axis1.x, axis1.y, axis1.z, shotAngle);
					q1.multiply(q2);
					q2.copy(q1);
					q2.getEulerAngles(axis1);
				}
				q2.getEulerAngles(axis1);
			} else {
				body.orientation.getEulerAngles(axis1);
			}

			object.rotationX = axis1.x;
			object.rotationY = axis1.y;
			object.rotationZ = axis1.z;
		}
		
		public function startShotFeedbackAnimation():void {
			tankParams.turret._transformation.getAxis(1, axis1);
			tankParams.rigidBox.body.transformMatrix.getAxis(0, axis2);
			var dot:Number = axis1.dot(axis2);
			shotMaxAngle = shotMaxAngle1 + (dot < 0 ? -dot : dot)*(shotMaxAngle2 - shotMaxAngle1);
			shotFeedbackSpeed = shotAngleSpeedForward;
			Main.writeVarsToConsole("[TankAnimator::startShotFeedbackanimation] shotMaxAngle: %1, shotFeedbackSpeed: %2 ", shotMaxAngle, shotFeedbackSpeed);
		}
		
		public function intergrate(time:Number):void {
			if (accAngle != 0 || acceleration != 0) {
				if (acceleration != 0) {
					accAngle += acceleration/200*time;
					if (accAngle < -maxAccAngle) {
						accAngle = -maxAccAngle;
					} else if (accAngle > maxAccAngle) {
						accAngle = maxAccAngle;
					}
				} else {
					if (accAngle < 0) {
						accAngle += 5*maxAccAngle*time;
						if (accAngle > 0) {
							accAngle = 0;
						}
					} else {
						accAngle -= 5*maxAccAngle*time;
						if (accAngle < 0) {
							accAngle = 0;
						}
					}
				}
			}
			
			if (shotFeedbackSpeed != 0) {
				if (shotFeedbackSpeed == shotAngleSpeedForward) {
					if (shotAngle >= shotMaxAngle) {
						shotAngle = shotMaxAngle;
						shotFeedbackSpeed = shotAngleSpeedBack;
					} else {
						shotAngle += shotFeedbackSpeed*time;
					}
				} else {
					if (shotAngle > 0) {
						shotAngle -= shotFeedbackSpeed*time;
					} else {
						shotAngle = 0;
						shotFeedbackSpeed = 0;
					}
				}
			}
		}
		
		public function animateDeath():void {
			tankParams.rigidBox.body.setRotationComponents(5, 5, 5);
			tankParams.rigidBox.body.setVelocityComponents(0, 0, 300);
		}

	}
}