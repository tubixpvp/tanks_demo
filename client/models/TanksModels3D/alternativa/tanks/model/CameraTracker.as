package alternativa.tanks.model {
	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;

	use namespace alternativa3d;
	
	public class CameraTracker {

		private var _elevationSin:Number = 0;
		private var _elevation:Number = 0;
		private var cameraDirection:Point3D = new Point3D();
		private var currDirection:Point3D = new Point3D();
		private var rotationAxis:Point3D = new Point3D();
		private var matrix:Matrix3D = new Matrix3D();
		private var distance:Number = 600;
		private var maxAngle:Number = Math.PI/6;
		private var angleThreshold:Number = Math.PI/180*10;
		private var trackingSpeed:Number = 0;
		private var distanceThreshold:Number = 0;
		private var distanceSpeed:Number = 0;
		private var pitch:Number = Math.PI/180*5;
		
		public function CameraTracker(elevation:Number, distance:Number, distanceThreshold:Number, trackingSpeed:Number, maxAngle:Number, angleThreshold:Number) {
			this.elevation = elevation;
			this.distance = distance;
			this.trackingSpeed = trackingSpeed;
			this.maxAngle = maxAngle;
			this.angleThreshold = angleThreshold;
			this.distanceThreshold = distanceThreshold;
			distanceSpeed = 0.1*distanceThreshold;
		}
		
		public function get elevation():Number {
			return _elevation;
		}

		public function set elevation(value:Number):void {
			_elevation = value;
			_elevationSin = Math.sin(value);
		}
		
		public function reset(camera:Camera3D, trackedObject:Object3D):void {
			calcReferenceDirection(camera, trackedObject, cameraDirection);
			adjustDirection(camera, cameraDirection);
			adjustPosition(camera, trackedObject.globalCoords, cameraDirection);
		}

		public function track(camera:Camera3D, trackedObject:Object3D, time:Number):void {
			var deltaAngle:Number = trackingSpeed*time;
			
			calcReferenceDirection(camera, trackedObject, cameraDirection);

			currDirection.reset(0, 0, 1);
			matrix.toTransform(0, 0, 0, camera.rotationX - pitch, 0, camera.rotationZ);
			currDirection.transformOrientation(matrix);
			
			rotationAxis.cross2(currDirection, cameraDirection);
			var angle:Number = Math.asin(rotationAxis.length) - angleThreshold;
			if (angle > 0) {
				rotationAxis.normalize();
				if (deltaAngle > angle) {
					deltaAngle = angle;
				} else {
					if (angle - maxAngle > deltaAngle) {
						deltaAngle = angle - maxAngle;
					}
				}
				matrix.fromAxisAngle(rotationAxis, deltaAngle);
				currDirection.transformOrientation(matrix);
				adjustDirection(camera, currDirection);
			}
			adjustPosition(camera, trackedObject.globalCoords, currDirection);
		}
		
		private function calcReferenceDirection(camera:Camera3D, trackedObject:Object3D, result:Point3D):void {
			var x:Number = trackedObject._transformation.b;
			var y:Number = trackedObject._transformation.f;
			var k:Number = Math.sqrt((1 - _elevationSin*_elevationSin)/(x*x + y*y));
			result.x = x*k;
			result.y = y*k;
			result.z = -_elevationSin;
		}
		
		private function adjustDirection(camera:Camera3D, direction:Point3D):void {
			camera.rotationX = pitch - Math.PI*0.5 - Math.atan2(-direction.z, Math.sqrt(direction.x*direction.x + direction.y*direction.y));
			camera.rotationZ = Math.atan2(-direction.x, direction.y);
		}
		
		private function adjustPosition(camera:Camera3D, pivot:Point3D, refDirection:Point3D):void {
			var x:Number = pivot.x - refDirection.x*distance;
			var y:Number = pivot.y - refDirection.y*distance;
			var z:Number = pivot.z - refDirection.z*distance;
			var dx:Number = camera.x - x;
			var dy:Number = camera.y - y;
			var dz:Number = camera.z - z;
			var dist:Number = Math.sqrt(dx*dx + dy*dy + dz*dz);
			if (dist > distanceThreshold) {
				var k:Number = distanceThreshold/dist;
				camera.x = x + k*dx;
				camera.y = y + k*dy;
				camera.z = z + k*dz;
			}
		}
		
	}
}