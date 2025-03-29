package alternativa.gui.base {
	import alternativa.gui.container.IContainer;
	import alternativa.skin.SkinManager;
	
	import flash.geom.Point;

	/**
	 * Интерфейс базового UI объекта 
	 */
	public interface IGUIObject {
			
		/**
		 * Расчет минимальных размеров объекта
		 * @return минимальные размеры
		 */		 		
		function computeMinSize():Point;
		
		/**
		 * Расчет предпочтительных размеров с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */		 		
		function computeSize(size:Point):Point;
		
		/**
		 * Отрисовка в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */		
		function draw(size:Point):void;
		
		/**
		 * Текущий размер 
		 */ 		
		function get currentSize():Point;
		
		/**
		 * Минимальный размер 
		 */		
		function get minSize():Point;

		/**
		 * Проверка на растягиваемость
		 * @param direction направление проверки
		 * @return растягиваемость по заданному направлению
		 */
		function isStretchable(direction:Boolean):Boolean;
		
		function set minSizeChanged(value:Boolean):void;
		
		/**
		 * Флаг актуальности минимального размера
		 */		
		function get minSizeChanged():Boolean;
		
		/**
		 * Флаг взаимосвязи размеров сторон
		 */		
		function get sidesCorrelated():Boolean;

		/**
		 * Установка координат через компоновщик
		 * @param p координаты
		 */
		function moveTo(p:Point):void;
		
		function set x(value:Number):void;
		
		function set y(value:Number):void;
		
		/**
		 * Координата X 
		 */		
		function get x():Number;
		/**
		 * Координата Y 
		 */		
		function get y():Number;
		
		function set skinManager(manager:SkinManager):void;
		
		/**
		 * Менеджер скинования.
		 * <p>При чтении свойства, если у объекта нет менеджера, то возвращается менеджер скинов родителя.</p>
		 * <p>При установке менеджер устанавливается рекурсивно всем потомкам и вызывается <code>updateSkin</code>.</p>
		 */
		function get skinManager():SkinManager;
		
		/**
		 * Обновление скина 
		 */
		function updateSkin():void;
		
		function set rootObject(object:IGUIObject):void;
		
		/**
		 * Корневой объект иерархии GUI объектов (окно, панель и т.д.)
		 */		
		function get rootObject():IGUIObject;
		
		function set parentContainer(container:IContainer):void;
		
		/**
		 * Родительский контейнер
		 */	
		function get parentContainer():IContainer;
				
	}
}