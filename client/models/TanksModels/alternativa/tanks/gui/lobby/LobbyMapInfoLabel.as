package alternativa.tanks.gui.lobby {
	
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.widget.Label;
	
	public class LobbyMapInfoLabel extends Label {
		
		public function LobbyMapInfoLabel(text:String = "") {
			super(text, Align.LEFT);
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */		
		override protected function getSkinType():Class {
			return LobbyMapInfoLabel;
		}

	}
}