package alternativa.gui.window.panel {
	import alternativa.iointerfaces.mouse.dnd.IDragObject;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	
	public class PanelDragObject implements IDragObject {
		
		private var panel:ResizeablePanelBase;
		private var gfx:Shape;
		
		public function PanelDragObject(panel:ResizeablePanelBase) {
			this.panel = panel;
			gfx = new Shape();
			/*gfx.graphics.lineStyle(1, 0x0000cc, 1);
			gfx.graphics.drawRect(0, 0, panel.currentSize.x, panel.currentSize.y);*/
		}
		
		/**
		 * Объект, который схватили 
		 */		
		public function get dragObject():Object {
			return panel;
		}
		
		/**
		 * Перетаскиваемая графика
		 */		
		public function get dragGraphics():DisplayObject {
			return gfx;
		}

	}
}