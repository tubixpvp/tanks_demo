package alternativa.tanks.gui.login {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.widget.Label;
	
	
	public class LoginHeader extends Label {
		
		public function LoginHeader(text:String = "", align:uint = Align.LEFT) {
			super(text, align);
		}
		
		override protected function getSkinType():Class {
			return LoginHeader;
		}

	}
}