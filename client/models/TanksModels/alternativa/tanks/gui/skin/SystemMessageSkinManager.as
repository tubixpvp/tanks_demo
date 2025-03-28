package alternativa.tanks.gui.skin {
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.Text;
	import alternativa.gui.widget.Widget;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.window.WindowBase;
	import alternativa.skin.SkinManager;
	
	public class SystemMessageSkinManager extends SkinManager {
		
		public function SystemMessageSkinManager() {
			
			addSkin(new LoginWindowSkin(), WindowBase);
			addSkin(new LoginWidgetSkin(), Widget);
			addSkin(new LobbyImageButtonSkin(), ImageButton);
			addSkin(new SystemMessageTextSkin(), Text);
			addSkin(new SystemMessageLabelSkin(), Label);
			
		}

	}
}