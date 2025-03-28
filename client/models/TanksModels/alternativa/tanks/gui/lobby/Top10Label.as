package alternativa.tanks.gui.lobby {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.widget.Label;
	
	
	public class Top10Label extends Label {
		
		public function Top10Label(text:String = "") {
			super(text, Align.LEFT);
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */		
		override protected function getSkinType():Class {
			return Top10Label;
		}

	}
}