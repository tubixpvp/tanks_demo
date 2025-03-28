package alternativa.gui.widget.comboBox {
	import flash.events.Event;
	
	public class ComboBoxEvent extends Event {
		
		public static const SELECT_ITEM:String = "ComboBoxEventSelectItem";
		
		public var data:Object;
		
		public function ComboBoxEvent(type:String, data:Object) {
			super(type, true, true);
			this.data = data;
		}

	}
}