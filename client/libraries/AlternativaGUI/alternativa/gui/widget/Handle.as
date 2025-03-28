package alternativa.gui.widget {
	import alternativa.gui.base.GUIObject;
	import alternativa.gui.init.GUI;
	import alternativa.gui.mouse.IMouseCoordListener;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ShapeButton;
	import alternativa.utils.MouseUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Handle extends GUIObject implements IMouseCoordListener {
		
		private var area:Bitmap;
		private var handle:Bitmap;
		private var handleContainer:Sprite;
		
		private var areaDiametr:int;
		private var handleDiametr:int;
		
		private var button:ShapeButton;
		
		private var holdY:int;
		private var oldRotation:Number;
		
		private var _currentPos:int;
		private var minPos:int;
		private var maxPos:int;
		
		/**
		 * Центр 
		 */		
		private var center:Point;
		
		
		public function Handle(areaBitmap:BitmapData, handleBitmap:BitmapData, areaDiametr:int, handleDiametr:int, minPos:int, maxPos:int, startPos:int) {
			super();
			
			this.areaDiametr = areaDiametr;
			this.handleDiametr = handleDiametr;
			this.minPos = minPos;
			this.maxPos = maxPos;
			
			center = new Point(Math.floor(areaDiametr*0.5), Math.floor(areaDiametr*0.5));
			
			area = new Bitmap(areaBitmap);
			handle = new Bitmap(handleBitmap, PixelSnapping.AUTO, true);
			handleContainer = new Sprite();
			handleContainer.mouseChildren = false;
			handleContainer.mouseEnabled = false;
			handleContainer.tabChildren = false;
			handleContainer.tabEnabled = false;
			addChild(area);
			addChild(handleContainer);
			handleContainer.addChild(handle);
			area.x = Math.round((areaDiametr - area.width)*0.5); 
			area.y = Math.round((areaDiametr - area.height)*0.5);
			handle.x = -handle.width*0.5;
			handle.y = -handle.height*0.5;
			handleContainer.x = area.x + area.width*0.5; 
			handleContainer.y = area.y + area.height*0.5; 
			
			currentPos = startPos;
			
			button = new ShapeButton();
			button.graphics.beginFill(0xff0000, 0);
			button.graphics.drawCircle(0, 0, handleDiametr*0.5);
			addChild(button);
			button.x = center.x;
			button.y = center.y;
			
			button.addEventListener(ButtonEvent.PRESS, onStartDrag);
			button.addEventListener(ButtonEvent.EXPRESS, onStopDrag);
		}
		
		/**
		 * Обновление скина 
		 */		
		/*override public function updateSkin():void {
			imageButtonSkin = ImageButtonSkin(skinManager.getSkin(ImageButton));
			super.updateSkin();
		}*/
		
		/**
		 * Расчет минимальных размеров объекта
		 * @return минимальные размеры
		 */		 		
		override public function computeMinSize():Point {
			_minSize = new Point(areaDiametr, areaDiametr);
			_minSizeChanged = false;
			
			return _minSize;
		}
		
		/**
		 * Расчет предпочтительных размеров с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */				
		override public function computeSize(size:Point):Point {
			return _minSize;
		}
		
		/**
		 * Отрисовка в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			super.draw(size);
		}
		
		private function onStartDrag(e:ButtonEvent):void {
			holdY = MouseUtils.localCoords(this).y - center.y;
			oldRotation = handleContainer.rotation;
			GUI.mouseManager.addMouseCoordListener(this);
			
			dispatchEvent(new HandleEvent(HandleEvent.START_DRAG, _currentPos));
		}
		private function onStopDrag(e:ButtonEvent):void {
			GUI.mouseManager.removeMouseCoordListener(this);
			
			dispatchEvent(new HandleEvent(HandleEvent.STOP_DRAG, _currentPos));
		}
		
		/**
		 * Рассылка изменения координат мыши 
		 * @param mouseCoord координаты мыши
		 */		
		public function mouseMove(mouseCoord:Point):void {
			var localMouseCoords:Point = MouseUtils.localCoords(this);
			var newRotation:int = oldRotation + holdY - (localMouseCoords.y - center.y);
			if (newRotation > maxPos) {
				newRotation = maxPos;
			} else if (newRotation < minPos) {
				newRotation = minPos;
			}
			currentPos = newRotation;
		}
		
		public function set currentPos(value:int):void {
			_currentPos = value;
			handleContainer.rotation = _currentPos;
			
			dispatchEvent(new HandleEvent(HandleEvent.CHANGE_POS, _currentPos));
		}	
		public function get currentPos():int {
			return _currentPos;
		}
			
			
	}
}