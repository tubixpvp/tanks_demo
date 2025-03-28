package alternativa.tanks.gui.loader {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.WindowAlign;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.window.WindowBase;
	import alternativa.tanks.gui.skin.LobbySkinManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	public class IndicatorWindow extends WindowBase {
		
		[Embed(source="../../resources/indicator_panel_back.png")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
		
		[Embed(source="../../resources/indicator_panel_border.png")] private static const borderBitmap:Class;
		private static const borderBd:BitmapData = new borderBitmap().bitmapData;
		
		private var back:Bitmap;
		private var border:Bitmap;
		
		private var board:IndicatorBoard;
		
		public function IndicatorWindow(value:String) {
			super(134, 60, false, false, "", false, false, false, WindowAlign.MIDDLE_CENTER);
			
			skinManager = new LobbySkinManager();
			
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE, 5);
			
			back = new Bitmap(backBd);
			addChildAt(back, 0);
			back.x = -8;
			back.y = -8;
			
			board = new IndicatorBoard(90, 50, 0, 3, 0.6, 0x00ff66, 0.1, 0.8);
			addObject(board);
			board.value = value;
			
			border = new Bitmap(borderBd);
			addChild(border);
			border.x = -8;
			border.y = -8;
			
			draw(computeSize(computeMinSize()));
		}
		
		public function set value(s:String):void {
			board.value = s;
		}

	}
}