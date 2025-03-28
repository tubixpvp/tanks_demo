package alternativa.gui.widget {
	import alternativa.gui.base.ActiveObject;
	import alternativa.gui.skin.widget.WidgetSkin;
	
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	
	public class Widget extends ActiveObject {
		
		/**
		 * Скин 
		 */		
		private var widgetSkin:WidgetSkin;
		/**
		 * Рамка вокруг объекта, возникающая, если он в фокусе 
		 */
		protected var focusFrame:Shape;
		
		
		public function Widget() {
			super();
		}
		
		/**
		 * Обновить скин 
		 */
		override public function updateSkin():void {
			super.updateSkin();
			widgetSkin = WidgetSkin(skinManager.getSkin(Widget));
		}
		
		/**
		 * Фокусировка
		 */		
		override protected function focus():void {
			drawFocusFrame(new Rectangle(0, 0, _currentSize.x, _currentSize.y));
			addChild(focusFrame);
		}
		/**
		 * Расфокусировка
		 */		
		override protected function unfocus():void {
			removeChild(focusFrame);
		}
		/**
		 * Отрисовка обводки при фокусировке 
		 * @param rect габариты обводки
		 */		
		protected function drawFocusFrame(rect:Rectangle):void {
			focusFrame = new Shape();
			focusFrame.graphics.beginBitmapFill(widgetSkin.focusFramePattern);
			focusFrame.graphics.drawRect(rect.x, rect.y, rect.width, 1);
			focusFrame.graphics.beginBitmapFill(widgetSkin.focusFramePattern);
			focusFrame.graphics.drawRect(rect.x, rect.y + rect.height - 1, rect.width, 1);
			focusFrame.graphics.beginBitmapFill(widgetSkin.focusFramePattern);
			focusFrame.graphics.drawRect(rect.x, rect.y, 1, rect.height);
			focusFrame.graphics.beginBitmapFill(widgetSkin.focusFramePattern);
			focusFrame.graphics.drawRect(rect.x + rect.width - 1, rect.y, 1, rect.height);
		}
		
	}
}