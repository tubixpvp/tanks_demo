package alternativa.physics.rigid.generators {
	
	import alternativa.physics.altphysics;
	import alternativa.physics.rigid.RigidBody;
	import alternativa.physics.rigid.RigidBodyContact;
	import alternativa.physics.rigid.RigidBodyContactGenerator;
	import alternativa.types.Point3D;
	
	use namespace altphysics;

	public class AnchoredCableContactGenerator extends RigidBodyContactGenerator {
		
		private var body:RigidBody;
		private var mountPoint:Point3D;
		private var _anchorPoint:Point3D;
		private var cableLength:Number;
		private var restitution:Number;
		
		private var vector:Point3D = new Point3D();
		private var point:Point3D = new Point3D();
		
		public function AnchoredCableContactGenerator(body:RigidBody, mountPoint:Point3D, anchorPoint:Point3D, cableLength:Number, restitution:Number) {
			super();
			this.body = body;
			this.mountPoint = mountPoint.clone();
			_anchorPoint = anchorPoint.clone();
			this.cableLength = cableLength;
			this.restitution = restitution;
		}
		
		public function set anchorPoint(value:Point3D):void {
			_anchorPoint.copy(value);
		}
		
		override public function addContacts(contact:RigidBodyContact):RigidBodyContact {
			point.copy(mountPoint);
			point.transform(body.transformMatrix);
			vector.difference(_anchorPoint, point);
			var len:Number = vector.length;
			var pen:Number = len - cableLength;
			if (pen > 0) {
				vector.multiply(1/len);
				contact.body1 = body;
				contact.body2 = null;
				contact.contactNormal.copy(vector);
				contact.contactPoint.copy(point);
				contact.restitution = restitution;
				contact.penetration = pen;
				contact.friction = 0;
				return contact.next;
			}
			return contact;
		}
		
	}
}