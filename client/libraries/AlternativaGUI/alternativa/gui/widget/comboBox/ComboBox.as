package alternativa.gui.widget.comboBox {
	import alternativa.gui.container.Container;
	import alternativa.gui.container.WidgetContainer;
	import alternativa.gui.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.gui.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.mouse.ICursorActive;
	import alternativa.gui.skin.widget.comboBox.ComboBoxSkin;
	import alternativa.gui.widget.list.IListRenderer;
	import alternativa.gui.widget.list.List;
	import alternativa.gui.widget.list.ListItemEvent;
	import alternativa.gui.widget.list.ListRendererParams;
	import alternativa.gui.window.WindowBase;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	/**
	 * Выпадающий список 
	 */	
	public class ComboBox extends WidgetContainer {
		
		/**
		 * Флаг раскрытости 
		 */		
		protected var opened:Boolean;
		/**
		 * Список раскрылся вниз 
		 */		
		protected var downOpened:Boolean;
		
		/**
		 * Список выбора 
		 */		
		private var selectList:List;
		/**
		 * Выбранный элемент списка 
		 */		
		private var selectedItem:IListRenderer;
		/**
		 * Контейнер для отображения выбранного элемента
		 */		
		private var selectedItemContainer:Container;
		/**
		 * Скин 
		 */		
		protected var skin:ComboBoxSkin;
		/**
		 * Графика поля
		 */		
		protected var gfx:Sprite;
		/**
		 * Левая часть поля 
		 */		
		private var left:Bitmap;
		/**
		 * Центральная часть поля 
		 */
		private var center:Bitmap;
		/**
		 * Правая часть поля 
		 */
		private var right:Bitmap;
		/**
		 * @private
		 * Фильтр открывания с клавиатуры 
		 */		
		protected var openFilter:FocusKeyFilter;
		/**
		 * @private
		 * Фильтр выделения предыдущего элемента списка 
		 */		
		protected var prevFilter:FocusKeyFilter;
		/**
		 * @private
		 * Фильтр выделения следующего элемента списка  
		 */		
		protected var nextFilter:FocusKeyFilter;
		/**
		 * @private
		 * Фильтр выбора элемента списка с клавиатуры 
		 */		
		protected var selectFilter:FocusKeyFilter;
		/**
		 * @private
		 * Действие "ОТКРЫТЬ"
		 */		
		protected const KEY_ACTION_OPEN:String = "ComboBoxOpen";
		/**
		 * Действие "ВЫДЕЛИТЬ ПРЕДЫДУЩИЙ ЭЛЕМЕНТ"
		 */
		private static const KEY_ACTION_PREV:String = "ComboBoxPrev";
		/**
		 * Действие "ВЫДЕЛИТЬ СЛЕДУЮЩИЙ ЭЛЕМЕНТ"
		 */
		private static const KEY_ACTION_NEXT:String = "ComboBoxNext";
		/**
		 * Действие "ВЫБРАТЬ ВЫДЕЛЕННЫЙ ЭЛЕМЕНТ"
		 */		
		private static const KEY_ACTION_SELECT:String = "ComboBoxSelect";
		
		/**
		 * @param selectList список выбора 
		 * @param ListItemClass класс отрисовщика элемента списка
		 */		
		public function ComboBox(selectList:List, ListItemClass:Class, selectedItemRendererParams:ListRendererParams) {
			super();
			this.selectList = selectList;
			
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE, 0);
			
			gfx = new Sprite();
			gfx.mouseEnabled = false;		
			gfx.mouseChildren = false;		
			gfx.tabEnabled = false;
			gfx.tabChildren = false;		
			addChildAt(gfx, 0);
			
			// Создаём части графики
			left = new Bitmap();
			center = new Bitmap();
			right = new Bitmap();
			gfx.addChild(left);
			gfx.addChild(center);
			gfx.addChild(right);
			
			// Выбранный элемент
			selectedItemContainer = new Container();
			addObject(selectedItemContainer);
			selectedItemContainer.stretchableH = true;
			selectedItemContainer.stretchableV = false;
			selectedItem = new ListItemClass(selectedItemRendererParams);
			//selectedItem.data = selectList.selected.data;
			selectedItemContainer.addObject(selectedItem);
			ICursorActive(selectedItem).addCursorListener(this);
			
			// Тень
			selectList.filters = new Array(new DropShadowFilter(4, 70, 0, 1, 4, 4, 0.3, BitmapFilterQuality.MEDIUM));
			
			// Подписка на событие выбора элемента
			selectList.addEventListener(ListItemEvent.SELECT, onListItemSelect);
			
			// Фильтры клавиатуры
			//openFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array([40])));
			prevFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array([38])));
			nextFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array([40])));
			keyFiltersConfig.addKeyDownFilter(prevFilter, KEY_ACTION_PREV);
			keyFiltersConfig.addKeyDownFilter(nextFilter, KEY_ACTION_NEXT);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_PREV, this, prev);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_NEXT, this, next);
			//selectFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array([13])));
			//keyFiltersConfig.addKeyDownFilter(openFilter, KEY_ACTION_OPEN);
			//keyFiltersConfig.bindKeyDownAction(KEY_ACTION_OPEN, this, showList);
			
			//keyFiltersConfig.bindKeyDownAction(KEY_ACTION_SELECT, this, select);
			
			opened = false;
		}
		
		private function prev():void {
			if (selectList.selectedPos > 1) {
				selectList.selectItem(selectList.selectedPos - 1);
			}
		}
		private function next():void {
			if (selectList.selectedPos < selectList.length) {
				selectList.selectItem(selectList.selectedPos + 1);
			}
		}
		private function select():void {
			hideList();
			selectItem(selectList.selected.data);
		}
		
		/**
		 * Обновить скин 
		 */
		override public function updateSkin():void {
			skin = ComboBoxSkin(skinManager.getSkin(ComboBox));
			super.updateSkin();
			
			// Установка размеров
			minSize.y = skin.nc.height;
			selectedItemContainer.minSize.y = minSize.y - 2*skin.borderThickness;
			
			// Установка отступов
			marginLeft = skin.borderThickness;
			marginTop = skin.borderThickness;
			marginRight = skin.borderThickness;
			marginBottom = skin.borderThickness;
			
			selectedItemContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE, 0);
			
			// Обновить состояние
			switchState();
			
			// Считаем ширину
			calcMinWidth();
			
			selectList.skinManager = skinManager;
		}
		
		/**
		 *  Расчёт минимальной ширины
		 */
		private function calcMinWidth():void {
			var w:int = marginLeft + marginRight;
			
			minSize.x = Math.max(w, minSize.x);
		}
		
		/**
		 * Показать список выбора
		 */		
		protected function showList():void {
			opened = true;
			
			keyFiltersConfig.removeKeyDownFilter(prevFilter);
			keyFiltersConfig.removeKeyDownFilter(nextFilter);
			
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.addObject(selectList);
			selectList.minSize.x = currentSize.x;
			//selectList.minSize.y = currentSize.x;
			selectList.computeMinSize();
			selectList.draw(selectList.computeSize(selectList.minSize));
			
			var localListCoord:Point = new Point(0, _currentSize.y);
			var globalListCoord:Point = localToGlobal(localListCoord);
			var inTopContainerLocalListCoord:Point;
			if (globalListCoord.y + selectList.currentSize.y <= stage.stageHeight) {
				downOpened = true;
				inTopContainerLocalListCoord = topContainer.globalToLocal(globalListCoord);
			} else {
				downOpened = false;
				inTopContainerLocalListCoord = topContainer.globalToLocal(globalListCoord.add(new Point(0, -(selectList.currentSize.y + currentSize.y))));
			}
			selectList.x = inTopContainerLocalListCoord.x;
			selectList.y = inTopContainerLocalListCoord.y;
			
			//IOInterfaces.focusManager.addFocusListener(this);
		}
		
		/*override public function set childFocused(value:Boolean):void {
			if (_childFocused != value) {
				_childFocused = value;
				if (!_childFocused && !_focused && opened) {
					hideList();
				}
			}
		}*/
		
		/**
		 * Рассылка изменения фокуса 
		 * @param focusOutObject объект, потерявший фокус
		 * @param focusInObject объект, получивший фокус
		 */		
		/*public function focusChanged(focusOutObject:IFocus, focusInObject:IFocus):void {
			if () {
				
			}
		}*/
		
		/**
		 * Скрыть список выбора 
		 */		
		protected function hideList():void {
			opened = false;
			
			keyFiltersConfig.addKeyDownFilter(prevFilter, KEY_ACTION_PREV);
			keyFiltersConfig.addKeyDownFilter(nextFilter, KEY_ACTION_NEXT);
			
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			if (topContainer.contains(selectList)) {
				topContainer.removeObject(selectList);
			}
		}
		
		/**
		 * Фокусировка
		 */
		override protected function focus():void {
			selectedItem.selected = true;
		}
		/**
		 * Расфокусировка
		 */
		override protected function unfocus():void {
			selectedItem.selected = false;
			hideList();
		}
		
		override public function computeMinSize():Point {
			
			return super.computeMinSize();
		}
		
		override public function computeSize(size:Point):Point {
			
			return super.computeSize(size);
		}
		
		/**
		 * Отрисовка в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			super.draw(size);
			
			center.x = left.width;
			center.width = currentSize.x - left.width - right.width;
			right.x = currentSize.x - right.width;
			
			if (opened) {
				var topContainer:Container = WindowBase(_rootObject).topContainer;
				var localListCoord:Point = new Point(0, _currentSize.y);
				var globalListCoord:Point = localToGlobal(localListCoord);
				var inTopContainerLocalListCoord:Point = topContainer.globalToLocal(globalListCoord);
				selectList.x = inTopContainerLocalListCoord.x;
				selectList.y = inTopContainerLocalListCoord.y;
				selectList.computeMinSize();
				selectList.computeSize(selectList.minSize);
				selectList.draw(new Point(size.x, selectList.minSize.y));
			}
		}
		
		
		
		/**
		 * @private
		 * Смена визуального состояния 
		 */
		protected function switchState():void {		
			/*if (locked) 
				state(skin.ll, skin.lc, skin.lr, skin.tfLocked, skin.colorLocked);								
			else 
			if (pressed) 
				state(skin.pl, skin.pc, skin.pr, skin.tfPressed, skin.colorPressed);													
			else 
			if (over) 
				state(skin.ol, skin.oc, skin.or, skin.tfOver, skin.colorOver); 
			else */
				state(skin.nl, skin.nc, skin.nr);										
		}
		
		/**
		 * Перегрузка графики поля
		 */
		private function state(_left:BitmapData,_center:BitmapData,_right:BitmapData):void {
			left.bitmapData = _left;
			center.bitmapData = _center;
			right.bitmapData = _right;
		}
		
		/**
		 * Обработка выбора элемента списка
		 * @param e событие списка
		 */		
		private function onListItemSelect(e:ListItemEvent):void {
			if (opened) {
				hideList();
			}
			selectItem(e.data);
		}
		
		/**
		 * Установка выбранного элемента списка 
		 * @param data данные выбранного элемента
		 */		
		public function selectItem(data:Object):void {
			selectedItem.data = data;
			repaintCurrentSize();
			// Рассылка события
			dispatchEvent(new ComboBoxEvent(ComboBoxEvent.SELECT_ITEM, data));
		}
		
		public function update():void {
			selectedItem.data = selectList.selected.data;
			if (isSkined)
				repaintCurrentSize();
		}
		
		/**
		 * Флаг наведения
		 */
		override public function set over(value:Boolean):void {
			super.over = value;
			switchState();
		}
		
		/**
		 * Флаг нажатия
		 */ 
		override public function set pressed(value:Boolean):void {
			super.pressed = value;
			switchState();
			/*if (_pressed) {
				if (opened) {
					hideList();
				} else {
					showList();
				}
			}*/
		}
		
		/**
		 * Данные выбранного элемента
		 */		
		public function get selected():Object {
			return selectedItem.data;
		}
		
	}
}