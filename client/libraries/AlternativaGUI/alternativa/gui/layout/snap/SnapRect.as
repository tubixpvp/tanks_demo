package alternativa.gui.layout.snap {
	import flash.geom.Rectangle;
	
	/**
	 * Магнитная область объекта с информацией о примагнитившихся сторонах и объектах.
	 * <p> Например, если к верхней стороне снаружи прилип объект objX своей нижней внешней стороной, то
	 * <br> snapedSides = 0000 0010 (в двоичном виде), 
	 * <br> snapedObjects[1][0] = objX, 
	 * <br> snapedObjectsSides[1][0] = 3 </p>
	 */	
	public class SnapRect extends Rectangle {
		
		// Индексы сторон для массива прилипших объектов
		/**
		 * Внешняя левая сторона 
		 */		
		public static const EXT_LEFT_SIDE:int = 0;
		/**
		 * Внешняя верхняя сторона 
		 */
		public static const EXT_TOP_SIDE:int = 1;
		/**
		 * Внешняя правая сторона 
		 */
		public static const EXT_RIGHT_SIDE:int = 2;
		/**
		 * Внешняя нижняя сторона 
		 */
		public static const EXT_BOTTOM_SIDE:int = 3;
		
		/**
		 * Внутренняя левая сторона 
		 */		
		public static const INT_LEFT_SIDE:int = 4;
		/**
		 * Внутренняя верхняя сторона 
		 */
		public static const INT_TOP_SIDE:int = 5;
		/**
		 * Внутренняя правая сторона 
		 */
		public static const INT_RIGHT_SIDE:int = 6;
		/**
		 * Внутренняя нижняя сторона 
		 */
		public static const INT_BOTTOM_SIDE:int = 7;
		
		
		/**
		 * Стороны, к которым прилипли другие снаповые объекты (в формате констант <code>Snap</code>)
		 */		
		private var _snapedSides:int;
		
		/**
		 * Массив массивов объектов, прилипших к снаповым сторонам
		 */		
		private var _snapedObjects:Array;
		/*  snapedObjects[i][j] 
						  |  |
						  |  |
						  |  \__ индексы объектов, прилипших к стороне
						  \_____ индексы сторон */
		/**
		 * Массив массивов сторон прилипших объектов, которыми они прилипли
		 */		
		private var _snapedObjectsSides:Array;
		/*  snapedObjectsSides[i][j] 
						       |  |
						       |  |
						       |  \__ индексы сторон объектов (в том же формате, что и i)
						       \_____ индексы сторон */
		
		/**
		 * @param x координата X левого верхнего угла
		 * @param y координата Y левого верхнего угла
		 * @param width ширина
		 * @param height высота
		 */		
		public function SnapRect(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0) {
			super(x, y , width, height);
			_snapedSides = Snap.NONE;
			_snapedObjects = new Array();
			_snapedObjectsSides = new Array();
			for (var i:int = 0; i < 8; i++) {
				_snapedObjects.push(new Array());
				_snapedObjectsSides.push(new Array());
			}
		}
		
		/**
		 * Стороны, к которым прилипли другие снаповые объекты (в формате констант <code>Snap</code>)
		 */		
		public function get snapedSides():int {
			return _snapedSides;
		}
		public function set snapedSides(value:int):void {
			_snapedSides = value;
		}
		
		/**
		 * Массив массивов объектов, прилипших к снаповым сторонам.
		 * <p> Т.е. в snapedObjects[i][j]
		 * <br> i — индексы сторон,
		 * <br> j — индексы объектов, прилипших к стороне. </p>
		 */
		public function get snapedObjects():Array {
			return _snapedObjects;
		}
		public function set snapedObjects(objects:Array):void {
			_snapedObjects = objects;
		}
		
		/**
		 * Массив массивов сторон прилипших объектов, которыми они прилипли.
		 * <p> Т.е. в snapedObjectsSides[i][j]
		 * <br> i — индексы сторон,
		 * <br> j — индексы сторон прилипших объектов (в том же формате, что и i). </p>
		 */
		public function get snapedObjectsSides():Array {
			return _snapedObjectsSides;
		}
		public function set snapedObjectsSides(sides:Array):void {
			_snapedObjectsSides = sides;
		}
		
		/**
		 * Клонирование
		 * @return копия со всеми параметрами
		 */		
		public function duplicate():SnapRect {
			var newRect:SnapRect = new SnapRect(x, y, width, height);
			newRect.snapedSides = _snapedSides;
			for (var i:int = 0; i < 8; i++) {
				for (var j:int = 0; j < _snapedObjects[i].length; j++) {
					newRect.snapedObjects[i][j] = _snapedObjects[i][j];
					newRect.snapedObjectsSides[i][j] = _snapedObjectsSides[i][j];
				}
			}
			return newRect;
		}

	}
}