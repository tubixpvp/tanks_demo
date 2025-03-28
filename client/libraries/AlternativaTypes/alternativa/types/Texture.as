package alternativa.types {
	import flash.display.BitmapData;
	
	use namespace alternativatypes;
	
	/**
	 * Класс предназначен для хранения текстур, используемых в материалах.
	 * 
	 * @see alternativa.engine3d.materials.TextureMaterial  
	 */
	public class Texture {

		/**
		 * @private
		 * Графическое содержимое текстуры
		 */
		alternativatypes var _bitmapData:BitmapData;

		/**
		 * @private
		 * Ширина текстуры
		 */
		alternativatypes var _width:uint;

		/**
		 * @private
		 * Высота тестуры
		 */
		alternativatypes var _height:uint;

		/**
		 * @private
		 * Наименование текстуры
		 */
		alternativatypes var _name:String;

		/**
		 * Создание экземпляра текстуры.
		 * 
		 * @param bitmapData графическое содержимое текстуры
		 * @param name наименование текстуры
		 * 
		 * @throws Error в качестве bitmapData был указан <code>null</code>
		 */
		public function Texture(bitmapData:BitmapData, name:String = null) {
			if (bitmapData == null) {
				throw new Error("Cannot create texture from null bitmapData");
			}
			_bitmapData = bitmapData;
			_width = bitmapData.width;
			_height = bitmapData.height;
			_name = name;
		}
		
		/**
		 * Графическое содержимое текстуры.
		 */		
		public function get bitmapData():BitmapData {
			return _bitmapData;
		}

		/**
		 * Ширина текстуры.
		 */
		public function get width():uint {
			return _width;
		}
		
		/**
		 * Высота тестуры.
		 */
		public function get height():uint {
			return _height;
		}

		/**
		 * Наименование текстуры.
		 */
		public function get name():String {
			return _name;
		}

		/**
		 * Строковое представление объекта.
		 *
		 * @return строковое представление объекта
		 */
		public function toString():String {
			return "[Texture " + ((_name != null) ? _name : "") + " " + _width + "x" + _height + "]";
		}

	}
}
