package alternativa.gui.base {
	import alternativa.gui.init.GUI;
	import alternativa.iointerfaces.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.iointerfaces.keyboard.keyfilter.SimpleKeyFilter;
	
	/**
	 * Край масштабируемого объекта
	 */	
	internal class ResizeableBaseEdge extends ActiveShapeObject {
		
		/* 3 ...  0
		   1 1  1 1
		   | |  | |
		   | |  | \_ TOP
		   | |  \___ BOTTOM 
		   | |
		   | \______ LEFT
		   \________ RIGHT
		   
		   1001 - TOP_RIGHT
		*/
		/**
		 * Тип края "ВЕРХНИЙ" 
		 */		
		public static const TOP:int = 1;
		/**
		 * Тип края "НИЖНИЙ" 
		 */
		public static const BOTTOM:int = 2;
		/**
		 * Тип края "ЛЕВЫЙ" 
		 */
		public static const LEFT:int = 4;
		/**
		 * Тип края "ПРАВЫЙ" 
		 */
		public static const RIGHT:int = 8;
		/**
		 * Тип края "ВЕРХНИЙ-ЛЕВЫЙ" 
		 */
		public static const TOP_LEFT:int = 5;
		/**
		 * Тип края "НИЖНИЙ-ЛЕВЫЙ" 
		 */		
		public static const BOTTOM_LEFT:int = 6;
		/**
		 * Тип края "ВЕРХНИЙ-ПРАВЫЙ" 
		 */
		public static const TOP_RIGHT:int = 9;
		/**
		 * Тип края "НИЖНИЙ-ПРАВЫЙ" 
		 */
		public static const BOTTOM_RIGHT:int = 10;
		/**
		 * @private
		 * Действие "ОТМЕНА МАСШТАБИРОВАНИЯ"
		 */		
		private const KEY_ACTION_CANCEL_RESIZE:String = "ResizeableBaseEdgeCancelResize";
		/**
		 * @private
		 * Тип края
		 */		
		private var _type:int;
		/**
		 * @private
		 * Ссылка на масштабируемый объект
		 */
		private var resizeableObject:ResizeableBase;
		/**
		 * @private
		 * Фильтр отмены масштабирования по Esc
		 */
		private var escFilter:FocusKeyFilter;
		
		
		public function ResizeableBaseEdge(resizeableObject:ResizeableBase, type:int, enabled:Boolean) {
			super();
			this.resizeableObject = resizeableObject;
			_type = type;
			cursorActive = enabled;
			
			// Подключение фильтра отмены масштабирования по Esc
			escFilter = new FocusKeyFilter(resizeableObject, new SimpleKeyFilter(new Array([27])));
			keyFiltersConfig.bindKeyUpAction(KEY_ACTION_CANCEL_RESIZE, resizeableObject, resizeableObject.onCancelResize);
		}
		
		/**
		 * Флаг нажатия
		 */
		override public function set pressed(value:Boolean):void {
			super.pressed = value;
			if (_pressed) {
				// Подписка на событие клавиатуры
				keyFiltersConfig.addKeyUpFilter(escFilter, KEY_ACTION_CANCEL_RESIZE);
				// Рассылка события о начале масштабирования
				resizeableObject.onStartResize(this);
				// Подписываем масштабируемый объект на изменение координат мыши
				GUI.mouseManager.addMouseCoordListener(resizeableObject);
			} else {
				// Отписываем масштабируемый объект от изменения координат мыши
				GUI.mouseManager.removeMouseCoordListener(resizeableObject);
				// Рассылка события о завершении масштабирования
				resizeableObject.onStopResize();
				// Отписка от события клавиатуры
				keyFiltersConfig.removeKeyUpFilter(escFilter);
				// Возвращаем фокус на масштабируемый объект
				stage.focus = resizeableObject;
			}
		}
		
		/**
		 * Тип края 
		 */		
		public function get type():int {
			return _type;
		}
		
		/**
		 * Определение вида курсора по типу края 
		 * @return вид курсора
		 */		
		private function getCursor():uint {
			var cursorType:uint;
			switch (_type) {
				case TOP_LEFT:
				case BOTTOM_RIGHT:
					cursorType = GUI.mouseManager.cursorTypes.RESIZE_DIAGONAL_DOWN;
					break;
				case TOP_RIGHT:
				case BOTTOM_LEFT:
					cursorType = GUI.mouseManager.cursorTypes.RESIZE_DIAGONAL_UP;
					break;
				case TOP:
				case BOTTOM:
					cursorType = GUI.mouseManager.cursorTypes.RESIZE_VERTICAL;
					break;
				case LEFT:
				case RIGHT:
					cursorType = GUI.mouseManager.cursorTypes.RESIZE_HORIZONTAL;
					break;
			}
			return cursorType;
		}
		/**
		 * Внешний вид курсора при наведении на объект
		 */
		override public function get cursorOverType():uint {
			return getCursor();
		}
		/**
		 * Внешний вид курсора при нажатии на объект или наведении на нажатый объект
		 */
		override public function get cursorPressedType():uint {
			return getCursor();
		}
		
		
		
	}
}