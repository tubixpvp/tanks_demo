package alternativa.tanks.gui.skin {
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.Text;
	import alternativa.gui.window.WindowBase;
	import alternativa.skin.SkinManager;
	import alternativa.tanks.gui.lobby.LobbyImageButton;
	import alternativa.tanks.gui.login.LongInput;
	import alternativa.tanks.gui.login.ShortInput;
	import alternativa.tanks.gui.widget.WindowHeader;
	
	
	public class RegistrationSkinManager extends SkinManager {
		
		public function RegistrationSkinManager() {
			
			addSkin(new LoginWindowSkin(), WindowBase);
			addSkin(new WindowHeaderSkin(), WindowHeader);
			addSkin(new LoginLongInputSkin(), LongInput);
			addSkin(new LoginShortInputSkin(), ShortInput);
			addSkin(new LoginLabelSkin(), Label);
			addSkin(new RegistrationTextSkin(), Text);
			addSkin(new LobbyImageButtonSkin(), LobbyImageButton);
			
		}

	}
}