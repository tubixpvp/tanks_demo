package alternativa.gui.skin.window.panel {
	import alternativa.gui.skin.window.WindowTitleSkin;
	import flash.display.BitmapData;
	import flash.text.TextFormat;
	
	public class PanelTitleSkin extends WindowTitleSkin	{
		
		// Иконка сворачивания
		public var iconMinimize:BitmapData;
		// Иконка разворачивания
		public var iconMaximize:BitmapData;
		
		public function PanelTitleSkin(normalNL:BitmapData,
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
				 					   iconMinimize:BitmapData,
				 					   iconMaximize:BitmapData,
									   marginLeft:int,
									   marginRight:int,
									   space:int,
									   controlButtonSpace:int,
									   borderThickness:int) {
			super (normalNL,
				   normalNC,
				   normalNR,
				   normalNL,
				   normalNC,
				   normalNR,
				   normalNL,
				   normalNC,
				   normalNR,
				   normalNL,
				   normalNC,
				   normalNR, 
				   normalNL,
				   normalNC,
				   normalNR,
				   normalNL,
				   normalNC,
				   normalNR,
				   closeNN,
				   closeNP,
				   closeAN,
				   closeAP,
				   minimizeNN,
				   minimizeNP,
				   minimizeAN,
				   minimizeAP,
				   maximizeNN,
				   maximizeNP,
				   maximizeAN,
				   maximizeAP,
				   restoreNN,
				   restoreNP,
				   restoreAN,
				   restoreAP,
				   marginLeft,
				   marginRight,
				   space,
				   controlButtonSpace,
				   borderThickness);
			
			this.iconMinimize = iconMinimize;
			this.iconMaximize = iconMaximize;
		}
	}
}