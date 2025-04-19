package alternativa.gui.chat.skin {
	
	import alternativa.gui.skin.widget.ImageSkin;
	
	import flash.geom.ColorTransform;

	public class ChatImageSkin extends ImageSkin {
		
		private static const colorNormal:ColorTransform = new ColorTransform();
		private static const colorLocked:ColorTransform = new ColorTransform();
		//private static const colorLocked:ColorTransform = new ColorTransform(0.5, 0.5, 0.5, 1, 50, 50, 50, 0);
		
		public function ChatImageSkin() {
			super(ChatImageSkin.colorNormal, ChatImageSkin.colorLocked);
		}
	}
}