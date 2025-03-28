package alternativa.physics.registry {
	import alternativa.physics.force.IRigidBodyForceGenerator;
	import alternativa.physics.rigid.RigidBody;
	
	public class BodyForceRegistration {
		public var body:RigidBody;
		public var forceGenerator:IRigidBodyForceGenerator;
		
		public var next:BodyForceRegistration;
		
		public function BodyForceRegistration(body:RigidBody, forceGenerator:IRigidBodyForceGenerator) {
			this.body = body;
			this.forceGenerator = forceGenerator;
		}
	}
}