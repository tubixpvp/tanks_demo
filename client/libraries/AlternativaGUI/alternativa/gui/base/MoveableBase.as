package alternativa.gui.base {
	import alternativa.iointerfaces.focus.IFocus;
	import alternativa.gui.init.GUI;
	import alternativa.iointerfaces.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.iointerfaces.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.gui.layout.snap.ISnapable;
	import alternativa.gui.layout.snap.Snap;
	import alternativa.gui.layout.snap.SnapRect;
	import alternativa.iointerfaces.mouse.ICursorActive;
	import alternativa.iointerfaces.mouse.IMouseCoordListener;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Перетаскиваемый интерактивный объект с возможностью снапа (<code>ISnapable</code>)
	 */	
	public class MoveableBase extends ActiveObject implements IMouseCoordListener, ISnapable {
		
		/**
		 * @private
		 * Флаг автоматического выноса объекта наверх по нажатию
		 */		
		private var _autoTopEnabled:Boolean;
		/**
		 * @private
		 * Объект по нажатию на который начинается таскание
		 */		
		private var _moveArea:ICursorActive;
		/**
		 * @private
		 * Старое значение режима кэширования
		 */		
		private var oldCacheAsBitmap:Boolean;
		/**
		 * @private
		 * Старые координаты
		 */		
		private var oldCoords:Point;
		/**
		 * @private
		 * Точка захвата мышью
		 */		
		public var pivot:Point;
		/**
		 * @private
		 * Блокировка перетаскивания 
		 */		
		private var _moveable:Boolean;
		
		/**
		 * @private
		 * Флаг включения снапинга 
		 */		
		private var _snapEnabled:Boolean;
		/**
		 * @private
		 * Конфигурация снапинга сторон объекта
		 */		
		private var _snapConfig:int;
		/**
		 * @private
		 * Снап область
		 */		
		private var _snapRect:Rectangle;

		/**
		 * @private
		 * Действие "ОТМЕНА ПЕРЕТАСКИВАНИЯ"
		 */
		protected const KEY_ACTION_CANCEL_MOVE:String = "MoveableBaseCancelMove";
		/**
		 * @private
		 * Фильтр отмены перетаскивания по Esc
		 */
		protected var escFilter:FocusKeyFilter;
		
		// Флаг включения группировки
		//private var _groupEnabled:Boolean;
		// Группа прилипших объектов
		//private var _snapGroup:SnapGroup;
		// Флаг перетаскивания всей снапгруппы (установлен при зажатом shift)
		//private var groupMove:Boolean;
		
		//protected const KEY_ACTION_GROUPMOVE_ENABLED:String = "MoveableBaseGroupMoveEnabled";
		//protected const KEY_ACTION_GROUPMOVE_DISABLED:String = "MoveableBaseGroupMoveDisabled";
		//protected var shiftFilter:SimpleKeyFilter;
		
		
		public function MoveableBase() {
			super();
			_autoTopEnabled = true;
			_moveable = true;
			// Инициализация снапа
			_snapEnabled = true;
			_snapConfig = Snap.EXTERNAL;
			_snapRect = new Rectangle();
			
			moveArea = this;
			
			//_groupEnabled = true;
			
			// Фильтры горячих клавиш
			//shiftFilter = new SimpleKeyFilter(new Array(16, null));
			//addKeyDownAction(shiftFilter, KEY_ACTION_GROUPMOVE_ENABLED);
			//addKeyUpAction(shiftFilter, KEY_ACTION_GROUPMOVE_DISABLED);
			
			// Подключение фильтра отмены перетаскивания по Esc
			escFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array(27, null)));
			keyFiltersConfig.bindKeyUpAction(KEY_ACTION_CANCEL_MOVE, this, cancelMove);
		}
		
		/**
		 * Отрисовка в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			super.draw(size);
			if (_snapRect.width == 0 && _snapRect.height == 0 && size.x > 0 && size.y > 0) {
				snapRect = new SnapRect(0, 0, size.x, size.y);
			}
		}
		
		/**
		 * Перетаскивание
		 * @param mouseCoord глобальные координаты мыши
		 */		
		public function mouseMove(mouseCoord:Point):void {
			//removeKeyDownAction(shiftFilter);
			//removeKeyUpAction(shiftFilter);
			// Расчет смещения
			var localCoords:Point = globalToLocal(mouseCoord);
			var offset:Point = new Point(localCoords.x - pivot.x, localCoords.y - pivot.y);
			// Передача воздействия компоновщику
			IManager(parentContainer.layoutManager).handleInfluences(new Array(this), new Array(offset));
		}

		/**
		 * Отмена перетаскивания
		 */		
		public function cancelMove():void {
			if (oldCoords != null) {
				moveTo(oldCoords);
			}
			if (pressed == true) {
				pressed = false;
			}
		}

		/**
		 * Изменились координаты
		 */
		protected function updateCoords():void {}
		
		//----- ICursorActive
		/**
		 * Внешний вид курсора при наведении на объект
		 */
		/*override public function get cursorOverType():uint {
			var cursorType:uint;
			if (_moveable && _moveArea == this) {
				cursorType = IOInterfaces.mouseManager.cursorTypes.MOVE;
			} else {
				cursorType = IOInterfaces.mouseManager.cursorTypes.ACTIVE;
			}
			return cursorType;
		}*/
		/**
		 * Внешний вид курсора при нажатии на объект или наведении на нажатый объект
		 */
		/*override public function get cursorPressedType():uint {
			var cursorType:uint;
			if (_moveable && _moveArea == this) {
				cursorType = IOInterfaces.mouseManager.cursorTypes.MOVE;
			} else {
				cursorType = IOInterfaces.mouseManager.cursorTypes.ACTIVE;
			}
			return cursorType;
		}*/
		
		
		//----- ICursorActiveListener
		 
		override public function set pressed(value:Boolean):void {
			_pressed = value;
			
			if (_pressed) {
				// При нажатии вынести объект наверх
				if (_autoTopEnabled) {
					if (parent.getChildIndex(this) < parent.numChildren - 1) {
						parent.setChildIndex(this, parent.numChildren-1);
					}
				}
				// START MOVE
				if (_moveable) {
				//if (_moveable && !_focused) {
					// Сохраняем режим кэширования графики
					oldCacheAsBitmap = cacheAsBitmap;
					// Включаем кэширование
					cacheAsBitmap = true;
					// Сохраняем координаты
					pivot = new Point(mouseX, mouseY);
					oldCoords = new Point(x, y);
					// Подписываемся на событие клавиатуры
					if (escFilter != null) {
						keyFiltersConfig.addKeyUpFilter(escFilter, KEY_ACTION_CANCEL_MOVE);
					}
					// Подписываемся на изменение координат мыши
					GUI.mouseManager.addMouseCoordListener(this);
				}
			} else {
				// STOP MOVE
				if (_moveable) {
				//if (_moveable && !_focused) {
					// Восстанавливаем режим кэширования графики
					cacheAsBitmap = oldCacheAsBitmap;
					// Отписываемся от события клавиатуры
					if (escFilter != null) {
						keyFiltersConfig.removeKeyUpFilter(escFilter);
					}
					// Сообщаем об изменении координат, если они изменились
					if (!oldCoords.equals(new Point(x, y))) updateCoords();
					// Отписываемся от изменения координат мыши
					GUI.mouseManager.removeMouseCoordListener(this);
					
					//addKeyDownAction(shiftFilter, KEY_ACTION_GROUPMOVE_ENABLED);
					//addKeyUpAction(shiftFilter, KEY_ACTION_GROUPMOVE_DISABLED);
					//groupMove = false;
				}
			}
		}
		
		//----- SNAP
		/**
		 * Флаг снапинга
		 */
		public function get snapEnabled():Boolean {
			return _snapEnabled;
		}
		public function set snapEnabled(value:Boolean):void {
			_snapEnabled = value;
		}
		
		/**
		 * Побитовая конфигурация снапинга сторон 
		 */		
		public function get snapConfig():int {
			return _snapConfig;
		}
		public function set snapConfig(value:int):void {
			_snapConfig = value;
		}
		
		/**
		 * Габаритный контейнер для снапинга (в локальных коодинатах)
		 */
		public function get snapRect():Rectangle {
			return _snapRect;
		}
		public function set snapRect(rect:Rectangle):void {
			_snapRect = rect;
		}
		
		
		// ISnapGroupable
		/*public function set groupEnabled(value:Boolean):void {
			_groupEnabled = value;
		}
		public function get groupEnabled():Boolean {
			return _groupEnabled;
		}
		
		public function set snapGroup(group:SnapGroup):void {
			_snapGroup = group;
		}
		public function get snapGroup():SnapGroup {
			return _snapGroup;
		}*/
		
		
		/*override public function keyDown(code:uint, filter:IKeyFilter):void {
			var action:String = keyDownActions[filter];
			switch (action) {
				case KEY_ACTION_GROUPMOVE_ENABLED:
					if (!groupMove) {
						groupMove = true;
					}
					break;
				
			}
		}*/
		
		/*override public function keyUp(code:uint, filter:IKeyFilter):void {
			var action:String = keyUpActions[filter];
			switch (action) {
				case KEY_ACTION_GROUPMOVE_DISABLED:
					groupMove = false;
					break;
				case KEY_ACTION_CANCEL_MOVE:
					if (oldCoords != null) {
						moveTo(oldCoords);
					}
					if (pressed == true) {
						pressed = false;
					}
					break;
			}
		}*/
		
		public function set autoTopEnabled(value:Boolean):void {
			_autoTopEnabled = value;
		}
		/**
		 * Флаг автоматического выноса объекта наверх по нажатию 
		 */		
		public function get autoTopEnabled():Boolean {
			return _autoTopEnabled;
		}
		
		public function set moveArea(value:ICursorActive):void {
			// Отлючаем текущую, если есть
			if (_moveArea != null) {
				_moveArea.removeCursorListener(this);
				_moveArea.cursorOverType = GUI.mouseManager.cursorTypes.ACTIVE;
				_moveArea.cursorPressedType = GUI.mouseManager.cursorTypes.ACTIVE;
			}
			// Присваиваем новую
			_moveArea = value;
			if (value != null) {
				_moveArea.addCursorListener(this);
				// Установка курсора
				_moveArea.cursorOverType = GUI.mouseManager.cursorTypes.MOVE;
				_moveArea.cursorPressedType = GUI.mouseManager.cursorTypes.MOVE;
				// Фильтр отмены перетаскивания
				if (_moveArea is IFocus) {
					escFilter = new FocusKeyFilter(IFocus(_moveArea), new SimpleKeyFilter(new Array(27, null)));
				} else {
					escFilter = null;
				}
			}
		}
		/**
		 * Область, за которую объект перетаскивается
		 */		
		public function get moveArea():ICursorActive {
			return _moveArea;
		}
		
		public function set moveable(value:Boolean):void {
			if (_moveable != value) {
				_moveable = value;
			}
		}
		/**
		 * Блокировка перетаскивания
		 */		
		public function get moveable():Boolean {
			return _moveable;
		}
		
		
	}
}