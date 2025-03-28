package alternativa.tanks.gui.scores {
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.tanks.gui.lobby.ScoresLabel;
	import alternativa.tanks.gui.skin.BattleFieldSkinManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	public class ScoresPanel extends Container {
		
		[Embed(source="../../resources/scores_panel.png")] private static const bitmapPanel:Class;
		private static const panelBd:BitmapData = new bitmapPanel().bitmapData;
		
		private var panel:Bitmap;
		private var scoresLabel:ScoresLabel;
		
		public function ScoresPanel() {
			super (0, 0, 0, 0);
			
			minSize.x = 102;
			minSize.y = 42;
			
			panel = new Bitmap(panelBd);
			addChildAt(panel, 0);
			
			skinManager = new BattleFieldSkinManager();
			
			this.rootObject = rootObject;
			
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE);
			
			scoresLabel = new ScoresLabel("00000000000");
			scoresLabel.stretchableH = true;
			addObject(scoresLabel);
			
			draw(computeSize(computeMinSize()));
		}
		
		public function set scores(value:int):void {
			if (value < 0) {
				value = 0;
			}
			if (value > 99999999999) {
				value = 99999999999;
			}
			var s:String = value.toString();
			while (s.length < 11) {
				s = "0" + s;
			}
			scoresLabel.text = s;
		}

	}
}