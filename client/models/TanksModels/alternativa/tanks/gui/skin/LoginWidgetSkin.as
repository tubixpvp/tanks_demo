package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.WidgetSkin;
	
	import flash.display.BitmapData;
	
	
	public class LoginWidgetSkin extends WidgetSkin {
		
		[Embed(source="../../resources/emptyBitmap.png")] private static const emptyBitmap:Class;
		
		private static const emptyBd:BitmapData = new emptyBitmap().bitmapData;
		
		public function LoginWidgetSkin(){
			super(emptyBd);
		}

	}
}