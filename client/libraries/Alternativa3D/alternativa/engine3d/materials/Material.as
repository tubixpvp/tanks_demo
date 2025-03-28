package alternativa.engine3d.materials {

	import alternativa.engine3d.*;
	import alternativa.engine3d.display.Skin;

	use namespace alternativa3d;

	/**
	 * Базовый класс для материалов.
	 */
	public class Material {

		/**
		 * @private
		 * Альфа.
		 */
		alternativa3d var _alpha:Number;
		/**
		 * @private
		 * Режим наложения цвета.
		 */
		alternativa3d var _blendMode:String;

		/**
		 * Создание экземпляра класса.
		 *
		 * @param alpha коэффициент непрозрачности материала. Значение 1 соответствует полной непрозрачности, значение 0 соответствует полной прозрачности.
		 * @param blendMode режим наложения цвета
		 */
		public function Material(alpha:Number, blendMode:String) {
			_alpha = alpha;
			_blendMode = blendMode;
		}

		/**
		 * Коэффициент непрозрачности материала. Значение 1 соответствует полной непрозрачности, значение 0 соответствует полной прозрачности.
		 */
		public function get alpha():Number {
			return _alpha;
		}

		/**
		 * @private
		 */
		public function set alpha(value:Number):void {
			if (_alpha != value) {
				_alpha = value;
				markToChange();
			}
		}

		/**
		 * Режим наложения цвета.
		 */
		public function get blendMode():String {
			return _blendMode;
		}

		/**
		 * @private
		 */
		public function set blendMode(value:String):void {
			if (_blendMode != value) {
				_blendMode = value;
				markToChange();
			}
		}

		/**
		 * Отметить материал на перерисовку.
		 */
		protected function markToChange():void {}

		/**
		 * @private
		 * Метод очищает переданный скин (нарисованную графику, дочерние объекты и т.д.).
		 * 
		 * @param skin скин для очистки
		 */
		alternativa3d function clear(skin:Skin):void {
			skin.gfx.clear();
		}

		/**
		 * Создание клона материала.
		 *
		 * @return клон материала
		 */
		public function clone():Material {
			return new Material(_alpha, _blendMode);
		}

	}
}
