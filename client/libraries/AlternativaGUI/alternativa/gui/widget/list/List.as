package alternativa.gui.widget.list {
	import alternativa.gui.container.scrollBox.ScrollBox;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.widget.button.ITriggerButton;
	import alternativa.gui.widget.button.RadioButtonGroup;
	import alternativa.gui.widget.button.IButton;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * Скроллируемый список
	 */	
	public class List extends ScrollBox {
		
		/**
		 * "База данных" элементов списка
		 */		
		protected var _dataProvider:IListDataProvider;
		
		protected var _rootItem:Object;
		
		//protected var rendererProvider:IListRendererProvider;
		protected var rendererClass:Class;
		/**
		 * Параметры отрисовщика элементов 
		 */		
		protected var itemRendererParams:ListRendererParams;
		/**
		 * Количество элементов
		 */		
		protected var itemsNum:int;
		/**
		 * Количество видимых элементов
		 */		
		protected var visibleItemsNum:int;
		/**
		 * Номер 1-го видимого элемента
		 */		
		protected var framePos:int;
		/**
		 * Средняя высота элемента
		 */		
		protected var averageItemHeight:int;
		/**
		 * Группа кнопок для элементов списка
		 */		
		protected var itemsButtonGroup:RadioButtonGroup;
		/**
		 * Выбранный элемент списка 
		 */		
		protected var selectedItem:IListRenderer;
		/**
		 * Порядковый номер выбранного элемента 
		 */		
		protected var selectedItemPos:int;
		/**
		 * Элементы списка (IListRenderer)
		 */		
		protected var items:Array;
		
		
		/**
		 * @param rendererProvider поставщик отрисовщиков элемента списка
		 * @param minWidth минимальная ширина
		 * @param minHeight минимальная высота
		 * @param scrollHorizontalMode режим скроллирования по горизонтали
		 * @param scrollVerticalMode режим скроллирования по вертикали
		 * @param step шаг скроллирования
		 * @param marginLeft отступ слева
		 * @param marginTop отступ сверху
		 * @param marginRight отступ справа
		 * @param marginBottom отступ снизу
		 */		
		public function List(rendererClass:Class,
							 rendererParams:ListRendererParams,
							 minWidth:int,
							 minHeight:int,
							 scrollHorizontalMode:int = 0,
							 scrollVerticalMode:int = 0,
							 step:int = 1,
							 marginLeft:int = 0,
							 marginTop:int = 0,
							 marginRight:int = 0,
							 marginBottom:int = 0) {
			
			super(minWidth,
				  minHeight,
				  scrollHorizontalMode,
				  scrollVerticalMode,
				  step,
				  marginLeft,
				  marginTop,
				  marginRight,
				  marginBottom);
			
			this.rendererClass = rendererClass;
			itemRendererParams = rendererParams;
			
						
			visibleItemsNum = 0;
			framePos = 0;
			selectedItemPos = 1;
			
			layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.TOP, 0);
			
			itemsButtonGroup = new RadioButtonGroup();
			
			items = new Array();
			
			addEventListener(ListItemEvent.SELECT, onListItemSelect);
		}
		
		/**
		 * Добавление элементов в начало списка
		 * @param num количество элементов
		 */		
		/*protected function addItemsToBeginning(num:int):void {
			var startIndex:int = framePos - 1;
			var endIndex:int = startIndex - num;
			for (var i:int = startIndex; i >= endIndex; i--) {
				var item:IListRenderer = IListRenderer(rendererProvider.getRenderer(null));
				item.data = _dataProvider.getItemsData(null, i, 1);
				item.list = this;
				itemsButtonGroup.addButton(IButton(item));
				addObjectAt(item, 0);
			}
		}*/
		/**
		 * Добавление элементов в конец списка
		 * @param num количество элементов
		 */		
		/*protected function addItemsToEnd(num:int):void {
			var startIndex:int = framePos + visibleItemsNum;
			var endIndex:int = startIndex + num - 1;
			for (var i:int = startIndex; i <= endIndex; i++) {
				var item:IListRenderer = IListRenderer(rendererProvider.getRenderer(null));
				item.data = _dataProvider.getItemsData(null, i, 1);
				item.list = this;
				itemsButtonGroup.addButton(IButton(item));
				addObject(item);
			}
		}*/
		/**
		 * Удаление элементов с начала списка
		 * @param num количество элементов
		 */		
		/*protected function removeItemsFromBeginning(num:int):void {
			for (var i:int = 0; i < num; i++) {
				removeObjectAt(0);
			}
		}*/
		/**
		 * Удаление элементов c конца списка
		 * @param num количество элементов
		 */
		/*protected function removeItemsFromEnd(num:int):void {
			for (var i:int = 0; i < num; i++) {
				removeObjectAt(framePos + visibleItemsNum - 1);
			}
		}*/
		
		/**
		 * @private
		 * Получить минимальный размер контента
		 * @return минимальный размер контента
		 */		
		override protected function getContentMinSize():Point {
			var newSize:Point;
			if (items.length != 0) {
				newSize = Point(layoutManager.computeMinSize()).add(new Point(_marginLeft + _marginRight, _marginTop + _marginBottom));
				newSize.y = averageItemHeight*itemsNum;
			} else {
				newSize = super.getContentMinSize();
			}
			trace("List getContentMinSize: " + newSize);
			return newSize;
		}
		
		/**
		 * @private
		 * Получить полный размер контента при заданном размере
		 * @param size заданный размер
		 * @return полный размер контента
		 */		
		override protected function getContentFullSize(size:Point):Point {
			if (items.length != 0) {
				// Определяем размер контента
				var contentSize:Point = layoutManager.computeSize(size.subtract(new Point(_marginLeft + _marginRight, _marginTop + _marginBottom)));
				// Определяем размер контейнера с отступами
				var newSize:Point = new Point(contentSize.x + _marginLeft + _marginRight, contentSize.y + _marginTop + _marginBottom);
				
				newSize.x = Math.max(size.x, newSize.x);
				newSize.y = Math.max(size.y, averageItemHeight*itemsNum);
				
				return newSize;
			} else {
				return super.getContentFullSize(size);
			}
		}
		
		override public function computeSize(size:Point):Point {
			var newSize:Point = super.computeSize(size);
			
			correctVisibleItemsNum(newSize);
			
			return newSize;
		}
		
		protected function correctVisibleItemsNum(newSize:Point):void {
			var num:int = newSize.y/averageItemHeight + 1;
			if (num > items.length) {
				var l:int = items.length;
				for (var i:int = 0; i < num - visibleItemsNum; i++) {
					var item:IListRenderer = IListRenderer(new rendererClass(itemRendererParams));
					items[l + i] = item;
					item.data = _dataProvider.getItemsData(null, l + i, 1);
					item.list = this;
					itemsButtonGroup.addButton(IButton(item));
					addObjectAt(item, l + i);
				}
				layoutManager.computeMinSize();
				layoutManager.computeSize(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
				//layoutManager.draw(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
			}
			visibleItemsNum = num;
		}
		
		/*override protected function onScrollVertical(e:Event):void {
			//trace("scrollBarVertical.position: " + scrollBarVertical.position);
			
			framePos = Math.round((scrollBarVertical.position/contentFullSize.y)*itemsNum);
			//trace("framePos: " + framePos);
			
			if (framePos + visibleItemsNum > items.length) {
				var l:int = items.length;
				var n:int = framePos + visibleItemsNum - l + 1;
				trace("n: " + n);
				for (var i:int = 0; i < n; i++) {
					var item:IListRenderer = IListRenderer(rendererProvider.getRenderer(null));
					items.push(item);
					item.data = _dataProvider.getItemsData(null, l + i, 1);
					//trace("item.data: " + item.data);
					item.list = this;
					itemsButtonGroup.addButton(IButton(item));
					addObject(item);
				}
				layoutManager.computeMinSize();
				layoutManager.computeSize(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
				layoutManager.draw(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
			}
			canvasMaskRect.y = -_marginTop + (scrollVertical ? scrollBarVertical.position : 0);
			canvas.scrollRect = canvasMaskRect;
		}*/
		
		/*override protected function onScrollVertical(e:Event):void {
			//trace("scrollBarVertical.position: " + scrollBarVertical.position);
			
			framePos = Math.round((scrollBarVertical.position/contentFullSize.y)*itemsNum);
			//trace("framePos: " + framePos);
			
			var repaintNecessity:Boolean = false;
			
			if (framePos + visibleItemsNum > items.length) {
				var l:int = items.length;
				var n:int = framePos + visibleItemsNum - l + 1;
				//trace("n: " + n);
				for (var i:int = 0; i < n; i++) {
					if ((l + i) < framePos) {
						if (items[l + i] == null) {
							var dummyItem:Dummy = new Dummy(0, averageItemHeight);
							items[l + i] = dummyItem;
							addObjectAt(dummyItem, l + i);
						}						
					} else {
						if (items[l + i] == null) {
							var item:IListRenderer = IListRenderer(rendererProvider.getRenderer(null));
							items[l + i] = item;
							item.data = _dataProvider.getItemsData(_rootItem, l + i, 1);
							//trace("item.data: " + item.data);
							item.list = this;
							itemsButtonGroup.addButton(IButton(item));
							addObjectAt(item, l + i);
						} else if (items[l + i] is Dummy) {
							removeObjectAt(l + i);
							
							var item:IListRenderer = IListRenderer(rendererProvider.getRenderer(null));
							items[l + i] = item;
							item.data = _dataProvider.getItemsData(_rootItem, l + i, 1);
							//trace("item.data: " + item.data);
							item.list = this;
							itemsButtonGroup.addButton(IButton(item));
							addObjectAt(item, l + i);
						}
					}
				}
				repaintNecessity = true;
			} else {
				n = visibleItemsNum;
				//trace("n: " + n);
				for (var i:int = 0; i < n; i++) {
					if (items[framePos + i] is Dummy) {
						removeObjectAt(framePos + i);
						
						var item:IListRenderer = IListRenderer(rendererProvider.getRenderer(null));
						items[framePos + i] = item;
						item.data = _dataProvider.getItemsData(_rootItem, framePos + i, 1);
						//trace("item.data: " + item.data);
						item.list = this;
						itemsButtonGroup.addButton(IButton(item));
						addObjectAt(item, framePos + i);
						
						repaintNecessity = true;
					}
				}
			}
			if (repaintNecessity) {
				//trace("repaintNecessity");
				layoutManager.computeMinSize();
				layoutManager.computeSize(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
				layoutManager.draw(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
			}
				
			canvasMaskRect.y = -_marginTop + (scrollVertical ? scrollBarVertical.position : 0);
			canvas.scrollRect = canvasMaskRect;
		}*/

		override protected function onScrollVertical(e:Event):void {
			//trace("scrollBarVertical.position: " + scrollBarVertical.position);
			
			framePos = Math.round((scrollBarVertical.position/contentFullSize.y)*itemsNum);
			//trace("framePos: " + framePos);
			
			var repaintNecessity:Boolean = false;
			
			if (framePos + visibleItemsNum > items.length) {
				var l:int = items.length;
				var n:int = framePos + visibleItemsNum - l + 1;
				for (var i:int = 0; i < n; i++) {
					var item:IListRenderer = IListRenderer(new rendererClass(itemRendererParams));
					items[l + i] = item;
					item.list = this;
					itemsButtonGroup.addButton(IButton(item));
					addObjectAt(item, l + i);
					
					item.minSize.y = averageItemHeight;
							
					if ((l + i) >= framePos) {
						item.data = _dataProvider.getItemsData(_rootItem, l + i, 1);
						//item.minSize.y = 0;						
					}
				}
				repaintNecessity = true;
			} else {
				n = visibleItemsNum;
				for (var i:int = 0; i < n; i++) {
					var item:IListRenderer = items[framePos + i];
					if (item.data == null) {
						item.data = _dataProvider.getItemsData(_rootItem, framePos + i, 1);
						repaintNecessity = true;
					}
					//item.minSize.y = 0;	
				}
			}
			if (repaintNecessity) {
				trace("repaintNecessity");
				layoutManager.computeMinSize();
				layoutManager.computeSize(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
				layoutManager.draw(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
				
				// Средняя высота элемента
				//averageItemHeight = contentFullSize.y/items.length;
			}
				
			canvasMaskRect.y = -_marginTop + (scrollVertical ? scrollBarVertical.position : 0);
			canvas.scrollRect = canvasMaskRect;
		}

		private function onListItemSelect(e:ListItemEvent):void {
			selectedItem = IListRenderer(e.target);
			selectedItemPos = items.indexOf(selectedItem) + 1; 
			//trace("selectedItemPos: " + selectedItemPos);
		}
		
		public function selectItem(itemPos:int):void {
			ITriggerButton(items[itemPos-1]).selected = true;
		}
		
		/**
		 * Полная перегрузка элементов списка
		 */		
		/*public function updateItems():void {
			// Удаление старых
			if (itemsNum > 0) {
				removeItemsFromBeginning(itemsNum);
			}
			// Добавление новых
			itemsButtonGroup = new RadioButtonGroup();
			
			// Загрузка данных
			itemsNum = _dataProvider.getItemsNum(null);
			items = new Array();
			
			for (var i:int = 0; i < itemsNum; i++) {
				var item:IListRenderer = IListRenderer(rendererProvider.getRenderer(null));
				items.push(item);
				if (i == 0) {
					selectedItem = item;
				} 
				item.data = _dataProvider.getItemsData(null, i, 1);
				item.list = this;
				itemsButtonGroup.addButton(IButton(item));
				addObject(item);
			}
		}*/
		
		public function get selected():IListRenderer {
			return selectedItem;
		}
		public function get selectedPos():int {
			return selectedItemPos;
		}
		public function get length():int {
			return itemsNum;
		}
		
		// 1-я загрузка
		protected function firstLoad():void {
			var num:int = Math.min(itemsNum, 10);
			for (var i:int = 0; i < num; i++) {
				var data:Object = _dataProvider.getItemsData(_rootItem, i, 1);
				var item:IListRenderer = IListRenderer(new rendererClass(itemRendererParams));
				item.data = data;
				items[i] = item;
				if (i == 0) {
					selectedItem = item;
				} 
				item.list = this;
				itemsButtonGroup.addButton(IButton(item));
				addObject(item);
			}
			// Определяем размер одного элемента
			var contentSize:Point = super.getContentMinSize();
				
			// Средняя высота элемента
			averageItemHeight = contentSize.y/num;
		}
				
		public function set dataProvider(provider:IListDataProvider):void {
			_dataProvider = provider;
			itemsNum = _dataProvider.getItemsNum(null);
			if (_rootItem != null) {
				firstLoad();
			}
		}
		
		public function set rootItem(object:Object):void {
			_rootItem = object;
			if (_dataProvider != null) {
				firstLoad();
			}
		}
		
	}
}