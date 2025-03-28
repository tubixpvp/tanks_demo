package alternativa.gui.widget.button {
	
	/**
	 * Логическое объединение кнопок
	 */	
	public class ButtonGroup {
		
		/**
	 	 * Список кнопок
	 	 */
		protected var buttonsList:Array;
		
		
		public function ButtonGroup() {
			buttonsList = new Array();
		}
		
		/**
	 	 * Добавление кнопки в группу
	 	 * @param button кнопка
	 	 */
		public function addButton(button:IButton):void {
			buttonsList.push(button);
			button.group = this;		
		}
		public function removeButton(button:IButton):void {
			buttonsList.splice(buttonsList.indexOf(button), 1);
			button.group = null;		
		}	
		
		/**
		 * Кнопка нажата
		 * @param button кнопка
		 */		
		public function buttonPressed(button:IButton):void {}
		
		/**
		 * Кнопка отжата
		 * @param button кнопка
		 */
		public function buttonExpressed(button:IButton):void {}
		
		/**
		 * Количество кнопок в группе
		 */		
		public function get buttonsNum():int {
			return buttonsList.length;
		}
		
	}
}