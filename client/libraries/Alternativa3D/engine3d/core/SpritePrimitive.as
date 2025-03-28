package alternativa.engine3d.core {

	import alternativa.engine3d.*;

	use namespace alternativa3d;

	/**
	 * @private
	 * Спрайтовый примитив.
	 */
	public class SpritePrimitive extends PolyPrimitive {

		/**
		 * @private
		 * Спрайт, которому принадлежит примитив. 
		 */
		alternativa3d var sprite:Sprite3D;  
		/**
		 * @private
		 * Параметр используется для сортировки примитивов в камере. 
		 */
		alternativa3d var screenDepth:Number;  

		/**
		 * @private
		 * Строковое представление объекта.
		 */
		override public function toString():String {
			return "[SpritePrimitive " + sprite.toString() + "]";
		}

	}
}
