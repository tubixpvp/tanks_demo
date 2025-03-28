package alternativa.gui.widget.button {
	/**
	* Квадратик с галочкой... или без галочки
	*/	
	public class CheckBox extends TriggerButton {
		
		public function CheckBox(text:String = "", textColor:int = -1) {
			super(text, textColor);
		}
		
		// Определение класса для скинования
		override protected function getSkinType():Class {
			return CheckBox;
		}
		
		/**
		 * Управление нажатием 
		 */	
		override public function set pressed(value:Boolean):void {
			_pressed = value;
			
			if (_pressed) {
				selected = !_selected;
			}
			// Генерация события
			if (_pressed)
				dispatchEvent(new ButtonEvent(ButtonEvent.PRESS, this));
			else
				dispatchEvent(new ButtonEvent(ButtonEvent.EXPRESS, this));
			
			if (group != null) {
				if (_pressed) {
					group.buttonPressed(this);
				} else {
					group.buttonExpressed(this);
				}
			}
		}
		
	}
}