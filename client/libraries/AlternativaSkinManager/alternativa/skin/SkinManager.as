package alternativa.skin {
	import flash.utils.Dictionary;
	
	/**
	 * Менеджер скинования
	 */	
	public class SkinManager {
		
		/**
		 * Список соответствия скинов классам объектов 
		 */		
		private var skinList:Dictionary;
		
		
		public function SkinManager() {
			skinList = new Dictionary();
		}
		 
		/**
		 * Добавить скин
		 * @param skin скин
		 * @param objectClass класс скинуемого объекта
		 */		
		public function addSkin(skin:ISkin, objectClass:Class): void {
			skinList[objectClass] = skin;
		}
		
		/**
		 * Получить скин для заданного класса объекта
		 * @param objectClass класс объекта
		 * @return скин
		 */		
		public function getSkin(objectClass:Class):ISkin {
			return skinList[objectClass];
		}
		
	}
}