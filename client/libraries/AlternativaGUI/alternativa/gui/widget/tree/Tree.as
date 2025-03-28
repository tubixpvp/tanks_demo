package alternativa.gui.widget.tree {
	import alternativa.gui.widget.button.RadioButtonGroup;
	import alternativa.gui.widget.list.IListDataProvider;
	import alternativa.gui.widget.list.IListRenderer;
	import alternativa.gui.widget.list.List;
	import alternativa.gui.widget.list.ListRendererParams;
	import alternativa.gui.widget.button.IButton;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	
	public class Tree extends List {
//		/import alternativa.gui.widget.button.IButton;
		
		protected var itemsData:Array;
		
		public function Tree(rendererClass:Class,
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
		
		override protected function correctVisibleItemsNum(newSize:Point):void {
			visibleItemsNum = Math.min(newSize.y/averageItemHeight + 1, items.length);
			
			//layoutManager.computeMinSize();
			//layoutManager.computeSize(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
		}
		
		private function onItemEvent(e:TreeItemEvent):void {
			var item:ITreeRenderer = ITreeRenderer(e.target);
			var data:Object = item.data;
			
			if (e.type == TreeItemEvent.EXPAND) {
				loadChildren(item, data, 0, _dataProvider.getItemsNum(data), item.level + 1);
			} else if (e.type == TreeItemEvent.COLLAPSE) {
				unloadChildren(item, data, 0, _dataProvider.getItemsNum(data));
			}
			minSizeChanged = true;
			repaintCurrentSize();
		}
		
		private function loadChildren(parentItem:IListRenderer, parent:Object, startPos:int, num:int, itemsLevel:int):void {
			var items:Array = _dataProvider.getItemsData(parent, startPos, num);
			var l:int = items.length;
			for (var i:int = 0; i < l; i++) {
				var item:IListRenderer = IListRenderer(new rendererClass(itemRendererParams));
				if ((getObjectIndex(parentItem) + i + 1) >= framePos && (getObjectIndex(parentItem) + i + 1) < (framePos + visibleItemsNum)) {
					item.data = _dataProvider.getItemsData(parent, i, 1)[0];
				}
				this.items.splice(getObjectIndex(parentItem) + i + 1, 0, item);
				this.itemsData.splice(getObjectIndex(parentItem) + i + 1, 0, item.data);
				item.list = this;
				itemsButtonGroup.addButton(IButton(item));
				
				addObjectAt(item, getObjectIndex(parentItem) + i + 1);
				
				ITreeRenderer(item).hasChildren = _dataProvider.getItemsNum(item.data);
				ITreeRenderer(item).opened = false;
				ITreeRenderer(item).level = itemsLevel;
				ITreeRenderer(item).index = startPos + i;
				ITreeRenderer(item).parentItem = ITreeRenderer(parentItem);
				
				EventDispatcher(item).addEventListener(TreeItemEvent.COLLAPSE, onItemEvent);
				EventDispatcher(item).addEventListener(TreeItemEvent.EXPAND, onItemEvent);
			}
			itemsNum += num;
			
			//trace("loadChildren items data: " + itemsData);
		}
		
		private function unloadChildren(parentItem:IListRenderer, parent:Object, startPos:int, num:int):void {
			var parentIndex:int = getObjectIndex(parentItem);
			for (var i:int = startPos; i < startPos + num; i++) {
				var item:IListRenderer = IListRenderer(getObjectAt(parentIndex + startPos + num - i));
				if (ITreeRenderer(item).opened) {
					if (_dataProvider.getItemsNum(item.data)) {
						unloadChildren(item, item.data, 0, _dataProvider.getItemsNum(item.data));
					}
				}
				itemsButtonGroup.removeButton(IButton(item));
				removeObjectAt(parentIndex + startPos + num - i);
				
				this.items.splice(items.indexOf(parentItem) + ITreeRenderer(item).index + 1, 1);
				this.itemsData.splice(items.indexOf(parentItem) + ITreeRenderer(item).index + 1, 1);
				
				EventDispatcher(item).removeEventListener(TreeItemEvent.COLLAPSE, onItemEvent);
				EventDispatcher(item).removeEventListener(TreeItemEvent.EXPAND, onItemEvent);
			}
			itemsNum -= num;
			
			//trace("unloadChildren items data: " + itemsData);
		}
		
		override protected function onScrollVertical(e:Event):void {
			//trace("scrollBarVertical.position: " + scrollBarVertical.position);
			
			framePos = Math.round((scrollBarVertical.position/contentFullSize.y)*itemsNum);
			//trace("framePos: " + framePos);
			
			var repaintNecessity:Boolean = false;
			
			for (var i:int = 0; i < visibleItemsNum; i++) {
				var item:IListRenderer = items[framePos + i];
				if (item != null) {
					if (item.data == null) {
						var parentItem:ITreeRenderer = ITreeRenderer(item).parentItem;
						item.data = _dataProvider.getItemsData(parentItem.data, ITreeRenderer(item).index, 1);
						itemsData[framePos + i] = item.data;
						ITreeRenderer(item).hasChildren = _dataProvider.getItemsNum(item.data);
						repaintNecessity = true;
					}
				}
			}
			
			if (repaintNecessity) {
				//trace("repaintNecessity");
				layoutManager.computeMinSize();
				layoutManager.computeSize(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
				layoutManager.draw(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
				
				// Средняя высота элемента
				//averageItemHeight = contentFullSize.y/items.length;
			}
				
			canvasMaskRect.y = -_marginTop + (scrollVertical ? scrollBarVertical.position : 0);
			canvas.scrollRect = canvasMaskRect;
			
			//trace("onScrollVertical items data: " + itemsData);
		}
		
		// 1-я загрузка
		override protected function firstLoad():void {
			itemsButtonGroup = new RadioButtonGroup();
			
			var num:int = _dataProvider.getItemsNum(_rootItem);
			itemsNum = num;
			var items:Array = _dataProvider.getItemsData(_rootItem, 0, num);
			
			for (var i:int = 0; i < items.length; i++) {
				var item:IListRenderer = IListRenderer(new rendererClass(itemRendererParams));
				item.data = _dataProvider.getItemsData(_rootItem, i, 1)[0];
				item.list = this;
				this.items.push(item);
				itemsData.push(item.data);
				itemsButtonGroup.addButton(IButton(item));
				addObject(item);
				
				ITreeRenderer(item).hasChildren = _dataProvider.getItemsNum(item.data);
				ITreeRenderer(item).opened = false;
				ITreeRenderer(item).level = 0;
				ITreeRenderer(item).index = i;
				
				EventDispatcher(item).addEventListener(TreeItemEvent.COLLAPSE, onItemEvent);
				EventDispatcher(item).addEventListener(TreeItemEvent.EXPAND, onItemEvent);
			}
			// Определяем размер одного элемента
			var contentSize:Point = Point(layoutManager.computeMinSize()).add(new Point(_marginLeft + _marginRight, _marginTop + _marginBottom));
				
			// Средняя высота элемента
			averageItemHeight = contentSize.y/num;
			
			//trace("firstLoad items data: " + itemsData);
		}
		
		override public function set dataProvider(provider:IListDataProvider):void {
			_dataProvider = provider;
			if (_rootItem != null) {
				itemsNum = _dataProvider.getItemsNum(_rootItem);
				firstLoad();
			}
		}
		override public function set rootItem(object:Object):void {
			_rootItem = object;
			if (_dataProvider != null) {
				itemsNum = _dataProvider.getItemsNum(_rootItem);
				firstLoad();
			}
		}
		
	}
}