package alternativa.gui.window {
	import alternativa.gui.base.IGUIObject;
	import alternativa.gui.base.ResizeableBase;
	import alternativa.gui.container.Container;
	import alternativa.gui.container.WindowContainer;
	import alternativa.gui.focus.IFocus;
	import alternativa.gui.focus.IFocusListener;
	import alternativa.gui.init.GUI;
	import alternativa.gui.layout.ILayoutManager;
	import alternativa.gui.layout.IWindowLayoutManager;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.WindowAlign;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.skin.window.WindowSkin;
	import alternativa.gui.widget.button.IButton;
	
	import flash.display.Bitmap;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class WindowBase	extends ResizeableBase implements IFocusListener {
		/**
		 * Общий контейнер 
		 */		
		protected var windowContainer:Container;
		/**
		 * Контейнер всего заголовка 
		 */		
		protected var titleContainer:Container;
		/**
		 * Контейнер заголовков вкладок
		 */		
		protected var tabTitleContainer:Container;
		/**
		 * Контейнер кнопок управления окном вне заголовков вкладок 
		 */		
		protected var controlButtonContainer:Container;
		/**
		 * Контейнер контента 
		 */		
		protected var container:Container;
		/**
		 * Родительский оконный контейнер 
		 */		
		protected var _parentWindowContainer:WindowContainer;
		/**
		 * Контейнер для элементов поверх всего содержимого
		 */		
		protected var _topContainer:Container;
		
		// Части графики
		protected var cTLbmp:Bitmap;
		protected var cTRbmp:Bitmap;
		protected var cBLbmp:Bitmap;
		protected var cBRbmp:Bitmap;
		protected var eTCbmp:Bitmap;
		protected var eMLbmp:Bitmap;
		protected var eMRbmp:Bitmap;
		protected var eBCbmp:Bitmap;
		protected var bgbmp:Bitmap;
		
		/**
		 * Скин 
		 */		
		protected var skin:WindowSkin;
		/**
		 * Флаг закрываемости
		 */		
		protected var closeable:Boolean;
		/**
		 * Флаг сворачиваемости
		 */		
		protected var minimizeable:Boolean;
		/**
		 * Флаг разворачиваемости
		 */		
		protected var maximizeable:Boolean;
		/**
		 * Флаг сворачивания
		 */		
		private var _minimized:Boolean;
		/**
		 * Флаг разворачивания
		 */		
		private var _maximized:Boolean;
		/**
		 * Флаг выбранности 
		 */		
		private var _selected:Boolean;
		/**
		 * Флаг наличия заголовка
		 */		
		protected var titled:Boolean;
		/**
		 * Текст заголовка
		 */		
		protected var _title:String;
		/**
		 * Заголовок
		 */		
		protected var winTitle:WindowTitleBase;
		/**
		 * Графика окна
		 */		
		protected var gfx:Sprite;
		/**
		 * Выравнивание окна на экране (крепление к сторонам экрана)
		 */		
		protected var _align:int;
		/**
		 * Список объектов в окне в порядке их таб-индексов
		 */		
		private var _tabIndexes:Array;
		
		// Сохраненные при разворачивании значения флагов масштабирования по сторонам
		protected var oldTopResizeEnabled:Boolean;
		protected var oldBottomResizeEnabled:Boolean;
		protected var oldLeftResizeEnabled:Boolean;
		protected var oldRightResizeEnabled:Boolean;
		
		
		public function WindowBase(minWidth:uint = 0, minHeight:uint = 0, resizeEnabled:Boolean = true, titled:Boolean = true, title:String = "", closeable:Boolean = true, minimizeable:Boolean = false, maximizeable:Boolean = false, screenAlign:int = WindowAlign.NONE) {
			super(resizeEnabled, resizeEnabled, resizeEnabled, resizeEnabled);
			
			tabEnabled = true;
			tabChildren = true;
			mouseChildren = true;
			
			// Сохранение флагов масштабирования
			oldTopResizeEnabled = resizeEnabled;
			oldBottomResizeEnabled = resizeEnabled;
			oldLeftResizeEnabled =  resizeEnabled;
			oldRightResizeEnabled = resizeEnabled;
			
			// Сохранение параметров
			this.titled = titled;
			this.closeable = closeable;
			this.minimizeable = minimizeable;
			this.maximizeable = maximizeable;
			_align = screenAlign;
			_selected = false;
			_minimized = false;
			_maximized = false;
			
			// Создание общего контейнера
			windowContainer = new Container();
			windowContainer.name = "WindowBase windowContainer";
			windowContainer.stretchableH = true;
			windowContainer.stretchableV = true;
			addChildAt(windowContainer, 0);
			// Сохранение параметров общего контейнера
			windowContainer.minSize.x = minWidth;
			windowContainer.minSize.y = minHeight;
			// Установка корневого объекта иерархии
			windowContainer.rootObject = this;
			
			if (titled) {
				_title = title;
				// Создание верхнего контейнера (для заголовков и кнопок управления окном)
				createTitleContainer();
			}
			
			// Создание контейнера контента
			createContentContainer();
			
			// Создаём части графики окна
			cTLbmp = new Bitmap();
			cTRbmp = new Bitmap();
			cBLbmp = new Bitmap();
			cBRbmp = new Bitmap();
			eTCbmp = new Bitmap();
			eMLbmp = new Bitmap();
			eMRbmp = new Bitmap();
			eBCbmp = new Bitmap();
			bgbmp = new Bitmap();
			
			gfx = new Sprite();
			gfx.mouseEnabled = false;
			gfx.mouseChildren = false;
			gfx.tabEnabled = false;
			gfx.tabChildren = false;
			
			gfx.addChild(cTLbmp);
			gfx.addChild(cTRbmp);
			gfx.addChild(cBLbmp);
			gfx.addChild(cBRbmp);
			gfx.addChild(eTCbmp);
			gfx.addChild(eMLbmp);
			gfx.addChild(eMRbmp);
			gfx.addChild(eBCbmp);
			gfx.addChild(bgbmp);
			
			container.addChildAt(gfx, 0);
			
			// Создание контейнера для элементов поверх всего содержимого
			_topContainer = new Container();
			addChild(_topContainer);
			// Установка корневого объекта иерархии
			_topContainer.rootObject = this;
			
			_tabIndexes = new Array(); 
		}
		
		/**
		 * Cоздание верхнего контейнера
		 */		
		protected function createTitleContainer():void {
			titleContainer = new Container();
			titleContainer.name = "WindowBase titleContainer";
			titleContainer.stretchableH = true;
			titleContainer.stretchableV = false;
			windowContainer.addObject(titleContainer);
			
			// Создание контейнера заголовков
			tabTitleContainer = new Container();
			tabTitleContainer.name = "WindowBase tabTitleContainer";
			tabTitleContainer.stretchableH = true;
			tabTitleContainer.stretchableV = false;
			titleContainer.addObject(tabTitleContainer);
			
			// Создание контейнера кнопок управления окном
			controlButtonContainer = new Container();
			controlButtonContainer.name = "WindowBase controlButtonContainer";
			controlButtonContainer.stretchableH = false;
			controlButtonContainer.stretchableV = false;
			titleContainer.addObject(controlButtonContainer);
			
			// Добавление заголовка окна
			winTitle = createTitle(container, title, closeable, minimizeable, maximizeable);
			if (winTitle != null) {
				winTitle.parentWindow = this;
				addTitle(winTitle);
				moveArea = winTitle;
				this.cursorOverType = GUI.mouseManager.cursorTypes.NORMAL;
				this.cursorPressedType = GUI.mouseManager.cursorTypes.NORMAL;
			}
		}
		
		/**
		 * Создание контейнера контента
		 */		
		protected function createContentContainer():void {
			container = new Container();
			container.name = "WindowBase contentContainer";
			container.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.TOP);
			windowContainer.addObject(container);
			container.stretchableH = true;
			container.stretchableV = true;
		}
		
		/**
		 * Создание заголовка
		 * @param contentContainer контейнер контента, относящегося к этому заголовку
		 * @param titleString строка заголока
		 * @param closeable наличие кнопки закрытия
		 * @param minimizeable наличие кнопки сворачивания
		 * @param maximizeable наличие кнопки разворачивания
		 * @return заголовок
		 */		
		protected function createTitle(contentContainer:Container, titleString:String, closeable:Boolean, minimizeable:Boolean, maximizeable:Boolean):WindowTitleBase {
			return new WindowTitleBase(contentContainer, titleString, closeable, minimizeable, maximizeable, true);
		}
		
		/**
		 * Добавление заголовка
		 * @param title заголовок
		 */		
		public function addTitle(title:WindowTitleBase):void {
			if (titled) {
				tabTitleContainer.addObject(title);
				title.addEventListener(WindowTitleEvent.CLOSE, onTitleClose);
				title.addEventListener(WindowTitleEvent.MAXIMIZE, onTitleMaximize);
				title.addEventListener(WindowTitleEvent.MINIMIZE, onTitleMinimize);
				title.addEventListener(WindowTitleEvent.RESTORE, onTitleRestore);
				//title.addEventListener(WindowTitleEvent.SELECT, onTitleSelect);
				//title.addEventListener(WindowTitleEvent.UNSELECT, onTitleUnselect);
			}
		}
		
		/**
		 * Добавление кнопки управления окном
		 * @param button кнопка управления
		 */		
		public function addControlButton(button:IButton):void {
			if (titled) {
				controlButtonContainer.addObject(button);
			}
		}			
		
		/**
		 * Установка скина
		 */		
		override public function updateSkin():void {
			skin = WindowSkin(skinManager.getSkin(getSkinType()));
			super.updateSkin();
			
			// Загрузка битмап из скина
			loadBitmaps();
			
			// Установка отступов и пробелов
			container.marginLeft = skin.containerMargin;
			container.marginTop = skin.containerMargin;
			container.marginRight = skin.containerMargin;
			container.marginBottom = skin.containerMargin;
			
			windowContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.TOP);
			
			if (titled) {
				titleContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.TOP);
				tabTitleContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, skin.titleSpace);
				titleContainer.marginLeft = skin.titleMargin;
				titleContainer.marginRight = skin.titleMargin;
				
				controlButtonContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.TOP, skin.controlButtonSpace);
				
				if (controlButtonContainer.objects.length > 0) {				
					controlButtonContainer.marginLeft = skin.controlButtonMarginLeft;
					controlButtonContainer.marginTop = skin.controlButtonMarginTop;
					controlButtonContainer.marginRight = skin.controlButtonMarginRight;
				}
			}
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс скинования
		 */		
		protected function getSkinType():Class {
			return WindowBase;
		}
		
		/**
		 * Загрузка битмап из скина
		 */		
		protected function loadBitmaps():void {
			cTLbmp.bitmapData = skin.cornerTLmargin;
			cTRbmp.bitmapData = skin.cornerTRmargin;
			cBLbmp.bitmapData = skin.cornerBL;
			cBRbmp.bitmapData = skin.cornerBR;
			eTCbmp.bitmapData = skin.edgeTC;
			eMLbmp.bitmapData = skin.edgeML;
			eMRbmp.bitmapData = skin.edgeMR;
			eBCbmp.bitmapData = skin.edgeBC;
			bgbmp.bitmapData = skin.bgMC;
			
			if (titled) {
				cTLbmp.bitmapData = skin.cornerTLactive;
				cTRbmp.bitmapData = skin.cornerTRactive;
				eTCbmp.bitmapData = skin.edgeTCactive;
			}
		}
		
		/**
		 * Вынос окна на передний план
		 */		
		public function toFront():void {
			if (parent.getChildIndex(this) < parent.numChildren - 1) {
				parent.setChildIndex(this, parent.numChildren-1);
			}
		}
		
		/**
		 * Расчет минимальных размеров
		 * @param size исходные размеры от менеджера компоновки
		 * @return минимальные размеры
		 */
		override public function computeMinSize():Point {
			var newSize:Point = windowContainer.computeMinSize();
			minSizeChanged = false;
			//trace("WindowBase computeMinSize newSize: " + newSize);
			return newSize;
		}
		
		/**
		 * Расчет предпочтительных размеров с учетом stretchable флагов и минимальных размеров.
		 * @param size заданные размеры
		 * @return рассчитанные размеры
		 */
		override public function computeSize(size:Point):Point {
			var newSize:Point = windowContainer.computeSize(size);
			return newSize;
		}
		
		/**
		 * Отрисовка в заданном размере
		 * @param size заданный размер
		 */	
		override public function draw(size:Point):void {
			super.draw(size);
			windowContainer.draw(size);
			// Перерисовываем рёбра и фон
			arrangeGraphics(container.currentSize);
		}
		
		/**
		 * Перерисовка частей графики
		 * @param size размер графики окна
		 */		
		protected function arrangeGraphics(size:Point):void {
			// Находим координаты нижнего правого угла
			var farX:int = size.x - cBRbmp.width;
			var farY:int = size.y - cBRbmp.height;
				
			// Расставляем углы
			cTRbmp.x = farX;
			cBLbmp.y = farY;
			cBRbmp.x = farX;
			cBRbmp.y = farY;
			
			var newWidth:int = size.x - cTLbmp.width - cTRbmp.width;
			var newHeight:int = size.y - cTLbmp.height - cBLbmp.height;
				
			eTCbmp.x = cTLbmp.width;
			eTCbmp.width = newWidth;
			
			eMLbmp.y = cTLbmp.height;
			eMLbmp.height = newHeight;
			
			eMRbmp.x = farX;
			eMRbmp.y = cTRbmp.height;
			eMRbmp.height = newHeight;
			
			eBCbmp.x = cBLbmp.width;
			eBCbmp.y = farY;
			eBCbmp.width = newWidth;
			
			bgbmp.x = cTLbmp.width;
			bgbmp.y = cTLbmp.height;
			bgbmp.width = newWidth;
			bgbmp.height = newHeight;
		}
		
		override public function repaintCurrentSize():void {
			var old:Point = currentSize;
			repaint(currentSize);
			if (!currentSize.equals(old)) updateSize();
		}

		// Добавить объект в контейнер
		public function addObject(object:IGUIObject):void {
			container.addObject(object);
			
			if (object is IFocus) {
				if (InteractiveObject(object).tabIndex != -1) {
					_tabIndexes.push(object);
					InteractiveObject(object).tabIndex = _tabIndexes.length-1;
				}
			}
		}
		
		// Добавить объект перед существующим объектом
		/*public function addObjectBefore(object:IGUIObject, before:IGUIObject):void {
			container.addObjectBefore(object, before);
		}

		// Добавить объект после существующего объекта
		public function addObjectAfter(object:IGUIObject, after:IGUIObject):void {
			container.addObjectAfter(object, after);
		}

		// Добавить объект в определённую позицию
		public function addObjectAt(object:IGUIObject, index:int):void {
			container.addObjectAt(object, index);
		}*/
		
		// Удалить объект из контейнера
		public function removeObject(object:IGUIObject):void {
			container.removeObject(object);
			// Удаление объекта из последовательности табуляции
			var index:int = tabIndexes.indexOf(object);
			if (index != -1) {
				tabIndexes.splice(index, 1);
				tabIndexes = tabIndexes;
			}
		}
		
		// Удалить объект из определённой позиции
		/*public function removeObjectAt(index:int):void {
			container.removeObjectAt(index);
		}
		
		// Удалить все объекты
		public function removeObjects():void {
			container.removeObjects();
		}
		
		// Получить объект из определённой позиции
		public function getObjectAt(index:int):IGUIObject {
			return container.getObjectAt(index);
		}
		
		// Вставить объект в определённую позицию
		public function setObjectIndex(object:IGUIObject, index:int):void {
			container.setObjectIndex(object, index);
		}

		// Поменять объекты местами
		public function swapObjects(object1:IGUIObject, object2:IGUIObject):void {
			container.swapObjects(object1, object2);
		}

		// Поменять объекты местами
		public function swapObjectsAt(index1:int, index2:int):void {
			container.swapObjectsAt(index1, index2);
		}*/

		// Проверяет наличие объекта в контейнере
		public function hasObject(object:IGUIObject):Boolean {
			return container.hasObject(object);
		}
		
		// Указать менеджер расположения объектов в контейнере
		public function set layoutManager(manager:ILayoutManager):void {
			container.layoutManager = manager;
		}

		public function get layoutManager():ILayoutManager {
			return container.layoutManager;
		}
		
		/**
		 * Установка хинта окна и заголовка 
		 * @param value строка хинта
		 */		
		override public function set hint(value:String):void {
			super.hint = value;
			winTitle.hint = value;
		}
		
		/**
		 * Получить минимальный размер 
		 * @return минимальный размер
		 */				
		override public function get minSize():Point {
			return windowContainer.minSize;		
		}
		/**
		 * Получить заголовок окна
		 * @return заголовок окна
		 * 
		 */		
		public function get title():String {
			return _title;
		}
		/**
		 * Установить флаг свернутости
		 * @param value - состояние флага свернутости
		 * 
		 */		
		public function set minimized(value:Boolean):void {
			_minimized = value;
		}
		/**
		 * Получить флаг свернутости
		 * @return флаг свернутости
		 * 
		 */			
		public function get minimized():Boolean {
			return _minimized;
		}
		
		/**
		 * Установить флаг развернутости
		 * @param value - состояние флага развернутости
		 * 
		 */		
		public function set maximized(value:Boolean):void {
			_maximized = value;
		}
		/**
		 * Получить флаг развернутости
		 * @return флаг развернутости
		 * 
		 */			
		public function get maximized():Boolean {
			return _maximized;
		}
		
		/**
		 * Получить контейнер для отображения поверх всего содержимого
		 * @return контейнер без установленого компоновщика
		 * 
		 */		
		public function get topContainer():Container {
			return _topContainer;
		}
		
		/**
		 * Получить родительский контейнер
		 * @return контейнер
		 */		
		public function get parentWindowContainer():WindowContainer {
			return _parentWindowContainer;
		}
		
		/**
		 * Получить контейнер контента
		 * @return контейнер контента
		 * 
		 */		
		public function get contentContainer():Container {
			return container;
		}
		
		/**
		 * Установить ссылку на родительский контейнер
		 */		
		public function set parentWindowContainer(wc:WindowContainer):void {
			_parentWindowContainer = wc;
		}
		
		/**
		 * Установить таб-индексы
		 * @param objects - объекты в необходимой последовательности
		 */		
		public function set tabIndexes(objects:Array):void {
			if (objects.length != 0) {
				for (var i:int = 0; i < objects.length; i++) {
					InteractiveObject(objects[i]).tabIndex = i;
					tabIndexes.push(objects[i]);
				}
			}
		}
		/**
		 * Получить объекты, участвующие в табуляции, в порядке их индексов
		 * @return массив объектов, участвующих в табуляции
		 */		
		public function get tabIndexes():Array {
			return _tabIndexes;
		}
		
		/**
		 * Установка флага актуальности минимального размера
		 * true - надо пересчитать
		 * false - пересчитали 
		 */	
		/*override public function set minSizeChanged(value:Boolean):void {
			//trace(this + " minSizeChanged: " + value);
			_minSizeChanged = value;
			if (_minSizeChanged) {
				repaintCurrentSize();
			}
		}*/
		
		
		//----- ICursorActive
		/**
		 * Внешний вид курсора при наведении на объект
		 */
		/*override public function get cursorOverType():uint {
			var cursorType:uint;
			if (moveable && moveArea == this) {
				cursorType = IOInterfaces.mouseManager.cursorTypes.MOVE;
			} else {
				cursorType = IOInterfaces.mouseManager.cursorTypes.NORMAL;
			}
			return cursorType;
		}*/
		/**
		 * Внешний вид курсора при нажатии на объект или наведении на нажатый объект
		 */
		/*override public function get cursorPressedType():uint {
			var cursorType:uint;
			if (moveable && moveArea == this) {
				cursorType = IOInterfaces.mouseManager.cursorTypes.MOVE;
			} else {
				cursorType = IOInterfaces.mouseManager.cursorTypes.NORMAL;
			}
			return cursorType;
		}*/
		
		/**
		 * Фокусировка
		 */
		override protected function focus():void {
			super.focus();
			if (!_selected) {
				onSelect();
				GUI.focusManager.addFocusListener(this);
			}
		}
		
		/**
		 * Установка флага фокусировки (при фокусировке на ком-то из детей)
		 */	
		override public function set childFocused(value:Boolean):void {
			super.childFocused = value;
			if (_childFocused) {
				if (!_selected) {
					onSelect();
					GUI.focusManager.addFocusListener(this);
				}
			}
		}
		
		/**
		 * Рассылка изменения фокуса 
		 * @param focusOutObject объект, потерявший фокус
		 * @param focusInObject объект, получивший фокус
		 */		
		public function focusChanged(focusOutObject:IFocus, focusInObject:IFocus):void {
			if (focusInObject == null) {
				GUI.focusManager.removeFocusListener(this);
				onUnselect();
			} else {
				var tree:Array = GUI.focusManager.focusTree;
				if (tree.indexOf(this) == -1) {
					GUI.focusManager.removeFocusListener(this);
					onUnselect();
				}
			}
		}
		
		private function onTitleMinimize(e:WindowTitleEvent):void {
			onMinimize();
		}
		private function onTitleMaximize(e:WindowTitleEvent):void {
			onMaximize();
		}
		private function onTitleRestore(e:WindowTitleEvent):void {
			onRestore();
		}
		private function onTitleClose(e:WindowTitleEvent):void {
			onClose();
		}
		
		// Выбор окна
		protected function onSelect():void {
			//trace("onSelect");
			_selected = true;
			if (autoTopEnabled) {
				toFront();
			}
			// Рассылка события
			dispatchEvent(new WindowEvent(WindowEvent.SELECT, this));
		}
		
		// Потеря фокуса
		protected function onUnselect():void {
			//trace("onUnselect");
			_selected = false;
			// Рассылка события
			dispatchEvent(new WindowEvent(WindowEvent.UNSELECT, this));
		}	
		
		// Сворачивание окна
		protected function onMinimize():void {
			// Сворачивание
			if (_parentWindowContainer != null && _parentWindowContainer.layoutManager is IWindowLayoutManager) {
				IWindowLayoutManager(_parentWindowContainer.layoutManager).minimizeWindow(this);
			}
			// Рассылка события
			dispatchEvent(new WindowEvent(WindowEvent.MINIMIZE, this));
		}
		
		// Разворачивание окна
		protected function onMaximize():void {
			_maximized = true;
			
			moveArea = null;
			winTitle.cursorActive = false;
			
			oldTopResizeEnabled = topResizeEnabled;
			oldBottomResizeEnabled = bottomResizeEnabled;
			oldLeftResizeEnabled = leftResizeEnabled;
			oldRightResizeEnabled = rightResizeEnabled;
			
			topResizeEnabled = false;
			bottomResizeEnabled = false;
			leftResizeEnabled = false;
			rightResizeEnabled = false;
			
			if (_parentWindowContainer != null && _parentWindowContainer.layoutManager is IWindowLayoutManager) {
				IWindowLayoutManager(_parentWindowContainer.layoutManager).maximizeWindow(this);
			}
			// Рассылка события
			dispatchEvent(new WindowEvent(WindowEvent.MAXIMIZE, this));
		}
		
		// Сворачивание окна до прежнего размера
		protected function onRestore():void {
			_maximized = false;
			
			moveArea = winTitle;
			winTitle.cursorActive = true;
			
			topResizeEnabled = oldTopResizeEnabled;
			bottomResizeEnabled = oldBottomResizeEnabled;
			leftResizeEnabled = oldLeftResizeEnabled;
			rightResizeEnabled = oldRightResizeEnabled;
			
			if (_parentWindowContainer != null && _parentWindowContainer.layoutManager is IWindowLayoutManager) {
				IWindowLayoutManager(_parentWindowContainer.layoutManager).restoreWindow(this);
			}
			// Рассылка события
			dispatchEvent(new WindowEvent(WindowEvent.RESTORE, this));
		}
		
		// Закрывание окна
		protected function onClose():void {
			dispatchEvent(new WindowEvent(WindowEvent.CLOSE, this));
		}
		
		public function set align(value:int):void {
			_align = value;
		}
		public function get align():int {
			return _align;
		}
		
		public function set margin(value:int):void {
			container.marginLeft = value;
			container.marginRight = value;
			container.marginTop = value;
			container.marginBottom = value;
		}
		public function get margin():int {
			return container.marginLeft;
		}
		
		// Сообщаем об изменении координат, если они изменились
		/*override protected function updateCoords():void {
			if (!_maximized && _parentWindowContainer.layoutManager is IWindowLayoutManager)
				IWindowLayoutManager(_parentWindowContainer.layoutManager).updateWindowCoords(this);
		}
		// Сообщаем об изменении размеров, если они изменились
		override protected function updateSize():void {
			if (!_maximized && _parentWindowContainer.layoutManager is IWindowLayoutManager)
				IWindowLayoutManager(_parentWindowContainer.layoutManager).updateWindowSize(this);
			minSizeChanged = true;
		}*/
		
		/**
		 * Установка флага актуальности минимального размера
		 * true - надо пересчитать
		 * false - пересчитали 
		 */	
		override public function set minSizeChanged(value:Boolean):void {
			if (windowContainer.minSizeChanged != value) {
				windowContainer.minSizeChanged = value;
			}
			super.minSizeChanged = value;
		}
		
		/**
		 * Флаг актуальности минимального размера
		 */		
		override public function get minSizeChanged():Boolean {
			return windowContainer.minSizeChanged;
		}
		
		public function set title(value:String):void {
			if (titled) {
				_title = value;
				winTitle.title = value;
			}
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		
	}
}