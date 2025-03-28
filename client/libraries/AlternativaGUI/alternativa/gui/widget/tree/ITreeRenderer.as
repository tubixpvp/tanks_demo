package alternativa.gui.widget.tree {
	import alternativa.gui.widget.list.IListRenderer;
	
	
	public interface ITreeRenderer extends IListRenderer {
		
		function get parentItem():ITreeRenderer;
		function set parentItem(value:ITreeRenderer):void;
		
		function get index():int;
		function set index(value:int):void;
		
		function get level():int;
		function set level(value:int):void;
		
		function get opened():Boolean;
		function set opened(value:Boolean):void;
		
		function get hasChildren():Boolean;
		function set hasChildren(value:Boolean):void;
			
	}
	
}