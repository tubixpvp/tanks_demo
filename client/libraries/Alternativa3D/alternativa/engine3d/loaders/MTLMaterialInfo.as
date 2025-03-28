package alternativa.engine3d.loaders {
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	/**
	 * @private
	 * Класс содержит обобщённую информацию о материале.
	 */
	public class MTLMaterialInfo {
		public var color:uint;
		public var alpha:Number;

		public var diffuseMapInfo:MTLTextureMapInfo;
		public var dissolveMapInfo:MTLTextureMapInfo;
	}
}