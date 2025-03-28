package alternativa.gui.widget.list {
	import alternativa.gui.layout.enums.Align;
	
	/**
	 * Параметры отрисовщика элемента списка
	 */	
	public class ListRendererParams	{
		
		/**
		 * Выравнивание по горизонтали
		 */		
		public var hAlign:uint;
		/**
		 * Выравнивание по вертикали 
		 */		
		public var vAlign:uint;
		/**
		 * Промежуток между объектами
		 */		
		public var space:int;
		/**
		 * Отступ слева 
		 */		
		public var marginLeft:int;
		/**
		 * Отступ сверху 
		 */
		public var marginTop:int;
		/**
		 * Отступ справа 
		 */
		public var marginRight:int;
		/**
		 * Отступ снизу 
		 */
		public var marginBottom:int;
		
		/**
		 * @param hAlign выравнивание по горизонтали 
		 * @param vAlign выравнивание по вертикали
		 * @param space промежуток между объектами
		 * @param marginLeft отступ слева
		 * @param marginTop отступ сверху
		 * @param marginRight отступ справа
		 * @param marginBottom отступ снизу
		 */		
		public function ListRendererParams(hAlign:uint = Align.LEFT, vAlign:uint = Align.MIDDLE, space:int = 0, marginLeft:int = 0, marginTop:int = 0, marginRight:int = 0, marginBottom:int = 0) {
			this.hAlign = hAlign;
			this.vAlign = vAlign;
			
			this.space = space;
			
			this.marginLeft = marginLeft;
			this.marginTop = marginTop;
			this.marginRight = marginRight;
			this.marginBottom = marginBottom;
		}

	}
}