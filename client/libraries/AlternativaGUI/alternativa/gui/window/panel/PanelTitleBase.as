package alternativa.gui.window.panel {
	import alternativa.gui.container.Container;
	import alternativa.gui.init.GUI;
	import alternativa.gui.skin.window.panel.PanelTitleSkin;
	import alternativa.gui.window.WindowTitleBase;
	
	import flash.display.Bitmap;
	import flash.geom.Point;
	
	public class PanelTitleBase	extends WindowTitleBase {
		
		// Иконка сворачивания/разворачивания
		private var icon:Bitmap;
		
		// Флаг сворачивания
		private var _minimized:Boolean = false;
		
		public function PanelTitleBase(tab:Container, title:String = null, closable:Boolean = false, active:Boolean = false) {
			trace("PanelTitleBase closable: " + closable);
			super(tab, title, closable, false, false, active);
			
			icon = new Bitmap();
			gfx.addChild(icon);
		}
		
		// Скинование
		override public function updateSkin():void {
			super.updateSkin();
			setMaximizedState();
		}
		
		// Определение класса для скинования
		override protected function getSkinType():Class {
			return PanelTitleBase;
		}
		
		// Отрисовка
		override public function draw(size:Point):void {
			super.draw(size);
			icon.x = Math.floor((size.x - icon.width)/2);	
			icon.y = Math.floor((size.y - icon.height)/2);	
		}
		
		// Установка состояния
		public function setMinimizedState():void {
			_minimized = true;
			icon.bitmapData = PanelTitleSkin(skin).iconMaximize;
		}
		public function setMaximizedState():void {
			_minimized = false;
			icon.bitmapData = PanelTitleSkin(skin).iconMinimize;
		}
		
		// Курсор
		override public function get cursorOverType():uint {
			return GUI.mouseManager.cursorTypes.ACTIVE;
		}
		override public function get cursorPressedType():uint {
			return GUI.mouseManager.cursorTypes.ACTIVE;
		}
		
	}
}