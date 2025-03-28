package alternativa.gui.skin.container.group {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	import flash.text.TextFormat;
	
	/**
	 * Скин контейнера с рамкой и заголовком
	 */	
	public class FrameGroupSkin implements ISkin {
		/**
		 * Верхний-левый угол рамки 
		 */	
		public var cornerTL:BitmapData;
		/**
		 * Верхний-правый угол рамки 
		 */
		public var cornerTR:BitmapData;
		/**
		 * Нижний-левый угол рамки 
		 */
		public var cornerBL:BitmapData;
		/**
		 * Нижний-правый угол рамки 
		 */
		public var cornerBR:BitmapData;
		/**
		 * Верхний край рамки
		 */
		public var edgeTC:BitmapData;
		/**
		 * Кончик рамки до заголовка
		 */
		public var edgeTCbefore:BitmapData;
		/**
		 * Кончик рамки после заголовка
		 */
		public var edgeTCafter:BitmapData;
		/**
		 * Левый край рамки
		 */
		public var edgeML:BitmapData;
		/**
		 * Правый край рамки
		 */
		public var edgeMR:BitmapData;
		/**
		 * Нижний край рамки
		 */
		public var edgeBC:BitmapData;
		
		/**
		 * Толщина рамки 
		 */		
		public var borderThickness:int;
		
		/**
		 * Отступ слева до заголовка 
		 */		
		public var titleMarginLeft:int;
		/**
		 * Отступ справа до заголовка 
		 */
		public var titleMarginRight:int;
		
		/**
		 * Текстовый формат заголовка 
		 */		
		public var titleTextFormat:TextFormat;
		
		/**
		 * Жесткость шрифта заголовка
		 */		
		public var titleSharpness:Number;
		/**
		 * Жирность шрифта заголовка
		 */		
		public var titleThickness:Number;
		
		
		/**
		 * @param cornerTL верхний-левый угол рамки
		 * @param cornerTR верхний-правый угол рамки 
		 * @param cornerBL нижний-левый угол рамки
		 * @param cornerBR нижний-правый угол рамки
		 * @param edgeTC верхний край рамки
		 * @param edgeTCbefore кончик рамки до заголовка
		 * @param edgeTCafter кончик рамки после заголовка
		 * @param edgeML левый край рамки
		 * @param edgeMR правый край рамки
		 * @param edgeBC нижний край рамки
		 * @param borderThickness толщина рамки
		 * @param titleMarginLeft отступ слева до заголовка 
		 * @param titleMarginRight отступ справа до заголовка
		 * @param titleTextFormat текстовый формат заголовка 
		 * @param titleSharpness жесткость шрифта заголовка
		 * @param titleThickness жирность шрифта заголовка
		 */		
		public function FrameGroupSkin(cornerTL:BitmapData,
									   cornerTR:BitmapData,
									   cornerBL:BitmapData,
									   cornerBR:BitmapData, 
								       edgeTC:BitmapData,
								       edgeTCbefore:BitmapData,
								       edgeTCafter:BitmapData,
								       edgeML:BitmapData,
								       edgeMR:BitmapData,
								       edgeBC:BitmapData,
								       borderThickness:int,
								       titleMarginLeft:int,
								       titleMarginRight:int,
								       titleTextFormat:TextFormat,
								       titleSharpness:Number,
								       titleThickness:Number) {
			
			this.cornerTL = cornerTL;
			this.cornerTR = cornerTR;
			this.cornerBL = cornerBL;
			this.cornerBR = cornerBR;
			this.edgeTC = edgeTC;
			this.edgeTCbefore = edgeTCbefore;
			this.edgeTCafter = edgeTCafter;
			this.edgeML = edgeML;
			this.edgeMR = edgeMR;
			this.edgeBC = edgeBC;
			
			this.borderThickness = borderThickness;
			
			this.titleMarginLeft = titleMarginLeft;
			this.titleMarginRight = titleMarginRight;
			this.titleTextFormat = titleTextFormat;
			this.titleSharpness = titleSharpness;
			this.titleThickness = titleThickness;
		}
		
	}
}