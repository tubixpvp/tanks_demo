package alternativa.physics.collision {
	import alternativa.types.Point3D;
	
	public class CollisionData {
		
		public var primitive1:CollisionPrimitive;
		public var primitive2:CollisionPrimitive;
		
		public var collisionNormal:Point3D = new Point3D();
		public var collisionPoint:Point3D = new Point3D();
		public var penetration:Number;
		
		public var pointAxisCode1:int;
		public var pointAxisCode2:int;
		
		public var timeStamp:int;
	}
}