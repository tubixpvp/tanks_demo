package alternativa.engine3d.physics {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.BSPNode;

	use namespace alternativa3d;
	
	/**
	 * @private
	 */
	public class CollisionPlane {

		// Узел BSP дерева, который содержит плоскость
		public var node:BSPNode;
		// Индикатор положения объекта относительно плоскости (спереди или сзади)
		public var infront:Boolean;
		// Расстояние до плоскости в начальной точке (всегда положительное)
		public var sourceOffset:Number;
		// Расстояние до плоскости в конечной точке
		public var destinationOffset:Number;
		
		// Хранилище неиспользуемых плоскостей
		static private var collector:Array = new Array();

		/**
		 * Создание плоскости
		 * 
		 * @param node
		 * @param infront
		 * @param sourceOffset
		 * @param destinationOffset
		 * @return 
		 */		
		static alternativa3d function createCollisionPlane(node:BSPNode, infront:Boolean, sourceOffset:Number, destinationOffset:Number):CollisionPlane {
			
			// Достаём плоскость из коллектора
			var plane:CollisionPlane = collector.pop();
			// Если коллектор пуст, создаём новую плоскость
			if (plane == null) {
				plane = new CollisionPlane();
			}

			plane.node = node;
			plane.infront = infront;
			plane.sourceOffset = sourceOffset;
			plane.destinationOffset = destinationOffset;

			return plane;
		}

		/**
		 * Удаление плоскости, все ссылки должны быть почищены
		 * 
		 * @param plane
		 */
		static alternativa3d function destroyCollisionPlane(plane:CollisionPlane):void {
			plane.node = null;
			collector.push(plane);
		}

	}
}
