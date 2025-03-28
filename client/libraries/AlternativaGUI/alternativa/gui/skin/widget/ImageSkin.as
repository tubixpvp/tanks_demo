package alternativa.gui.skin.widget {
	import alternativa.skin.ISkin;
	
	import flash.geom.ColorTransform;
	
	public class ImageSkin implements ISkin {
		
		public var colorNormal:ColorTransform;
		public var colorLocked:ColorTransform;
		
		public function ImageSkin(colorNormal:ColorTransform, colorLocked:ColorTransform) {
			this.colorNormal = colorNormal;
			this.colorLocked = colorLocked;
		}
		
	}
}