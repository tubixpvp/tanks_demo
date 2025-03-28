package alternativa.iointerfaces.mouse.dnd {
	import flash.events.Event;
	
	/**
	 * Событие драг'н'дропа
	 */	
	public class DragEvent extends Event {
		
		// Рассылаются объектом, с которого начали тащить
		/**
		 * Начало драга
	 	 */
		public static const START:String = "startDrag";
		/**
		 * Отмена драга
	 	 */
		public static const CANCEL:String = "cancelDrag";
		/**
		 * Успешное завершение драга
	 	 */
		public static const STOP:String = "stopDrag";
		
		// Рассылаются дроп-областью
		/**
		 * Наведение на дроп-область при перетаскивании
		 */		
		public static const OVER:String = "dragOver";
		/**
		 * Снятие наведения с дроп-области при перетаскивании
		 */
		public static const OUT:String = "dragOut";
		/**
		 * Перетаскивание над дроп-областью
		 */		
		public static const DRAG:String = "drag";
		/**
		 * Отпускание перетаскиваемого объекта на дроп-область
		 */		
		public static const DROP:String = "drop";
		
		/**
		 * Перетаскиваемый объект 
		 */		
		public var dragObject:IDragObject;
		/**
		 * X координата курсора мыши в координатах перетаскиваемого объекта 
		 */		
		public var localX:Number;
		/**
		 * Y координата курсора мыши в координатах перетаскиваемого объекта 
		 */
		public var localY:Number;
		
		/**
		 * @param type тип события
		 * @param dragObject перетаскиваемый объект 
		 * @param localX координата x курсора мыши в координатах перетаскиваемого объекта 
		 * @param localY координата y курсора мыши в координатах перетаскиваемого объекта 
		 */		
		public function DragEvent(type:String, dragObject:IDragObject, localX:Number = 0, localY:Number = 0) {
			this.dragObject = dragObject;
			this.localX = localX;
			this.localY = localY;
			super(type, true);
		}
		
	}
}