package alternativa.physics.force {
	import alternativa.physics.rigid.RigidBody;
	
	/**
	 * 
	 */
	public interface IRigidBodyForceGenerator {
		function updateForce(body:RigidBody, time:Number):void;
	}
}