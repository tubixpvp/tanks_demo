package alternativa.gui.chat.skin {
	import alternativa.gui.skin.window.WindowSkin;
	
	import flash.display.BitmapData;
	
	public class ChatPanelSkin extends WindowSkin {
		
		/*[Embed(source="../../resources/window_tl.png")] private static const bitmapTL:Class;
		[Embed(source="../../resources/window_tl_active.png")] private static const bitmapTLactive:Class;
		[Embed(source="../../resources/window_tl_margin.png")] private static const bitmapTLmargin:Class;
		[Embed(source="../../resources/window_ml.png")] private static const bitmapML:Class;
		[Embed(source="../../resources/window_bl.png")] private static const bitmapBL:Class;
		[Embed(source="../../resources/window_tc.png")] private static const bitmapTC:Class;
		[Embed(source="../../resources/window_tc_active.png")] private static const bitmapTCactive:Class;
		[Embed(source="../../resources/window_mc.png")] private static const bitmapMC:Class;
		[Embed(source="../../resources/window_bc.png")] private static const bitmapBC:Class;
		[Embed(source="../../resources/window_tr.png")] private static const bitmapTR:Class;
		[Embed(source="../../resources/window_tr_active.png")] private static const bitmapTRactive:Class;
		[Embed(source="../../resources/window_tr_margin.png")] private static const bitmapTRmargin:Class;
		[Embed(source="../../resources/window_mr.png")] private static const bitmapMR:Class;
		[Embed(source="../../resources/window_br.png")] private static const bitmapBR:Class;
		
		[Embed(source="../../resources/title_close_n.png")] private static const bitmapCloseNormal:Class;
		[Embed(source="../../resources/title_close_a.png")] private static const bitmapCloseActive:Class;
		[Embed(source="../../resources/title_minimize_n.png")] private static const bitmapMinimizeNormal:Class;
		[Embed(source="../../resources/title_minimize_a.png")] private static const bitmapMinimizeActive:Class;
		[Embed(source="../../resources/title_maximize_n.png")] private static const bitmapMaximizeNormal:Class;
		[Embed(source="../../resources/title_maximize_a.png")] private static const bitmapMaximizeActive:Class;
		[Embed(source="../../resources/title_restore_n.png")] private static const bitmapRestoreNormal:Class;
		[Embed(source="../../resources/title_restore_a.png")] private static const bitmapRestoreActive:Class;
		
		private static const cornerTL:BitmapData = new bitmapTL().bitmapData;
		private static const cornerTLactive:BitmapData = new bitmapTLactive().bitmapData;
		private static const cornerTLmargin:BitmapData = new bitmapTLmargin().bitmapData;
		private static const cornerTR:BitmapData = new bitmapTR().bitmapData;
		private static const cornerTRactive:BitmapData = new bitmapTRactive().bitmapData;
		private static const cornerTRmargin:BitmapData = new bitmapTRmargin().bitmapData;
		private static const cornerBL:BitmapData = new bitmapBL().bitmapData;
		private static const cornerBR:BitmapData = new bitmapBR().bitmapData;
		private static const edgeTC:BitmapData = new bitmapTC().bitmapData;
		private static const edgeTCactive:BitmapData = new bitmapTCactive().bitmapData;
		private static const edgeML:BitmapData = new bitmapML().bitmapData;
		private static const edgeMR:BitmapData = new bitmapMR().bitmapData;
		private static const edgeBC:BitmapData = new bitmapBC().bitmapData;
		private static const bgMC:BitmapData = new bitmapMC().bitmapData;
		
		private static const closeNormal:BitmapData = new bitmapCloseNormal().bitmapData;
		private static const closeActive:BitmapData = new bitmapCloseActive().bitmapData;
		private static const minimizeNormal:BitmapData = new bitmapMinimizeNormal().bitmapData;
		private static const minimizeActive:BitmapData = new bitmapMinimizeActive().bitmapData;
		private static const maximizeNormal:BitmapData = new bitmapMaximizeNormal().bitmapData;
		private static const maximizeActive:BitmapData = new bitmapMaximizeActive().bitmapData;
		private static const restoreNormal:BitmapData = new bitmapRestoreNormal().bitmapData;
		private static const restoreActive:BitmapData = new bitmapRestoreActive().bitmapData;
		*/
		
		[Embed(source="resources/emptyBitmap.png")] private static const emptyBitmap:Class;
		private static const cornerTL:BitmapData = new emptyBitmap().bitmapData;
		private static const cornerTLactive:BitmapData = new emptyBitmap().bitmapData;
		private static const cornerTLmargin:BitmapData = new emptyBitmap().bitmapData;
		private static const cornerTR:BitmapData = new emptyBitmap().bitmapData;
		private static const cornerTRactive:BitmapData = new emptyBitmap().bitmapData;
		private static const cornerTRmargin:BitmapData = new emptyBitmap().bitmapData;
		private static const cornerBL:BitmapData = new emptyBitmap().bitmapData;
		private static const cornerBR:BitmapData = new emptyBitmap().bitmapData;
		private static const edgeTC:BitmapData = new emptyBitmap().bitmapData;
		private static const edgeTCactive:BitmapData = new emptyBitmap().bitmapData;
		private static const edgeML:BitmapData = new emptyBitmap().bitmapData;
		private static const edgeMR:BitmapData = new emptyBitmap().bitmapData;
		private static const edgeBC:BitmapData = new emptyBitmap().bitmapData;
		private static const bgMC:BitmapData = new emptyBitmap().bitmapData;
		
		private static const closeNormal:BitmapData = new emptyBitmap().bitmapData;
		private static const closeActive:BitmapData = new emptyBitmap().bitmapData;
		private static const minimizeNormal:BitmapData = new emptyBitmap().bitmapData;
		private static const minimizeActive:BitmapData = new emptyBitmap().bitmapData;
		private static const maximizeNormal:BitmapData = new emptyBitmap().bitmapData;
		private static const maximizeActive:BitmapData = new emptyBitmap().bitmapData;
		private static const restoreNormal:BitmapData = new emptyBitmap().bitmapData;
		private static const restoreActive:BitmapData = new emptyBitmap().bitmapData;
		
		private static const containerMargin:int = 7;
		private static const titleMargin:int = 0;
		private static const titleSpace:int = 1;
		private static const controlButtonMarginLeft:int = 4;
		private static const controlButtonMarginTop:int = 4;
		private static const controlButtonMarginRight:int = 4;
		private static const controlButtonSpace:int = 2;
		
		private static const borderThickness:int = 0;
		
		public function ChatPanelSkin() {
			super(ChatPanelSkin.cornerTL,
				  ChatPanelSkin.cornerTLactive,
				  ChatPanelSkin.cornerTLmargin,
				  ChatPanelSkin.cornerTR,
				  ChatPanelSkin.cornerTRactive,
				  ChatPanelSkin.cornerTRmargin,
				  ChatPanelSkin.cornerBL,
				  ChatPanelSkin.cornerBR, 
				  ChatPanelSkin.edgeTC,
				  ChatPanelSkin.edgeTCactive,
				  ChatPanelSkin.edgeML,
				  ChatPanelSkin.edgeMR,
				  ChatPanelSkin.edgeBC,
				  ChatPanelSkin.bgMC,
				  ChatPanelSkin.closeNormal,
				  ChatPanelSkin.closeNormal,
				  ChatPanelSkin.closeActive,
				  ChatPanelSkin.closeActive,
				  ChatPanelSkin.minimizeNormal,
				  ChatPanelSkin.minimizeNormal,
				  ChatPanelSkin.minimizeActive,
				  ChatPanelSkin.minimizeActive,
				  ChatPanelSkin.maximizeNormal,
				  ChatPanelSkin.maximizeNormal,
				  ChatPanelSkin.maximizeActive,
				  ChatPanelSkin.maximizeActive,
				  ChatPanelSkin.restoreNormal,
				  ChatPanelSkin.restoreNormal,
				  ChatPanelSkin.restoreActive,
				  ChatPanelSkin.restoreActive,
				  ChatPanelSkin.containerMargin,
				  ChatPanelSkin.titleMargin,
				  ChatPanelSkin.titleSpace,
				  ChatPanelSkin.controlButtonMarginLeft,
				  ChatPanelSkin.controlButtonMarginTop,
				  ChatPanelSkin.controlButtonMarginRight,
				  ChatPanelSkin.controlButtonSpace,
				  ChatPanelSkin.borderThickness);
		}

	}
}