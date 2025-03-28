package alternativa.gui.mouse {
	import flash.utils.Dictionary;
	
	/**
	 * Интерфейс типов курсора
	 */	
	public interface ICursorTypes {
		
		// Стандартные виды курсоров
		
		/**
		 * Нет курсора
		 */		
		function get NONE():uint;
		/**
		 * Обычный курсор
		 */
		function get NORMAL():uint;
		/**
		 * Активный курсор
		 */
		function get ACTIVE():uint;
		/**
		 * Курсор для нажатия ссылок
		 */
		function get HAND():uint;
		/**
		 * Курсор хватания драг-объекта
		 */
		function get GRAB():uint;
		/**
		 * Курсор перетаскивания драг-объекта
		 */
		function get DRAG():uint;
		/**
		 * Курсор отпускания драг-объекта
		 */
		function get DROP():uint;
		/**
		 * Курсор перетаскивания
		 */
		function get MOVE():uint;
		/**
		 * Курсор масштабирования по горизонтали
		 */
		function get RESIZE_HORIZONTAL():uint;
		/**
		 * Курсор масштабирования по вертикали
		 */
		function get RESIZE_VERTICAL():uint;
		/**
		 * Курсор масштабирования по диагонали (за правый-верхний или левый-нижний угол)
		 */
		function get RESIZE_DIAGONAL_UP():uint;
		/**
		 * Курсор масштабирования по диагонали (за правый-нижний или левый-верхний угол)
		 */
		function get RESIZE_DIAGONAL_DOWN():uint;
		/**
		 * Курсор "действие невозможно"
		 */
		function get IMPOSIBLE():uint;
		/**
		 * Курсор "редактирование текста"
		 */
		function get EDIT_TEXT():uint;
		
		// Дополнительные виды
		//function get additionalCursors():Dictionary;
		
		// Добавить дополнительный тип курсора
		//function addCursorType(cursorTypeName:String):uint;
			
	}
}