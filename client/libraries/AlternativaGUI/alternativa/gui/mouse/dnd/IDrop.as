package alternativa.gui.mouse.dnd {
	import alternativa.gui.mouse.ICursorActive;
	
	/**
	 * Интерфейс объекта, принимающего перетаскиваемый объект
	 */	
	public interface IDrop extends ICursorActive {
		
		/**
	 	 * Возможность приема перетаскиваемого объекта
	 	 */
		function canDrop(dragObject:IDragObject):Boolean;
	
	}
}