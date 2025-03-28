package alternativa.model.general.world3d {
	import alternativa.model.general.world3d.physics.RigidBox3D;
	import alternativa.object.ClientObject;
	
	public interface IPhysicsObject {
		function getRigidBox3D(clientObject:ClientObject):RigidBox3D;
	}
}