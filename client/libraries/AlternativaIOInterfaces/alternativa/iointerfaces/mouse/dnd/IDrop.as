package alternativa.iointerfaces.mouse.dnd {
	import alternativa.iointerfaces.mouse.ICursorActive;
	
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