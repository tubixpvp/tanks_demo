package alternativa.gui.widget.tree {
	import alternativa.gui.widget.list.ListItemEvent;
	
	
	public class TreeItemEvent extends ListItemEvent {
		
		public static const EXPAND:String = "TreeItemExpand";
		public static const COLLAPSE:String = "TreeItemCollapse";
		
		public function TreeItemEvent(type:String, data:Object)	{
			super(type, data);
		}

	}
}