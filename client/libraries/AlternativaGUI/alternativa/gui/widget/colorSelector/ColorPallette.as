package alternativa.gui.widget.colorSelector {
	import alternativa.gui.container.scrollBox.ScrollBox;
	import alternativa.gui.init.GUI;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.ScrollMode;
	import alternativa.gui.layout.impl.SimpleGridLayoutManager;
	import alternativa.iointerfaces.mouse.ICursorActive;
	import alternativa.gui.widget.Image;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ShapeButton;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	
	
	public class ColorPallette extends ScrollBox {
		
		private var _colors:Array;
		
		// Выбранный цвет
		private var _selectedColor:uint;
		
		private var selection:Shape;
		
		private var button:ShapeButton;
		
		
		public function ColorPallette(direction:Boolean,
									  cellsNum:int,
									  cellSize:Point,
									  colors:Array,
									  selectedColor:uint,
									  minWidth:int = 0,
								 	  minHeight:int = 0,
								  	  scrollMode:int = ScrollMode.AUTO,
								  	  stretchable:Boolean = false,
								  	  step:int = 1,
								  	  marginLeft:int = 0,
								  	  marginTop:int = 0,
								  	  marginRight:int = 0,
								  	  marginBottom:int = 0)	{
			var horizMode:int;
			var vertMode:int;
			if (direction == Direction.HORIZONTAL) {
				horizMode = scrollMode;
				vertMode = ScrollMode.NONE;
			} else {
				vertMode = scrollMode;
				horizMode = ScrollMode.NONE;
			}
			super(minWidth,
				  minHeight,
				  horizMode,
				  vertMode,
				  step,
				  marginLeft,
				  marginTop,
				  marginRight,
				  marginBottom);
			
			if (direction == Direction.HORIZONTAL) {
				stretchableH = stretchable;
				stretchableV = false;
			} else {
				stretchableH = false;
				stretchableV = stretchable;
			}
			
			_colors = colors;
			_selectedColor = selectedColor;
			
			layoutManager = new SimpleGridLayoutManager(direction, cellsNum, cellSize);
			
			for (var i:int = 0; i < _colors.length; i++) {
				var c:Image = new Image(new BitmapData(20, 20, false, uint(_colors[i])));
				addObject(c);
			}
			
			selection = new Shape();
			canvas.addChild(selection);
			
			selection.graphics.lineStyle(1, 0xffffff, 1);
			selection.graphics.drawRect(0, 0, 20, 20);
			selection.graphics.lineStyle(1, 0x000000, 1);
			selection.graphics.drawRect(1, 1, 18, 18);
			
			button = new ShapeButton();
			addChild(button);
			button.addEventListener(ButtonEvent.PRESS, onSelect);
		}
		
		override public function updateSkin():void {
			super.updateSkin();
			
			button.x = skin.borderThickness + _marginLeft;
			button.y = skin.borderThickness + _marginTop;
		}
		
		override public function draw(size:Point):void {
			super.draw(size);
			button.graphics.clear();
			button.graphics.beginFill(0x0000ff, 0);
			button.graphics.drawRect(0, 0, viewSize.x - _marginLeft - _marginRight, viewSize.y - _marginTop - _marginBottom);
			
			drawSelection();
		}
		
		private function onSelect(e:ButtonEvent):void {
			//trace("overed: " + IOInterfaces.mouseManager.overed);
			var objectsUnderCursor:Array = GUI.mouseManager.objectsUnderCursor;
			//trace("objectsUnderCursor: " + objectsUnderCursor);
			
			// Удаление из списка кнопки
			var index:int = objectsUnderCursor.indexOf(button);
			if (index != -1) objectsUnderCursor.splice(index, 1);
			
			if (objectsUnderCursor.length > 0) {
				index = objectsUnderCursor.length-1;
				var activeObject:ICursorActive;
				while (activeObject == null && index >= 0) {
					if (objectsUnderCursor[index] is ICursorActive) {
						if (ICursorActive(objectsUnderCursor[index]).cursorActive) {
							// активный объект найден
							activeObject = ICursorActive(objectsUnderCursor[index]);
						} else {
							// поиск активного объекта среди родителей текущего
							activeObject = findActiveParent(DisplayObject(objectsUnderCursor[index]));
						}
					} else {
						// поиск активного объекта среди родителей текущего
						activeObject = findActiveParent(DisplayObject(objectsUnderCursor[index]));
					}
					index--;
				}
				if (activeObject != null) {
					//trace("activeObject: " + activeObject);
					var colorIndex:int = objects.indexOf(activeObject);
					_selectedColor = _colors[colorIndex];
					//trace("selectedColor: " + hexString(_selectedColor));
					drawSelection();
					
					dispatchEvent(new Event(Event.CHANGE, true, true));
				}
			}
		}
		
		// поиск активного объекта среди родителей заданного
		private function findActiveParent(object:DisplayObject):ICursorActive {
			var activeObject:ICursorActive;
			var currentParent:DisplayObject = object.parent;
			// Перебираем родителей
			while (currentParent != null && activeObject == null) {
				// Если активный
				if (currentParent is ICursorActive) {
					if (ICursorActive(currentParent).cursorActive) {
						activeObject = ICursorActive(currentParent);
					}
				}
				currentParent = currentParent.parent;
			}
			return activeObject;
		}
		
		private function drawSelection():void {
			var index:int = _colors.indexOf(_selectedColor);
			var colorImage:Image = Image(objects[index]);
			selection.x = colorImage.x;
			selection.y = colorImage.y;
		}
		
		// Преобразование цвета в 16-чную систему
		private function hexString(value:uint):String {
			var s:String = value.toString(16);
			while (s.length < 6) {
				s = "0" + s;
			}
			return s;
		}
		
		public function get selectedColor():uint {
			return _selectedColor;
		}

	}
}