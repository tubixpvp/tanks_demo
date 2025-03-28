package alternativa.tanks.gui.lobby {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.widget.Label;
	
	
	public class ScoresLabel extends Label {
		
		public function ScoresLabel(text:String = "") {
			super(text, Align.CENTER);
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */		
		override protected function getSkinType():Class {
			return ScoresLabel;
		}
		
	}
}