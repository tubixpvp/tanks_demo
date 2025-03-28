package alternativa.skin.cursor.noneSkin {
	import alternativa.iointerfaces.mouse.CursorState;
	import alternativa.skin.cursor.CursorSkin;
	
	import flash.display.BitmapData;
	import flash.text.TextFormat;
	
	public class NoneCursorSkin extends CursorSkin {
		
		[Embed(source="resources/cursor_none.png")] private static const cursorNone:Class;
		private static const none:BitmapData = new cursorNone().bitmapData;
		
		private static const hintTextFormat:TextFormat = new TextFormat("Alternativa", 12, 0x000000);
		
		private static const hintTextThickness:Number = 50;
		private static const hintTextSharpness:Number = -50;
		
		private static const hintBorderEnabled:Boolean = true;
		private static const hintBorderColor:uint = 0x000000;
		private static const hintBgColor:uint = 0xFFFFBF;
		
		private static const hintOffsetLeft:int = 2;
		private static const hintOffsetRight:int = 9;
		private static const hintOffsetTop:int = 2;
		private static const hintOffsetBottom:int = 19;
		
		public function NoneCursorSkin() {
			super(new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  new CursorState(none, 0, 0),
				  NoneCursorSkin.hintTextFormat,
				  NoneCursorSkin.hintTextThickness,
				  NoneCursorSkin.hintTextSharpness,
				  NoneCursorSkin.hintBorderEnabled,
				  NoneCursorSkin.hintBorderColor,
				  NoneCursorSkin.hintBgColor,
				  NoneCursorSkin.hintOffsetLeft,
				  NoneCursorSkin.hintOffsetRight,
				  NoneCursorSkin.hintOffsetTop,
				  NoneCursorSkin.hintOffsetBottom);
		}
		
	}
}