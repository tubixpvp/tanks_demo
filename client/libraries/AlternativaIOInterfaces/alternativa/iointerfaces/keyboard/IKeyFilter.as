package alternativa.iointerfaces.keyboard {
	import flash.events.KeyboardEvent;
	
	/**
	 * Интерфейс фильтра событий клавиатуры
	 */	
	public interface IKeyFilter	{
		
		/**
		 * Профильтровать событие клавиатуры
		 * @param e событие
		 * @return результат фильтрования
		 */		
		function filter(e:KeyboardEvent):Boolean;
		
		/**
		 * Список фильтруемых клавиш
		 */		
		function get keyCode():Array;
			
	}
}