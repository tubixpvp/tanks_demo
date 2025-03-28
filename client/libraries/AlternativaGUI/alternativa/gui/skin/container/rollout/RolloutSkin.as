package alternativa.gui.skin.container.rollout {
	import alternativa.skin.ISkin;
	
	import flash.display.BitmapData;
	
	/**
	 * Скин свитка
	 */	
	public class RolloutSkin implements ISkin {
		
		/**
		 * Левая часть заголовка в нормальном состоянии 
		 */		
		public var nl:BitmapData;
		/**
		 * Центральная часть заголовка в нормальном состоянии 
		 */		
		public var nc:BitmapData;
		/**
		 * Правая часть заголовка в нормальном состоянии 
		 */
		public var nr:BitmapData;
		
		/**
		 * Левая часть заголовка в наведенном состоянии 
		 */		
		public var ol:BitmapData;
		/**
		 * Центральная часть заголовка в наведенном состоянии 
		 */
		public var oc:BitmapData;
		/**
		 * Правая часть заголовка в наведенном состоянии 
		 */
		public var or:BitmapData;
		
		/**
		 * Левая часть заголовка в нажатом состоянии 
		 */
		public var pl:BitmapData;
		/**
		 * Центральная часть заголовка в нажатом состоянии 
		 */
		public var pc:BitmapData;
		/**
		 * Правая часть заголовка в нажатом состоянии 
		 */
		public var pr:BitmapData;
		
		/**
		 * Левая часть заголовка в заблокированном состоянии 
		 */
		public var ll:BitmapData;
		/**
		 * Центральная часть заголовка в заблокированном состоянии 
		 */
		public var lc:BitmapData;
		/**
		 * Правая часть заголовка в заблокированном состоянии 
		 */
		public var lr:BitmapData;
		
		/**
		 * Левая часть заголовка в фокусе
		 */
		public var fl:BitmapData;
		/**
		 * Центральная часть заголовка в фокусе 
		 */
		public var fc:BitmapData;
		/**
		 * Правая часть заголовка в фокусе
		 */
		public var fr:BitmapData;
		
		/**
		 * Y координата заголовка в отжатом состоянии 
		 */		
		public var yNormal:int;
		/**
		 * Y координата заголовка в нажатом состоянии 
		 */
		public var yPress:int;
		
		/**
		 * Отступ в контейнере заголовка сверху
		 */		
		public var titleMarginTop:int;
		/**
		 * Отступ в контейнере заголовка снизу
		 */
		public var titleMarginBottom:int;
		/**
		 * Отступ в контейнере заголовка слева
		 */
		public var titleMarginLeft:int;
		/**
		 * Отступ в контейнере заголовка справа
		 */
		public var titleMarginRight:int;
		
		/**
		 * Отступ в контейнере контента сверху
		 */
		public var contentMarginTop:int;
		/**
		 * Отступ в контейнере контента снизу
		 */
		public var contentMarginBottom:int;
		/**
		 * Отступ в контейнере контента слева
		 */
		public var contentMarginLeft:int;
		/**
		 * Отступ в контейнере контента справа
		 */
		public var contentMarginRight:int;
		
		/**
		 * Иконка в заголовке в развернутом состоянии 
		 */		
		public var maximized:BitmapData;
		/**
		 * Иконка в заголовке в свернутом состоянии 
		 */
		public var minimized:BitmapData;
		/**
		 * Графика кнопки закрывания свитка 
		 */
		public var close:BitmapData;
		
		/**
		 * @param nl левая часть заголовка в нормальном состоянии
		 * @param nc центральная часть заголовка в нормальном состоянии
		 * @param nr правая часть заголовка в нормальном состоянии
		 * @param ol левая часть заголовка в наведенном состоянии
		 * @param oc центральная часть заголовка в наведенном состоянии
		 * @param or правая часть заголовка в наведенном состоянии
		 * @param pl левая часть заголовка в нажатом состоянии
		 * @param pc центральная часть заголовка в нажатом состоянии
		 * @param pr правая часть заголовка в нажатом состоянии
		 * @param ll левая часть заголовка в заблокированном состоянии
		 * @param lc центральная часть заголовка в заблокированном состоянии
		 * @param lr правая часть заголовка в заблокированном состоянии
		 * @param fl левая часть заголовка в фокусе
		 * @param fc центральная часть заголовка в фокусе
		 * @param fr правая часть заголовка в фокусе
		 * @param yNormal Y координата заголовка в отжатом состоянии
		 * @param yPress Y координата заголовка в нажатом состоянии
		 * @param titleMarginTop отступ в контейнере заголовка сверху
		 * @param titleMarginBottom отступ в контейнере заголовка снизу
		 * @param titleMarginLeft отступ в контейнере заголовка слева
		 * @param titleMarginRight отступ в контейнере заголовка справа
		 * @param contentMarginTop отступ в контейнере контента сверху
		 * @param contentMarginBottom отступ в контейнере контента снизу
		 * @param contentMarginLeft отступ в контейнере контента слева
		 * @param contentMarginRight отступ в контейнере контента справа
		 * @param maximized иконка в заголовке в развернутом состоянии 
		 * @param minimized иконка в заголовке в свернутом состоянии
		 * @param close графика кнопки закрывания свитка
		 */		
		public function RolloutSkin(nl:BitmapData,
								  	nc:BitmapData,
								  	nr:BitmapData,
								  	ol:BitmapData,
								  	oc:BitmapData,
								  	or:BitmapData,
								  	pl:BitmapData,
								  	pc:BitmapData,
								  	pr:BitmapData,
								  	ll:BitmapData,
								  	lc:BitmapData,
								  	lr:BitmapData,
								  	fl:BitmapData,
								  	fc:BitmapData,
								  	fr:BitmapData,
								  	yNormal:int,
								  	yPress:int,
								  	titleMarginTop:int,
								  	titleMarginBottom:int,
								  	titleMarginLeft:int,
								  	titleMarginRight:int,
								  	contentMarginTop:int,
								  	contentMarginBottom:int,
								 	contentMarginLeft:int,
								  	contentMarginRight:int,
								  	maximized:BitmapData,
								  	minimized:BitmapData,
								  	close:BitmapData) {
			this.nl = nl;							   	
			this.nc = nc;							   	
			this.nr = nr;
			
			this.ol = ol;							   	
			this.oc = oc;							   	
			this.or = or;
			
			this.pl = pl;							   	
			this.pc = pc;							   	
			this.pr = pr;
			
			this.ll = ll;							   	
			this.lc = lc;							   	
			this.lr = lr;

			this.fl = fl;							   	
			this.fc = fc;							   	
			this.fr = fr;
			
			this.yNormal = yNormal;
			this.yPress = yPress;
			
			this.titleMarginTop = titleMarginTop;
			this.titleMarginBottom = titleMarginBottom;
			this.titleMarginLeft = titleMarginLeft;
			this.titleMarginRight = titleMarginRight;
			
			this.contentMarginTop = contentMarginTop;
			this.contentMarginBottom = contentMarginBottom;
			this.contentMarginLeft = contentMarginLeft;
			this.contentMarginRight = contentMarginRight;
			
			this.maximized = maximized;
			this.minimized = minimized;
			this.close = close;
		}

	}
}