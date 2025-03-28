package alternativa.engine3d.core {

	import alternativa.engine3d.alternativa3d;

	use namespace alternativa3d;

	/**
	 * @private
	 * Сплиттеровый примитив.
	 */
	public class SplitterPrimitive extends PolyPrimitive {

		/**
		 * Сплиттер 
		 */
		alternativa3d var splitter:Splitter;

		/**
		 * @inheritDoc 
		 */
		override alternativa3d function createFragment():PolyPrimitive {
			var primitive:SplitterPrimitive = create();
			primitive.splitter = splitter;
			primitive.mobility = mobility;
			return primitive;
		}

		// Хранилище неиспользуемых примитивов
		static private var collector:Array = new Array();

		/**
		 * @private
		 * Создать примитив
		 */
		static alternativa3d function create():SplitterPrimitive {
			var primitive:SplitterPrimitive;
			if ((primitive = collector.pop()) != null) {
				return primitive;
			}
			return new SplitterPrimitive();
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
		static alternativa3d function destroy(primitive:SplitterPrimitive):void {
			primitive.splitter = null;
			primitive.points.length = 0;
			collector.push(primitive);
		}

	}
}
