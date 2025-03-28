package alternativa.physics.force {
	import alternativa.physics.*;
	import alternativa.physics.rigid.RigidBody;
	import alternativa.types.Point3D;

	use namespace altphysics;

	public class RigidBodySpring implements IRigidBodyForceGenerator {

		private var vector1:Point3D = new Point3D();
		private var vector2:Point3D = new Point3D();
		
		private var _connectionPoint:Point3D = new Point3D();
		private var _otherConnectionPoint:Point3D = new Point3D();
		private var _springConstant:Number;
		private var _restLength:Number;
		private var _otherBody:RigidBody;
		
		public function RigidBodySpring(connectionPoint:Point3D, otherBody:RigidBody, otherConnectionPoint:Point3D, springConstant:Number, restLength:Number) {
			_connectionPoint.copy(connectionPoint);
			_otherConnectionPoint = otherConnectionPoint;
			_otherBody = otherBody;
			_springConstant = springConstant;
			_restLength = restLength;
		}

		public function updateForce(body:RigidBody, time:Number):void {
			// TODO: Оптимизировать!!!
			vector1.copy(_connectionPoint);
			vector1.transform(body.transformMatrix);
			vector2.copy(_otherConnectionPoint);
			vector2.transform(_otherBody.transformMatrix);
			vector2.subtract(vector1);
			var len:Number = vector2.length;
			if (len == 0) {
				trace("[RigidBodySpring::updateForce] spring length is zero");
			}
			var magnitude:Number = len - _restLength;
			magnitude *= _springConstant;
			vector2.multiply(magnitude/len);
			body.addForceAtPoint(vector2, vector1);
		}
		
	}
}