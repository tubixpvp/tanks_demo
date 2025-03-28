package alternativa.tanks.gui.lifelevel {
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.init.Main;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import alternativa.osgi.service.console.IConsoleService;
	
	
	public class LifeLevelPanel extends Container {
		
		[Embed(source="../../resources/lifelevel_panel.png")] private static const bitmapPanel:Class;
		private static const panelBd:BitmapData = new bitmapPanel().bitmapData;
		
		private var panel:Bitmap;
		private var lamps:Array;
		
		public function LifeLevelPanel(lampNumber:int) {
			super (5, 0, 5, 9);
			
			if (lampNumber > 4) {
				lampNumber == 4;
			}
			if (lampNumber < 0) {
				lampNumber == 0;
			}
			
			minSize.x = 42;
			minSize.y = 102;
			
			panel = new Bitmap(panelBd);
			addChildAt(panel, 0);
			
			layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.BOTTOM);
						
			lamps = new Array();
			var lamp:LifeLevelLamp;
			for (var i:int = 0; i < lampNumber; i++) {
				lamp = new LifeLevelLamp();
				addObject(lamp);
				lamps.unshift(lamp);
			}
		}
		
		public function set level(value:int):void {
			(Main.osgi.getService(IConsoleService) as IConsoleService).writeToConsole("LifeLevelPanel set level: " + value);
			
			if (value > 4) {
				value == 4;
			}
			if (value < 0) {
				value == 0;
			}
			var lamp:LifeLevelLamp;
			switch (lamps.length) {
				case 4:
					// Тяжелый танк
					switch (value) {
						case 4:
							for (var i:int = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								lamp.color = LifeLevelLamp.COLOR_GREEN;
								lamp.power = true;
								lamp.blink = 0;
							}
							break;
						case 3:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								if (i == 3) {
									lamp.power = false;
								} else {
									lamp.color = LifeLevelLamp.COLOR_GREEN;
									lamp.power = true;
								}
								lamp.blink = 0;
							}
							break;
						case 2:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								if (i > 1) {
									lamp.power = false;
								} else if (i == 1) {
									lamp.color = LifeLevelLamp.COLOR_GREEN;
									lamp.power = true;
								} else {
									lamp.color = LifeLevelLamp.COLOR_YELLOW;
									lamp.power = true;
								}
								lamp.blink = 0;
							}
							break;
						case 1:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								if (i > 0) {
									lamp.power = false;
									lamp.blink = 0;
								} else {
									lamp.color = LifeLevelLamp.COLOR_RED;
									lamp.power = true;
									lamp.blink = 500;
								}
							}
							break;
						case 0:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								lamp.power = false;
								lamp.blink = 0;
							}
							break;
					}
					break;
				case 3:
					// Средний танк
					switch (value) {
						case 3:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								lamp.color = LifeLevelLamp.COLOR_GREEN;
								lamp.power = true;
								lamp.blink = 0;
							}
							break;
						case 2:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								if (i > 1) {
									lamp.power = false;
								} else if (i == 1) {
									lamp.color = LifeLevelLamp.COLOR_GREEN;
									lamp.power = true;
								} else {
									lamp.color = LifeLevelLamp.COLOR_YELLOW;
									lamp.power = true;
								}
								lamp.blink = 0;
							}
							break;
						case 1:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								if (i > 0) {
									lamp.power = false;
									lamp.blink = 0;
								} else {
									lamp.color = LifeLevelLamp.COLOR_RED;
									lamp.power = true;
									lamp.blink = 500;
								}
							}
							break;
						case 0:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								lamp.power = false;
								lamp.blink = 0;
							}
							break;
					}						
					break;
				case 2:
					// Легкий танк
					// Средний танк
					switch (value) {
						case 2:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								lamp.color = LifeLevelLamp.COLOR_GREEN;
								lamp.power = true;
								lamp.blink = 0;
							}
							break;
						case 1:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								if (i == 1) {
									lamp.power = false;
									lamp.blink = 0;
								} else {
									lamp.color = LifeLevelLamp.COLOR_RED;
									lamp.power = true;
									lamp.blink = 500;
								}
							}
							break;
						case 0:
							for (i = 0; i < lamps.length; i++) {
								lamp = LifeLevelLamp(lamps[i]);
								lamp.power = false;
								lamp.blink = 0;
							}
							break;
					}
					break;
			}
		}

	}
}