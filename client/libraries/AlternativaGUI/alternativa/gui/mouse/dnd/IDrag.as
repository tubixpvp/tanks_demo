package alternativa.gui.mouse.dnd {
	import alternativa.gui.mouse.ICursorActive;
	
	/**
	 * Интерфейс объекта, захватываемого для перетаскивания
	 */	
	public interface IDrag extends ICursorActive {
		
		/**
	 	 * Возможность захвата для перетаскивания
	 	 */
		function isDragable():Boolean;
		
		/**
	 	 * Перетаскиваемый объект
	 	 */
		function getDragObject():IDragObject;
		
	}
}