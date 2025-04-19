package alternativa.gui.chat {
	import alternativa.gui.widget.Input;
	
	
	public class TextInput extends Input {
		
		public function TextInput()	{
			super("", 100);
			stretchableH = true;
		}
		
		override protected function focus():void {}
		
		override protected function unfocus():void {}

	}
}