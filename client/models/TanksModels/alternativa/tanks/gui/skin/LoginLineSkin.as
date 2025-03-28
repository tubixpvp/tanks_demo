package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.LineSkin;
	
	import flash.display.BitmapData;
	
	public class LoginLineSkin extends LineSkin {
		
		[Embed(source="../../resources/vline_t.png")] private static const bitmapVT:Class;
		[Embed(source="../../resources/vline_m.png")] private static const bitmapVM:Class;
		[Embed(source="../../resources/vline_b.png")] private static const bitmapVB:Class;
		[Embed(source="../../resources/hline_l.png")] private static const bitmapHL:Class;
		[Embed(source="../../resources/hline_c.png")] private static const bitmapHC:Class;
		[Embed(source="../../resources/hline_r.png")] private static const bitmapHR:Class;

		private static const bmpVT:BitmapData = new bitmapVT().bitmapData;
		private static const bmpVM:BitmapData = new bitmapVM().bitmapData;
		private static const bmpVB:BitmapData = new bitmapVB().bitmapData;
		private static const bmpHL:BitmapData = new bitmapHL().bitmapData;
		private static const bmpHC:BitmapData = new bitmapHC().bitmapData;
		private static const bmpHR:BitmapData = new bitmapHR().bitmapData;
		
		public function LoginLineSkin() {
			super(LoginLineSkin.bmpVT,
				  LoginLineSkin.bmpVM,
				  LoginLineSkin.bmpVB,
				  LoginLineSkin.bmpHL,
				  LoginLineSkin.bmpHC,
				  LoginLineSkin.bmpHR);				
		}

	}
}