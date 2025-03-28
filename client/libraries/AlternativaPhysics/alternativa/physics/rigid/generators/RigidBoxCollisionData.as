package alternativa.physics.rigid.generators {
	import alternativa.physics.collision.CollisionData;

	public class RigidBoxCollisionData extends CollisionData {

		private static var pool:Array = new Array();
		
		public static function create():RigidBoxCollisionData {
			var data:RigidBoxCollisionData = pool.pop();
			if (data == null) {
				data = new RigidBoxCollisionData();
			}
			data.fresh = true;
			data.timeStamp = 0;
			return data;
		}
		
		public static function destroy(data:RigidBoxCollisionData):void {
			data.primitive1 = null;
			data.primitive2 = null;
			data.otherBox = null;
			pool.push(data);
		}
		
		public var fresh:Boolean;
		public var otherBox:RigidBox;

		public function RigidBoxCollisionData() {
			super();
		}
		
		public function equals(data:RigidBoxCollisionData):Boolean {
			var result:Boolean = otherBox == data.otherBox && pointAxisCode1 == data.pointAxisCode1 && pointAxisCode2 == data.pointAxisCode2;
			return result;
		}
		
		public function toString():String {
			return "RigidBoxCollisionData" +
				"\n  collisionPoint " + collisionPoint +
				"\n  collisionNormal " + collisionNormal +
				"\n  pointAxisCode1 " + pointAxisCode1.toString(2) +
				"\n  pointAxisCode2 " + pointAxisCode2.toString(2);
		}
		
	}
}