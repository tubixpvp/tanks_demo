package alternativa.engine3d.display {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.PolyPrimitive;
	import alternativa.engine3d.materials.Material;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	use namespace alternativa3d;
	
	/**
	 * @private
	 * Контейнер, используемый материалами для отрисовки примитивов. Каждый примитив BSP-дерева рисуется в своём контейнере.
	 */
	public class Skin extends Sprite {

		/**
		 * @private
		 * Графика скина (для быстрого доступа)
		 */
		alternativa3d var gfx:Graphics = graphics;

		/**
		 * @private
		 * Ссылка на следующий скин
		 */
		alternativa3d var nextSkin:Skin;
		
		/**
		 * @private
		 * Примитив
		 */
		alternativa3d var primitive:PolyPrimitive;

		/**
		 * @private
		 * Материал, связанный со скином.
		 */
		alternativa3d var material:Material;

		// Хранилище неиспользуемых скинов
		static private var collector:Array = new Array();

		/**
		 * @private
		 * Создание скина.
		 */
		static alternativa3d function createSkin():Skin {
			var skin:Skin;
			if ((skin = collector.pop()) != null) {
				return skin;
			}
			return new Skin();
		}

		/**
		 * @private
		 * Удаление скина, все ссылки должны быть почищены.
		 */
		static alternativa3d function destroySkin(skin:Skin):void {
			collector.push(skin);
		}
	}
}