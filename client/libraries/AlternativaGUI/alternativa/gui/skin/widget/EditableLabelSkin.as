package alternativa.gui.skin.widget {
	import alternativa.skin.ISkin;
	
	public class EditableLabelSkin implements ISkin {
		
		public var selectionColor:uint;
		public var selectionAlpha:Number;
		public var selectionBorder:Boolean;
		public var selectionBorderColor:uint;
		
		public var tfSelectionBorder:Boolean;
		public var tfSelectionBorderColor:uint;
		
		public var selectionMargin:int;
		
		public function EditableLabelSkin(selectionColor:uint,
										  selectionAlpha:Number,
										  selectionBorder:Boolean,
										  selectionBorderColor:uint,
										  tfSelectionBorder:Boolean,
										  tfSelectionBorderColor:uint,
										  selectionMargin:int) {
										  	
			this.selectionColor = selectionColor;
			this.selectionAlpha = selectionAlpha;
			this.selectionBorder = selectionBorder;
			this.selectionBorderColor = selectionBorderColor;
			
			this.tfSelectionBorder = tfSelectionBorder;
			this.tfSelectionBorderColor = tfSelectionBorderColor;
			this.selectionMargin = selectionMargin;
		}			
		
	}
}