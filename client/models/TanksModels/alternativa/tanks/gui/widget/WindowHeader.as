package alternativa.tanks.gui.widget {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.widget.Label;
	
	
	public class WindowHeader extends Label {
		
		public function WindowHeader(text:String = "", align:uint = Align.LEFT) {
			super(text, align);
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */		
		override protected function getSkinType():Class {
			return WindowHeader;
		}

	}
}