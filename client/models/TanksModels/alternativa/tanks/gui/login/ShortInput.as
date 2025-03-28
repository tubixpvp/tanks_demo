package alternativa.tanks.gui.login {
	import alternativa.gui.widget.Input;
	
	public class ShortInput extends Input {
		
		public function ShortInput(text:String = "") {
			super(text, 60);
			minSize.x = 137;
		}
		
		override protected function getSkinType():Class {
			return ShortInput;
		}

	}
}