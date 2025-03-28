package alternativa.tanks.gui.lobby {
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	
	import projects.tanks.models.lobby.struct.TopRecord;
	
	
	public class Top10List extends Container {
		
		public function Top10List() {
			super(10, 25, 10, 15);
			
			minSize.x = 178;
			minSize.y = 243;
			
			layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.TOP, 8);
		}
		
		public function addItem(name:String, scores:int):void {
			addObject(new Top10ListItem(name, scores));
		}
		
		public function setItemsData(data:Array):void {
			for (var i:int = 0; i < objects.length; i++) {
				Top10ListItem(objects[i]).setName(TopRecord(data[i]).name);
				Top10ListItem(objects[i]).setScore(TopRecord(data[i]).score);
			}
		}
		
	}
}