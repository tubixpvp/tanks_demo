package alternativa.tanks.gui.skin {
	import alternativa.gui.widget.Image;
	import alternativa.skin.SkinManager;
	import alternativa.tanks.gui.lobby.LobbyImageButton;
	import alternativa.tanks.gui.lobby.ScoresLabel;
	
	public class BattleFieldSkinManager extends SkinManager	{
		
		public function BattleFieldSkinManager() {
			addSkin(new BattleFieldImageSkin(), Image);
			addSkin(new LobbyImageButtonSkin(), LobbyImageButton);
			addSkin(new BattleFieldScoresLabelSkin(), ScoresLabel);
		}

	}
}