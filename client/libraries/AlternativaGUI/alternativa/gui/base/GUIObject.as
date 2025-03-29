package alternativa.gui.base {
	import alternativa.gui.container.IContainer;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.window.WindowBase;
	import alternativa.skin.SkinManager;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Базовый интерфейсный объект
	 */
	public class GUIObject extends Sprite implements IGUIObject {
		
		/**
		 * @private
		 * Текущий размер
		 */		
		protected var _currentSize:Point;
		/**
		 * @private
		 * Растягиваемость по вертикали
		 */		
		protected var _stretchableV:Boolean;
		/**
		 * @private
		 * Растягиваемость по горизонтали
		 */		
		protected var _stretchableH:Boolean;
		/**
		 * @private
		 * Минимальный размер
		 */		
		protected var _minSize:Point;
		/**
		 * Список дочерних объектов для скинования
		 */
		private var skinObjects:Dictionary;
		/**
		 * Менеджер скинования
		 */
		private var _skinManager:SkinManager;
		/**
		 * @private
		 * Корневой объект иерархии, в которой находится объект
		 */		
		protected var _rootObject:IGUIObject;
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
		protected var _minSizeChanged:Boolean;
		/**
		 * @private
		 * Флаг наличия зависимости между размерами по вертикали и по горизонтали
		 */		
		protected var _sidesCorrelated:Boolean;
		
		
		public function GUIObject() {	
			skinObjects = new Dictionary(true);		
			
			_currentSize = new Point();
			_minSize = new Point();
			
			_stretchableH = false;
			_stretchableV = false;
			
			isSkined = false;
			_minSizeChanged = true;
			_sidesCorrelated = false;
			
			mouseEnabled = false;
			mouseChildren = false;
			
			tabEnabled = false;
			tabChildren = false;
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
			if (_minSizeChanged) {
				computeMinSize();
			}
			var newSize:Point = computeSize(size);
			if (!_minSizeChanged) {
				draw(newSize);
			} else {
				computeMinSize();
				computeSize(size);
				draw(newSize);
			}
		}

		/**
		 * Отрисовка с пересчетом в текущем размере
		 */		
		public function repaintCurrentSize():void {
			repaint(currentSize);
		}
		
		/**
		 * Расчет минимальных размеров объекта
		 * @return минимальные размеры
		 */		 		
		public function computeMinSize():Point {
			_minSizeChanged = false;
			return _minSize;
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
		 * Добавить объект
		 * @param child объект
		 * @return this
		 */		
		override public function addChild(child:DisplayObject):DisplayObject {
			addSkinnableObject(child);
			if (child is IGUIObject && this.rootObject != null) IGUIObject(child).rootObject = this.rootObject;
			super.addChild(child);				
			return this;
		}
		
		/**
		 * Добавить объект, в определенную позицию
		 * @param child объект
		 * @param index позиция
		 * @return this
		 */		
		override public function addChildAt(child:DisplayObject,index:int):DisplayObject {
			addSkinnableObject(child);
			super.addChildAt(child,index);				
			return this;
		}
		
		/**
		 * Зарегистрировать объект как skinnable объект
		 * @param object объект
		 */		
		public function addSkinnableObject(object:DisplayObject):void {
			if (object is IGUIObject) {
				skinObjects[object] = object;				
				if (skinManager!=null) IGUIObject(object).skinManager = skinManager;
			}													
		}
		 
		/**
		 * Удалить scinnable объект
		 * @param object объект
		 */		
		public function removeSkinnableObject(object:DisplayObject):void {
			delete(skinObjects[object]);			
		}
		
		/**
		 * Обновление скина 
		 */		
		public function updateSkin():void {
			isSkined = true;
			minSizeChanged = true;
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
			// Устанавливаем скины для объектов
			for each (var object:IGUIObject in skinObjects) {				
				object.skinManager = manager;		
			}
			updateSkin();			
		}
		
		public function set rootObject(object:IGUIObject):void {
			_rootObject = object;
			for each (var obj:IGUIObject in this) {				
				IGUIObject(obj).rootObject = object;		
			}
		}
		
		public function set parentContainer(container:IContainer):void {
			_parentContainer = container;
		}
		
		public function set minSizeChanged(value:Boolean):void {
			_minSizeChanged = value;
			if (_minSizeChanged && _parentContainer != null && !_parentContainer.minSizeChanged) {
				_parentContainer.minSizeChanged = true;
			} else if (_minSizeChanged && parent is WindowBase && !WindowBase(parent).minSizeChanged) {
				WindowBase(parent).minSizeChanged = true;
			}
		}
		
		/**
		 * Корневой объект иерархии GUI объектов (окно, панель и т.д.)
		 */		
		public function get rootObject():IGUIObject {
			return _rootObject;
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
			if (_skinManager == null && parent != null && parent is GUIObject) {
				manager = GUIObject(parent).skinManager;
			} else {
				manager = _skinManager;
			}
			return manager;
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
			result+= "["+getQualifiedClassName(this)+"] " + this.name;
			return result;	
		}
		
	}
}