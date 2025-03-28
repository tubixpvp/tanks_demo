package alternativa.gui.window {
	import alternativa.gui.widget.button.ImageButton;
	
	/**
	 * 
	 * Кнопка управления окном, принадлежащая окну или заголовку
	 * 
	 */	
	public class WindowTitleButton extends ImageButton {
		
		public function WindowTitleButton() {
			super(0, 1);
		}
		
		// Фокусировка
		override protected function focus():void {}
		// Расфокусировка
		override protected function unfocus():void {}

	}
}