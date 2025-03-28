package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.button.ImageButtonSkin;
	
	import flash.geom.ColorTransform;
	

	public class LobbyMapIconSkin extends ImageButtonSkin {
		
		private static const colorNormal:ColorTransform = new ColorTransform();
		private static const colorOver:ColorTransform = new ColorTransform();
		private static const colorPress:ColorTransform = new ColorTransform();
		private static const colorLock:ColorTransform = new ColorTransform();
		//private static const colorLock:ColorTransform = new ColorTransform(0.8, 0.6, 0.4);
		
		public var colorFocus:ColorTransform;
		
		public function LobbyMapIconSkin() {
			super(LobbyMapIconSkin.colorNormal,
				  LobbyMapIconSkin.colorOver,
				  LobbyMapIconSkin.colorPress,
				  LobbyMapIconSkin.colorLock);
			
			colorFocus = new ColorTransform();
		}

	}
}