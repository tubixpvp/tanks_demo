package alternativa.gui.widget.button {
	import alternativa.gui.skin.widget.button.ShortcutSkin;
	import flash.display.BitmapData;
	
	public class ShortcutBase extends ImageButton {
		
		// Шкурка
		protected var skin:ShortcutSkin;
		
		public function ShortcutBase(image:BitmapData = null, hint:String = null, yNormal:int = 0, yPress:int = 1) {
			super(yNormal, yPress, image);
			this.hint = hint; 
		}
		
		override public function updateSkin():void {
			super.updateSkin();
			skin = ShortcutSkin(skinManager.getSkin(ShortcutBase));
		}
		
	}
}