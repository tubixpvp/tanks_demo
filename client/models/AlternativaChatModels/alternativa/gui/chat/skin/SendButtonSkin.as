package alternativa.gui.chat.skin {
	import alternativa.gui.skin.widget.button.ImageButtonSkin;
	
	import flash.geom.ColorTransform;
	
	public class SendButtonSkin extends ImageButtonSkin {
		
		private static const colorNormal:ColorTransform = new ColorTransform();
		private static const colorOver:ColorTransform = new ColorTransform(1.1, 1.1, 1.1, 1, 0, 20, 10, 0);
		private static const colorPress:ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		private static const colorLock:ColorTransform = new ColorTransform();//new ColorTransform(0.5, 0.5, 0.5, 1, 50, 50, 50, 0);
		
		public var colorFocus:ColorTransform;
		
		public function SendButtonSkin() {
			super(SendButtonSkin.colorNormal,
				  SendButtonSkin.colorOver,
				  SendButtonSkin.colorPress,
				  SendButtonSkin.colorLock);
			
			colorFocus = new ColorTransform(1.1, 1.1, 1.1, 1, 0, 20, 10, 0);
		}
		
	}
}