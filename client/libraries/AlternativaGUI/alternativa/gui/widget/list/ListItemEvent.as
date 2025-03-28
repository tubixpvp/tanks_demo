package alternativa.gui.widget.list {
	import flash.events.Event;
	import flash.ui.Keyboard;

	/**
	 * Событие элемента списка 
	 */
	public class ListItemEvent extends Event {

		public static const SELECT:String = "ListItemSelect";
		public static const UNSELECT:String = "ListItemUnselect";
		//public static const CLICK:String = "listItemClick";
		//public static const EXPAND:String = "listItemExpand";
		//public static const COLLAPSE:String = "listItemCollapse";
		
		public var data:Object;
		public var shiftKey:Boolean;
		public var ctrlKey:Boolean;
		
		public function ListItemEvent(type:String, data:Object, shiftKey:Boolean = false, ctrlKey:Boolean = false) {
			this.data = data;
			this.shiftKey = shiftKey;
			this.ctrlKey = ctrlKey;
			super(type, true);
		}
		
	}
}