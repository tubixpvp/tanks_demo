package alternativa.gui.container {
	import alternativa.gui.base.ActiveShapeObject;
	import alternativa.gui.init.GUI;
	import alternativa.iointerfaces.mouse.dnd.DragEvent;
	import alternativa.iointerfaces.mouse.dnd.IDragObject;
	import alternativa.iointerfaces.mouse.dnd.IDrop;
	import alternativa.gui.window.panel.PanelDragObject;
	import alternativa.gui.window.panel.ResizeablePanelBase;
	
	import flash.geom.Point;
	
	public class PanelSlotButton extends ActiveShapeObject implements IDrop {
		
		private var windowPanelContainer:WindowPanelContainer;
		
		// Размер краевой полосы
		private	var _edgeSize:int;
		
		protected var _focused:Boolean;
		
		
		public function PanelSlotButton(windowPanelContainer:WindowPanelContainer) {
			super();
			this.windowPanelContainer = windowPanelContainer;
			// Обработка драга
			addEventListener(DragEvent.DROP, onPanelDrop);
		}
		
		public function canDrop(dragObject:IDragObject):Boolean {
			return (dragObject is PanelDragObject);
		}
		
		private function onPanelDrop(e:DragEvent):void {
			
			var p:ResizeablePanelBase = ResizeablePanelBase(PanelDragObject(e.dragObject).dragObject);
			
			windowPanelContainer.movePanel(p, new Point(e.localX, e.localY));
			
			/*var align:int = windowPanelContainer.detectArea(new Point(e.localX, e.localY));
			if (p.align != align) p.align = align;
			
			var direction:Boolean = windowPanelContainer.detectPanelDirection(align, new Point(e.localX, e.localY));
			
			var angle:Number;
			if (direction == Direction.HORIZONTAL) {
				if (align & WindowAlign.BOTTOM_MASK) {
					// 0
					angle = AvailableAngle.DEGREES_0;
				} else if (align & WindowAlign.TOP_MASK) {
					// 180
					angle = AvailableAngle.DEGREES_180;
				}
			} else {
				if (align & WindowAlign.RIGHT_MASK) {
					// 270
					angle = AvailableAngle.DEGREES_270;
				} else if (align & WindowAlign.LEFT_MASK) {
					// 90
					angle = AvailableAngle.DEGREES_90;
				}
			}
			// Поворот панели
			if (p.angle != angle) {
				p.angle = angle;
				
				p.parentContainer.minSizeChanged = true;
				p.parentContainer.removeObject(p);
				windowPanelContainer.addPanel(p);
				p.parentContainer.minSizeChanged = true;
				
				windowPanelContainer.repaintCurrentSize();
			} else {
				Container(p.parentContainer).repaintCurrentSize();
			}*/
			
			//windowPanelContainer.minSizeChanged = true;
		}
		
		override public function draw(size:Point):void {
			super.draw(size);
			
			graphics.clear();
			graphics.beginFill(0x0000cc, 0);
			graphics.drawRect(0, 0, size.x, size.y);
			graphics.drawRect(_edgeSize, _edgeSize, size.x - _edgeSize*2, size.y - _edgeSize*2);
		}
		
		/**
		 * Установка флага фокусировки
		 */	
		public function set focused(value:Boolean):void {
			_focused = value;
		}
		/**
		 * Получить флаг фокусировки
		 * @return флаг фокусировки
		 * 
		 */		
		public function get focused():Boolean {
			return _focused;
		}
		
		/**
		 * Внешний вид курсора при наведении на объект
		 */
		override public function get cursorOverType():uint {
			return (this.parent != null)? GUI.mouseManager.cursorTypes.DROP : GUI.mouseManager.cursorTypes.NORMAL;
		}
		
		/**
		 * Внешний вид курсора при нажатии на объект или наведении на нажатый объект
		 */
		override public function get cursorPressedType():uint {
			return GUI.mouseManager.cursorTypes.DROP;
		}
		
		public function set edgeSize(value:int):void {
			_edgeSize = value;
		}

	}
}