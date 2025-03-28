package alternativa.gui.mouse {
	
	import flash.utils.Dictionary;
	
	public class DefaultCursorTypes implements ICursorTypes	{
		
		// Список дополнительных курсоров
		protected var _additionalCursors:Dictionary;
		
		private var additionalCursorsLastIndex:uint = Cursor.defaultCursorsLastIndex;
		
		public function DefaultCursorTypes() {
			_additionalCursors = new Dictionary(false);
		}
		
		// Стандартные виды курсоров
		public function get NONE():uint { return Cursor.NONE; }
		public function get NORMAL():uint { return Cursor.NORMAL; }
		public function get ACTIVE():uint { return Cursor.ACTIVE; }
		public function get HAND():uint { return Cursor.HAND; }
		public function get GRAB():uint { return Cursor.GRAB; }
		public function get DRAG():uint { return Cursor.DRAG; }
		public function get DROP():uint { return Cursor.DROP; }
		public function get MOVE():uint { return Cursor.MOVE; }
		public function get RESIZE_HORIZONTAL():uint { return Cursor.RESIZE_HORIZONTAL; }
		public function get RESIZE_VERTICAL():uint { return Cursor.RESIZE_VERTICAL; }
		public function get RESIZE_DIAGONAL_UP():uint { return Cursor.RESIZE_DIAGONAL_UP; }
		public function get RESIZE_DIAGONAL_DOWN():uint { return Cursor.RESIZE_DIAGONAL_DOWN; }
		public function get IMPOSIBLE():uint { return Cursor.IMPOSIBLE; }
		public function get EDIT_TEXT():uint { return Cursor.EDIT_TEXT; }
		
		// Дополнительные виды
		/*public function get additionalCursors():Dictionary {
			return _additionalCursors;
		}
		
		public function addCursorType(cursorTypeName:String):uint {
			additionalCursorsLastIndex++;
			_additionalCursors[name] = additionalCursorsLastIndex;
		}*/
		
	}
}