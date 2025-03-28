package alternativa.tanks.gui.lobby {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.widget.Label;
	
	
	public class LobbyHeader extends Label {
		
		public function LobbyHeader(text:String = "", align:uint = Align.LEFT) {
			super(text, align);
		}
		
		override protected function getSkinType():Class {
			return LobbyHeader;
		}

	}
}