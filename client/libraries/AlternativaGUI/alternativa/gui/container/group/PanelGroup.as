package alternativa.gui.container.group {
	import alternativa.gui.container.Container;
	import alternativa.gui.skin.window.WindowSkin;
	import alternativa.gui.window.WindowBase;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * Контейнер в виде рельефной панели
	 */
	public class PanelGroup extends Container {
		
		/**
		 * Скин окна 
		 */		
		private var windowSkin:WindowSkin;
		/**
		 * @private
		 * Контейнер графики панели 
		 */		
		protected var gfx:Sprite;
		/**
		 * @private
		 * Верхний-левый угол
		 */
		protected var cTLbmp:Bitmap;
		/**
		 * @private
		 * Верхний-правый угол
		 */
		protected var cTRbmp:Bitmap;
		/**
		 * @private
		 * Нижний-левый угол
		 */
		protected var cBLbmp:Bitmap;
		/**
		 * @private
		 * Нижний-правый угол
		 */
		protected var cBRbmp:Bitmap;
		/**
		 * @private
		 * Верхний край
		 */
		protected var eTCbmp:Bitmap;
		/**
		 * @private
		 * Левый край
		 */	
		protected var eMLbmp:Bitmap;
		/**
		 * @private
		 * Правый край
		 */
		protected var eMRbmp:Bitmap;
		/**
		 * @private
		 * Нижний край
		 */
		protected var eBCbmp:Bitmap;
		/**
		 * @private
		 * Центр 
		 */		
		protected var bgbmp:Bitmap;
		
		
		/**
		 * @param marginLeft отступ слева
		 * @param marginTop отступ сверху
		 * @param marginRight отступ справа
		 * @param marginBottom отступ снизу
		 */		
		public function PanelGroup(marginLeft:int = 0, marginTop:int = 0, marginRight:int = 0, marginBottom:int = 0) {
			super(marginLeft, marginTop, marginRight, marginBottom);
			
			cTLbmp = new Bitmap();
			cTRbmp = new Bitmap();
			cBLbmp = new Bitmap();
			cBRbmp = new Bitmap();
			eTCbmp = new Bitmap();
			eMLbmp = new Bitmap();
			eMRbmp = new Bitmap();
			eBCbmp = new Bitmap();
			bgbmp = new Bitmap();
			
			gfx = new Sprite();
			gfx.mouseEnabled = false;
			gfx.tabEnabled = false;
			
			gfx.addChild(cTLbmp);
			gfx.addChild(cTRbmp);
			gfx.addChild(cBLbmp);
			gfx.addChild(cBRbmp);
			gfx.addChild(eTCbmp);
			gfx.addChild(eMLbmp);
			gfx.addChild(eMRbmp);
			gfx.addChild(eBCbmp);
			gfx.addChild(bgbmp);
			addChildAt(gfx, 0);
		}
		
		/**
		 * Обновление скина 
		 */
		override public function updateSkin():void {
			windowSkin = WindowSkin(skinManager.getSkin(WindowBase));
			
			// Загрузка битмап из скина
			loadBitmaps();
			
			super.updateSkin();
			
			minSize.x = _marginLeft + _marginRight;
			minSize.y = _marginTop + _marginBottom;
		}
		
		/**
		 * @private
		 * Загрузка битмап из скина
		 */		
		protected function loadBitmaps():void {
			cTLbmp.bitmapData = windowSkin.cornerTLmargin;
			cTRbmp.bitmapData = windowSkin.cornerTRmargin;
			cBLbmp.bitmapData = windowSkin.cornerBL;
			cBRbmp.bitmapData = windowSkin.cornerBR;
			eTCbmp.bitmapData = windowSkin.edgeTC;
			eMLbmp.bitmapData = windowSkin.edgeML;
			eMRbmp.bitmapData = windowSkin.edgeMR;
			eBCbmp.bitmapData = windowSkin.edgeBC;
			bgbmp.bitmapData = windowSkin.bgMC;
		}
		
		/**
		 * Отрисовка контейнера в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			super.draw(size);
			arrangeGraphics(size);
		}
		
		/**
		 * @private
		 * Перерисовка частей графики
		 * @param size размер контейнера
		 */		
		protected function arrangeGraphics(size:Point):void {
			
			// Находим координаты нижнего правого угла
			var farX:int = size.x - cBRbmp.width;
			var farY:int = size.y - cBRbmp.height;
				
			// Расставляем углы
			cTRbmp.x = farX;
			cBLbmp.y = farY;
			cBRbmp.x = farX;
			cBRbmp.y = farY;
			
			var newWidth:int = size.x - cTLbmp.width - cTRbmp.width;
			var newHeight:int = size.y - cTLbmp.height - cBLbmp.height;
				
			eTCbmp.x = cTLbmp.width;
			eTCbmp.width = newWidth;
			
			eMLbmp.y = cTLbmp.height;
			eMLbmp.height = newHeight;
			
			eMRbmp.x = farX;
			eMRbmp.y = cTRbmp.height;
			eMRbmp.height = newHeight;
			
			eBCbmp.x = cBLbmp.width;
			eBCbmp.y = farY;
			eBCbmp.width = newWidth;
			
			bgbmp.x = cTLbmp.width;
			bgbmp.y = cTLbmp.height;
			bgbmp.width = newWidth;
			bgbmp.height = newHeight;
		}
		
	}
}