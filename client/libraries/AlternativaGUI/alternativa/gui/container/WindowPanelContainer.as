package alternativa.gui.container {
	import alternativa.gui.init.GUI;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.AvailableAngle;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.WindowAlign;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.layout.impl.PanelLayoutManager;
	import alternativa.gui.layout.impl.SimpleWindowLayoutManager;
	import alternativa.gui.mouse.IMouseCoordListener;
	import alternativa.gui.mouse.dnd.DragEvent;
	import alternativa.gui.window.WindowBase;
	import alternativa.gui.window.panel.ResizeablePanelBase;
	
	import flash.geom.Point;
	
	
	public class WindowPanelContainer extends WindowContainer implements IMouseCoordListener {
		
		protected var panelTopContainer:PanelContainer;
		protected var panelBottomContainer:PanelContainer;
		protected var panelLeftContainer:PanelContainer;
		protected var panelRightContainer:PanelContainer;
		
		private var dragedPanel:ResizeablePanelBase;
		
		protected var middleContainer:Container;
		protected var middleCenterContainer:WindowContainer;
		
		// Размер краевой полосы
		private	var edgeSize:int;
		
		private	var panelSlotButton:PanelSlotButton;
		
		public function WindowPanelContainer() {
			super();
			_stretchableH = true;
			_stretchableV = true;
			//setLayoutManager(new FeedbackFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.MIDDLE, 0));
			layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.MIDDLE, 0);
			
			panelTopContainer = new PanelContainer();
			panelTopContainer.stretchableH = true;
			panelTopContainer.layoutManager = new PanelLayoutManager(Direction.HORIZONTAL);
			panelBottomContainer = new PanelContainer();
			panelBottomContainer.stretchableH = true;
			panelBottomContainer.layoutManager = new PanelLayoutManager(Direction.HORIZONTAL);
			panelLeftContainer = new PanelContainer();
			panelLeftContainer.stretchableV = true;
			panelLeftContainer.layoutManager = new PanelLayoutManager(Direction.VERTICAL);
			panelRightContainer = new PanelContainer();
			panelRightContainer.stretchableV = true;
			panelRightContainer.layoutManager = new PanelLayoutManager(Direction.VERTICAL);
			
			middleContainer = new Container();
			middleContainer.stretchableH = true;
			middleContainer.stretchableV = true;
			middleCenterContainer = new WindowContainer();
			//middleCenterContainer.layoutManager = new RelativeWindowLayoutManager();
			middleCenterContainer.layoutManager = new SimpleWindowLayoutManager();
			
			addObject(panelTopContainer);
			addObject(middleContainer);
			addObject(panelBottomContainer);
			canvas.setChildIndex(panelTopContainer, canvas.numChildren-1);
			
			middleContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE, 0);
			middleContainer.addObject(panelLeftContainer);
			middleContainer.addObject(middleCenterContainer);
			middleContainer.addObject(panelRightContainer);
			//middleContainer.canvas.setChildIndex(panelLeftContainer, middleContainer.canvas.numChildren-1);
			
			panelTopContainer.rootObject = this;
			panelBottomContainer.rootObject = this;
			middleContainer.rootObject = this;
			
			panelSlotButton = new PanelSlotButton(this);
		}
		
		override public function computeSize(_size:Point):Point {
			var newSize:Point = super.computeSize(_size);
			edgeSize = Math.round(newSize.y*0.25);
			panelSlotButton.edgeSize = edgeSize;
			//trace("WindowPanelContainer computeSize: " + newSize);
			return newSize;
		}
		
		// Добавление окна
		override public function addWindow(w:WindowBase):void {
			middleCenterContainer.addWindow(w);
		}
		// Добавление панели
		public function addPanel(p:ResizeablePanelBase):void {
			if (p.direction == Direction.HORIZONTAL) {
				if (p.align & WindowAlign.TOP_MASK) {
					panelTopContainer.addPanel(p);
				} else {
					panelBottomContainer.addPanel(p);
				}
			} else {
				if (p.align & WindowAlign.LEFT_MASK) {
					panelLeftContainer.addPanel(p);
				} else {
					panelRightContainer.addPanel(p);
				}	
			}
			p.addEventListener(DragEvent.START, onStartPanelDrag);
			p.addEventListener(DragEvent.DROP, onStopPanelDrag);
			p.addEventListener(DragEvent.STOP, onStopPanelDrag);
			p.addEventListener(DragEvent.CANCEL, onStopPanelDrag);
		}
		
		private function onStartPanelDrag(e:DragEvent):void {
			dragedPanel = ResizeablePanelBase(e.dragObject.dragObject);
			addChild(panelSlotButton);
			
			panelSlotButton.repaint(_currentSize);
			
			GUI.mouseManager.addMouseCoordListener(this);
		}
		
		/**
		 * Рассылка изменения координат мыши 
		 * @param mouseCoord координаты мыши
		 */		
		public function mouseMove(mouseCoord:Point):void {
			movePanel(dragedPanel, mouseCoord);
		}		
		
		private function onStopPanelDrag(e:DragEvent):void {
			dragedPanel = null;
			removeChild(panelSlotButton);
			GUI.mouseManager.removeMouseCoordListener(this);
		}
		
		/**
		 * Перемещение панели (смена выравнивания с поворотом, если необходимо) 
		 * @param p - панель
		 */		
		public function movePanel(p:ResizeablePanelBase, coord:Point):void {
			var align:int = detectArea(coord);
			if (align != WindowAlign.MIDDLE_CENTER) {
				var direction:Boolean = detectPanelDirection(align, coord);
				if (p.align != align || direction != p.direction) {
					if (p.align != align) p.align = align;
					
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
						addPanel(p);
						p.parentContainer.minSizeChanged = true;
						
						repaintCurrentSize();
					} else {
						Container(p.parentContainer).repaintCurrentSize();
					}
				}
			}
		}
		
		
		// Определение области размещения
		private function detectArea(coord:Point):int {
			// Результат
			var area:int;
			
			if (coord.y < edgeSize) {
				//верхняя строка
				area = area | WindowAlign.TOP_MASK;
			} else if (coord.y > (_currentSize.y - edgeSize)) {
				//нижняя строка
				area = area | WindowAlign.BOTTOM_MASK;
			} else {
				// центральная строка
				area = area | WindowAlign.MIDDLE_MASK;
			}
			
			if (coord.x < edgeSize) {
				//левый столбец
				area = area | WindowAlign.LEFT_MASK;
			} else if (coord.x > (_currentSize.x - edgeSize)) {
				//правый столбец
				area = area | WindowAlign.RIGHT_MASK;
			} else {
				// центральный столбец
				area = area | WindowAlign.CENTER_MASK;
			}
			return area;
		}
		
		
		private function detectPanelDirection(align:int, coord:Point):Boolean {
			// Направление
			var d:Boolean;
			
			if (align & WindowAlign.CENTER_MASK) {
				d = Direction.HORIZONTAL;
			} else if (align & WindowAlign.MIDDLE_MASK) {
				d = Direction.VERTICAL;
			} else {
				if (align & WindowAlign.LEFT_MASK) {
					// левые углы
					if (align & WindowAlign.TOP_MASK) {
						// верхний
						d = (coord.y <= coord.x) ? Direction.HORIZONTAL : Direction.VERTICAL;
					} else {
						// нижний
						d = (coord.y > (-coord.x + currentSize.y)) ? Direction.HORIZONTAL : Direction.VERTICAL;
					}
				} else {
					// правые углы
					if (align & WindowAlign.TOP_MASK) {
						// верхний
						d = (coord.y <= -(coord.x - currentSize.x)) ? Direction.HORIZONTAL : Direction.VERTICAL;
					} else {
						// нижний
						d = (coord.y > (coord.x - currentSize.x + currentSize.y)) ? Direction.HORIZONTAL : Direction.VERTICAL;
					}
				}
			}
			return d;
		}
		
		/*override public function set minSizeChanged(value:Boolean):void {
			super.minSizeChanged = value;
			
		}*/
		
	}
}