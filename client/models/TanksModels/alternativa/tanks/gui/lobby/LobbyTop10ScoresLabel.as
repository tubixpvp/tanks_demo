package alternativa.tanks.gui.lobby {
	
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.widget.Label;
	
	import flash.text.AntiAliasType;
	
	public class LobbyTop10ScoresLabel extends Label {
		
		public function LobbyTop10ScoresLabel(text:String = "") {
			super(text, Align.LEFT);
			
			//tf.antiAliasType = AntiAliasType.NORMAL;
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */		
		override protected function getSkinType():Class {
			return LobbyTop10ScoresLabel;
		}

	}
}