package alternativa.engine3d.core {

	import alternativa.engine3d.*;
	import alternativa.types.Point3D;
	import alternativa.types.Set;

	use namespace alternativa3d;

	/**
	 * @private
	 */
	public final class BSPNode {

		// Сплиттер ноды (если есть)
		alternativa3d var splitter:Splitter;

		// Передний и задний сектора (если есть сплиттер)
		alternativa3d var frontSector:Sector;
		alternativa3d var backSector:Sector;

		// Тип примитива
		alternativa3d var isSprite:Boolean;

		// Родительская нода
		alternativa3d var parent:BSPNode;

		// Дочерние ветки
		alternativa3d var front:BSPNode; 
		alternativa3d var back:BSPNode;

		// Нормаль плоскости ноды
		alternativa3d var normal:Point3D = new Point3D();

		// Смещение плоскости примитива
		alternativa3d var offset:Number;

		// Минимальная мобильность ноды
		alternativa3d var mobility:int = int.MAX_VALUE;

		// Набор примитивов в ноде
		alternativa3d var primitive:PolyPrimitive;
		alternativa3d var backPrimitives:Set;
		alternativa3d var frontPrimitives:Set;

		// Хранилище неиспользуемых нод
		static private var collector:Array = new Array();

		// Создать ноду на основе примитива
		static alternativa3d function create(primitive:PolyPrimitive):BSPNode {
			var node:BSPNode;
			if ((node = collector.pop()) == null) {
				node = new BSPNode(); 
			}

			// Добавляем примитив в ноду
			node.primitive = primitive;
			// Сохраняем ноду
			primitive.node = node;
			// Если это спрайтовый примитив или сплиттеровый примитив
			if (primitive.face == null) {
				var sprimitive:SplitterPrimitive = primitive as SplitterPrimitive;
				if (sprimitive == null) {
					// SpritePrimitive
					node.normal.x = 0;
					node.normal.y = 0;
					node.normal.z = 0;
					node.offset = 0;
					node.isSprite = true;
				} else {
					node.splitter = sprimitive.splitter;
					node.normal.copy(sprimitive.splitter.normal);
					node.offset = sprimitive.splitter.offset;
					node.isSprite = false;
				}
			} else {
				// Сохраняем плоскость
				node.normal.copy(primitive.face.globalNormal);
				node.offset = primitive.face.globalOffset;
				node.isSprite = false;
			}
			// Сохраняем мобильность
			node.mobility = primitive.mobility;
			return node;
		}

		// Удалить ноду, все ссылки должны быть почищены
		static alternativa3d function destroy(node:BSPNode):void {
			//trace(node.back, node.front, node.parent, node.primitive, node.backPrimitives, node.frontPrimitives);
			collector.push(node);
		}

	}
}
