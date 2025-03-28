package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.button.ImageButtonSkin;
	
	import flash.geom.ColorTransform;
	
	public class LobbyImageButtonSkin extends ImageButtonSkin {
		
		private static const colorNormal:ColorTransform = new ColorTransform();
		private static const colorOver:ColorTransform = new ColorTransform();
		private static const colorPress:ColorTransform = new ColorTransform();
		private static const colorLock:ColorTransform = new ColorTransform();
		
		public var colorFocus:ColorTransform;
		
		public function LobbyImageButtonSkin() {
			super(LobbyImageButtonSkin.colorNormal,
				  LobbyImageButtonSkin.colorOver,
				  LobbyImageButtonSkin.colorPress,
				  LobbyImageButtonSkin.colorLock);
			
			colorFocus = new ColorTransform();
		}
		
	}
}