package alternativa.gui.base {
	import alternativa.gui.container.IContainer;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.skin.SkinManager;
	
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Облегченный интерфейсный объект на основе <code>Shape</code>
	 */
	public class GUIShapeObject extends Shape implements IGUIObject	{
		
		/**
		 * @private
		 * Текущий размер
		 */		
		protected var _currentSize:Point;
		/**
		 * @private
		 * Растягиваемость по вертикали
		 */		
		private var _stretchableV:Boolean;
		/**
		 * @private
		 * Растягиваемость по горизонтали
		 */		
		private var _stretchableH:Boolean;
		/**
		 * @private
		 * Минимальный размер
		 */		
		private var _minSize:Point;
		/**
		 * Менеджер скинования
		 */
		private var _skinManager:SkinManager;
		/**
		 * @private
		 * Корневой объект иерархии, в которой находится объект
		 */		
		private var _rootObject:IGUIObject;
		/**
		 * @private
		 * Родительский контейнер
		 */		
		protected var _parentContainer:IContainer;
		/**
		 * Флаг наличия скина
		 */	
		public var isSkined:Boolean;
		/**
		 * @private
		 * Флаг необходимости перерасчета минимального размера
		 */	
		private var _minSizeChanged:Boolean = true;
		/**
		 * @private
		 * Флаг наличия зависимости между размерами по вертикали и по горизонтали
		 */
		private var _sidesCorrelated:Boolean = false;
				
		
		public function GUIShapeObject() {	
			_currentSize = new Point();
			_minSize = new Point();
			_stretchableH = false;
			_stretchableV = false;
			isSkined = false;
		}
		
		/**
		 * Установка координат через компоновщик
		 * @param p координаты
		 */
		public function moveTo(p:Point):void {
			if (p.x != x || p.y != y) {
				var offset:Point = new Point(p.x - x, p.y - y);
				// Передача воздействия компоновщику
				IManager(parentContainer.layoutManager).handleInfluences(new Array(this), new Array(offset));
			}
		}
		
		/**
		 * Отрисовка в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */		
		public function draw(size:Point):void {
			_currentSize = size.clone();
		}

		/**
		 * Отрисовка с пересчетом в заданных размерах
		 * @param size размеры
		 */		
		public function repaint(size:Point):void {
			if (_minSizeChanged)
				computeMinSize();
			var newSize:Point = computeSize(size);
			if (!_minSizeChanged)
				draw(newSize);
		}

		/**
		 * Отрисовка с пересчетом в текущем размере
		 */		
		public function repaintCurrentSize():void {
			draw(computeSize(currentSize));
		}
		
		/**
		 * Расчет минимальных размеров объекта
		 * @return минимальные размеры
		 */	 		
		public function computeMinSize():Point {
			return _minSize.clone();
		}
		
		/**
		 * Расчет предпочтительных размеров с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */					
		public function computeSize(size:Point):Point {
			var newSize:Point = _minSize.clone();
			
			if (size != null) {
				if (_stretchableH) newSize.x = Math.max(size.x, _minSize.x);
				if (_stretchableV) newSize.y = Math.max(size.y, _minSize.y);
			} 
			
			return newSize;
		}

		/**
		 * Проверка на растягиваемость
		 * @param direction направление проверки
		 * @return растягиваемость по заданному направлению
		 */				
		public function isStretchable(direction:Boolean):Boolean {
			return  direction == Direction.VERTICAL ? _stretchableV : _stretchableH;
		}

		/**
		 * Обновление скина 
		 */		
		public function updateSkin():void {
			isSkined = true;
		}

		/**
		 * Растягиваемость по вертикали
		 */		
		public function set stretchableV(value:Boolean):void {
			_stretchableV = value;
		}
		
		/**
		 * Растягиваемость по горизонтали
		 */		
		public function set stretchableH(value:Boolean):void {
			_stretchableH = value;
		}
		
		public function set skinManager(manager:SkinManager):void {
			_skinManager = manager;
			updateSkin();			
		}

		public function set rootObject(object:IGUIObject):void {
			_rootObject = object;
		}
		
		/**
		 * Корневой объект иерархии GUI объектов (окно, панель и т.д.)
		 */		
		public function get rootObject():IGUIObject {
			return _rootObject;
		}
				
		public function set parentContainer(container:IContainer):void {
			_parentContainer = container;
		}
		
		/**
		 * Родительский контейнер
		 */	
		public function get parentContainer():IContainer {
			return _parentContainer;
		}
		
		/**
		 * Текущий размер 
		 */				
		public function get currentSize():Point {
			return _currentSize;		
		}
		
		/**
		 * Минимальный размер 
		 */			
		public function get minSize():Point {
			return _minSize;		
		}
		
		/**
		 * Менеджер скинования.
		 * <p>При чтении свойства, если у объекта нет менеджера, то возвращается менеджер скинов родителя.</p>
		 * <p>При установке менеджер устанавливается рекурсивно всем потомкам и вызывается <code>updateSkin</code>.</p>
		 */		
		public function get skinManager():SkinManager {
			var manager:SkinManager;
			if (_skinManager == null && parent != null && parent is IGUIObject) {
				manager = IGUIObject(parent).skinManager;
			} else {
				manager = _skinManager;
			}
			return manager;
		}
		
		public function set minSizeChanged(value:Boolean):void {
			_minSizeChanged = value;
		}
		
		/**
		 * Флаг актуальности минимального размера
		 */		
		public function get minSizeChanged():Boolean {
			return _minSizeChanged;
		}
		
		/**
		 * Флаг взаимосвязи размеров сторон
		 */		
		public function get sidesCorrelated():Boolean {
			return _sidesCorrelated;
		}
		
		/**
		 * @private 
		 */
		override public function toString():String {
			var result:String = new String();
			result+= "["+getQualifiedClassName(this)+"]";
			result+="\n";
			result+="currentSize:"+this._currentSize;
			result+="\n";
			result+="stretchableH:"+isStretchable(Direction.HORIZONTAL);
			result+="\n";
			result+="stretchableV:"+isStretchable(Direction.VERTICAL);
			return result;	
		
		}
		
	}
}