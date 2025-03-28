package alternativa.skin.cursor {
	
	import alternativa.iointerfaces.mouse.Cursor;
	import alternativa.iointerfaces.mouse.CursorState;
	import alternativa.skin.ISkin;
	
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	public class CursorSkin implements ISkin {
		
		// Графика курсора во всех состояних
		public var state:Dictionary;
		
		// Формат хинта
		public var hintTextFormat:TextFormat;
		public var hintTextThickness:Number;
		public var hintTextSharpness:Number;
		public var hintBorderEnabled:Boolean;
		public var hintBorderColor:uint;
		public var hintBgColor:uint;
		public var hintOffsetLeft:int;
		public var hintOffsetRight:int;
		public var hintOffsetTop:int;
		public var hintOffsetBottom:int;
		
		public function CursorSkin(normal:CursorState,
								   active:CursorState,
								   hand:CursorState,
								   grab:CursorState,
								   drag:CursorState,
								   drop:CursorState,
								   move:CursorState,
								   resizeHorizontal:CursorState,
								   resizeVertical:CursorState,
								   resizeDiagonalUp:CursorState,
								   resizeDiagonalDown:CursorState,
								   imposible:CursorState,
								   editText:CursorState,
								   hintTextFormat:TextFormat,
								   hintTextThickness:Number,
								   hintTextSharpness:Number,
								   hintBorderEnabled:Boolean,
								   hintBorderColor:uint,
								   hintBgColor:uint,
								   hintOffsetLeft:int,
								   hintOffsetRight:int,
								   hintOffsetTop:int,
								   hintOffsetBottom:int) {
								   	
			state = new Dictionary(false);
			
			state[Cursor.NORMAL] = normal;
			state[Cursor.ACTIVE] = active;
			state[Cursor.HAND] = hand;
			state[Cursor.GRAB] = grab;
			state[Cursor.DRAG] = drag;
			state[Cursor.DROP] = drop;
			state[Cursor.MOVE] = move;
			state[Cursor.RESIZE_HORIZONTAL] = resizeHorizontal;
			state[Cursor.RESIZE_VERTICAL] = resizeVertical;
			state[Cursor.RESIZE_DIAGONAL_UP] = resizeDiagonalUp;
			state[Cursor.RESIZE_DIAGONAL_DOWN] = resizeDiagonalDown;
			state[Cursor.IMPOSIBLE] = imposible;
			state[Cursor.EDIT_TEXT] = editText;
			
			this.hintTextFormat = hintTextFormat;
			this.hintTextThickness = hintTextThickness;
			this.hintTextSharpness = hintTextSharpness;
			
			this.hintBorderEnabled = hintBorderEnabled;
			this.hintBorderColor = hintBorderColor;
			this.hintBgColor = hintBgColor;
			
			this.hintOffsetLeft = hintOffsetLeft;
			this.hintOffsetRight = hintOffsetRight;
			this.hintOffsetTop = hintOffsetTop;
			this.hintOffsetBottom = hintOffsetBottom;
		}
		
	}
}