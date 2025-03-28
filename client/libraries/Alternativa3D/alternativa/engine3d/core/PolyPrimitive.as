package alternativa.engine3d.core {

	import alternativa.engine3d.*;
	
	use namespace alternativa3d;
	
	/**
	 * @private
	 * Примитивный полигон (примитив), хранящийся в узле BSP-дерева.
	 */
	public class PolyPrimitive {

		/**
		 * @private
		 * Количество точек
		 */
		alternativa3d var num:uint;
		/**
		 * @private
		 * Точки
		 */
		alternativa3d var points:Array = new Array();
		/**
		 * @private
		 * Грань
		 */
		alternativa3d var face:Face;
		/**
		 * @private
		 * Родительский примитив
		 */
		alternativa3d var parent:PolyPrimitive;
		/**
		 * @private
		 * Соседний примитив (при наличии родительского)
		 */
		alternativa3d var sibling:PolyPrimitive;
		/**
		 * @private
		 * Фрагменты
		 */
		alternativa3d var backFragment:PolyPrimitive;
		/**
		 * @private
		 */
		alternativa3d var frontFragment:PolyPrimitive;
		/**
		 * @private
		 * BSP-нода, в которой находится примитив
		 */
		alternativa3d var node:BSPNode;
		/**
		 * @private
		 * Значения для расчёта качества сплиттера
		 */
		alternativa3d var splits:uint;
		/**
		 * @private
		 */
		alternativa3d var disbalance:int;
		/**
		 * @private
		 * Качество примитива как сплиттера (меньше - лучше)
		 */
		public var splitQuality:Number;
		/**
		 * @private
		 * Приоритет в BSP-дереве. Чем ниже мобильность, тем примитив выше в дереве.
		 */
		public var mobility:int;

		/**
		 * @private
		 * Метод создает новый фрагмент этого примитива. 
		 */
		alternativa3d function createFragment():PolyPrimitive {
			var primitive:PolyPrimitive = create();
			primitive.face = face;
			primitive.mobility = mobility;
			return primitive;
		}

		// Хранилище неиспользуемых примитивов
		static private var collector:Array = new Array();

		/**
		 * @private
		 * Создать примитив
		 */
		static alternativa3d function create():PolyPrimitive {
			var primitive:PolyPrimitive;
			if ((primitive = collector.pop()) != null) {
				return primitive;
			}
			return new PolyPrimitive();
		}

		/**
		 * @private
		 * Кладёт примитив в коллектор для последующего реиспользования.
		 * Ссылка на грань и массивы точек зачищаются в этом методе.
		 * Ссылки на фрагменты (parent, sibling, back, front) должны быть зачищены перед запуском метода.
		 * 
		 * Исключение:
		 * при сборке примитивов в сцене ссылки на back и front зачищаются после запуска метода. 
		 *   
		 * @param primitive примитив на реиспользование
		 */
		static alternativa3d function destroy(primitive:PolyPrimitive):void {
			primitive.face = null;
			primitive.points.length = 0;
			collector.push(primitive);
		}

		/**
		 * Строковое представление объекта.
		 */
		public function toString():String {
			return "[Primitive " + face._mesh._name + "]";
		}

	}
}
