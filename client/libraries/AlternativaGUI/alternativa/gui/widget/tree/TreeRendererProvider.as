package alternativa.gui.widget.tree
{
	import alternativa.gui.widget.list.IListRenderer;
	import alternativa.gui.widget.list.IListRendererProvider;
	import alternativa.gui.widget.list.ListRendererParams;
	
	public class TreeRendererProvider implements IListRendererProvider {
		
		public function getRenderer(item:Object):IListRenderer {
			return new TreeRenderer(new ListRendererParams());
		}

	}
}