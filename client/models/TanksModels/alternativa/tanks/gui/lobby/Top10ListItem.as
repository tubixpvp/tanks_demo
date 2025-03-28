package alternativa.tanks.gui.lobby {
	
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
		
	public class Top10ListItem extends Container {
		
		private var nameLabel:Top10Label;
		private var scoresLabel:LobbyTop10ScoresLabel;
		
		public function Top10ListItem(name:String, scores:int)	{
			super(0, 0, 0, 0);
			
			stretchableH = true;
			
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE);
			nameLabel = new Top10Label(nameToString(name));
			nameLabel.stretchableH = true;
			scoresLabel = new LobbyTop10ScoresLabel(scoresToString(scores));
			
			addObject(nameLabel);
			addObject(scoresLabel);
		}
		
		public function setName(name:String):void {
			nameLabel.text = nameToString(name);
		}
		public function setScore(score:int):void {
			scoresLabel.text = scoresToString(score);
		}
		
		private function nameToString(value:String):String {
			var result:String;
			if (value.length > 12) {
				result = value.substring(0, 11) + "...";
			} else {
				result = value;
			}
			return result;
			//return value.toLocaleUpperCase();
		}
		private function scoresToString(value:int):String {
			return value.toString();
		}

	}
}