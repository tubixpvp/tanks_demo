package alternativa.gui.skin.widget.button {
	import alternativa.skin.ISkin;
	
	import flash.geom.ColorTransform;
	
	/**
	 * Скин для кнопки ImageButton
	 */
	public class ImageButtonSkin implements ISkin {
		
		// Настройка трансформации цвета при залочивании
		public var colorNormal:ColorTransform;
		public var colorOver:ColorTransform;
		public var colorPress:ColorTransform;
		public var colorLock:ColorTransform;
		
		public function ImageButtonSkin(colorNormal:ColorTransform,colorOver:ColorTransform,colorPress:ColorTransform,colorLock:ColorTransform) {			
			this.colorNormal = colorNormal;
			this.colorOver = colorOver;
			this.colorPress = colorPress;
			this.colorLock = colorLock;
					
		}
		
	}
}