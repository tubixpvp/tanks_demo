package alternativa.gui.base {
	
	/**
	 * Объект пустышка
	 */	
	public class Dummy extends GUIObject {
		
		public function Dummy(minWidth:int, minHeight:int, stretchableH:Boolean = false, stretchableV:Boolean = false) {
			super();
			minSize.x = minWidth;
			minSize.y = minHeight;			
			this.stretchableH = stretchableH;
			this.stretchableV = stretchableV;		
		}
		
	}
}