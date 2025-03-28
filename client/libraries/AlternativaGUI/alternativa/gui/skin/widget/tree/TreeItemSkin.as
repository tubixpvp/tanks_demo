package alternativa.gui.skin.widget.tree {
	import alternativa.gui.skin.widget.list.ListItemSkin;
	
	import flash.display.BitmapData;

   /**
	* Скин для элемента дерева
	*/
	public class TreeItemSkin extends ListItemSkin {
		
		public var bitmapSubClosed:BitmapData;		
		public var bitmapSubOpened:BitmapData;
		
		public function TreeItemSkin(selectionColor:uint,
									 selectionAlphaOver:Number,
									 selectionAlphaOverSelected:Number,
									 selectionAlphaSelected:Number,
									 bitmapSubOpened:BitmapData,
									 bitmapSubClosed:BitmapData) {
			super(selectionColor,
				  selectionAlphaOver,
				  selectionAlphaOverSelected,
				  selectionAlphaSelected);
					
			this.bitmapSubClosed = bitmapSubClosed;
			this.bitmapSubOpened = bitmapSubOpened;								
		}
		
	}
}