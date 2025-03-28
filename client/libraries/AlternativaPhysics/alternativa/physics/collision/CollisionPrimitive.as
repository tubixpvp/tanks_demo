package alternativa.physics.collision {
	
	import alternativa.physics.altphysics;
	import alternativa.physics.rigid.RigidBody;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	
	use namespace altphysics;
	
	public class CollisionPrimitive {
		
		public var position:Point3D = new Point3D();
		public var transform:Matrix3D = new Matrix3D();
		public var body:RigidBody;
		
		public function CollisionPrimitive(body:RigidBody) {
			this.body = body;
		}
		
		public function updateTransform():void {
			transform.copy(body.transformMatrix);
			position.x = body.position.x;
			position.y = body.position.y;
			position.z = body.position.z;
			transform.d = position.x;
			transform.h = position.y;
			transform.l = position.z;
		}

	}
}