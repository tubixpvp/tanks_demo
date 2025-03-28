package alternativa.tanks.gui.login {
	import alternativa.gui.widget.Input;
	
	public class LongInput extends Input {
		
		public function LongInput(text:String = "")	{
			super(text, 60);
			minSize.x = 197;
		}
		
		override protected function getSkinType():Class {
			return LongInput;
		}

	}
}