package alternativa.gui.chat.skin {
	import alternativa.gui.chat.ChatListItemMessage;
	import alternativa.gui.chat.SendButton;
	import alternativa.gui.container.scrollBox.ScrollBar;
	import alternativa.gui.container.scrollBox.ScrollBox;
	import alternativa.gui.container.scrollBox.Scroller;
	import alternativa.gui.widget.Image;
	import alternativa.gui.widget.Input;
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.Text;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.window.panel.ResizeablePanelBase;
	import alternativa.skin.SkinManager;
	
	
	public class ChatSkinManager extends SkinManager {
		
		public function ChatSkinManager() {
			
			addSkin(new ChatPanelSkin(), ResizeablePanelBase);
			addSkin(new ChatScrollBoxSkin(), ScrollBox);
			addSkin(new ChatScrollBarSkin(), ScrollBar);
			addSkin(new ChatScrollerSkin(), Scroller);
			addSkin(new ChatImageSkin(), Image);
			addSkin(new ChatImageButtonSkin(), ImageButton);
			addSkin(new SendButtonSkin(), SendButton);
			addSkin(new ChatLabelSkin(), Label);
			addSkin(new ChatTextSkin(), Text);
			addSkin(new ChatInputSkin(), Input);
			addSkin(new ChatListItemMessageSkin(), ChatListItemMessage);
			
		}

	}
}