package alternativa.utils {

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	/**
	 * Утилиты для работы с объектами и классами.
	 */	
	public class ObjectUtils {
		/**
		 * Получение иерархии классов объекта.
		 * 
		 * @param object объект, для которого получается иерархия классов
		 * @param topClass класс, ограничивающий иерархию сверху. Если класс не указан, то возвращается полная иерархия
		 * классов до Object.
		 * 
		 * @return массив, содержащий иерархию классов объекта
		 */		
		static public function getClassTree(object:*, topClass:Class = null):Array {
			var res:Array = new Array();
			var objectClass:Class = Class(getDefinitionByName(getQualifiedClassName(object)));
			topClass = (topClass == null) ? Object : topClass;
			while (objectClass != topClass) {
				res.push(objectClass);
				objectClass = Class(getDefinitionByName(getQualifiedSuperclassName(objectClass)));
			}
			res.push(objectClass);
			return res;
		}

		/**
		 * Получение имени класса объекта.
		 * 
		 * @param object объект 
		 * 
		 * @return имя класса объекта
		 */
		static public function getClassName(object:*):String {
			var res:String = getQualifiedClassName(object);
			var index:int = res.indexOf("::");
			return index == -1 ? res : res.substring(index + 2);
		}

		/**
		 * Получение класса объекта.
		 * 
		 * @param object объект
		 * 
		 * @return класс объекта 
		 */		
		static public function getClass(object:*):Class {
			return Class(getDefinitionByName(getQualifiedClassName(object)));
		}

	}
}
