package alternativa.gui.widget.list {
	import alternativa.gui.widget.button.IButton;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * Скроллируемый список
	 */	
	public class ListLazy extends List {
		
		protected var itemsData:Array;
		
		private var lastItemCompensation:int;
		
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
		public function ListLazy(rendererClass:Class,
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
			
			super(rendererClass,
				  rendererParams,
				  minWidth,
				  minHeight,
				  scrollHorizontalMode,
				  scrollVerticalMode,
				  step,
				  marginLeft,
				  marginTop,
				  marginRight,
				  marginBottom);
			
			itemsData = new Array();
		}
		
		override public function computeSize(size:Point):Point {
			var newSize:Point = super.computeSize(size);
			
			var num:int = newSize.y/averageItemHeight + 1;
			
			lastItemCompensation = num*averageItemHeight - newSize.y;
			
			if (num > visibleItemsNum) {
				for (var i:int = 0; i < num - visibleItemsNum; i++) {
					var item:IListRenderer = IListRenderer(new rendererClass(itemRendererParams));
					items.push(item);
					item.data = _dataProvider.getItemsData(null, framePos + visibleItemsNum + i - 1, 1);
					itemsData[framePos + visibleItemsNum + i - 1] = item.data;
					item.list = this;
					itemsButtonGroup.addButton(IButton(item));
					addObject(item);
				}
				layoutManager.computeMinSize();
				layoutManager.computeSize(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
			}
			visibleItemsNum = num;
			
			return newSize;
		}
		
		/**
		 * Установка маски
		 */		
		override protected function setMask():void {
			canvasMaskRect.x = -_marginLeft;
			canvasMaskRect.y = -_marginTop;
			canvasMaskRect.width = viewSize.x;
			canvasMaskRect.height = viewSize.y;
			canvas.scrollRect = canvasMaskRect;
		}
		
		override protected function onScrollVertical(e:Event):void {
			framePos = Math.round((scrollBarVertical.position/contentFullSize.y)*itemsNum);
			
			for (var i:int = 0; i < visibleItemsNum; i++) {
				var item:IListRenderer = IListRenderer(items[i]);
				var data:Object = (itemsData[framePos + i] == null) ? _dataProvider.getItemsData(null, framePos + i, 1) : itemsData[framePos + i];
				item.data = data;
			}
			
			/*if (framePos + visibleItemsNum >= itemsNum) {
				canvasMaskRect.y = -_marginTop + lastItemCompensation*0.5;
			} else {
				canvasMaskRect.y = -_marginTop;
			}*/
			canvas.scrollRect = canvasMaskRect;
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
		
		// 1-я загрузка
		override protected function firstLoad():void {
			var num:int = Math.min(itemsNum, 10);
			for (var i:int = 0; i < num; i++) {
				var data:Object = _dataProvider.getItemsData(_rootItem, i, 1);
				var item:IListRenderer = IListRenderer(new rendererClass(itemRendererParams));
				item.data = data;
				items.push(item);
				itemsData[i] = data;
				if (i == 0) {
					selectedItem = item;
				} 
				item.list = this;
				itemsButtonGroup.addButton(IButton(item));
				addObject(item);
			}
			// Определяем размер одного элемента
			var contentSize:Point = Point(layoutManager.computeMinSize()).add(new Point(_marginLeft + _marginRight, _marginTop + _marginBottom));
				
			// Средняя высота элемента
			averageItemHeight = contentSize.y/num;
		}
		
	}
}