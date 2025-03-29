package alternativa.gui.base {
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Перетаскиваемый и масштабируемый интерактивный объект с возможностью снапа (<code>ISnapable</code>)
	 */		
	public class ResizeableBase extends MoveableBase {
		
		/**
		 * @private
		 * Флаг растягивания сверху 
		 */		
		private var _topResizeEnabled:Boolean;
		/**
		 * @private
		 * Флаг растягивания снизу
		 */		
		private var _bottomResizeEnabled:Boolean;
		/**
		 * @private
		 * Флаг растягивания слева
		 */		
		private var _leftResizeEnabled:Boolean;
		/**
		 * @private
		 * Флаг растягивания справа
		 */		
		private var _rightResizeEnabled:Boolean;
		/**
		 * @private
		 * Толщина краёв
		 */		
		private static const edgeSize:int = 4;
		/**
		 * @private
		 * Максимальный размер угла
		 */		
		private static const maxCornerSize:int = 25;
		/**
		 * @private
		 * Ширина угловых краёв
		 */		
		private var edgeCornerWidth:uint;
		/**
		 * @private
		 * Высота угловых краёв
		 */		
		private var edgeCornerHeight:uint;
		/**
		 * @private
		 * Выступание областей для масштабирования за края объекта
		 */		
		private var edgeSurplus:int = 2;
		/**
		 * @private
		 * Контейнер краев 
		 */		
		private var edges:Sprite;
		/**
		 * @private
		 * Верхний край 
		 */		
		private var edgeT:ResizeableBaseEdge;
		/**
		 * @private
		 * Нижний край 
		 */
		private var edgeB:ResizeableBaseEdge;
		/**
		 * @private
		 * Левый край 
		 */
		private var edgeL:ResizeableBaseEdge;
		/**
		 * @private
		 * Правый край 
		 */
		private var edgeR:ResizeableBaseEdge;
		/**
		 * @private
		 * Верхний-левый край 
		 */
		private var edgeTL:ResizeableBaseEdge;
		/**
		 * @private
		 * Верхний-правый край 
		 */
		private var edgeTR:ResizeableBaseEdge;
		/**
		 * @private
		 * Нижний-левый край 
		 */
		private var edgeBL:ResizeableBaseEdge;
		/**
		 * @private
		 * Нижний-правый край 
		 */
		private var edgeBR:ResizeableBaseEdge;
		/**
		 * @private
		 * Текущий край растягивания
		 */		
		private var currentEdge:ResizeableBaseEdge;
		/**
		 * @private
		 * Старые координаты
		 */		
		private var oldCoords:Point;
		/**
		 * @private
		 * Старый размер
		 */		
		private var oldSize:Point;
		
		/**
		 * @param top масштабируемость за верхний край
		 * @param bottom масштабируемость за нижний край
		 * @param left масштабируемость за левый край
		 * @param right масштабируемость за правый край
		 */		
		public function ResizeableBase(top:Boolean, bottom:Boolean, left:Boolean, right:Boolean) {
			super();
			_topResizeEnabled = top;
			_bottomResizeEnabled = bottom;
			_leftResizeEnabled = left;
			_rightResizeEnabled = right;
			
			_stretchableH = true;
			_stretchableV = true;
			
			// Область для краёв
			edges = new Sprite();
			edges.mouseEnabled = false;
			edges.tabEnabled = false;
			addChild(edges);
			edges.alpha = 0;
			// Выступ за край
			edges.x = -edgeSurplus;
			edges.y = -edgeSurplus;
			// Создание краев для масштабирования
			edgeT = new ResizeableBaseEdge(this, ResizeableBaseEdge.TOP, _topResizeEnabled);
			edgeB = new ResizeableBaseEdge(this, ResizeableBaseEdge.BOTTOM, _bottomResizeEnabled);
			edgeL = new ResizeableBaseEdge(this, ResizeableBaseEdge.LEFT, _leftResizeEnabled);
			edgeR = new ResizeableBaseEdge(this, ResizeableBaseEdge.RIGHT, _rightResizeEnabled);
			edgeTL = new ResizeableBaseEdge(this, ResizeableBaseEdge.TOP_LEFT, _topResizeEnabled && _leftResizeEnabled);
			edgeTR = new ResizeableBaseEdge(this, ResizeableBaseEdge.TOP_RIGHT, _topResizeEnabled && _rightResizeEnabled);
			edgeBL = new ResizeableBaseEdge(this, ResizeableBaseEdge.BOTTOM_LEFT, _bottomResizeEnabled && _leftResizeEnabled);
			edgeBR = new ResizeableBaseEdge(this, ResizeableBaseEdge.BOTTOM_RIGHT, _bottomResizeEnabled && _rightResizeEnabled);
			edges.addChild(edgeT);
			edges.addChild(edgeB);
			edges.addChild(edgeL);
			edges.addChild(edgeR);
			edges.addChild(edgeTL);
			edges.addChild(edgeTR);
			edges.addChild(edgeBL);
			edges.addChild(edgeBR);
			
			keyFiltersConfig.childrenKeysAvailable = true;
			keyFiltersConfig.addActiveChild(edgeT);
			keyFiltersConfig.addActiveChild(edgeB);
			keyFiltersConfig.addActiveChild(edgeL);
			keyFiltersConfig.addActiveChild(edgeR);
			keyFiltersConfig.addActiveChild(edgeTL);
			keyFiltersConfig.addActiveChild(edgeTR);
			keyFiltersConfig.addActiveChild(edgeBL);
			keyFiltersConfig.addActiveChild(edgeBR);
		}
		
		/**
		 * Отрисовка в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			// сохраняем новые снаповые габариты
			if (!(snapRect.width == 0 && snapRect.height == 0)) {
				snapRect = new Rectangle(snapRect.x, snapRect.y, snapRect.width + size.x - _currentSize.x, snapRect.height + size.y - _currentSize.y);
			}
			super.draw(size);
			drawEdges();
		}
		
		/**
		 * Отрисовка краев для масштабирования
		 */		
		private function drawEdges():void {
			// Расчет размеров углов
			edgeCornerWidth = Math.min(Math.max(_currentSize.x >>> 2, edgeSize), maxCornerSize);
			edgeCornerHeight = Math.min(Math.max(_currentSize.y >>> 2, edgeSize), maxCornerSize);
			// Отрисовка углов
			drawEdgeCorner(edgeTL);
			drawEdgeCorner(edgeTR);
			drawEdgeCorner(edgeBL);
			drawEdgeCorner(edgeBR);
			// Отрисовка краев
			drawEdge(edgeT);
			drawEdge(edgeB);
			drawEdge(edgeL);
			drawEdge(edgeR);
		}
		
		/**
		 * Отрисовка края для масштабирования
		 * @param edge край
		 */		
		private function drawEdge(edge:ResizeableBaseEdge):void {
			if (edge != null) {
				var gfx:Graphics = edge.graphics;
				gfx.clear();
				gfx.beginFill(0xFF0000);
				switch (edge.type) {
					case ResizeableBaseEdge.TOP:
						edge.x = leftResizeEnabled ? edgeCornerWidth : 0;
						gfx.drawRect(0, 0, _currentSize.x - edge.x - (rightResizeEnabled ? edgeCornerWidth : 0) + edgeSurplus*2, edgeSize);
						break;
					case ResizeableBaseEdge.BOTTOM:
						edge.x = leftResizeEnabled ? edgeCornerWidth : 0;
						edge.y = _currentSize.y + edgeSurplus*2;
						gfx.drawRect(0, 0, _currentSize.x - edge.x - (rightResizeEnabled ? edgeCornerWidth : 0) + edgeSurplus*2, -edgeSize);
						break;
					case ResizeableBaseEdge.LEFT:
						edge.y = topResizeEnabled ? edgeCornerHeight : 0;
						gfx.drawRect(0, 0, edgeSize, _currentSize.y - edge.y - (bottomResizeEnabled ? edgeCornerHeight : 0) + edgeSurplus*2);
						break;
					case ResizeableBaseEdge.RIGHT:
						edge.x = _currentSize.x + edgeSurplus*2;
						edge.y = topResizeEnabled ? edgeCornerHeight : 0;
						gfx.drawRect(0, 0, -edgeSize, _currentSize.y - edge.y - (bottomResizeEnabled ? edgeCornerHeight : 0) + edgeSurplus*2);
						break;
				}
			}
		}
		/**
		 * Отрисовка углового края для масштабирования
		 * @param edge край
		 */		
		private function drawEdgeCorner(edge:ResizeableBaseEdge):void {
			if (edge != null) {
				var dirH:int;
				var dirV:int;
				switch (edge.type) {
					case ResizeableBaseEdge.TOP_LEFT:
						dirV = 1;
						dirH = 1;
						break;
					case ResizeableBaseEdge.TOP_RIGHT:
						dirV = 1;
						dirH = -1;
						edge.x = _currentSize.x + edgeSurplus*2;
						break;
					case ResizeableBaseEdge.BOTTOM_LEFT:
						dirV = -1;
						dirH = 1;
						edge.y = _currentSize.y + edgeSurplus*2;
						break;
					case ResizeableBaseEdge.BOTTOM_RIGHT:
						dirV = -1;
						dirH = -1;
						edge.x = _currentSize.x + edgeSurplus*2;
						edge.y = _currentSize.y + edgeSurplus*2;
						break;
				}
				with (edge.graphics) {
					clear();
					beginFill(0x0000FF);
					lineTo(edgeCornerWidth*dirH, 0);
					lineTo(edgeCornerWidth*dirH, edgeSize*dirV);
					lineTo(edgeSize*dirH, edgeSize*dirV);
					lineTo(edgeSize*dirH, edgeCornerHeight*dirV);
					lineTo(0, edgeCornerHeight*dirV);
				}
			}
		}
		
		/**
		 * Перетаскивание или масштабирование
		 * @param mouseCoord глобальные координаты мыши
		 */		
		override public function mouseMove(mouseCoord:Point):void {
			// Локальные координаты мыши
			var localCoords:Point = globalToLocal(mouseCoord);
			
			if (pressed) {
				//removeKeyDownFilter(shiftFilter);
				//removeKeyUpFilter(shiftFilter);
				// Расчет смещения
				var offset:Point = new Point(localCoords.x - pivot.x, localCoords.y - pivot.y);
				// Передача воздействия компоновщику
				IManager(parentContainer.layoutManager).handleInfluences(new Array(this), new Array(offset));
			} else {
				// Изменения по координатам и размерам
				var delta:Rectangle = new Rectangle();
				switch (currentEdge.type) {
					case ResizeableBaseEdge.TOP_LEFT:
						delta.x = localCoords.x - pivot.x;
						delta.y = localCoords.y - pivot.y;
						delta.width = -delta.x;
						delta.height = -delta.y;
						break;
					case ResizeableBaseEdge.TOP_RIGHT:
						delta.y = localCoords.y - pivot.y;
						delta.width = localCoords.x - pivot.x;
						delta.height = -delta.y;
						break;
					case ResizeableBaseEdge.BOTTOM_LEFT:
						delta.x = localCoords.x - pivot.x;
						delta.width = -delta.x;
						delta.height = localCoords.y - pivot.y;
						break;
					case ResizeableBaseEdge.BOTTOM_RIGHT:
						delta.width = localCoords.x - pivot.x;
						delta.height = localCoords.y - pivot.y;
						break;
					case ResizeableBaseEdge.TOP:
						delta.y = localCoords.y - pivot.y;
						delta.height = -delta.y;
						break;
					case ResizeableBaseEdge.BOTTOM:
						delta.height = localCoords.y - pivot.y;
						break;
					case ResizeableBaseEdge.LEFT:
						delta.x = localCoords.x - pivot.x;
						delta.width = -delta.x;
						break;
					case ResizeableBaseEdge.RIGHT:
						delta.width = localCoords.x - pivot.x;
						break;
				}
				resize(delta);
			}
		}
		
		/**
		 * @private
		 * Начало масштабирования 
		 * @param resizeEdge край, за который масштабируют
		 */		
		internal function onStartResize(resizeEdge:ResizeableBaseEdge):void {
			currentEdge = resizeEdge;
			// Сохраняем координаты
			pivot = new Point(mouseX, mouseY);
			oldCoords = new Point(x, y);
			// Сохраняем размер
			oldSize = _currentSize.clone();
		}

		/**
		 * @private
		 * Завершение масштабирования
		 */		
		internal function onStopResize():void {
			if (currentEdge != null) {
				currentEdge = null;
				// Сообщаем об изменении координат и размера, если они изменились
				if (!oldCoords.equals(new Point(x, y))) {
					updateCoords();
				}
				if (!oldSize.equals(_currentSize)) {
					updateSize();
				}
			}
		}
		
		/**
		 * @private
		 * Отмена масштабирования
		 */		
		internal function onCancelResize():void {
			// Если в данный момент происходит масштабирование, то возращаемся к старому размеру и координатам
			if (currentEdge != null) {
				// сохранение типа края, за который масштабировали
				var edgeType:int = currentEdge.type;
				// Остановка масштабирования
				currentEdge.pressed = false;
				// Вычисление изменений по координатам и размерам
				var delta:Rectangle = new Rectangle();
				switch (edgeType) {
					case ResizeableBaseEdge.TOP_LEFT:
						delta.width = oldSize.x - _currentSize.x;
						delta.height = oldSize.y - _currentSize.y;
						delta.x = -delta.width;
						delta.y = -delta.height;
						break;
					case ResizeableBaseEdge.TOP_RIGHT:
						delta.width = oldSize.x - _currentSize.x;
						delta.height = oldSize.y - _currentSize.y;
						delta.y = -delta.height;
						break;
					case ResizeableBaseEdge.BOTTOM_LEFT:
						delta.width = oldSize.x - _currentSize.x;
						delta.height = oldSize.y - _currentSize.y;
						delta.x = -delta.width;
						break;
					case ResizeableBaseEdge.BOTTOM_RIGHT:
						delta.width = oldSize.x - _currentSize.x;
						delta.height = oldSize.y - _currentSize.y;
						break;
					case ResizeableBaseEdge.TOP:
						delta.height = oldSize.y - _currentSize.y;
						delta.y = -delta.height;
						break;
					case ResizeableBaseEdge.BOTTOM:
						delta.height = oldSize.y - _currentSize.y;
						break;
					case ResizeableBaseEdge.LEFT:
						delta.width = oldSize.x - _currentSize.x;
						delta.x = -delta.width;
						break;
					case ResizeableBaseEdge.RIGHT:
						delta.width = oldSize.x - _currentSize.x;
						break;
				}
				// Восстановление старых размеров и координат
				resize(delta);
			}
		}
		
		/**
		 * Масштабирование
		 * @param delta изменения по координатм и размерам
		 */		
		private function resize(delta:Rectangle):void {
			// Передача воздействия компоновщику
			IManager(parentContainer.layoutManager).handleInfluences(new Array(this), new Array(delta));
		}
		
		/**
		 * Изменился размер
		 */		
		protected function updateSize():void {}
		
		public function set topResizeEnabled(value:Boolean):void {
			_topResizeEnabled = value;
			
			edgeT.cursorActive = value;
			edgeTL.cursorActive = value;
			edgeTR.cursorActive = value;
		}

		public function set bottomResizeEnabled(value:Boolean):void {
			_bottomResizeEnabled = value;
			
			edgeB.cursorActive = value;
			edgeBL.cursorActive = value;
			edgeBR.cursorActive = value;
		}

		public function set leftResizeEnabled(value:Boolean):void {
			_leftResizeEnabled = value;
			
			edgeL.cursorActive = value;
			edgeTL.cursorActive = value;
			edgeBL.cursorActive = value;
		}

		public function set rightResizeEnabled(value:Boolean):void {
			_rightResizeEnabled = value;
			
			edgeR.cursorActive = value;
			edgeTR.cursorActive = value;
			edgeBR.cursorActive = value;
		}
		/**
		 * Флаг растягивания сверху 
		 */
		public function get topResizeEnabled():Boolean {
			return _topResizeEnabled;
		}
		/**
		 * Флаг растягивания снизу
		 */
		public function get bottomResizeEnabled():Boolean {
			return _bottomResizeEnabled;
		}
		/**
		 * Флаг растягивания слева
		 */
		public function get leftResizeEnabled():Boolean {
			return _leftResizeEnabled;
		}
		/**
		 * Флаг растягивания справа
		 */
		public function get rightResizeEnabled():Boolean {
			return _rightResizeEnabled;
		}
		
	}
}