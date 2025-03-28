package alternativa.model.general.world3d.physics {
	import alternativa.engine3d.core.Object3D;
	import alternativa.physics.rigid.RigidBody;
	
	public interface IObjectAnimator {
		function animateObject(object:Object3D, body:RigidBody):void;
	}
}