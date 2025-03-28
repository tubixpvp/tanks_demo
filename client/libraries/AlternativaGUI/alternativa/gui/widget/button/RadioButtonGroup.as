package alternativa.gui.widget.button {
	
	public class RadioButtonGroup extends ButtonGroup {
		
		// Выбранная кнопка
		protected var selectedButton:IButton;
		
		public function RadioButtonGroup() {
			super();
		}
		
		// Добавление кнопки в группу
		override public function addButton(button:IButton):void {
			super.addButton(button);
			if (buttonsList.length == 1) {
				selectedButton = button;
				ITriggerButton(selectedButton).selected = true;
			}
		}
		
		override public function removeButton(button:IButton):void {
			if (selectedButton == button) {
				var index:int = buttonsList.indexOf(button);
				if (index > 0) {
					selectedButton = buttonsList[index-1];
				} else {
					selectedButton = null;
				}
			}
			super.removeButton(button);
		}
		
		// Кнопка нажата
		override public function buttonPressed(button:IButton):void {
			if (button != selectedButton) {
				// Сброс старой выбранной кнопки
				if (selectedButton != null)
					ITriggerButton(selectedButton).selected = false;
				// Сохранение выбранной кнопки
				selectedButton = button;
			}
			// Функция вызвана не самой кнопкой
			if (ITriggerButton(selectedButton).selected != true) {
				ITriggerButton(selectedButton).selected = true;
			}
		}
		
		// Кнопку отжали
		override public function buttonExpressed(button:IButton):void {
			
		}
		
		// Кнопка выбрана (установили флаг без нажатия)
		public function buttonSelected(button:IButton):void {
			if (button != selectedButton) {
				// Сброс старой выбранной кнопки
				if (selectedButton != null) {
					ITriggerButton(selectedButton).selected = false;
				}
				// Сохранение выбранной кнопки
				selectedButton = button;
			}
		}
		
		// Сброс нажатой кнопки
		public function resetSelectedButton():void {
			ITriggerButton(selectedButton).selected = false;
			selectedButton = null;
		}
		
		
	}
}