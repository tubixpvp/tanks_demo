package alternativa.engine3d.materials {

	/**
	 * Класс содержит константы точности перспективной коррекции текстурного материала.
	 * 
	 * @see TextureMaterial
	 */
	public class TextureMaterialPrecision {

		/**
		 * Адаптивная триангуляция не будет выполняться, только простая триангуляция. 
		 */
		public static const NONE:Number = -1;
		/**
		 * Очень низкое качество адаптивной триангуляции.
		 */
		public static const VERY_LOW:Number = 50;
		/**
		 * Низкое качество адаптивной триангуляции.
		 */
		public static const LOW:Number = 25;
		/**
		 * Среднее качество адаптивной триангуляции. 
		 */
		public static const MEDIUM:Number = 10;
		/**
		 * Высокое качество адаптивной триангуляции.
		 */
		public static const HIGH:Number = 6;
		/**
		 * Очень высокое качество адаптивной триангуляции.
		 */
		public static const VERY_HIGH:Number = 3;
		/**
		 * Максимальное качество адаптивной триангуляции.
		 */
		public static const BEST:Number = 1;

	}
}
