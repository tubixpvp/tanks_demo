package alternativa.model.general.world3d {
	import alternativa.engine3d.core.Object3D;
	import alternativa.object.ClientObject;
	
	import flash.utils.ByteArray;
	
	public interface IObject3D {
		function getObject3D(clientObject:ClientObject):Object3D;
	}
	
}