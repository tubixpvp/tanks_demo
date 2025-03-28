package alternativa.physics.rigid.generators {
	import alternativa.physics.altphysics;
	import alternativa.physics.collision.CollisionBox;
	import alternativa.physics.rigid.RigidBody;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	
	import flash.utils.Dictionary;
	
	use namespace altphysics;
	
	public class RigidBox {
		
		public var body:RigidBody;
		public var collisionBox:CollisionBox;
		public var radius:Number;
		
		public var boxCollisionCache:Dictionary = new Dictionary();
		public var next:RigidBox;
		
		private var point:Point3D = new Point3D();
		
		public function RigidBox(width:Number, length:Number, height:Number, mass:Number) {
			body = new RigidBody();
			collisionBox = new CollisionBox(body, new Point3D(0.5*width, 0.5*length, 0.5*height));
			setParams(width, length, height, mass);
		}
		
		public function setParams(width:Number, length:Number, height:Number, mass:Number):void {
			radius = Math.sqrt(width*width + length*length + height*height)*0.5;
			collisionBox.halfSize.reset(0.5*width, 0.5*length, 0.5*height);
			if (mass == 0) {
				body.setInfinteMass();
			} else {
				var coeff:Number = mass/12;
				var xx:Number = width*width;
				var yy:Number = length*length;
				var zz:Number = height*height;
				var inertiaTensor:Matrix3D = new Matrix3D();
				inertiaTensor.a = coeff*(yy + zz);
				inertiaTensor.f = coeff*(xx + zz);
				inertiaTensor.k = coeff*(xx + yy);
				body.setIntertiaTensor(inertiaTensor);
				body.setMass(mass);
			} 	
		}
		
		public function setNext(box:RigidBox):RigidBox {
			next = box;
			body.next = box.body;
			return box;
		}
		
	}
}