package alternativa.gui.layout.snap {
	
	/**
	 * Связь между двумя объектами в снап группе (<code>SnapGroup</code>)
	 */	
	public class SnapGroupLink {
		
		/**
		 * Объект 1
		 */		
		public var obj1:ISnapGroupable;
		/**
		 * Объект 2
		 */		
		public var obj2:ISnapGroupable;
		
		
		/**
		 * @param obj1 объект 1
		 * @param obj2 объект 2
		 */		
		public function SnapGroupLink(obj1:ISnapGroupable, obj2:ISnapGroupable)	{
			this.obj1 = obj1;
			this.obj2 = obj2;
		}

	}
}