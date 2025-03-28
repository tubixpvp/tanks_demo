package alternativa.model.general.world3d.view3d {
	import alternativa.object.ClientObject;
	
	public interface IView3DModel {
		function getParams(clientObject:ClientObject):View3DModelParams;
	}
}