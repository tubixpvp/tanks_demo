package alternativa.physics.force {
	import alternativa.physics.*;
	import alternativa.physics.rigid.RigidBody;
	import alternativa.types.Point3D;

	use namespace altphysics;

	public class RigidBodyAnchoredBungee implements IRigidBodyForceGenerator {

		private var vector1:Point3D = new Point3D();
		private var vector2:Point3D = new Point3D();
		
		private var _connectionPoint:Point3D = new Point3D();
		private var _anchorPoint:Point3D = new Point3D();
		private var _springConstant:Number;
		private var _restLength:Number;
		
		public function RigidBodyAnchoredBungee(connectionPoint:Point3D, anchorPoint:Point3D, springConstant:Number, restLength:Number) {
			_connectionPoint.copy(connectionPoint);
			_anchorPoint.copy(anchorPoint);
			_springConstant = springConstant;
			_restLength = restLength;
		}

		public function updateForce(body:RigidBody, time:Number):void {
			// TODO: Оптимизировать!!!
			vector1.copy(_connectionPoint);
			vector1.transform(body.transformMatrix);
			vector2.copy(_anchorPoint);
			vector2.subtract(vector1);
			var len:Number = vector2.length;
			var magnitude:Number = len - _restLength;
			if (magnitude > 0) {
				magnitude *= _springConstant;
				vector2.multiply(magnitude/len);
				body.addForceAtPoint(vector2, vector1);
			}
		}
		
		public function set anchorPoint(value:Point3D):void {
			_anchorPoint.copy(value);
		}
		
	}
}