package alternativa.engine3d.loaders {

	/**
	 * Структура для хранения имён файла диффузной текстуры и файла карты прозрачности.
	 */
	public class TextureMapsInfo {
		/**
		 * Имя файла диффузной текстуры.
		 */		
		public var diffuseMapFileName:String;
		/**
		 * Имя файла карты прозрачности.
		 */
		public var opacityMapFileName:String;
		
		public function TextureMapsInfo(diffuseMapFileName:String = null, opacityMapFileName:String = null) {
			this.diffuseMapFileName = diffuseMapFileName;
			this.opacityMapFileName = opacityMapFileName;
		}
	}
}