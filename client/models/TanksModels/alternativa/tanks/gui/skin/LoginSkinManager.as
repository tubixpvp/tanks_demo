package alternativa.tanks.gui.skin {
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.Line;
	import alternativa.gui.widget.Text;
	import alternativa.gui.widget.Widget;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.window.WindowBase;
	import alternativa.skin.SkinManager;
	import alternativa.tanks.gui.lobby.LobbyImageButton;
	import alternativa.tanks.gui.login.LoginHeader;
	import alternativa.tanks.gui.login.LongInput;
	import alternativa.tanks.gui.login.ShortInput;
	import alternativa.tanks.gui.widget.WindowHeader;
	
	public class LoginSkinManager extends SkinManager {
		
		public function LoginSkinManager() {
			
			addSkin(new LoginWindowSkin(), WindowBase);
			addSkin(new WindowHeaderSkin(), WindowHeader);
			addSkin(new LobbyImageButtonSkin(), LobbyImageButton);
			addSkin(new LobbyImageButtonSkin(), ImageButton);
			addSkin(new LoginShortInputSkin(), ShortInput);
			addSkin(new LoginLongInputSkin(), LongInput);
			addSkin(new LoginLineSkin(), Line);
			addSkin(new LoginLabelSkin(), Label);
			addSkin(new LoginWidgetSkin(), Widget);
			addSkin(new LoginTextSkin(), Text);
			addSkin(new LoginHeaderSkin(), LoginHeader);
			
		}

	}
}