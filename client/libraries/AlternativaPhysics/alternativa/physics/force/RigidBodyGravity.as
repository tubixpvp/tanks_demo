package alternativa.physics.force {
	import alternativa.physics.*;
	import alternativa.physics.rigid.RigidBody;
	import alternativa.types.Point3D;

	use namespace altphysics;

	/**
	 * 
	 */
	public class RigidBodyGravity implements IRigidBodyForceGenerator {
		
		private var _gravity:Point3D = new Point3D();
		
		public function RigidBodyGravity(g:Point3D) {
			_gravity.copy(g);
		}

		public function updateForce(body:RigidBody, time:Number):void {
			if (body.inverseMass == 0) {
				return;
			}
			body.addForceComponents(_gravity.x*body.mass, _gravity.y*body.mass, _gravity.z*body.mass);
		}
		
	}
}