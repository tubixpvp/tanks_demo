package alternativa.gui.widget.button {
	/**
	* Кругляш с точечкой... или без точечки
	*/	
	public class RadioButton extends TriggerButton {
		
		public function RadioButton(text:String = "", textColor:int = -1) {
			super(text, textColor);
		}
		
		// Определение класса для скинования
		override protected function getSkinType():Class {
			return RadioButton;
		}
		
		/**
		 * Управление нажатием 
		 */	
		override public function set pressed(value:Boolean):void {
			_pressed = value;
			
			if (!_selected) {
				selected = true;
			}
			
			if (group != null) {
				if (_pressed) {
					group.buttonPressed(this);
				} else {
					group.buttonExpressed(this);
				}
			}
		}
		
		// Флаг выбранности
		override public function set selected(value:Boolean):void {
			if (group != null) {
				if (_selected) {
					if (value == false) {
						_selected = value;
						RadioButtonGroup(group).resetSelectedButton();
					}
				} else {
					if (value == true) {
						_selected = value;
						RadioButtonGroup(group).buttonPressed(this);
					}
				}
			}
			if (isSkined) {
				switchState();	
				draw(currentSize);
			}
		}
		
	}
}