package alternativa.gui.mouse {
	
	public final class CursorDelay implements IMouseConst {
		
		internal static const DOUBLE_CLICK_DELAY:int = 150;//250;
		internal static const HINT_DELAY:int = 600;
		internal static const HINT_TIMEOUT:int = 3000;
		
		// Максимальное время между кликами двойного щелчка в мс
		public function get DOUBLE_CLICK_DELAY():int { return DOUBLE_CLICK_DELAY};
		
		// Задержка перед показом хинта в мс
		public function get HINT_DELAY():int { return HINT_DELAY};
		
		// Время показа хинта в мс
		public function get HINT_TIMEOUT():int { return HINT_TIMEOUT};
		
	}
}