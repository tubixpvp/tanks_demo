package alternativa.gui.widget {
	import alternativa.gui.init.GUI;
	import alternativa.iointerfaces.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.iointerfaces.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.skin.widget.EditableLabelSkin;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.utils.clearInterval;
	
	
	public class EditableLabel extends Label {
		
		private var _editEnabled:Boolean;
		
		private var editable:Boolean = false;
		
		private var selected:Boolean = false;
		
		private var selection:Shape;
		
		private var skin:EditableLabelSkin;
		
		private var showSelection:Boolean;
		
		// Интервал до включения редактируемости
		private var editableInt:int = -1;
		private var editableDelay:int = 500;
		
		// Интервал для ожидания 2-го щелчка
		private var doubleClickInt:int = -1;
		
		// Названия действий
		protected static const KEY_ACTION_EDIT:String = "EditableLabelEdit";
		
		
		public function EditableLabel(text:String = null, align:uint = 0, maxChars:uint = 255, showSelection:Boolean = true, color:int = -1) {
			super(text, align, color);
			
			_editEnabled = true;
			
			// Автовыравнивание при редактировании
			switch (align) {
				case Align.LEFT:
					tf.autoSize = TextFieldAutoSize.LEFT;
					break;
				case Align.CENTER:
					tf.autoSize = TextFieldAutoSize.CENTER;
					break;
				case Align.RIGHT:
					tf.autoSize = TextFieldAutoSize.RIGHT;
					break;
			}
			
			this.showSelection = showSelection;
			
			// Инициализация фокуса и мыши
			cursorActive = true;
			tabEnabled = true;
			
			tf.tabEnabled = false;
			tf.mouseEnabled= false;
			
			// Установки параметров
			tf.maxChars = maxChars;
			
			// Создание области выделения
			selection = new Shape();
			addChildAt(selection, 0);
			selection.visible = false;
			
			//addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			// Настройка ретрансляции
			tf.addEventListener(Event.CHANGE, onChange);
			//tf.addEventListener(MouseEvent.MOUSE_OVER, onTfMouse);
			//tf.addEventListener(MouseEvent.MOUSE_OUT, onTfMouse);
			
			// Фильтры горячих клавиш
			var editFilter:FocusKeyFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array(13, null)));
			//addKeyDownAction(editFilter, KEY_ACTION_EDIT);
		}
		
		/*private function onTfMouse(e:MouseEvent):void {
			dispatchEvent(new MouseEvent(e.type));
			e.stopPropagation();
		}*/
		private function onChange(e:Event):void {
			_text = tf.text;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		
		// Установка шкурки
		override public function updateSkin():void {
			skin = EditableLabelSkin(skinManager.getSkin(EditableLabel));
			super.updateSkin();
		}
		
		/**
		 * Отрисовка в заданном размере
		 * @param size
		 */	
		override public function draw(size:Point):void {
			super.draw(size);
			repaintSelection();
		}
		
		// Перерисовка выделения
		private function repaintSelection():void {
			with (selection.graphics) {
				clear();
				beginFill(skin.selectionColor, skin.selectionAlpha);
				if (skin.selectionBorder) {
					selection.graphics.lineStyle(1, skin.selectionBorderColor);
				}
				drawRect(-skin.selectionMargin, -skin.selectionMargin, _textWidth + 2*skin.selectionMargin, _currentSize.y + 2*skin.selectionMargin);
			}
			// Вынужденное шаманство из-за разницы в 3px с настоящей шириной текстового поля
			selection.x = tf.x + 2;
		}
		
		/**
		 * Рассылка одинарного щелчка
		 * (через некоторое время после mouseDown)
		 */		
		override public function click():void {
			if (!selected) {
				selected = true;
			} else {
				if (_editEnabled) {
					startEdit();
				}
			}
		}
		/**
		 * Рассылка двойного щелчка
		 * (по второму подряд mouseDown)
		 */		
		override public function doubleClick():void {
			if (!selected) {
				selected = true;
			}
		}
		
		// начать редактирование
		public function startEdit():void {
			tf.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			tf.addEventListener(FocusEvent.FOCUS_OUT, onTfFocusOut);
			stage.focus = tf;
			selection.visible = false;
			tf.type = TextFieldType.INPUT;
			tf.border = skin.tfSelectionBorder;
			tf.borderColor = skin.tfSelectionBorderColor;
			tf.setSelection(0, tf.text.length);
			tf.selectable = true;
			tf.mouseEnabled = true;
			GUI.mouseManager.changeCursor(GUI.mouseManager.cursorTypes.NONE);
			
			clearInterval(editableInt);
			editableInt = -1;
			editable = false;
		}
		
		private function saveText():void {
			tf.setSelection(0, 0);
			tf.type = TextFieldType.DYNAMIC;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.border = false;
			
			// переброс фокуса
			stage.focus = this;
			
			// Пересчет размеров
			if (tf.text == "") {
				tf.text = _text;
			} else {
				_text = tf.text;
			}
			tf.text = _text;// после переключение в редактируемое текстовое поле расширяется вправо - нужно пересчитать
			
			// пересчет ширины
			var oldTextWidth:int = _textWidth;				
			calcTextWidth();
			var d:int = _textWidth - oldTextWidth;
			// перерисовка
			repaint(new Point(_currentSize.x + d, _minSize.y));
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onTfFocusOut(e:FocusEvent):void {
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			tf.removeEventListener(FocusEvent.FOCUS_OUT, onTfFocusOut);
			saveText();
			selection.visible = false;
			selected = false;
		}
		
		// Обработчик фокуса
		override protected function focus():void {
			trace("EditableLabel focus");
			if (showSelection) {
				selection.visible = true;
			}
		}
		
		override protected function unfocus():void {
			trace("EditableLabel unfocus");
			selection.visible = false;
			selected = false;
		}
		
		/*override public function keyDown(code:uint, filter:IKeyFilter):void {
			var action:String = keyDownActions[filter];
			switch (action) {
				case KEY_ACTION_EDIT:
					// начало редактирования
					startEdit();
					break;
			}
		}*/
		//override public function keyUp(code:uint, filter:IKeyFilter):void {}
		
		// сохранение
		private function onKeyDown(e:KeyboardEvent):void {
			e.stopPropagation();
			if (e.keyCode == 13) {
				removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				tf.removeEventListener(FocusEvent.FOCUS_OUT, onTfFocusOut);
				saveText();
				if (showSelection) {
					selection.visible = true;
				}
			}
		}
		
		// Блокировка
		override public function set locked(value:Boolean):void {
			super.locked = value;
			tabEnabled = !value && _editEnabled;
			mouseEnabled = !value && _editEnabled;
		}
		
		public function set editEnabled(value:Boolean):void {
			_editEnabled = value;
			tabEnabled = value;
			//mouseEnabled = value;
			tf.mouseEnabled = value;
			tf.tabEnabled = value;
		}
		public function get editEnabled():Boolean {
			return _editEnabled;
		}
		
		/**
		 * Тип курсора 
		 */	
		/*override public function get cursorOverType():uint {
			var cursorType:uint = IOInterfaces.mouseManager.cursorTypes.ACTIVE;
			return cursorType;
			//var cursor:uint = (stage.focus == tf) ? Cursor.NONE :  Cursor.ACTIVE;
			//return cursor;
		}
		override public function get cursorPressedType():uint {
			var cursorType:uint = IOInterfaces.mouseManager.cursorTypes.ACTIVE;
			return cursorType;
		}*/
		
	}
}