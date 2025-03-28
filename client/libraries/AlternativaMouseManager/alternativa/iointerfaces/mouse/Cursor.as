package alternativa.iointerfaces.mouse {
	import alternativa.init.IOInterfaces;
	import alternativa.iointerfaces.keyboard.IKeyboardListener;
	import alternativa.iointerfaces.keyboard.KeyFiltersConfig;
	import alternativa.iointerfaces.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.iointerfaces.mouse.dnd.DragEvent;
	import alternativa.iointerfaces.mouse.dnd.IDrag;
	import alternativa.iointerfaces.mouse.dnd.IDragObject;
	import alternativa.iointerfaces.mouse.dnd.IDrop;
	import alternativa.skin.cursor.CursorSkin;
	import alternativa.utils.MouseUtils;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Mouse;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	
	public class Cursor extends Sprite implements IKeyboardListener {
		
		// Виды курсоров
		public static const NONE:uint = 0;
		public static const NORMAL:uint = 1;
		public static const ACTIVE:uint = 2;
		public static const HAND:uint = 3;
		public static const GRAB:uint = 4;
		public static const DRAG:uint = 5;
		public static const DROP:uint = 6;
		public static const MOVE:uint = 7;
		public static const RESIZE_HORIZONTAL:uint = 8;
		public static const RESIZE_VERTICAL:uint = 9;
		public static const RESIZE_DIAGONAL_UP:uint = 10;
		public static const RESIZE_DIAGONAL_DOWN:uint = 11;
		public static const IMPOSIBLE:uint = 12;
		public static const EDIT_TEXT:uint = 13;
		
		public static const defaultCursorsLastIndex:uint = 13;
		
		// Единственный экземпляр курсора
		private static var instance:Cursor;
		
		// Изображение курсора
		private var gfx:Bitmap;
		
		// Набор курсоров
		private var skin:CursorSkin;
		
		// Идентификатор текущего состояния
		private var currentStateId:uint;
		
		// Флаг, блокирующий изменение курсора
		private var locked:Boolean = false;
		
		private var mouseMoved:Boolean = true;
		
		private var _objectsUnderCursor:Array;
		
		// Хинт
		private var hint:TextField;
		private var hintTimer:uint;
		
		// Объект, над которым находится курсор
		internal static var overed:ICursorActive;
		
		// Иерархия объектов с установленным флагом over
		internal static var overedTree:Array;
		
		// Нажатый объект
		internal static var pressed:ICursorActive;
		
		// Объект, на котором щёлкнули (устанавливается с задержкой после pressed)
		private var clicked:ICursorActive;
		
		// Подписчики на изменение координат мыши
		private var mouseCoordListeners:Array;
		
		// Подписчики на прокрутку колёсика
		private var mouseWheelListeners:Array;
		
		// Интервал для ожидания 2-го щелчка
		private var doubleClickInt:int = -1;
		
		// Расстояние от места клика, после которого включается перетаскивание
		private static const dragEnableDistance:Number = 2;
		
		// DnD
		private var dragged:IDrag;
		private var dropped:IDrop;
		
		private var dragOffset:Point;
		private var dragObject:IDragObject;
		
		/**
		 * Конфигурация фильтров клавиатуры 
		 */		
		private var _keyFiltersConfig:KeyFiltersConfig;
		
		protected var escFilter:SimpleKeyFilter;
		protected const KEY_ACTION_CANCEL_DRAG:String = "CursorCancelDrag";
		
		
		public function Cursor(parent:DisplayObjectContainer) {
			super();
			
			visible = false;
			currentStateId = NORMAL;
			
			// Создаём хинт			
			hint = new TextField();
			addChild(hint);
			
			// Графика курсора
			gfx = new Bitmap();
			addChild(gfx);
			
			parent.mouseEnabled = false;
			parent.mouseChildren = false;
			parent.addChild(this);
			
			mouseCoordListeners = new Array();
			mouseWheelListeners = new Array();
			overedTree = new Array();
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			// Инициализация событий клавиатуры 
			_keyFiltersConfig = new KeyFiltersConfig();
			escFilter = new SimpleKeyFilter(new Array(27, null));
			_keyFiltersConfig.bindKeyUpAction(KEY_ACTION_CANCEL_DRAG, this, cancelDrag);
		}
		
		// Инициализация курсора
		public static function init(parent:DisplayObjectContainer):void {
			if (instance == null) {
				// Создаём экземпляр курсора
				instance = new Cursor(parent);
			}
			// Установить координаты курсора
			var mx:int = instance.stage.mouseX;
			var my:int = instance.stage.mouseY;
			var coord:Point = instance.globalToLocal(new Point(mx, my));
			instance.x += coord.x;
			instance.y += coord.y;
			
			if (mx > 0 && mx < instance.stage.stageWidth && my > 0 && my < instance.stage.stageHeight) {
				Mouse.hide();
				instance.visible = true;
				instance.mouseMoved = true;
			}			
		}

		// Сменить курсор
		public static function change(id:uint):void {
			if (!instance.locked) {
				instance.currentStateId = id;
				instance.draw(id);
			}
		}
		
		/**
		 * Перепроверить список объектов под курсором 
		 */
		public static function update():void {
			instance.mouseMoved = true;
			instance.onEnterFrame();
		}
		
		/**
		 * Установка скина
		 * @param skin скин
		 */		
		public static function updateSkin(skin:CursorSkin):void {
			instance.skin = skin;
			// Установка состояния
			change(instance.currentStateId);
			// Параметры хинта
			with (instance.hint) {
				defaultTextFormat = instance.skin.hintTextFormat;
				autoSize = TextFieldAutoSize.LEFT;
				antiAliasType = AntiAliasType.ADVANCED;
				sharpness = instance.skin.hintTextSharpness;
				thickness = instance.skin.hintTextThickness;
				embedFonts = true;
				selectable = false;
				if (instance.skin.hintBorderEnabled) {
					border = true;
					borderColor = instance.skin.hintBorderColor;
				} 
				background = true;
				backgroundColor = instance.skin.hintBgColor;
				visible = false;
			}
		}
		
		// Отрисовать курсор
		private function draw(id:uint):void {
			if (id != NONE) {
				gfx.visible = true;
				if (skin != null) {
					var state:CursorState = skin.state[id];
					gfx.bitmapData = state.bitmap;
					gfx.x = -state.xOffset;
					gfx.y = -state.yOffset;
				}
			} else {
				gfx.visible = false;
			}
		}
		
		// Заблокировать курсор
		public static function lock():void {
			instance.locked = true;
		}

		// Разблокировать курсор
		public static function unlock():void {
			instance.locked = false;
			instance.draw(instance.currentStateId);
		}
		
		// Показать хинт
		private function showHint(text:String):void {
			hint.htmlText = text;
			hint.width = Math.ceil(hint.width);
			hint.visible = true;
			clearTimeout(hintTimer);
			hintTimer = setTimeout(hideHint, CursorDelay.HINT_TIMEOUT);
			posHint();
		}

		// Скрыть хинт
		private function hideHint():void {
			hint.htmlText = "";
			hint.visible = false;
			clearTimeout(hintTimer);
		}

		// Позиционирование хинта		
		private function posHint():void {
			var hintSize:Point = localToGlobal(new Point(hint.width, hint.height));
			if (hintSize.x + skin.hintOffsetRight > stage.stageWidth) {
				hint.x = -skin.hintOffsetLeft - hint.width
			} else {
				hint.x = skin.hintOffsetRight;
			}
			if (hintSize.y + skin.hintOffsetBottom > stage.stageHeight) {
				hint.y = -skin.hintOffsetTop - hint.height;
			} else {
				hint.y = skin.hintOffsetBottom;
			}
		}
		
		// Запуск хинта объекта
		private function startHint(object:ICursorActive):void {
			if (object.hint != null && object.hint != "") {
				hintTimer = setTimeout(showHint, CursorDelay.HINT_DELAY, object.hint);
			} else {
				if (hint.visible) {
					hideHint();
				}
			}
		}
		
		/**
		 * Добавить слушателя изменения координат мыши
		 * @param listener
		 */		
		public static function addMouseCoordListener(listener:IMouseCoordListener):void {
			if (instance.mouseCoordListeners.indexOf(listener) == -1) {
				instance.mouseCoordListeners.push(listener);
			}
		}
		/**
		 * Удалить слушателя изменения координат мыши
		 * @param listener
		 */		
		public static function removeMouseCoordListener(listener:IMouseCoordListener):void {
			var index:int = instance.mouseCoordListeners.indexOf(listener);
			if (index != -1) {
				instance.mouseCoordListeners.splice(index, 1);
			}
		}
		
		/**
		 * Добавить слушателя прокрутки колесика мыши
		 * @param listener
		 */		
		public static function addMouseWheelListener(listener:IMouseWheelListener):void {
			if (instance.mouseWheelListeners.indexOf(listener) == -1) {
				instance.mouseWheelListeners.push(listener);
			}
		}
		/**
		 * Удалить слушателя прокрутки колесика мыши
		 * @param listener
		 */		
		public static function removeMouseWheelListener(listener:IMouseWheelListener):void {
			var index:int = instance.mouseWheelListeners.indexOf(listener);
			if (index != -1) {
				instance.mouseWheelListeners.splice(index, 1);
			}
		}
		
		private function onMouseMove(e:MouseEvent):void {
			mouseMoved = true;
		}
		
		// При перемещении
		private function onEnterFrame(e:Event = null):void {
			if (mouseMoved) {
				mouseMoved = false;
				
				// Установить координаты курсора
				var coord:Point = globalToLocal(new Point(stage.mouseX, stage.mouseY));
				x += coord.x;
				y += coord.y;
				
				// Если курсор ещё скрыт, показать
				if (!visible) {
					Mouse.hide();
					visible = true;
				}
				// Изменяем координаты хинта
				if (hint.visible) {
					posHint();
				}
				
				//if (pressed == null) {
				if (true) {
					// Сбор объектов под курсором
					var objectsUnderPoint:Array = stage.getObjectsUnderPoint(new Point(x, y));
					//trace("objectsUnderPoint: " + objectsUnderPoint);
					// Удаление из списка графики курсора и хинта
					var index:int = objectsUnderPoint.indexOf(gfx);
					if (index != -1) objectsUnderPoint.splice(index, 1);
					index = objectsUnderPoint.indexOf(hint);
					if (index != -1) objectsUnderPoint.splice(index, 1);
					//trace("objectsUnderPoint: " + objectsUnderPoint);
					
					_objectsUnderCursor = objectsUnderPoint;
					
					var newTree:Array;
					var diffTree:Array;
					// Анализ объектов под курсором
					if (objectsUnderPoint.length > 0) {
						index = objectsUnderPoint.length-1;
						var activeObject:ICursorActive;
						while (activeObject == null && index >= 0) {
							if (objectsUnderPoint[index] is ICursorActive) {
								if (ICursorActive(objectsUnderPoint[index]).cursorActive) {
									// активный объект найден
									activeObject = ICursorActive(objectsUnderPoint[index]);
								} else {
									// поиск активного объекта среди родителей текущего
									activeObject = findActiveParent(DisplayObject(objectsUnderPoint[index]));
								}
							} else {
								// поиск активного объекта среди родителей текущего
								activeObject = findActiveParent(DisplayObject(objectsUnderPoint[index]));
							}
							index--;
						}
						if (activeObject != null) {
							if (overed == null) {
								// over
								newTree = arrangeOveredTree(activeObject);
								diffTree = getDifferenceTree(newTree, overedTree);
								over(diffTree, activeObject);
								overedTree = newTree;
							} else {
								if (overed != activeObject) {
									// out-over
									newTree = arrangeOveredTree(activeObject);
									diffTree = getDifferenceTree(overedTree, newTree);
									out(diffTree, activeObject);
									diffTree = getDifferenceTree(newTree, overedTree);
									over(diffTree, activeObject);
									overedTree = newTree;
								}
							}
						} else {
							if (overed != null) {
								// out
								diffTree = getDifferenceTree(overedTree, new Array());
								out(diffTree);
								overedTree = new Array();
								// Смена курсора
								if (dragged == null) change(NORMAL);
								// Скрываем хинт
								hideHint();
							}
						}
					} else {
						if (overed != null) {
							// out
							diffTree = getDifferenceTree(overedTree, new Array());
							out(diffTree);
							overedTree = new Array();
							// Смена курсора
							if (dragged == null) change(NORMAL);
							// Скрываем хинт
							hideHint();
						}
					}
				}
				// Рассылка изменения координат мыши
				for (var i:int = 0; i < mouseCoordListeners.length; i++) {
					var mouseCoordListener:IMouseCoordListener = IMouseCoordListener(mouseCoordListeners[i]);
					mouseCoordListener.mouseMove(new Point(stage.mouseX, stage.mouseY));
				}
			}
		}
		
		/**
		 * Составить иерархию объектов от объекта получившего наведение 
		 * @param overObject объект под курсором
		 * @return иерархия объектов (ICursorActive)
		 */		
		private function arrangeOveredTree(overObject:ICursorActive):Array {
			var tree:Array = new Array(overObject);
			var currentParent:DisplayObject = DisplayObject(overObject).parent;
			// Перебираем родителей
			while (currentParent != null) {
				// Если активный
				if (currentParent is ICursorActive) {
					if (ICursorActive(currentParent).cursorActive) {
						tree.push(ICursorActive(currentParent));
					}
				}
				currentParent = currentParent.parent;
			}
			//trace("overedTree: " + tree);
			return tree;
		}
		
		/**
		 * Составить дерево объектов из tree1, которых нет в tree2
		 * @param tree1 дерево объектов 1
		 * @param tree2 дерево объектов 2
		 * @return дерево разницы между tree1 и tree2
		 */		
		private function getDifferenceTree(tree1:Array, tree2:Array):Array {
			var tree:Array = new Array();
			var i:int = 0;
			var stop:Boolean = false;
			while(i < tree1.length && !stop) {
				if (tree2.indexOf(tree1[i]) == -1) {
					tree.push(tree1[i]);
				} else {
					stop = true;
				}			
				i++
			}
			return tree;
		}
		
		private function over(diffTree:Array, overObject:ICursorActive):void {
			//trace("Cursor over: " + overObject);
			//trace("Cursor over diffTree: " + diffTree);
			// Сохранение наведения
			overed = overObject;
			
			if (dragged != null) {
				// Ищем и устанавливаем дроп-объект вверх от наведённого
				var newDropped:IDrop = getDropObject(overed);
				
				// Если найден новый
				if (newDropped != dropped) {
					// Сохраняем новый дроп
					dropped = newDropped;
					// Устанавливаем дроп курсор
					change(DROP);
					// Отсылаем событие о затаскивании
					var local:Point = MouseUtils.localCoords(DisplayObject(dropped));
					EventDispatcher(dropped).dispatchEvent(new DragEvent(DragEvent.OVER, dragObject, local.x, local.y));
				}
			} else {
				// Смена курсора
				change(overed.cursorOverType);
			}
			
			// Запускаем хинт объекта, если есть
			if (!hint.visible) {
				startHint(ICursorActive(overed));
			} else {
				var h:String = ICursorActive(overed).hint;
				if (h != null && h != "") {
					showHint(h);
				} else {
					hideHint();
				}
			}
			
			// Рассылка события
			for (var t:int = 0; t < diffTree.length; t++) {
				var listeners:Array = ICursorActive(diffTree[t]).cursorListeners;
				for (var i:int = 0; i < listeners.length; i++) {
					var listener:ICursorActiveListener = ICursorActiveListener(listeners[i]);
					if (listener.over != true) {
						listener.over = true;
					}
				}
			}
		}
		
		private function out(diffTree:Array, overObject:ICursorActive = null):void {
			//trace("Cursor out: " + overed);
			//trace("Cursor out diffTree: " + diffTree);
			// Отмена запуска хинта 
			clearTimeout(hintTimer);
			// Рассылка события
			for (var t:int = 0; t < diffTree.length; t++) {
				var listeners:Array = ICursorActive(diffTree[t]).cursorListeners;
				for (var i:int = 0; i < listeners.length; i++) {
					var listener:ICursorActiveListener = ICursorActiveListener(listeners[i]);
					if (listener.over != false) {
						listener.over = false;
					}
				}
			}
			overed = null;
			
			// Если есть дроп
			if (dropped != null) {
				// Ищем дроп над объектом куда сводимся
				var newDropped:IDrop = getDropObject(overObject);
				
				// Если дроп сменился или его вообще нет
				if (newDropped != dropped) {
					// Восстанавливаем курсор драга
					change(DRAG);
					
					// Отсылаем событие о стаскивании
					var local:Point = MouseUtils.localCoords(DisplayObject(dropped));
					EventDispatcher(dropped).dispatchEvent(new DragEvent(DragEvent.OUT, dragObject, local.x, local.y));
					
					// Очищаем дроп
					dropped = null;
				}
			}
		}
		
		// Установить всем активным родителям объекта наведённое состояние
		/*private function setActiveParentsOver(object:DisplayObject):void {
			var currentParent:DisplayObject = object.parent;
			// Перебираем родителей
			while (currentParent != null) {
				// Если активный
				if (currentParent is ICursorActive) {
					// Рассылка события
					var listeners:Array = ICursorActive(currentParent).cursorListeners;
					for (var i:int = 0; i < listeners.length; i++) {
						var listener:ICursorActiveListener = ICursorActiveListener(listeners[i]);
						if (listener.over != true) {
							listener.over = true;
							//overedTree.push(listener);
						}
					}
				}
				currentParent = currentParent.parent;
			}
		}
		// Установить всем активным родителям объекта нормальное состояние
		private function setActiveParentsNormal(object:DisplayObject):void {
			var currentParent:DisplayObject = object.parent;
			// Перебираем родителей
			while (currentParent != null) {
				// Если активный
				if (currentParent is ICursorActive) {
					// Рассылка события
					var listeners:Array = ICursorActive(currentParent).cursorListeners;
					for (var i:int = 0; i < listeners.length; i++) {
						var listener:ICursorActiveListener = ICursorActiveListener(listeners[i]);
						if (listener.over != false) {
							listener.over = false;
						}
					}
				}
				currentParent = currentParent.parent;
			}
		}*/
		
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
		
		
		private function notDoubleClick():void {
			clearInterval(doubleClickInt);
			doubleClickInt = -1;
			
			if (clicked != null && pressed == null) {
				onClick();
			}
		}
		// Двойной щелчок (по 2-му нажатию)
		private function onDoubleClick():void {
			// Рассылка события
			var listeners:Array = clicked.cursorListeners;
			for (var i:int = 0; i < listeners.length; i++) {
				var listener:ICursorActiveListener = ICursorActiveListener(listeners[i]);
				listener.doubleClick();
			}
			clicked = null;
		}
		// Рассылка клика
		private function onClick():void {
			if (clicked != null) {
				// Рассылка события
				var listeners:Array = clicked.cursorListeners;
				for (var i:int = 0; i < listeners.length; i++) {
					var listener:ICursorActiveListener = ICursorActiveListener(listeners[i]);
					listener.click();
				}
				clicked = null;
			}
		}
		
		// При нажатии
		private function onMouseDown(e:MouseEvent):void {
			// Сохраняем нажатый объект
			pressed = overed;
			
			// Если есть активный объект
			if (pressed != null) {
				// Смена фокуса
				IOInterfaces.focusManager.focus = DisplayObject(pressed);
				
				// Смена курсора
				change(ICursorActive(pressed).cursorPressedType);
				// Блокировка текущего курсора
				lock();
				
				// Рассылка нажатия
				var listeners:Array = ICursorActive(pressed).cursorListeners;
				for (var i:int = 0; i < listeners.length; i++) {
					var listener:ICursorActiveListener = ICursorActiveListener(listeners[i]);
					listener.pressed = true;
				}
				// 1-й щелчок
				if (doubleClickInt == -1) {
					clicked = pressed;
					// Установка ожидания 2-го щелчка
					clearInterval(doubleClickInt);
					doubleClickInt = -1;
					doubleClickInt = setInterval(notDoubleClick, CursorDelay.DOUBLE_CLICK_DELAY);
				} else {
				// 2-й щелчок
					clearInterval(doubleClickInt);
					doubleClickInt = -1;
					// Рассылка двойного щелчка
					onDoubleClick();
				}
				
				// Если объект таскаемый, сохраняем точку привязки
				if (pressed is IDrag) {
					if (IDrag(pressed).isDragable()) {
						dragOffset = MouseUtils.localCoords(DisplayObject(pressed));
						// Переподписывание обработчиков
						stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
						stage.addEventListener(MouseEvent.MOUSE_MOVE, onStartDrag);
					}
				}
				
				// Подписываемся на отжатие
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			} else {
				IOInterfaces.focusManager.focus = null;
			}
			// Скрываем хинт
			hideHint();
		}
		
		// При отпускании
		private function onMouseUp(e:MouseEvent):void {
			// Отписываемся от события мыши
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			// Если было включено перетаскивание
			if (dragOffset != null) {
				// Сбрасываем точку привязки
				dragOffset = null;
				// Переподписывание обработчиков
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStartDrag);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			
			// Проверка на клик
			if (overed == pressed && clicked != null) {
				if (doubleClickInt == -1) {
					onClick();
				}
			} else {
				clicked = null;
			}
			
			// Рассылка события
			if (pressed != null) {
				var listeners:Array = ICursorActive(pressed).cursorListeners;
				for (var i:int = 0; i < listeners.length; i++) {
					var listener:ICursorActiveListener = ICursorActiveListener(listeners[i]);
					listener.pressed = false;
				}
				// Удаляем информацию о нажатом объекте
				pressed = null;
			}
			
			// Разблокируем курсор
			unlock();
			
			// Смена курсора
			if (overed != null) {
				change(ICursorActive(overed).cursorOverType);
			} else {
				change(NORMAL);
			}
		}
		
		// Начать перетаскивание
		private function onStartDrag(e:MouseEvent):void {
			onMouseMove(e);
			
			// Ищем расстояние от точки привязки
			var dist:Number = Point.distance(dragOffset, MouseUtils.localCoords(DisplayObject(pressed)));
			// Если расстояние больше указанного, включаем перетаскивание
			if (dist > dragEnableDistance) {
				//trace("startDrag");
				// Переподписываем движение мыши
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStartDrag);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
				
				// Сохраняем перетаскиваемый объект 
				dragged = IDrag(pressed);
				
				// Разблокируем курсор
				unlock();
				// Включаем курсор перетаскивания
				change(DRAG);
				
				// Сбрасываем флаг нажатия для объекта
				var listeners:Array = pressed.cursorListeners;
				for (var i:int = 0; i < listeners.length; i++) {
					var listener:ICursorActiveListener = ICursorActiveListener(listeners[i]);
					if (listener.pressed != false) {
						listener.pressed = false;
					}
				}
				
				// Сохраняем драг-объект
				dragObject = dragged.getDragObject();
				
				// Добавляем вид перетаскиваемого объекта
				addChildAt(dragObject.dragGraphics, 0);
				
				// Смещаем графику
				dragObject.dragGraphics.x -= dragOffset.x;
				dragObject.dragGraphics.y -= dragOffset.y;
				
				// Сообщаем о начале перетаскивания
				EventDispatcher(dragged).dispatchEvent(new DragEvent(DragEvent.START, dragObject, dragOffset.x, dragOffset.y));
				
				// Подписываемся на отмену драга по Esc
				if (IOInterfaces.keyboardAvailable) {
					_keyFiltersConfig.addKeyUpFilter(escFilter, KEY_ACTION_CANCEL_DRAG);
					IOInterfaces.keyboardManager.addKeyboardListener(this);
				}
			
				// Сбрасываем нажатый объект
				pressed = null;
				// Сбрасываем точку привязки
				dragOffset = null;
			}
		}
		
		// Тащим объект
		private function onDrag(e:MouseEvent):void {
			onMouseMove(e);
		}
		// Бросаем перетаскиваемый объект
		private function onDrop(e:MouseEvent = null):void {
			//trace("onDrop");
			// Если есть дроп-объект
			if (dropped != null) {
				// Рассылаем от таскаемого объекта, что его утащили
				EventDispatcher(dragged).dispatchEvent(new DragEvent(DragEvent.STOP, dragObject));
				// Рассылаем от дропа о приёмке объекта 
				var local:Point = MouseUtils.localCoords(DisplayObject(dropped));
				EventDispatcher(dropped).dispatchEvent(new DragEvent(DragEvent.DROP, dragObject, local.x, local.y));
				// Скрываем хинт
				hideHint();
				// Удаляем информацию о дроп-объекте
				dropped = null;
			} else {
				// Рассылаем отмену драга
				EventDispatcher(dragged).dispatchEvent(new DragEvent(DragEvent.CANCEL, dragObject));
			}
			
			// Удаляем графику таскаемого объекта
			if (dragObject.dragGraphics != null) {
				if (contains(dragObject.dragGraphics)) {
					removeChild(dragObject.dragGraphics);
				}
				// Удаляем драг-объект
				dragObject = null;
			}
			
			// Удаляем информацию о таскаемом объекте
			dragged = null;
			
			// Разблокируем курсор
			unlock();
			
			// Меняем курсор на наведенный
			if (overed != null && overed is ICursorActive) {
				change(ICursorActive(overed).cursorOverType);
			} else {
				change(Cursor.NORMAL);
			}
			
			// Переподписываем движение мыши
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			// Отписываемся от отмены драга по Esc
			if (IOInterfaces.keyboardAvailable) {
				IOInterfaces.keyboardManager.removeKeyboardListener(this);
				_keyFiltersConfig.removeKeyUpFilter(escFilter);
			}
		}
		
		private function cancelDrag():void {
			dropped = null;
			onDrop();
		}
		
		// Наведение при перетаскивании
		/*private function onDragOver(e:MouseEvent):void {
			// Сохраняем наведённый объект
			overed = DisplayObject(e.target);
			
			// Если объект активный
			if (overed is ICursorActive) {
				// Меняем состояние объекта на наведённое
				ICursorActive(overed).over = true;
				// Запускаем хинт объекта, если есть
				startHint(ICursorActive(overed));
			}
			// Меняем у активных родителей состояние на наведённое
			setActiveParentsOver(overed);
			
			// Ищем и устанавливаем дроп-объект вверх от наведённого
			var newDropped:IDrop = getDropObject(overed);
			
			// Если найден новый
			if (newDropped != dropped) {
				// Сохраняем новый дроп
				dropped = newDropped;
				// Устанавливаем дроп курсор
				change(DROP);
				// Отсылаем событие о затаскивании
				var local:Point = MouseUtils.localCoords(DisplayObject(dropped));
				EventDispatcher(dropped).dispatchEvent(new DragEvent(DragEvent.OVER, dragObject, local.x, local.y));
			}
		}
		// Снятие наведения при перетаскивании
		private function onDragOut(e:MouseEvent):void {
			if (overed != null) {
				// Меняем у активных родителей состояние на нормальное
				setActiveParentsNormal(overed);
				
				// Если объект overed - активный
				if (overed is ICursorActive) {
					// Меняем состояние у объекта на нормальное
					ICursorActive(overed).over = false;
					// Удаляем информацию о наведённом объекте
					overed = null;
				}
			}
			
			// Если есть дроп
			if (dropped != null) {
				// Ищем дроп над объектом куда сводимся
				var newDropped:IDrop = getDropObject(e.relatedObject);
				
				// Если дроп сменился или его вообще нет
				if (newDropped != dropped) {
					// Восстанавливаем курсор драга
					change(DRAG);
					
					// Отсылаем событие о стаскивании
					var local:Point = MouseUtils.localCoords(DisplayObject(dropped));
					EventDispatcher(dropped).dispatchEvent(new DragEvent(DragEvent.OUT, dragObject, local.x, local.y));
					
					// Очищаем дроп
					dropped = null;
				}
			}
		}*/
		
		// Нахождение дроп-объекта выше начиная с текущего
		// null, если не найден 
		private function getDropObject(object:ICursorActive):IDrop {
			var drop:IDrop = null;
			if (object != null) {
				// Проверяем с текущего вверх на функционал дропа
				var current:DisplayObject = DisplayObject(object);
				while (current != null) {
					// Если объект может принимать объекты и объект не тащим сам на себя
					if (current is IDrop && current != dragged) {
						// Проверяем возможность приёма
						if (IDrop(current).canDrop(dragObject)) {
							// Нашли
							drop = IDrop(current);
							break;
						}
					}
					current = current.parent;
				}
			}
			return drop;
		}
		
		// При наведении
		/*private function onMouseOver(e:MouseEvent):void {
			// Сохраняем наведённый объект
			overed = DisplayObject(e.target);
			//trace("Cursor over " + overed);
			
			// Если объект активный
			if (overed is ICursorActive) {
				// Меняем состояние объекта на наведённое
				ICursorActive(overed).over = true;
				if (ICursorActive(overed).pressed) {
					change(ICursorActive(overed).cursorPressed);
				} else {
					change(ICursorActive(overed).cursorOver);
				}
				// Запускаем хинт объекта, если есть
				startHint(ICursorActive(overed));
			}
			// Меняем у активных родителей состояние на наведённое
			setActiveParentsOver(overed);
		}
		
		// При отведении
		private function onMouseOut(e:MouseEvent):void {
			if (overed != null) {
				// Меняем у активных родителей состояние на нормальное
				setActiveParentsNormal(overed);
				
				// Если объект overed - активный
				if (overed is ICursorActive) {
					// Меняем состояние у объекта на нормальное
					ICursorActive(overed).over = false;
					
					// Скрываем хинт
					hideHint();
					
					// Обычный курсор
					change(NORMAL);
	
					// Удаляем информацию о наведённом объекте
					overed = null;
				}
			}
		}*/
		
		// При снятии фокуса
		/*private function onFocusOut(e:FocusEvent):void {
			if (focused != null) {
				if (mouseFocusChanged) {
					// Если фокус был на активном объекте
					if (focused is ICursorActive) {
						ICursorActive(focused).focused = false;
					}
					// Меняем у активных родителей состояние на нормальное
					//setActiveParentsNormal(focused);
					// Удаляем информацию о фокусированном объекте
					focused = null;
				} else if (keyFocusChanged) {
					// Удаляем информацию о фокусированном объекте
					focused = null;
				} else {
					// Фокус потерян не при переключении на другой объект (а например окно флэш-плейера стало неактивным)
					keyFocusChanged = false;
					mouseFocusChanged = false;
				}
			}
		}
		
		// При получении фокуса
		private function onFocusIn(e:FocusEvent):void {
			// Сохраняем фокусированный объект
			focused = DisplayObject(e.target);
			
			if (mouseFocusChanged) {
				// Если фокус на активном объекте
				if (focused is ICursorActive) {
					if (ICursorActive(focused).focused != true)	ICursorActive(focused).focused = true;
				}
				// Меняем у активных родителей состояние на наведённое
				//setActiveParentsOver(focused);
				
				mouseFocusChanged = false;
			} else if (keyFocusChanged) {
				keyFocusChanged = false;			
			} else {
				keyFocusChanged = false;
				mouseFocusChanged = false;
				
				// Если фокус на активном объекте
				if (focused is ICursorActive) {
					if (ICursorActive(focused).focused != true)	ICursorActive(focused).focused = true;
				}
			}
		}*/
		
		// Прокрутка колёсика
		private function onMouseWheel(e:MouseEvent):void {
			// Рассылка слушателям
			for (var i:int = 0; i < mouseWheelListeners.length; i++) {
				var mouseWheelListener:IMouseWheelListener = IMouseWheelListener(mouseWheelListeners[i]);
				mouseWheelListener.mouseWheel(e.delta);
			}
		}
		
		// При уходе мыши со сцены
		private function onMouseLeave(e:Event):void {
			Mouse.show();
			visible = false;
		}
		
		/**
		 * Объекты под курсором 
		 */		
		public static function get objectsUnderCursor():Array {
			return instance._objectsUnderCursor;
		}
		
		//----- IKeyboardListener
		/**
		 * Получить данныe о конфигурации фильтров и функций,
		 * вызываемых по нажатию и отжатию клавиш клавиатуры 
		 * @return данныe о конфигурации фильтров и функций
		 */		
		public function get keyFiltersConfig():KeyFiltersConfig {
			return _keyFiltersConfig;
		}
		
	}
}