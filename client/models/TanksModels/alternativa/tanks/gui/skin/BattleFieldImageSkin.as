package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.ImageSkin;
	
	import flash.geom.ColorTransform;
	
	public class BattleFieldImageSkin extends ImageSkin {
		
		private static const colorNormal:ColorTransform = new ColorTransform();
		private static const colorLocked:ColorTransform = new ColorTransform();
		
		public function BattleFieldImageSkin() {
			super(BattleFieldImageSkin.colorNormal, BattleFieldImageSkin.colorLocked);
		}

	}
}