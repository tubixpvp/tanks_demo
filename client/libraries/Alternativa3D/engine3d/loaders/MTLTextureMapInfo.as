package alternativa.engine3d.loaders {
	/**
	 * @private
	 * Класс содержит информацию о текстуре в формате MTL material format (Lightwave, OBJ) и функционал для разбора 
	 * описания текстуры.
	 * Описание формата можно посмотреть по адресу: http://local.wasp.uwa.edu.au/~pbourke/dataformats/mtl/
	 */
	public class MTLTextureMapInfo {
		
		// Ассоциация параметров команды объявления текстуры и методов для их чтения
		private static const optionReaders:Object = {
			"-clamp": clampReader,
			"-o": offsetReader,
			"-s": sizeReader,

			"-blendu": stubReader,
			"-blendv": stubReader,
			"-bm": stubReader,
			"-boost": stubReader,
			"-cc": stubReader,
			"-imfchan": stubReader,
			"-mm": stubReader,
			"-t": stubReader,
			"-texres": stubReader
		};
		
		// Смещение в текстурном пространстве
		public var offsetU:Number = 0;
		public var offsetV:Number = 0;
		public var offsetW:Number = 0;
		
		// Масштабирование текстурного пространства
		public var sizeU:Number = 1;
		public var sizeV:Number = 1;
		public var sizeW:Number = 1;
		
		// Флаг повторения текстуры
		public var repeat:Boolean = true;
		// Имя файла текстуры 
		public var fileName:String;
		
		/**
		 * Метод выполняет разбор данных о текстуре.
		 * 
		 * @param parts Данные о текстуре. Массив должен содержать части разделённой по пробелам входной строки MTL-файла.
		 * @return объект, содержащий данные о текстуре
		 */
		public static function parse(parts:Array):MTLTextureMapInfo {
			var info:MTLTextureMapInfo = new MTLTextureMapInfo();
			// Начальное значение индекса единица, т.к. первый элемент массива содержит тип текстуры
			var index:int = 1;
			var reader:Function;
			// Чтение параметров текстуры
			while ((reader = optionReaders[parts[index]]) != null) {
				index = reader(index, parts, info);
			}
			// Если не было ошибок, последний элемент массива должен содержать имя файла текстуры
			info.fileName = parts[index];
			return info;
		}
		
		/**
		 * Читатель-заглушка. Пропускает все неподдерживаемые параметры.
		 */
		private static function stubReader(index:int, parts:Array, info:MTLTextureMapInfo):int	{
			index++;
			var maxIndex:int = parts.length - 1;
			while ((MTLTextureMapInfo.optionReaders[parts[index]] == null) && (index < maxIndex)) {
				index++;
			}
			return index;
		}

		/**
		 * Метод чтения параметров масштабирования текстурного пространства.
		 */
		private static function sizeReader(index:int, parts:Array, info:MTLTextureMapInfo):int	{
			info.sizeU = Number(parts[index + 1]);
			index += 2;
			var value:Number = Number(parts[index]);
			if (!isNaN(value)) {
				info.sizeV = value;
				index++;
				value = Number(parts[index]);
				if (!isNaN(value)) {
					info.sizeW = value;
					index++;
				}
			}
			return index;
		}
	
		/**
		 * Метод чтения параметров смещения текстуры.
		 */
		private static function offsetReader(index:int, parts:Array, info:MTLTextureMapInfo):int	{
			info.offsetU = Number(parts[index + 1]);
			index += 2;
			var value:Number = Number(parts[index]);
			if (!isNaN(value)) {
				info.offsetV = value;
				index++;
				value = Number(parts[index]);
				if (!isNaN(value)) {
					info.offsetW = value;
					index++;
				}
			}
			return index;
		}
		
		/**
		 * Метод чтения параметра повторения текстуры.
		 */
		private static function clampReader(index:int, parts:Array, info:MTLTextureMapInfo):int		{
			info.repeat = parts[index + 1] == "off";
			return index + 2;
		}
	}
}