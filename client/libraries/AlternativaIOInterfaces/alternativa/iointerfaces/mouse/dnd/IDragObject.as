package alternativa.iointerfaces.mouse.dnd {
	import flash.display.DisplayObject;
	
	/**
	 * Интерфейс перетаскиваемого объекта.
	 * <p>
	 * Перетаскиваемый объект фактически представляет из себя ссылку на объект,
	 * который пытаются перетащить и графику, перетаскиваемую за курсором.
	 * </p>
	 */	
	public interface IDragObject {
		
		/**
		 * Объект, который схватили 
		 */		
		function get dragObject():Object;
		
		/**
		 * Перетаскиваемая графика
		 */		
		function get dragGraphics():DisplayObject;
		
	}
}