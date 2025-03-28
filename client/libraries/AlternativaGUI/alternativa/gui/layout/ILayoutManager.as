package alternativa.gui.layout {
	import alternativa.gui.container.IContainer;
	
	import flash.geom.Point;
	
	/**
	 * Интерфейс компоновщика
	 */	
	public interface ILayoutManager {
		
		/**
		 * Вычислить минимальные размеры контента контейнера
		 * @return минимальные размеры
		 */	
		function computeMinSize():Point;
		
		/**
		 * Подсчитать размер контента контейнера
		 * @param container контейнер
		 * @param size заданный размер
		 * @return рассчитанный размер
		 * 
		 */		
		function computeSize(size:Point):Point;
		
		/**
		 * Отрисовать и расположить объекты контейнера
		 * @param container контейнер
		 * @param size заданный размер
		 * @return размер отрисовки
		 */
		function draw(size:Point):Point;
		
		/**
		 * Контейнер, с которым работаем 
		 */		
		function set container(c:IContainer):void;
		
		/**
		 * Минимальный размер контента контейнера (без пересчета) 
		 */		
		function get minSize():Point;

	}
}