package alternativa.gui.skin.cursor.baseSkin {
	import alternativa.gui.mouse.CursorState;
	import alternativa.gui.skin.cursor.CursorSkin;
	
	import flash.display.BitmapData;
	import flash.text.TextFormat;
	
	public class BaseCursorSkin extends CursorSkin {
		
		[Embed(source="resources/cursor_normal.png")] private static const cursorNormal:Class;
		[Embed(source="resources/cursor_active.png")] private static const cursorActive:Class;
		[Embed(source="resources/cursor_hand.png")] private static const cursorHand:Class;
		[Embed(source="resources/cursor_grab.png")] private static const cursorGrab:Class;
		[Embed(source="resources/cursor_drag.png")] private static const cursorDrag:Class;
		[Embed(source="resources/cursor_drop.png")] private static const cursorDrop:Class;
		[Embed(source="resources/cursor_move.png")] private static const cursorMove:Class;
		[Embed(source="resources/cursor_resize_horizontal.png")] private static const cursorResizeHorizontal:Class;
		[Embed(source="resources/cursor_resize_vertical.png")] private static const cursorResizeVertical:Class;
		[Embed(source="resources/cursor_resize_diagonal_up.png")] private static const cursorResizeDiagonalUp:Class;
		[Embed(source="resources/cursor_resize_diagonal_down.png")] private static const cursorResizeDiagonalDown:Class;
		[Embed(source="resources/cursor_imposible.png")] private static const cursorImposible:Class;
		[Embed(source="resources/cursor_edit_text.png")] private static const cursorEditText:Class;
		
		private static const normal:BitmapData = new cursorNormal().bitmapData;
		private static const active:BitmapData = new cursorActive().bitmapData;
		private static const hand:BitmapData = new cursorHand().bitmapData;
		private static const grab:BitmapData = new cursorGrab().bitmapData;
		private static const drag:BitmapData = new cursorDrag().bitmapData;
		private static const drop:BitmapData = new cursorDrop().bitmapData;
		private static const move:BitmapData = new cursorMove().bitmapData;
		private static const resizeHorizontal:BitmapData = new cursorResizeHorizontal().bitmapData;
		private static const resizeVertical:BitmapData = new cursorResizeVertical().bitmapData;
		private static const resizeDiagonalUp:BitmapData = new cursorResizeDiagonalUp().bitmapData;
		private static const resizeDiagonalDown:BitmapData = new cursorResizeDiagonalDown().bitmapData;
		private static const imposible:BitmapData = new cursorImposible().bitmapData;
		private static const editText:BitmapData = new cursorEditText().bitmapData;
		
		private static const hintTextFormat:TextFormat = new TextFormat("Alternativa", 12, 0x000000);
		
		private static const hintTextThickness:Number = 50;
		private static const hintTextSharpness:Number = -50;
		
		private static const hintBorderEnabled:Boolean = true;
		private static const hintBorderColor:uint = 0x000000;
		private static const hintBgColor:uint = 0xFFFFBF;
		
		private static const hintOffsetLeft:int = 2;
		private static const hintOffsetRight:int = 6;
		private static const hintOffsetTop:int = 2;
		private static const hintOffsetBottom:int = 12;
		
		public function BaseCursorSkin() {
			super(new CursorState(normal, 1, 1),
				  new CursorState(active, 1, 1),
				  new CursorState(hand, 4, 1),
				  new CursorState(grab, 9, 14),
				  new CursorState(drag, 7, 5),
				  new CursorState(drop, 7, 5),
				  new CursorState(move, 10, 10),
				  new CursorState(resizeHorizontal, 11, 4),
				  new CursorState(resizeVertical, 4, 11),
				  new CursorState(resizeDiagonalUp, 9, 9),
				  new CursorState(resizeDiagonalDown, 9, 9),
				  new CursorState(imposible, 8, 8),
				  new CursorState(editText, 3, 2),
				  BaseCursorSkin.hintTextFormat,
				  BaseCursorSkin.hintTextThickness,
				  BaseCursorSkin.hintTextSharpness,
				  BaseCursorSkin.hintBorderEnabled,
				  BaseCursorSkin.hintBorderColor,
				  BaseCursorSkin.hintBgColor,
				  BaseCursorSkin.hintOffsetLeft,
				  BaseCursorSkin.hintOffsetRight,
				  BaseCursorSkin.hintOffsetTop,
				  BaseCursorSkin.hintOffsetBottom);
		}
		
	}
}