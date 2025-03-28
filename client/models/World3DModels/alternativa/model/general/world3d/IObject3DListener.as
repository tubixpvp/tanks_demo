package alternativa.model.general.world3d {
	import alternativa.engine3d.core.Object3D;
	import alternativa.object.ClientObject;
	
	public interface IObject3DListener {
		
		function object3DLoaded(clientObject:ClientObject, clientObject3D:ClientObject, object3d:Object3D):void;
		function object3DUnloaded(clientObject:ClientObject, clientObject3D:ClientObject, object3d:Object3D):void;
		
	}
}