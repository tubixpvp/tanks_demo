package alternativa.gui.skin.window {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class WindowTitleSkin implements ISkin {
		
		public var normalNL:BitmapData;
		public var normalNC:BitmapData;
		public var normalNR:BitmapData;
		public var normalOL:BitmapData;
		public var normalOC:BitmapData;
		public var normalOR:BitmapData;
		public var normalPL:BitmapData;
		public var normalPC:BitmapData;
		public var normalPR:BitmapData;
		
		public var activeNL:BitmapData;
		public var activeNC:BitmapData;
		public var activeNR:BitmapData;
		public var activeOL:BitmapData;
		public var activeOC:BitmapData;
		public var activeOR:BitmapData;
		public var activePL:BitmapData;
		public var activePC:BitmapData;
		public var activePR:BitmapData;
		// Кнопка закрыть
		public var closeNN:BitmapData;
		public var closeNP:BitmapData;
		public var closeAN:BitmapData;
		public var closeAP:BitmapData;
		// Кнопка свернуть вниз
		public var minimizeNN:BitmapData;
		public var minimizeNP:BitmapData;
		public var minimizeAN:BitmapData;
		public var minimizeAP:BitmapData;
		// Кнопка развернуть
		public var maximizeNN:BitmapData;
		public var maximizeNP:BitmapData;
		public var maximizeAN:BitmapData;
		public var maximizeAP:BitmapData;
		// Кнопка свернуть до прежних размеров
		public var restoreNN:BitmapData;
		public var restoreNP:BitmapData;
		public var restoreAN:BitmapData;
		public var restoreAP:BitmapData;
		
		public var marginLeft:int;
		public var marginRight:int;
		
		public var space:int;
		public var controlButtonSpace:int;
		
		public var borderThickness:int;
		
		public function WindowTitleSkin(normalNL:BitmapData,
										normalNC:BitmapData,
										normalNR:BitmapData, 
				  						normalOL:BitmapData,
				  						normalOC:BitmapData,
				  						normalOR:BitmapData,
				   						normalPL:BitmapData,
				   						normalPC:BitmapData,
				   						normalPR:BitmapData,
				   						activeNL:BitmapData,
				   						activeNC:BitmapData,
				   						activeNR:BitmapData, 
				 						activeOL:BitmapData,
				 						activeOC:BitmapData,
				 						activeOR:BitmapData,
				 						activePL:BitmapData,
				 						activePC:BitmapData,
				 						activePR:BitmapData,
				 						closeNN:BitmapData,
				 						closeNP:BitmapData,
				 						closeAN:BitmapData,
				 						closeAP:BitmapData,
				 						minimizeNN:BitmapData,
										minimizeNP:BitmapData,
										minimizeAN:BitmapData,
										minimizeAP:BitmapData,
										maximizeNN:BitmapData,
										maximizeNP:BitmapData,
										maximizeAN:BitmapData,
										maximizeAP:BitmapData,
										restoreNN:BitmapData,
										restoreNP:BitmapData,
										restoreAN:BitmapData,
										restoreAP:BitmapData,
									    marginLeft:int,
									    marginRight:int,
									    space:int,
									    controlButtonSpace:int,
									    borderThickness:int) {
			this.normalNL = normalNL;
			this.normalNC = normalNC;
			this.normalNR = normalNR;
			this.normalOL = normalOL;
			this.normalOC = normalOC;
			this.normalOR = normalOR;
			this.normalPL = normalPL;
			this.normalPC = normalPC;
			this.normalPR = normalPR;
			
			this.activeNL = activeNL;
			this.activeNC = activeNC;
			this.activeNR = activeNR;
			this.activeOL = activeOL;
			this.activeOC = activeOC;
			this.activeOR = activeOR;
			this.activePL = activePL;
			this.activePC = activePC;
			this.activePR = activePR;
			
			this.closeNN = closeNN;
			this.closeNP = closeNP;
			this.closeAN = closeAN;
			this.closeAP = closeAP;
			
			this.minimizeNN = minimizeNN;
			this.minimizeNP = minimizeNP;
			this.minimizeAN = minimizeAN;
			this.minimizeAP = minimizeAP;
			
			this.maximizeNN = maximizeNN;
			this.maximizeNP = maximizeNP;
			this.maximizeAN = maximizeAN;
			this.maximizeAP = maximizeAP;
			
			this.restoreNN = restoreNN;
			this.restoreNP = restoreNP;
			this.restoreAN = restoreAN;
			this.restoreAP = restoreAP;
			
			this.marginLeft = marginLeft;
			this.marginRight = marginRight;
			
			this.space = space;
			this.controlButtonSpace = controlButtonSpace;
			
			this.borderThickness = borderThickness;
		}
		
	}
}