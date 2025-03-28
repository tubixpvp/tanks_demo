package alternativa.gui.window.panel {
	import alternativa.gui.base.IGUIObject;
	import alternativa.gui.base.IRotateable;
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.AvailableAngle;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.WindowAlign;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.window.WindowBase;
	import alternativa.gui.window.WindowTitleBase;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class ResizeablePanelBase extends WindowBase {
		
		private var maximizedSize:Point;
		
		private var _direction:Boolean;
		
		private var _dragable:Boolean;
		
		// Угол поворота графики
		private var _rotationAngle:Number;
		
		private var _resizeable:Boolean;
		
		public function ResizeablePanelBase(direction:Boolean, screenAlign:int, minWidth:uint = 0, minHeight:uint = 0, stretchable:Boolean = false, resizeable:Boolean = false, titled:Boolean = false, title:String = null, closeable:Boolean = true, minimizeable:Boolean = false, minimized:Boolean = false) {
			
			if (direction == Direction.HORIZONTAL) {
				var w:int = minWidth;
				var h:int = minHeight;
			} else {
				w = minHeight;
				h = minWidth;
			}
			super(w, h, resizeable, titled, title, closeable, false, false, screenAlign);
			
			_stretchableH = stretchable && (direction == Direction.HORIZONTAL);
			_stretchableV = stretchable && (direction == Direction.VERTICAL);
			windowContainer.stretchableH = _stretchableH;
			windowContainer.stretchableV = _stretchableV;
			
			maximizedSize = new Point();
			
			//сохранение параметров
			this.minimized = minimized;
			_resizeable = resizeable;
			_direction = direction;
			_dragable = true;
			
			// Поворот графики
			if (direction == Direction.HORIZONTAL) {
				if (screenAlign & WindowAlign.BOTTOM_MASK) {
					// 0
					initAngle(AvailableAngle.DEGREES_0);
				} else if (screenAlign & WindowAlign.TOP_MASK) {
					// 180
					initAngle(AvailableAngle.DEGREES_180);
				}
			} else {
				if (screenAlign & WindowAlign.RIGHT_MASK) {
					// 270
					initAngle(AvailableAngle.DEGREES_270);
				} else if (screenAlign & WindowAlign.LEFT_MASK) {
					// 90
					initAngle(AvailableAngle.DEGREES_90);
				}
			}
			
			moveArea = null;
			
			// разрешение масштабирования сторон в зависимости от выравнивания на экране
			if (resizeable) {
				oldTopResizeEnabled = topResizeEnabled;
				oldBottomResizeEnabled = bottomResizeEnabled;
				oldLeftResizeEnabled = leftResizeEnabled;
				oldRightResizeEnabled = rightResizeEnabled;
				
				topResizeEnabled = (align & WindowAlign.BOTTOM_MASK) && !minimized;
				bottomResizeEnabled = (align & WindowAlign.TOP_MASK) && !minimized;
				leftResizeEnabled = (align & WindowAlign.RIGHT_MASK) && !minimized;
				rightResizeEnabled = (align & WindowAlign.LEFT_MASK) && !minimized;
			}				
			/*if (resizeable) {
				topResizeEnabled = align & WindowAlign.BOTTOM_MASK;
				bottomResizeEnabled = align & WindowAlign.TOP_MASK;
				leftResizeEnabled = align & WindowAlign.RIGHT_MASK;
				rightResizeEnabled = align & WindowAlign.LEFT_MASK;
				
				_stretchableV = topResizeEnabled || bottomResizeEnabled;
				_stretchableH = leftResizeEnabled || rightResizeEnabled;
				windowContainer.stretchableH = _stretchableH;
				windowContainer.stretchableV = _stretchableV;
				
				oldTopResizeEnabled = topResizeEnabled;
				oldBottomResizeEnabled = bottomResizeEnabled;
				oldLeftResizeEnabled = leftResizeEnabled;
				oldRightResizeEnabled = rightResizeEnabled;
			}*/
			
			if (titled) {
				//winTitle = createTitle(container, title, true);
				//addTitle(winTitle);
				//moveArea = winTitle;
				//winTitle.addEventListener(Event.CLOSE, onClose);
				//winTitle.addEventListener(MouseEvent.CLICK, onTitleClick);
			}
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
		override protected function createTitle(contentContainer:Container, titleString:String, closeable:Boolean, minimizeable:Boolean, maximizeable:Boolean):WindowTitleBase {
			return new PanelTitleBase(contentContainer, titleString, closeable, true);
		}
		
		// Установка скина
		override public function updateSkin():void {
			super.updateSkin();
			
			/*if (minimized) {
				minimize();
			} else {
				maximize();
			}*/
		}
		
		// Переопределение класса для скинования
		override protected function getSkinType():Class {
			return ResizeablePanelBase;
		}
		
		
		override public function computeMinSize():Point {
			var newSize:Point = super.computeMinSize();
			
			if (titled && minimized) {
				var titleSize:Point = winTitle.computeMinSize();
				newSize.y = titleSize.y;
			}
			//trace("ResizeablePanelBase computeMinSize: " + newSize);
			return newSize;
		}
		
		override public function computeSize(size:Point):Point {
			//trace("ResizeablePanelBase computeSize size: " + size);
			//var limitedSize:Point = size.clone();
			var limitedSize:Point = new Point();
			
			// проверка на минимум
			if (_direction == Direction.HORIZONTAL) {
				limitedSize.x = _stretchableH ? Math.max(size.x, windowContainer.minSize.x, windowContainer.layoutManager.minSize.x) : Math.max(windowContainer.minSize.x, windowContainer.layoutManager.minSize.x);
				limitedSize.y = Math.max(size.y, windowContainer.minSize.y);
			} else {
				limitedSize.x = Math.max(size.x, windowContainer.minSize.x);
				limitedSize.y = _stretchableV ? Math.max(size.y, windowContainer.minSize.y, windowContainer.layoutManager.minSize.y) : Math.max(windowContainer.minSize.y, windowContainer.layoutManager.minSize.y);
			}
			
			if (_direction == Direction.HORIZONTAL) {
				if (limitedSize.y > rootObject.currentSize.y*0.5 && rootObject.currentSize.y != 0) {
					limitedSize.y = Math.floor(rootObject.currentSize.y*0.5);
					minSizeChanged = true;
				}
			} else {
				if (limitedSize.x > rootObject.currentSize.x*0.5 && rootObject.currentSize.x != 0) {
					limitedSize.x = Math.floor(rootObject.currentSize.x*0.5);
					minSizeChanged = true;
				}
			}
			// проверка на минимум
			//size.x = isStretchable(Direction.HORIZONTAL) ? Math.max(_size.x, _minSize.x, layoutManager.minSize.x) : Math.max(_minSize.x, layoutManager.minSize.x);
			//size.y = isStretchable(Direction.VERTICAL) ? Math.max(_size.y, _minSize.y, layoutManager.minSize.y) : Math.max(_minSize.y, layoutManager.minSize.y);
			
			//size.x = isStretchable(Direction.HORIZONTAL) ? Math.max(_size.x, _minSize.x) : _minSize.x;
			//size.y = isStretchable(Direction.VERTICAL) ? Math.max(_size.y, _minSize.y) : _minSize.y;
			
			// Определяем размер контента
			var contentSize:Point = windowContainer.layoutManager.computeSize(limitedSize.subtract(new Point(windowContainer.marginLeft + windowContainer.marginRight, windowContainer.marginTop + windowContainer.marginBottom)));
			
			// Определяем размер контейнера с отступами
			var newSize:Point = new Point(contentSize.x + windowContainer.marginLeft + windowContainer.marginRight, contentSize.y + windowContainer.marginTop + windowContainer.marginBottom);
			
			// Пытаемся принять предлагаемый размер (не меньше размера с учетом контента)
			newSize.x = Math.max(limitedSize.x, newSize.x);
			newSize.y = Math.max(limitedSize.y, newSize.y);
			
			//super.computeSize(size);
			
			//trace("ResizeablePanelBase computeSize newSize: " + newSize);
			return newSize;
		}
		
		/*override public function computeSize(size:Point):Point {
			var newSize:Point = minSize.clone();
			
			/*if (isStretchable(Direction.HORIZONTAL)) {
				newSize.x = Math.max(size.x, minSize.x);
			} else {
				if (leftResizeEnabled || rightResizeEnabled) {
					newSize.x = Math.max(size.x, minSize.x);
				}
			}
			if (isStretchable(Direction.VERTICAL)) {
				newSize.y =  Math.max(size.y, minSize.y);
			} else {
				if (topResizeEnabled || bottomResizeEnabled) {
					newSize.y = Math.max(size.y, minSize.y);		
				}
			}
			newSize = super.computeSize(newSize);
			if (titled && minimized) {
				var titleSize:Point = winTitle.computeSize(new Point(newSize.x, 0));
				newSize = new Point(newSize.x, titleSize.y);
			}
			//trace("ResizeablePanel computeSize newSize: " + newSize.x + ", " + newSize.y);
			return newSize;
		}*/
		
		override public function draw(size:Point):void {
			//trace("ResizeablePanel draw size: " + size.x + ", " + size.y);
			//trace(" ");
			super.draw(size);
		}
		
		// загрузка битмап из скина
		override protected function loadBitmaps():void {
			
			var rotationMatrix:Matrix = new Matrix(Math.cos(_rotationAngle), Math.sin(_rotationAngle), -Math.sin(_rotationAngle), Math.cos(_rotationAngle));
			switch (_rotationAngle) {
				case 0:
					cTLbmp.bitmapData = skin.cornerTLmargin;
					cTRbmp.bitmapData = skin.cornerTRmargin;
					cBLbmp.bitmapData = skin.cornerBL;
					cBRbmp.bitmapData = skin.cornerBR;
					eTCbmp.bitmapData = skin.edgeTC;
					eMLbmp.bitmapData = skin.edgeML;
					eMRbmp.bitmapData = skin.edgeMR;
					eBCbmp.bitmapData = skin.edgeBC;
					bgbmp.bitmapData = skin.bgMC;
					break;
				case Math.PI*0.5:
					cTLbmp.bitmapData = new BitmapData(skin.cornerBL.height, skin.cornerBL.width, true, 0);
					cTRbmp.bitmapData = new BitmapData(skin.cornerTLmargin.height, skin.cornerTLmargin.width, true, 0);
					cBLbmp.bitmapData = new BitmapData(skin.cornerBR.height, skin.cornerBR.width, true, 0);
					cBRbmp.bitmapData = new BitmapData(skin.cornerTRmargin.height, skin.cornerTRmargin.width, true, 0);
					
					eTCbmp.bitmapData = new BitmapData(skin.edgeML.height, skin.edgeML.width, true, 0);
					eMLbmp.bitmapData = new BitmapData(skin.edgeBC.height, skin.edgeBC.width, true, 0);
					eMRbmp.bitmapData = new BitmapData(skin.edgeTC.height, skin.edgeTC.width, true, 0);
					eBCbmp.bitmapData = new BitmapData(skin.edgeMR.height, skin.edgeMR.width, true, 0);
					bgbmp.bitmapData = new BitmapData(skin.bgMC.height, skin.bgMC.width, true, 0);
					
					rotationMatrix.tx = skin.cornerBL.height;
					cTLbmp.bitmapData.draw(skin.cornerBL, rotationMatrix, null, BlendMode.NORMAL, cTLbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.cornerTLmargin.height;
					cTRbmp.bitmapData.draw(skin.cornerTLmargin, rotationMatrix, null, BlendMode.NORMAL, cTRbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.cornerBR.height;
					cBLbmp.bitmapData.draw(skin.cornerBR, rotationMatrix, null, BlendMode.NORMAL, cBLbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.cornerTRmargin.height;
					cBRbmp.bitmapData.draw(skin.cornerTRmargin, rotationMatrix, null, BlendMode.NORMAL, cBRbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.edgeML.height;
					eTCbmp.bitmapData.draw(skin.edgeML, rotationMatrix, null, BlendMode.NORMAL, eTCbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.edgeBC.height;
					eMLbmp.bitmapData.draw(skin.edgeBC, rotationMatrix, null, BlendMode.NORMAL, eMLbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.edgeTC.height;
					eMRbmp.bitmapData.draw(skin.edgeTC, rotationMatrix, null, BlendMode.NORMAL, eMRbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.edgeMR.height;
					eBCbmp.bitmapData.draw(skin.edgeMR, rotationMatrix, null, BlendMode.NORMAL, eBCbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.bgMC.height;
					bgbmp.bitmapData.draw(skin.bgMC, rotationMatrix, null, BlendMode.NORMAL, bgbmp.bitmapData.rect, false);
					break;
				case Math.PI:
					cTLbmp.bitmapData = new BitmapData(skin.cornerBR.width, skin.cornerBR.height, true, 0);
					cTRbmp.bitmapData = new BitmapData(skin.cornerBL.width, skin.cornerBL.height, true, 0);
					cBLbmp.bitmapData = new BitmapData(skin.cornerTRmargin.width, skin.cornerTRmargin.height, true, 0);
					cBRbmp.bitmapData = new BitmapData(skin.cornerTLmargin.width, skin.cornerTLmargin.height, true, 0);
					
					eTCbmp.bitmapData = new BitmapData(skin.edgeBC.width, skin.edgeBC.height, true, 0);
					eMLbmp.bitmapData = new BitmapData(skin.edgeMR.width, skin.edgeMR.height, true, 0);
					eMRbmp.bitmapData = new BitmapData(skin.edgeML.width, skin.edgeML.height, true, 0);
					eBCbmp.bitmapData = new BitmapData(skin.edgeTC.width, skin.edgeTC.height, true, 0);
					bgbmp.bitmapData = new BitmapData(skin.bgMC.width, skin.bgMC.height, true, 0);
				
					rotationMatrix.tx = skin.cornerBR.width;
					rotationMatrix.ty = skin.cornerBR.height;
					cTLbmp.bitmapData.draw(skin.cornerBR, rotationMatrix, null, BlendMode.NORMAL, cTLbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.cornerBL.width;
					rotationMatrix.ty = skin.cornerBL.height;
					cTRbmp.bitmapData.draw(skin.cornerBL, rotationMatrix, null, BlendMode.NORMAL, cTRbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.cornerTRmargin.width;
					rotationMatrix.ty = skin.cornerTRmargin.height;
					cBLbmp.bitmapData.draw(skin.cornerTRmargin, rotationMatrix, null, BlendMode.NORMAL, cBLbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.cornerTLmargin.width;
					rotationMatrix.ty = skin.cornerTLmargin.height;
					cBRbmp.bitmapData.draw(skin.cornerTLmargin, rotationMatrix, null, BlendMode.NORMAL, cBRbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.edgeBC.width;
					rotationMatrix.ty = skin.edgeBC.height;
					eTCbmp.bitmapData.draw(skin.edgeBC, rotationMatrix, null, BlendMode.NORMAL, eTCbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.edgeMR.width;
					rotationMatrix.ty = skin.edgeMR.height;
					eMLbmp.bitmapData.draw(skin.edgeMR, rotationMatrix, null, BlendMode.NORMAL, eMLbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.edgeML.width;
					rotationMatrix.ty = skin.edgeML.height;
					eMRbmp.bitmapData.draw(skin.edgeML, rotationMatrix, null, BlendMode.NORMAL, eMRbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.edgeTC.width;
					rotationMatrix.ty = skin.edgeTC.height;
					eBCbmp.bitmapData.draw(skin.edgeTC, rotationMatrix, null, BlendMode.NORMAL, eBCbmp.bitmapData.rect, false);
					
					rotationMatrix.tx = skin.bgMC.width;
					rotationMatrix.ty = skin.bgMC.height;
					bgbmp.bitmapData.draw(skin.bgMC, rotationMatrix, null, BlendMode.NORMAL, bgbmp.bitmapData.rect, false);
					break;
				case Math.PI*1.5:
					cTLbmp.bitmapData = new BitmapData(skin.cornerTRmargin.height, skin.cornerTRmargin.width, true, 0);
					cTRbmp.bitmapData = new BitmapData(skin.cornerBR.height, skin.cornerBR.width, true, 0);
					cBLbmp.bitmapData = new BitmapData(skin.cornerTLmargin.height, skin.cornerTLmargin.width, true, 0);
					cBRbmp.bitmapData = new BitmapData(skin.cornerBL.height, skin.cornerBL.width, true, 0);
					
					eTCbmp.bitmapData = new BitmapData(skin.edgeMR.height, skin.edgeMR.width, true, 0);
					eMLbmp.bitmapData = new BitmapData(skin.edgeTC.height, skin.edgeTC.width, true, 0);
					eMRbmp.bitmapData = new BitmapData(skin.edgeBC.height, skin.edgeBC.width, true, 0);
					eBCbmp.bitmapData = new BitmapData(skin.edgeML.height, skin.edgeML.width, true, 0);
					bgbmp.bitmapData = new BitmapData(skin.bgMC.height, skin.bgMC.width, true, 0);
					
					rotationMatrix.ty = skin.cornerTRmargin.width;
					cTLbmp.bitmapData.draw(skin.cornerTRmargin, rotationMatrix, null, BlendMode.NORMAL, cTLbmp.bitmapData.rect, false);
					
					rotationMatrix.ty = skin.cornerBR.width;
					cTRbmp.bitmapData.draw(skin.cornerBR, rotationMatrix, null, BlendMode.NORMAL, cTRbmp.bitmapData.rect, false);
					
					rotationMatrix.ty = skin.cornerTLmargin.width;
					cBLbmp.bitmapData.draw(skin.cornerTLmargin, rotationMatrix, null, BlendMode.NORMAL, cBLbmp.bitmapData.rect, false);
					
					rotationMatrix.ty = skin.cornerBL.width;
					cBRbmp.bitmapData.draw(skin.cornerBL, rotationMatrix, null, BlendMode.NORMAL, cBRbmp.bitmapData.rect, false);
					
					rotationMatrix.ty = skin.edgeMR.width;
					eTCbmp.bitmapData.draw(skin.edgeMR, rotationMatrix, null, BlendMode.NORMAL, eTCbmp.bitmapData.rect, false);
					
					rotationMatrix.ty = skin.edgeTC.width;
					eMLbmp.bitmapData.draw(skin.edgeTC, rotationMatrix, null, BlendMode.NORMAL, eMLbmp.bitmapData.rect, false);
					
					rotationMatrix.ty = skin.edgeBC.width;
					eMRbmp.bitmapData.draw(skin.edgeBC, rotationMatrix, null, BlendMode.NORMAL, eMRbmp.bitmapData.rect, false);
					
					rotationMatrix.ty = skin.edgeML.width;
					eBCbmp.bitmapData.draw(skin.edgeML, rotationMatrix, null, BlendMode.NORMAL, eBCbmp.bitmapData.rect, false);
					
					rotationMatrix.ty = skin.bgMC.width;
					bgbmp.bitmapData.draw(skin.bgMC, rotationMatrix, null, BlendMode.NORMAL, bgbmp.bitmapData.rect, false);
					break;
			} 
				
			if (titled) {
				/*if (closeable) {
					closeButton.normalBitmap = skin.closeNN;
					closeButton.overBitmap = skin.closeNN;
					closeButton.pressBitmap = skin.closeNP;
					closeButton.lockBitmap = skin.closeNN;
				}
				if (minimizeable) {				
					minimizeButton.normalBitmap = skin.minimizeNN;
					minimizeButton.overBitmap = skin.minimizeNN;
					minimizeButton.pressBitmap = skin.minimizeNP;
					minimizeButton.lockBitmap = skin.minimizeNN;
				}
				if (maximizeable) {
					maximizeButton.normalBitmap = skin.maximizeNN;
					maximizeButton.overBitmap = skin.maximizeNN;
					maximizeButton.pressBitmap = skin.maximizeNP;
					maximizeButton.lockBitmap = skin.maximizeNN;
				}*/			
				switch (_rotationAngle) {
					case 0:
						cTLbmp.bitmapData = skin.cornerTLactive;
						cTRbmp.bitmapData = skin.cornerTRactive;
						eTCbmp.bitmapData = skin.edgeTCactive;
						break;
					case Math.PI*0.5:
					
						break;
					case Math.PI:
					
						break;
					case Math.PI*1.5:
					
						break;
				} 
			}
		}
		
		override public function addObject(object:IGUIObject):void {
			super.addObject(object);
			if (object is IRotateable) IRotateable(object).initAngle(_rotationAngle);
		}
		
		// Обработчик щелчка на заголовке панели
		private function onTitleClick(e:MouseEvent):void {
			if (minimized) {
				maximize();
			} else {
				minimize();
			}
		}
		
		// Разворачивание
		protected function maximize():void {
			//trace("maximize");
			minimized = false;
			
			_currentSize = maximizedSize.clone();
			
			if (winTitle != null)
				PanelTitleBase(winTitle).setMaximizedState();
			container.visible = true;
			container.scaleY = 1;
			//container.mouseEnabled = true;
			gfx.visible = true;
			gfx.scaleY = 1;
			//gfx.mouseEnabled = true;
			
			topResizeEnabled = oldTopResizeEnabled;
			bottomResizeEnabled = oldBottomResizeEnabled;
			leftResizeEnabled = oldLeftResizeEnabled;
			rightResizeEnabled = oldRightResizeEnabled;
			
			minSizeChanged = true;
			if (rootObject != null)
				Container(rootObject).repaintCurrentSize();
			
			//topResizeEnabled = true;
			//if (Container(parent.parent).minSizeChanged == true)
			//Container(parent.parent).computeMinSize();
			//Container(parent.parent).computeSize(GUIObject(parent.parent).currentSize);
			//Container(parent.parent).draw(Container(parent.parent).currentSize);
			//Container(parent.parent).repaintCurrentSize();
			//Container(parentContainer).draw(Container(parentContainer).computeSize(Container(parentContainer).computeMinSize()));
		}
		
		// Сворачивание
		protected function minimize():void {
			//trace("minimize");
			minimized = true;
			
			maximizedSize = _currentSize.clone();
			_currentSize = titleContainer.currentSize.clone();
			
			if (winTitle != null)
				PanelTitleBase(winTitle).setMinimizedState();
			//containerMaxSize = new Point(container.currentSize.x, container.currentSize.y);
			//container.mouseEnabled = false;
			container.scaleY = 0;
			container.visible = false;
			//gfx.mouseEnabled = false;
			gfx.scaleY = 0;
			gfx.visible = false;
			
			oldTopResizeEnabled = topResizeEnabled;
			oldBottomResizeEnabled = bottomResizeEnabled;
			oldLeftResizeEnabled = leftResizeEnabled;
			oldRightResizeEnabled = rightResizeEnabled;
			
			topResizeEnabled = false;
			bottomResizeEnabled = false;
			leftResizeEnabled = false;
			rightResizeEnabled = false;
			
			minSizeChanged = true;
			if (rootObject != null)
				Container(rootObject).repaintCurrentSize();
			
			//topResizeEnabled = false;
			//if (Container(parent.parent).minSizeChanged == true)
			//Container(parent.parent).computeMinSize();
			//Container(parent.parent).computeSize(GUIObject(parent.parent).currentSize);
			//Container(parent.parent).draw(Container(parent.parent).currentSize);
			//GUIObject(parent.parent).repaintCurrentSize();
			//Container(parentContainer).draw(Container(parentContainer).computeSize(Container(parentContainer).computeMinSize()));
		}
		
		/*public function set minimized(value:Boolean):void {
			if (value) {
				minimize();
			} else {
				maximize();
			}
		}*/
		
		// Сообщаем об изменении координат, если они изменились
		override protected function updateCoords():void {
			
		}
		// Сообщаем об изменении размеров, если они изменились
		override protected function updateSize():void {
			minSizeChanged = true;
			if (rootObject != null)
				Container(rootObject).repaintCurrentSize();
		}
		
		/**
		 * Установка флага актуальности минимального размера
		 * true - надо пересчитать
		 * false - пересчитали 
		 */	
		override public function set minSizeChanged(value:Boolean):void {
			//trace("WindowBase minSizeChanged: " + value);
			_minSizeChanged = value;
			if (_minSizeChanged && _parentContainer != null)
				_parentContainer.minSizeChanged = true;
		}
		
		/*public function set direction(value:Boolean):void {
			if (_direction != value) {
				var w:int = windowContainer.minSize.x;
				var h:int = windowContainer.minSize.y;
				//_minSize.x = h;
				//_minSize.y = w;
				windowContainer.minSize.x = h;
				windowContainer.minSize.y = w;
				
				var sH:Boolean = _stretchableH;
				var sV:Boolean = _stretchableV;
				_stretchableH = sV;
				_stretchableV = sH;
				windowContainer.stretchableH = _stretchableH;
				windowContainer.stretchableV = _stretchableV;
				
				if (container.layoutManager is CompletelyFillLayoutManager) {
					CompletelyFillLayoutManager(container.layoutManager).direction = value;
				}				
				
				windowContainer.minSizeChanged = true;
				minSizeChanged = true;
			}
			_direction = value;
		}*/
		public function get direction():Boolean {
			return _direction;
		}
		
		override public function set stretchableH(value:Boolean):void {
			super.stretchableH = value;
			windowContainer.stretchableH = value;
		}
		
		override public function set stretchableV(value:Boolean):void {
			super.stretchableV = value;
			windowContainer.stretchableV = value;
		}
		
		//----- Rotateable
		
		/**
		 * Задать начальный угол поворота (без поворота графики)
		 * @param value - угол, кратный 90 градусам, заданный в радианах
		 */		
		public function initAngle(value:Number):void {
			_rotationAngle = value;
			
			// Поворот графики
			if (isSkined) loadBitmaps();
			
			// разрешение масштабирования сторон в зависимости от выравнивания на экране
			if (_resizeable) {
				topResizeEnabled = (align & WindowAlign.BOTTOM_MASK) && (_direction == Direction.HORIZONTAL);
				bottomResizeEnabled = (align & WindowAlign.TOP_MASK) && (_direction == Direction.HORIZONTAL);
				leftResizeEnabled = (align & WindowAlign.RIGHT_MASK) && (_direction == Direction.VERTICAL);
				rightResizeEnabled = (align & WindowAlign.LEFT_MASK) && (_direction == Direction.VERTICAL);
				
				//if (_direction == Direction.HORIZONTAL) stretchableV = topResizeEnabled || bottomResizeEnabled;
				//if (_direction == Direction.VERTICAL) stretchableH = leftResizeEnabled || rightResizeEnabled;
			}
			
			// Поворот контента
			for each (var object:DisplayObject in container.objects) {
				if (object is IRotateable)
					IRotateable(object).initAngle(value);
			}
		}
		
		/**
		 * Повернуть графику объекта на один из доступных углов
		 * @param value - угол, кратный 90 градусам, заданный в радианах
		 */		 
		public function set angle(value:Number):void {
			
			// Изменение направления, если необходимо
			if (((_rotationAngle == AvailableAngle.DEGREES_0 || _rotationAngle == AvailableAngle.DEGREES_180) && (value == AvailableAngle.DEGREES_90 || value == AvailableAngle.DEGREES_270))
				 || ((_rotationAngle == AvailableAngle.DEGREES_90 || _rotationAngle == AvailableAngle.DEGREES_270) && (value == AvailableAngle.DEGREES_0 || value == AvailableAngle.DEGREES_180)) 
					) {
				
				_direction = !_direction;
				
				var w:int = windowContainer.minSize.x;
				var h:int = windowContainer.minSize.y;
				//_minSize.x = h;
				//_minSize.y = w;
				windowContainer.minSize.x = h;
				windowContainer.minSize.y = w;
				
				w = _currentSize.x;
				h = _currentSize.y;
				_currentSize.x = h;
				_currentSize.y = w;
				
				var sH:Boolean = _stretchableH;
				var sV:Boolean = _stretchableV;
				
				if (_direction == Direction.HORIZONTAL) {
					stretchableH = sV;
					stretchableV = false;
				} else {
					stretchableH = false;
					stretchableV = sH;
				}
				
				if (container.layoutManager is CompletelyFillLayoutManager) {
					CompletelyFillLayoutManager(container.layoutManager).direction = _direction;
				}				
				
				windowContainer.minSizeChanged = true;
				minSizeChanged = true;
			}
			
			_rotationAngle = value;
			
			// Поворот графики
			if (isSkined) loadBitmaps();
			
			// разрешение масштабирования сторон в зависимости от выравнивания на экране
			if (_resizeable) {
				topResizeEnabled = (align & WindowAlign.BOTTOM_MASK) && (_direction == Direction.HORIZONTAL);
				bottomResizeEnabled = (align & WindowAlign.TOP_MASK) && (_direction == Direction.HORIZONTAL);
				leftResizeEnabled = (align & WindowAlign.RIGHT_MASK) && (_direction == Direction.VERTICAL);
				rightResizeEnabled = (align & WindowAlign.LEFT_MASK) && (_direction == Direction.VERTICAL);
				
				//if (_direction == Direction.HORIZONTAL) stretchableV = topResizeEnabled || bottomResizeEnabled;
				//if (_direction == Direction.VERTICAL) stretchableH = leftResizeEnabled || rightResizeEnabled;
			}
			
			// Поворот контента
			for each (var object:DisplayObject in container.objects) {
				if (object is IRotateable)
					IRotateable(object).angle = value;
			}
		}
		
		/**
		 * Получить угол поворота графики объекта
		 * @return - угол поворота
		 */			
		public function get angle():Number {
			return _rotationAngle;
		}
		
		// ----- DND
		/*public function isDragable():Boolean {
			return _dragable;
		}
		
		public function getDragObject():IDragObject {
			return new PanelDragObject(this);
		}*/
		
	}
}