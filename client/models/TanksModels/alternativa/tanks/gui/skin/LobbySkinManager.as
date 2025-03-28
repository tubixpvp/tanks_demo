package alternativa.tanks.gui.skin {
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.widget.button.RadioButton;
	import alternativa.gui.window.WindowBase;
	import alternativa.skin.SkinManager;
	import alternativa.tanks.gui.lobby.LobbyHeader;
	import alternativa.tanks.gui.lobby.LobbyImageButton;
	import alternativa.tanks.gui.lobby.LobbyMapIcon;
	import alternativa.tanks.gui.lobby.LobbyMapIconLabel;
	import alternativa.tanks.gui.lobby.LobbyMapInfoLabel;
	import alternativa.tanks.gui.lobby.LobbyTop10ScoresLabel;
	import alternativa.tanks.gui.lobby.ScoresLabel;
	import alternativa.tanks.gui.lobby.Top10Label;
	import alternativa.tanks.gui.login.LoginHeader;
	
	public class LobbySkinManager extends SkinManager {
		
		public function LobbySkinManager() {
			
			addSkin(new LoginWindowSkin(), WindowBase);
			addSkin(new LobbyHeaderSkin(), LobbyHeader);
			addSkin(new LobbyLabelSkin(), Label);
			addSkin(new LobbyTop10ScoresSkin(), LobbyTop10ScoresLabel);
			addSkin(new LobbyMapInfoLabelSkin(), LobbyMapInfoLabel);
			addSkin(new LobbyMapIconLabelSkin(), LobbyMapIconLabel);
			addSkin(new LobbyTop10LabelSkin(), Top10Label);
			addSkin(new ScoresLabelSkin(), ScoresLabel);
			addSkin(new LobbyImageButtonSkin(), LobbyImageButton);
			addSkin(new LobbyImageButtonSkin(), ImageButton);
			addSkin(new LobbyMapIconSkin(), LobbyMapIcon);
			addSkin(new LobbyRadioButtonSkin(), RadioButton);
			addSkin(new LoginHeaderSkin(), LoginHeader);
			
		}

	}
}