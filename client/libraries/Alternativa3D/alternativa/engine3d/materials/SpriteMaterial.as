package alternativa.engine3d.materials {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Scene3D;
	import alternativa.engine3d.core.Sprite3D;
	import alternativa.engine3d.display.Skin;
	import alternativa.types.*;
	
	import flash.display.BlendMode;

	use namespace alternativa3d;
	use namespace alternativatypes;

	/**
	 * Базовый класс для материалов спрайтов.
	 */
	public class SpriteMaterial extends Material {

		/**
		 * @private
		 * Спрайт.
		 */
		alternativa3d var _sprite:Sprite3D;

		/**
		 * Создание экземпляра материала.
		 * 
		 * @param alpha коэффициент непрозрачности материала. Значение 1 соответствует полной непрозрачности, значение 0 соответствует полной прозрачности.
		 * @param blendMode режим наложения цвета
		 */
		public function SpriteMaterial(alpha:Number = 1, blendMode:String = BlendMode.NORMAL) {
			super(alpha, blendMode);
		}

		/**
		 * Спрайт, которому назначен материал.
		 */
		public function get sprite():Sprite3D {
			return _sprite;
		}

		/**
		 * @private
		 * Добавление на сцену.
		 *
		 * @param scene
		 */
		alternativa3d function addToScene(scene:Scene3D):void {}

		/**
		 * @private
		 * Удаление из сцены.
		 * 
		 * @param scene
		 */
		alternativa3d function removeFromScene(scene:Scene3D):void {}

		/**
		 * @private
		 * Назначение спрайту.
		 *
		 * @param sprite спрайт
		 */
		alternativa3d function addToSprite(sprite:Sprite3D):void {
			_sprite = sprite;
		}

		/**
		 * @private
		 * Удаление из спрайта.
		 * 
		 * @param sprite спрайт
		 */
		alternativa3d function removeFromSprite(sprite:Sprite3D):void {
			_sprite = null;
		}

		/**
		 * @private
		 * Метод определяет, может ли материал нарисовать спрайт. Метод используется в системе отрисовки сцены и должен использоваться
		 * наследниками для указания видимости связанной со спрайтом. Реализация по умолчанию возвращает
		 * <code>true</code>.
		 *
		 * @param camera камера через которую происходит отрисовка.
		 * 
		 * @return <code>true</code>, если материал может отрисовать указанный примитив, иначе <code>false</code>
		 */
		alternativa3d function canDraw(camera:Camera3D):Boolean {
			return true;
		}

		/**
		 * @private
		 * Метод выполняет отрисовку в заданный скин.
		 *
		 * @param camera камера, вызвавшая метод
		 * @param skin скин, в котором нужно отрисовать
		 */
		alternativa3d function draw(camera:Camera3D, skin:Skin):void {
			skin.alpha = _alpha;
			skin.blendMode = _blendMode;
		}

		/**
		 * @inheritDoc
		 */
		override protected function markToChange():void {
			if (_sprite != null) {
				_sprite.addMaterialChangedOperationToScene();
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function clone():Material {
			return new SpriteMaterial(_alpha, _blendMode);
		}

	}
}
