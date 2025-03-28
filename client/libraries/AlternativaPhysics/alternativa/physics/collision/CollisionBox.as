package alternativa.physics.collision {
	import alternativa.physics.rigid.RigidBody;
	import alternativa.types.Point3D;
	
	public class CollisionBox extends CollisionPrimitive {
		
		public var halfSize:Point3D = new Point3D();

		public function CollisionBox(body:RigidBody, halfSize:Point3D) {
			super(body);
			this.halfSize.copy(halfSize);
		}

	}
}