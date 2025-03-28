package alternativa.utils {

	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Утилиты для работы с растровыми изображениями.
	 */	
	public class BitmapUtils {

		/**
		 * Наложение прозрачности на изображение. Метод создаёт копию исходного изображения и помещает в его альфа-канал
		 * карту прозрачности, представленную вторым изображением.
		 * 
		 * @param bitmapData изображение на которое накладывается прозрачность
		 * @param alphaBitmapData grayscale изображение, представляющее карту прозрачности
		 * @param dispose удалять ли исходные изображения 
		 * @return новое растровое изображение с наложенной прозрачностью
		 */		
		static public function mergeBitmapAlpha(bitmapData:BitmapData, alphaBitmapData:BitmapData, dispose:Boolean = false):BitmapData {
			var res:BitmapData = new BitmapData(bitmapData.width, bitmapData.height);
			res.copyPixels(bitmapData, bitmapData.rect, new Point());
  			res.copyChannel(alphaBitmapData, alphaBitmapData.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			if (dispose) {
				bitmapData.dispose();
				alphaBitmapData.dispose();
			}
			return res;
		}
		
		/**
		 * Копирование фрагмента изображения в новое растровое изображение.
		 * 
		 * @param sourceBitmapData исходное изображение
		 * @param rect ограничивающий прямоугольник фрагмента
		 * @return новое растровое изображение, содержащее заданный фрагмент исходного
		 */
		static public function getFragment(sourceBitmapData:BitmapData, rect:Rectangle):BitmapData {
			var res:BitmapData = new BitmapData(rect.width, rect.height, sourceBitmapData.transparent, 0);
			res.copyPixels(sourceBitmapData, rect, new Point());
			return res;
		}
		
		/**
		 * Получение области, ограничивающей непрозрачную часть изображения.
		 * 
		 * @param bitmapData исходное изображение
		 * @return прямоугольник, ограничивающий непрозрачную часть изображения
		 */		
		static public function getNonTransparentRect(bitmapData:BitmapData):Rectangle {
			return (bitmapData.transparent) ? bitmapData.getColorBoundsRect(0xFF000000, 0, false) : bitmapData.rect;
		}

	}
}
