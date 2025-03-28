package alternativa.gui.widget.tree {
	import alternativa.gui.base.Dummy;
	import alternativa.gui.skin.widget.tree.TreeItemSkin;
	import alternativa.gui.widget.Image;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.widget.list.ListRenderer;
	import alternativa.gui.widget.list.ListRendererParams;
	
	
	public class TreeRenderer extends ListRenderer implements ITreeRenderer {
		
		private var _level:int;
		private var _index:int;
		private var _hasChildren:Boolean;
		private var _opened:Boolean;
		private var _parentItem:ITreeRenderer;
		
		private var openedIcon:ImageButton;
		private var icon:Image;
		private var marginDummy:Dummy;
		
		
		public function TreeRenderer(params:ListRendererParams) {
			super(params);
			
			_hasChildren = false;
			_opened = false;
			
			openedIcon = new ImageButton(0, 0);
			addObjectAt(openedIcon, 0);
			openedIcon.addEventListener(ButtonEvent.PRESS, openOrClose);
			
			marginDummy = new Dummy(0, 0);
			addObjectAt(marginDummy, 0);
		}
		
		override public function updateSkin():void {
			super.updateSkin();
			
			if (_hasChildren) {
				openedIcon.normalBitmap = TreeItemSkin(skin).bitmapSubClosed;
				openedIcon.overBitmap = TreeItemSkin(skin).bitmapSubClosed;
				openedIcon.pressBitmap = TreeItemSkin(skin).bitmapSubClosed;
				openedIcon.lockBitmap = TreeItemSkin(skin).bitmapSubClosed;
			} else {
				marginDummy.minSize.x = TreeItemSkin(skin).bitmapSubClosed.width;
			}			
			openedIcon.minSize.y = TreeItemSkin(skin).bitmapSubClosed.height;
		}
		
		/**
		 * @private
		 * Определение класса для скинования
		 * @return класс для скинования
		 */		
		override protected function getSkinType():Class {
			return TreeRenderer;
		}
		
		public function get parentItem():ITreeRenderer {
			return _parentItem;
		}
		public function set parentItem(value:ITreeRenderer):void {
			_parentItem = value;
		}
		
		public function get index():int {
			return _index;
		}
		public function set index(value:int):void {
			_index = value;
		}
		
		public function get opened():Boolean {
			return _opened;
		}
		public function set opened(value:Boolean):void {
			_opened = value;
			if (isSkined) {
				switchIcon();
			}
		}
		public function get hasChildren():Boolean {
			return _hasChildren;
		}
		public function set hasChildren(value:Boolean):void {
			_hasChildren = value;
			if (isSkined) {
				switchIcon();
			}
		}
		public function get level():int {
			return _level;
		}
		public function set level(value:int):void {
			_level = value;
			if (isSkined) {
				if (!_hasChildren) {
					marginDummy.minSize.x = TreeItemSkin(skin).bitmapSubClosed.width*(level + 1);
				} else {
					marginDummy.minSize.x = TreeItemSkin(skin).bitmapSubClosed.width*(level);
				}
			} 
		}
		
		override public function doubleClick():void {
			if (_hasChildren) {
				openOrClose();
			}
		}
		
		private function switchIcon():void {
			if (_hasChildren) {
				//openedIcon.visible = true;
				if (_opened) {
					openedIcon.normalBitmap = TreeItemSkin(skin).bitmapSubOpened;
					openedIcon.overBitmap = TreeItemSkin(skin).bitmapSubOpened;
					openedIcon.pressBitmap = TreeItemSkin(skin).bitmapSubOpened;
					openedIcon.lockBitmap = TreeItemSkin(skin).bitmapSubOpened;
				} else {
					openedIcon.normalBitmap = TreeItemSkin(skin).bitmapSubClosed;
					openedIcon.overBitmap = TreeItemSkin(skin).bitmapSubClosed;
					openedIcon.pressBitmap = TreeItemSkin(skin).bitmapSubClosed;
					openedIcon.lockBitmap = TreeItemSkin(skin).bitmapSubClosed;
				}
			} else {
				//openedIcon.visible = false;
			}
		}
		
		private function openOrClose(e:ButtonEvent = null):void {
			_opened = !_opened;
			if (isSkined) {
				switchIcon();
			}
			if (_opened) {
				dispatchEvent(new TreeItemEvent(TreeItemEvent.EXPAND, data));
			} else {
				dispatchEvent(new TreeItemEvent(TreeItemEvent.COLLAPSE, data));
			}
		}

	}
}