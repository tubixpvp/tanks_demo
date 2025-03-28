package alternativa.gui.widget.comboBox {
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.widget.list.List;
	import alternativa.gui.widget.list.ListRendererParams;
	
	public class ButtonComboBox extends ComboBox {
		
		private var openButton:ImageButton;
		
		public function ButtonComboBox(selectList:List, ListItemClass:Class, selectedItemRendererParams:ListRendererParams) {
			super(selectList, ListItemClass, selectedItemRendererParams);
			
			openButton = new ImageButton(0, 0);
			addObject(openButton);
			
			openButton.addEventListener(ButtonEvent.CLICK, onOpenButtonClick);
		}
		
		override public function updateSkin():void {
			super.updateSkin();
			
			openButton.normalBitmap = skin.buttonNormal;
			openButton.overBitmap = skin.buttonOver;
			openButton.pressBitmap = skin.buttonPress;
			openButton.lockBitmap = skin.buttonLock;
			
		}
		
		override public function set locked(value:Boolean):void {
			super.locked = value;
			openButton.locked = value;
		}
		
		private function onOpenButtonClick(e:ButtonEvent):void {
			if (opened) {
				hideList();
			} else {
				showList();
			}
		}
		
	}
}