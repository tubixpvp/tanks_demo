package alternativa.tanks.gui.skin {
	import alternativa.gui.widget.Label;
	import alternativa.skin.SkinManager;
	
	public class RadarSkinManager extends SkinManager {
		
		public function RadarSkinManager() {
			addSkin(new RadarLabelSkin(), Label);
		}

	}
}