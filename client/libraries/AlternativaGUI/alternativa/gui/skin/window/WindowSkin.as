package alternativa.gui.skin.window {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	public class WindowSkin implements ISkin {
		
		// Графика окна
		public var cornerTL:BitmapData;
		public var cornerTR:BitmapData;
		public var cornerBL:BitmapData;
		public var cornerBR:BitmapData;
		public var edgeTC:BitmapData;
		public var edgeML:BitmapData;
		public var edgeMR:BitmapData;
		public var edgeBC:BitmapData;
		public var bgMC:BitmapData;
		
		public var cornerTLmargin:BitmapData;
		public var cornerTRmargin:BitmapData;
		public var cornerTLactive:BitmapData;
		public var cornerTRactive:BitmapData;
		public var edgeTCactive:BitmapData;
		
		// Кнопка закрыть
		public var closeNN:BitmapData;
		public var closeNP:BitmapData;
		public var closeAN:BitmapData;
		public var closeAP:BitmapData;
		// Кнопка свернуть
		public var minimizeNN:BitmapData;
		public var minimizeNP:BitmapData;
		public var minimizeAN:BitmapData;
		public var minimizeAP:BitmapData;
		// Кнопка развернуть
		public var maximizeNN:BitmapData;
		public var maximizeNP:BitmapData;
		public var maximizeAN:BitmapData;
		public var maximizeAP:BitmapData;
		// Кнопка восстановить размер
		public var restoreNN:BitmapData;
		public var restoreNP:BitmapData;
		public var restoreAN:BitmapData;
		public var restoreAP:BitmapData;
		
		public var containerMargin:int;
		public var titleMargin:int;
		public var titleSpace:int;
		public var controlButtonMarginLeft:int;
		public var controlButtonMarginTop:int;
		public var controlButtonMarginRight:int;
		public var controlButtonSpace:int;
		
		public var borderThickness:int;
		
		public function WindowSkin (cornerTL:BitmapData,
									cornerTLactive:BitmapData,
									cornerTLmargin:BitmapData,
									cornerTR:BitmapData,
									cornerTRactive:BitmapData,
									cornerTRmargin:BitmapData,
									cornerBL:BitmapData,
									cornerBR:BitmapData, 
								    edgeTC:BitmapData,
								    edgeTCactive:BitmapData,
								    edgeML:BitmapData,
								    edgeMR:BitmapData,
								    edgeBC:BitmapData,
								    bgMC:BitmapData,
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
								    containerMargin:int,
								    titleMargin:int,
								    titleSpace:int,
								    controlButtonMarginLeft:int,
								    controlButtonMarginTop:int,
								    controlButtonMarginRight:int,
								    controlButtonSpace:int,
								    borderThickness:int) {
			
			this.cornerTL = cornerTL;
			this.cornerTR = cornerTR;
			this.cornerBL = cornerBL;
			this.cornerBR = cornerBR;
			this.edgeTC = edgeTC;
			this.edgeML = edgeML;
			this.edgeMR = edgeMR;
			this.edgeBC = edgeBC;
			this.bgMC = bgMC;
			
			this.cornerTLmargin = cornerTLmargin;
			this.cornerTRmargin = cornerTRmargin;
			this.cornerTLactive = cornerTLactive;
			this.cornerTRactive = cornerTRactive;
			this.edgeTCactive = edgeTCactive;
			
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
			
			this.containerMargin = containerMargin;
			this.titleMargin = titleMargin;
			this.titleSpace = titleSpace;
			this.controlButtonMarginLeft = controlButtonMarginLeft;
			this.controlButtonMarginTop = controlButtonMarginTop;
			this.controlButtonMarginRight = controlButtonMarginRight;
			this.controlButtonSpace = controlButtonSpace;
			
			this.borderThickness = borderThickness;
		}
		
	}
}