package alternativa.engine3d.materials {
	/**
	 * @private
	 * Точка, подготовленная к отрисовке.
	 */
	public final class DrawPoint {

		/**
		 * Координата X в системе координат камеры.
		 */
		public var x:Number;
		/**
		 * Координата Y в системе координат камеры.
		 */
		public var y:Number;
		/**
		 * Координата Z в системе координат камеры.
		 */
		public var z:Number;
		/**
		 * Координата U в текстурном пространстве.
		 */
		public var u:Number;
		/**
		 * Координата V в текстурном пространстве.
		 */
		public var v:Number;

		/**
		 * Создаёт новый экземпляр класса.
		 * 
		 * @param x координата X в системе координат камеры
		 * @param y координата Y в системе координат камеры
		 * @param z координата Z в системе координат камеры
		 * @param u координата U в текстурном пространстве
		 * @param v координата V в текстурном пространстве
		 */
		public function DrawPoint(x:Number, y:Number, z:Number, u:Number = 0, v:Number = 0) {
			this.x = x;
			this.y = y;
			this.z = z;
			this.u = u;
			this.v = v;
		}

	}
}
