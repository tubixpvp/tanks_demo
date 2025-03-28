package alternativa.iointerfaces.focus {
	import alternativa.init.IOInterfaces;
	import alternativa.iointerfaces.mouse.ICursorActive;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.FocusEvent;
	
	
	/**
	 * Менеджер фокусировки 
	 */
	public class FocusManager implements IFocusManager {
		
		/**
		 * Фокус меняется мышью
		 */		
		private var mouseFocusChanged:Boolean = true;
		/**
		 * Фокус меняется с клавиатуры
		 */		
		private var keyFocusChanged:Boolean = false;
		/**
		 * Подписчики на изменение фокуса
		 */		
		private var focusListeners:Array;
		/**
		 * Объект, на котором установлен фокус
		 */		
		private var _focused:IFocus;
		/**
		 * Иерархия фокусных обектов (<code>IFocus</code>), построенная от объекта в фокусе
		 */		
		private static var _focusTree:Array;
		/**
		 * Сцена 
		 */		
		private var stage:Stage;
		
		
		public function FocusManager() {
			_focusTree = new Array();
			focusListeners = new Array();
		}
		
		/**
		 * Инициализация 
		 * @param stage сцена
		 */		
		public function init(stage:Stage):void {
			this.stage = stage;
			stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onMouseFocusChange);
			stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange);
			stage.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			stage.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		}
		
		/**
		 * Добавить слушателя изменения фокуса
		 * @param listener слушатель
		 */	
		public function addFocusListener(listener:IFocusListener):void {
			focusListeners.push(listener);
		}
		/**
		 * Удалить слушателя изменения фокуса
		 * @param listener слушатель
		 */		
		public function removeFocusListener(listener:IFocusListener):void {
			focusListeners.splice(focusListeners.indexOf(listener), 1);
		}
		
		/**
		 * Фокус 
		 */
		public function set focus(target:DisplayObject):void {
			//trace("FocusManager set focus target: " + target);
			mouseFocusChanged = false;
			keyFocusChanged = false;
			
			var oldFocused:IFocus = focused;
			var newFocus:IFocus;
			
			if (target != null) {
				if (target is IFocus) {
					if (_focused != target) {
						if (_focused != null) {
							IFocus(_focused).focused = false;
						}
						if (IFocus(target).tabEnabled) {
							stage.focus =  InteractiveObject(target);
							_focused = IFocus(target);
							if (IFocus(_focused).focused == false) {
								IFocus(_focused).focused = true;
							}
						} else {
							newFocus = findFocusParent(target);
							if (newFocus != null && newFocus != _focused) {
								stage.focus =  InteractiveObject(newFocus);
								_focused = newFocus;
								IFocus(_focused).focused = true;
							}
						}
					} else {
						if (IFocus(target).tabEnabled && stage.focus != target) {
							stage.focus =  InteractiveObject(target);
						}
					}
				} else {
					newFocus = findFocusParent(target);
					if (newFocus != null && newFocus != _focused) {
						stage.focus = InteractiveObject(newFocus);
						_focused = newFocus;
						IFocus(_focused).focused = true;
					}
				}
			} else {
				if (_focused != null) {
					IFocus(_focused).focused = false;
					_focused = null;
				}
			}
			
			if (_focused != null) {
				arrangeNewTree(_focused);
			}
			
			// Рассылка события
			for (var i:int = 0; i < focusListeners.length; i++) {
				var listener:IFocusListener = IFocusListener(focusListeners[i]);
				listener.focusChanged(oldFocused, focused);
			}
		}		
		
		/**
		 * Событие получения фокуса 
		 * @param e событие
		 */		
		private function onFocusIn(e:FocusEvent):void {
			//trace("FocusManager onFocusIn target: " + e.target);
			if (mouseFocusChanged) {
				// Произошло переключение фокуса с помощью мыши
				if (e.target is InteractiveObject) {
					if (InteractiveObject(e.target).mouseEnabled && e.target is IFocus) {
						_focused = IFocus(e.target);
						IFocus(e.target).focused = true;
						arrangeNewTree(IFocus(e.target));
					} else {
						e.stopImmediatePropagation();
					}
				} else {
					e.stopImmediatePropagation();
				}
			} else if (keyFocusChanged) {
				// Произошло переключение фокуса с помощью клавиатуры
				if (IOInterfaces.keyboardAvailable) {
					if (_focused == e.target) {
						e.stopImmediatePropagation();
					} else {
						_focused = IFocus(e.target);
						IFocus(e.target).focused = true;
						arrangeNewTree(IFocus(e.target));
						//trace("FocusManager new focusTree: " + _focusTree);
					}
				} else {
					// Отмена "незаконной" табуляции
					e.stopImmediatePropagation();
					stage.focus = InteractiveObject(_focused);
				}
			} else {
				// Произошло переключение фокуса через set focus
				if (_focused == e.target) {
					//e.stopImmediatePropagation();
				} else {
					// ?????????
					//e.stopImmediatePropagation();
					
					//_focused = e.target;
					//arrangeNewTree(IFocus(e.target));
					//clearTree();
					//trace("FocusManager new focusTree: " + _focusTree);
				}
			}
		}
		
		/**
		 * Событие потери фокуса 
		 * @param e событие
		 */
		private function onFocusOut(e:FocusEvent):void {
			//trace("FocusManager onFocusOut target: " + e.target);
			if (mouseFocusChanged) {
				var overed:ICursorActive = IOInterfaces.mouseManager.overed;
				if (overed != null) {
					if (overed is IFocus) {
						if (IFocus(overed).tabEnabled && overed == _focused) {
							e.stopImmediatePropagation();
						} else {
							clearTree();
						}
					} else {
						var newFocus:ICursorActive = findActiveParent(DisplayObject(overed));
						if (newFocus != null && newFocus is IFocus) {
							if (newFocus == _focused) {
								e.stopImmediatePropagation();
							} else {
								clearTree();
							}					
						} else {
							clearTree();
						}
					}
				} else {
					clearTree();
				}
			} else if (keyFocusChanged) {
				if (IOInterfaces.keyboardAvailable) {
					clearTree();
				} else {
					e.stopImmediatePropagation();
					stage.focus = InteractiveObject(_focused);
				}
			} else {
				clearTree();
			}
		}
		
		/**
		 * Поиск активного объекта среди родителей заданного
		 * @param object заданный объект
		 * @return искомый активный объект
		 */		
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
		
		/**
		 * Поиск объекта для фокусировки среди родителей заданного
		 * @param object заданный объект
		 * @return искомый фокусный объект
		 */		
		private function findFocusParent(object:DisplayObject):IFocus {
			var focusObject:IFocus;
			var currentParent:DisplayObject = object.parent;
			// Перебираем родителей
			while (currentParent != null && focusObject == null) {
				// Если активный
				if (currentParent is IFocus) {
					if (IFocus(currentParent).tabEnabled) {
						focusObject = IFocus(currentParent);
					}
				}
				currentParent = currentParent.parent;
			}
			return focusObject;
		}
		
		/**
		 * Очистка иерархии фокусных объектов
		 */
		public function clearTree():void {
			if (_focused != null) {
				IFocus(_focused).focused = false;
				_focused = null;
			}
			for (var i:int = 1; i < _focusTree.length; i++) {
				IFocus(_focusTree[i]).childFocused = false;
			}
			_focusTree = new Array();
		}
		
		/**
		 * Составить иерархию фокусных объектов вверх от заданного 
		 * @param focusTarget заданный объект, находящийся в фокусе
		 * @return иерархия фокусных объектов
		 */	
		public function arrangeNewTree(focusTarget:IFocus):Array {
			var oldTree:Array = _focusTree;
			var newTree:Array = new Array(focusTarget);
			var currentParent:DisplayObject = DisplayObject(focusTarget).parent;
			
			// Перебираем родителей
			while (currentParent != null) {
				// Если есть поддержка фокуса
				if (currentParent is IFocus) {
					if (IFocus(currentParent).tabEnabled) {
						newTree.push(IFocus(currentParent));
						if (!IFocus(currentParent).childFocused) {
							IFocus(currentParent).childFocused = true;
						}
					}
				}
				currentParent = currentParent.parent;
			}
			// Сброс фокуса у тех, кто не вошёл в новое дерево
			if (oldTree.length > 0) {
				for (var i:int = 0; i < oldTree.length; i++) {
					if (newTree.indexOf(oldTree[i]) == -1) {
						IFocus(oldTree[i]).childFocused = false;
					}
				}
			}			
			// Сохранение нового дерева
			_focusTree = newTree;
			//trace("focusTree: " + _focusTree);
			return newTree;
		}
		
		/**
		 * Событие изменения фокуса с клавиатуры
		 * @param e событие
		 */		
		private function onKeyFocusChange(e:FocusEvent):void {
			keyFocusChanged = true;
		}
		/**
		 * Событие изменения фокуса мышью
		 * @param e событие
		 */	
		private function onMouseFocusChange(e:FocusEvent):void {
			mouseFocusChanged = true;
		}
		
		/**
		 * Объект, находящийся в фокусе
		 */
		public function get focused():IFocus {
			return _focused;
		}
		
		/**
		 * Иерархия фокусных объектов
		 */
		public function get focusTree():Array {
			return _focusTree;
		}

	}
}