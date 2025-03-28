package alternativa.gui.skin.widget.list {
	import alternativa.skin.ISkin;
	
	 /**
	* Скин для элемента списка
	*/
	public class ListItemSkin implements ISkin {
		
		/**
		 * Цвет области выделения элемента списка
		 */		
		public var selectionColor:uint;
		/**
		 * Прозрачность области выделения при наведении на невыделенный элемент списка
		 */			
		public var selectionAlphaOver:Number;
		/**
		 * Прозрачность области выделения при наведении на выделенный элемент списка
		 */		
		public var selectionAlphaOverSelected:Number;
		/**
		 * Прозрачность области выделения выделенного элемента списка
		 */
		public var selectionAlphaSelected:Number;
		
		
		/**
		 * @param selectionColor цвет области выделения элемента списка
		 * @param selectionAlphaOver прозрачность области выделения при наведении на невыделенный элемент списка
		 * @param selectionAlphaOverSelected прозрачность области выделения при наведении на выделенный элемент списка
		 * @param selectionAlphaSelected прозрачность области выделения выделенного элемента списка
		 */		
		public function ListItemSkin(selectionColor:uint,
									 selectionAlphaOver:Number,
									 selectionAlphaOverSelected:Number,
									 selectionAlphaSelected:Number) {
									 	
			this.selectionColor = selectionColor;
			this.selectionAlphaOver = selectionAlphaOver;
			this.selectionAlphaOverSelected = selectionAlphaOverSelected;
			this.selectionAlphaSelected = selectionAlphaSelected;
		}
	
	}
}