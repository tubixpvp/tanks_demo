package alternativa.model.general.world3d {
	import alternativa.model.general.world3d.object3d.Object3DParams;
	import alternativa.object.ClientObject;
	import alternativa.types.Point3D;
	
	public interface IObject3DParams {
		function getObject3DParams(clientObject:ClientObject):Object3DParams;
	}
}