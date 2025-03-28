package alternativa.model.general.world3d.view3d {
	import alternativa.engine3d.controllers.WalkController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.display.View;
	
	public final class View3DModelParams {
		public var camera:Camera3D;
		public var view:View;
		
		public function View3DModelParams(camera:Camera3D, view:View) {
			this.camera = camera;
			this.view = view;
		}
	}
}