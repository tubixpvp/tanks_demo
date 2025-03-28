package alternativa.tanks.gui.skin {
	import alternativa.gui.skin.widget.button.TriggerButtonSkin;
	
	import flash.display.BitmapData;
	
	public class LobbyRadioButtonSkin extends TriggerButtonSkin	{
		
		[Embed(source="../../resources/lobby-radiobutton_unselected.png")] private static const bitmapUnselected:Class;
		[Embed(source="../../resources/lobby-radiobutton_selected.png")] private static const bitmapSelected:Class;
		//[Embed(source="../../resources/lobby-radiobutton_locked_unselected.png")] private static const bitmapLockedUnselected:Class;
		//[Embed(source="../../resources/lobby-radiobutton_locked_selected.png")] private static const bitmapLockedSelected:Class;

		private static const unselected:BitmapData = new bitmapUnselected().bitmapData;
		private static const selected:BitmapData = new bitmapSelected().bitmapData;
		//private static const lockedUnselected:BitmapData = new bitmapLockedUnselected().bitmapData;
		//private static const lockedSelected:BitmapData = new bitmapLockedSelected().bitmapData;
		
		private static const space:int = 0;
		
		
		public function LobbyRadioButtonSkin() {
			super(LobbyRadioButtonSkin.unselected,
				  LobbyRadioButtonSkin.selected,
				  LobbyRadioButtonSkin.unselected,
				  LobbyRadioButtonSkin.selected,
				  LobbyRadioButtonSkin.space);
		}

	}
}