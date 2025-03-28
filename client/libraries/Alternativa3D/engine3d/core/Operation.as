package alternativa.engine3d.core {
	import alternativa.engine3d.*;
	import alternativa.types.Set;
	
	use namespace alternativa3d;
	
	/**
	 * @private
	 */
	public class Operation {

		alternativa3d static const OBJECT_CALCULATE_TRANSFORMATION:uint = 0x01000000;
		alternativa3d static const OBJECT_CALCULATE_MOBILITY:uint = 0x02000000;
		alternativa3d static const VERTEX_CALCULATE_COORDS:uint = 0x03000000;
		alternativa3d static const FACE_CALCULATE_BASE_UV:uint = 0x04000000;
		alternativa3d static const FACE_CALCULATE_NORMAL:uint = 0x05000000;
		alternativa3d static const FACE_CALCULATE_UV:uint = 0x06000000;
		alternativa3d static const FACE_UPDATE_PRIMITIVE:uint = 0x07000000;
		alternativa3d static const SECTOR_UPDATE:uint = 0x08000000;
		alternativa3d static const SPLITTER_UPDATE:uint = 0x09000000;
		alternativa3d static const SCENE_CALCULATE_BSP:uint = 0x0A000000;
		alternativa3d static const SECTOR_FIND_NODE:uint = 0x0B000000;
		alternativa3d static const SPLITTER_CHANGE_STATE:uint = 0x0C000000;
		alternativa3d static const SECTOR_CHANGE_VISIBLE:uint = 0x0D000000;
		alternativa3d static const FACE_UPDATE_MATERIAL:uint = 0x0E000000;
		alternativa3d static const SPRITE_UPDATE_MATERIAL:uint = 0x0F000000;
		alternativa3d static const CAMERA_CALCULATE_MATRIX:uint = 0x10000000;
		alternativa3d static const CAMERA_CALCULATE_PLANES:uint = 0x11000000;
		alternativa3d static const CAMERA_RENDER:uint = 0x12000000;
		alternativa3d static const SCENE_CLEAR_PRIMITIVES:uint = 0x13000000;

		// Объект
		alternativa3d var object:Object;

		// Метод
		alternativa3d var method:Function;

		// Название метода
		alternativa3d var name:String;

		// Последствия
		private var sequel:Operation; 
		private var sequels:Set;

  		// Приоритет операции
		alternativa3d var priority:uint;

		// Находится ли операция в очереди
		alternativa3d var queued:Boolean = false;

		public function Operation(name:String, object:Object = null, method:Function = null, priority:uint = 0) {
			this.object = object;
			this.method = method;
			this.name = name;
			this.priority = priority;
		}

		// Добавить последствие
		alternativa3d function addSequel(operation:Operation):void {
			if (sequel == null) {
				if (sequels == null) {
					sequel = operation;
				} else {
					sequels[operation] = true;
				}
			} else {
				if (sequel != operation) {
					sequels = new Set(true);
					sequels[sequel] = true;
					sequels[operation] = true;
					sequel = null;
				}
			}
		}

		// Удалить последствие
		alternativa3d function removeSequel(operation:Operation):void {
			if (sequel == null) {
				if (sequels != null) {
					delete sequels[operation];
					var key:*;
					var single:Boolean = false;
					for (key in sequels) {
						if (single) {
							single = false;
							break;
						}
						single = true;
					}
					if (single) {
						sequel = key;
						sequels = null;
					}
				}
			} else {
				if (sequel == operation) {
					sequel = null;
				}
			}
		}

		alternativa3d function collectSequels(collector:Array):void {
			if (sequel == null) {
				// Проверяем последствия
				for (var key:* in sequels) {
					var operation:Operation = key;
					// Если операция ещё не в очереди
					if (!operation.queued) {
						// Добавляем её в очередь
						collector.push(operation);
						// Устанавливаем флаг очереди
						operation.queued = true;
						// Вызываем добавление в очередь её последствий
						operation.collectSequels(collector);
					}
				}
			} else {
				if (!sequel.queued) {
					collector.push(sequel);
					sequel.queued = true;
					sequel.collectSequels(collector);
				}
			}
		}

		public function toString():String {
			return "[Operation " + (priority >>> 24) + "/" + (priority & 0xFFFFFF) + " " + object + "." + name + "]";
		}

	}
}
