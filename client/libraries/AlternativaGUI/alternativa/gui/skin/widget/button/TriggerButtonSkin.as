package alternativa.gui.skin.widget.button {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class TriggerButtonSkin implements ISkin {
		
		public var unselected:BitmapData;
		public var selected:BitmapData;
		public var lockedUnselected:BitmapData;
		public var lockedSelected:BitmapData;
		
		public var space:int;
		
		public function TriggerButtonSkin(unselected:BitmapData,
									 	  selected:BitmapData,
										  lockedUnselected:BitmapData,
									 	  lockedSelected:BitmapData,
									 	  space:int) {

			this.unselected = unselected;
			this.selected = selected;
			this.lockedUnselected = lockedUnselected;
			this.lockedSelected = lockedSelected;
			
			this.space = space;
		}
			
		
	}
}