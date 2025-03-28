package alternativa.physics.rigid.generators {
	import alternativa.physics.altphysics;
	import alternativa.physics.rigid.RigidBody;
	import alternativa.physics.rigid.RigidBodyContact;
	import alternativa.physics.rigid.RigidBodyContactGenerator;
	import alternativa.types.Point3D;
	
	use namespace altphysics;
	
	public class SphereWithPlaneContactGenerator extends RigidBodyContactGenerator {
		
		private var body:RigidBody;
		private var planeNormal:Point3D = new Point3D();
		private var planeOffset:Number;
		private var radius:Number;
		private var restitution:Number;
		private var friction:Number;
		
		public function SphereWithPlaneContactGenerator(body:RigidBody, radius:Number, planeNormal:Point3D, planeOffset:Number, restitution:Number, friction:Number) {
			super();
			this.body = body;
			this.radius = radius;
			this.planeNormal.copy(planeNormal);
			this.planeOffset = planeOffset;
			this.restitution = restitution;
			this.friction = friction;
		}
		
		override public function addContacts(firstContact:RigidBodyContact):RigidBodyContact {
			var offset:Number = planeNormal.dot(body.position) - planeOffset;
			if (offset < radius) {
				firstContact.body1 = body;
				firstContact.body2 = null;
				firstContact.penetration = radius - offset;
				firstContact.contactNormal.copy(planeNormal);
				firstContact.contactPoint.copy(planeNormal);
				firstContact.contactPoint.multiply(-radius);
				firstContact.contactPoint.add(body.position);
				firstContact.restitution = restitution;
				firstContact.friction = friction;
				return firstContact.next;
			}
			return firstContact;
		}
		
	}
}