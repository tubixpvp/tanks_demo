package alternativa.gui.layout.snap {
	import flash.geom.Point;
	
	public class SnapPoint extends Point {
		
		// Стороны, к которым прилипли другие снаповые объекты (в формате констант Snap)
		private var _snapedSides:int;
		
		// Массив массивов объектов, прилипших к снаповым сторонам
		/*  snapedObjects[i][j] 
						  |  |
						  |  |
						  |  \__ индексы объектов, прилипших к стороне
						  \_____ индексы сторон (в формате констант SnapRect)
		*/
		private var _snapedObjects:Array;
		
		// Массив массивов сторон прилипших объектов, которыми они прилипли
		/*  snapedObjectsSides[i][j] 
						       |  |
						       |  |
						       |  \__ индексы сторон объектов (в том же формате, что и i)
						       \_____ индексы сторон
		*/
		private var _snapedObjectsSides:Array;
		
		public function SnapPoint(x:Number = 0, y:Number = 0) {
			super(x, y);
			_snapedSides = Snap.NONE;
			_snapedObjects = new Array();
			_snapedObjectsSides = new Array();
			for (var i:int = 0; i < 8; i++) {
				_snapedObjects.push(new Array());
				_snapedObjectsSides.push(new Array());
			}
		}
		
		public function set snapedSides(value:int):void {
			_snapedSides = value;
		}
		public function get snapedSides():int {
			return _snapedSides;
		}
		
		public function set snapedObjects(objects:Array):void {
			_snapedObjects = objects;
		}
		public function get snapedObjects():Array {
			return _snapedObjects;
		}
		
		public function set snapedObjectsSides(sides:Array):void {
			_snapedObjectsSides = sides;
		}
		public function get snapedObjectsSides():Array {
			return _snapedObjectsSides;
		}
		
		/**
		 * Клонирование
		 * @return копия со всеми параметрами
		 */		
		public function duplicate():SnapPoint {
			var newPoint:SnapPoint = new SnapPoint(x, y);
			newPoint.snapedSides = _snapedSides;
			for (var i:int = 0; i < 8; i++) {
				for (var j:int = 0; j < _snapedObjects[i].length; j++) {
					newPoint.snapedObjects[i][j] = _snapedObjects[i][j];
					newPoint.snapedObjectsSides[i][j] = _snapedObjectsSides[i][j];
				}
			}
			return newPoint;
		}

	}
}