package alternativa.gui.window {
	import alternativa.gui.container.Container;
	import alternativa.gui.container.WidgetContainer;
	import alternativa.gui.init.GUI;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.skin.window.WindowTitleSkin;
	import alternativa.gui.widget.button.ButtonEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class WindowTitleBase extends WidgetContainer {
		
		private var _parentWindow:WindowBase;
		
		private var _active:Boolean;
		private var _closable:Boolean;
		private var _minimizeable:Boolean;
		private var _maximizeable:Boolean;
		
		// Части графики
		private var left:Bitmap;
		private var center:Bitmap;
		private var right:Bitmap;
		private var close:Bitmap;
		
		private var titleNormalNormal:TextField;
		private var titleNormalOver:TextField;
		private var titleNormalPress:TextField;
		private var titleActiveNormal:TextField;
		private var titleActiveOver:TextField;
		private var titleActivePress:TextField;
		
		protected var gfx:Sprite;
		
		// Шкурка
		protected var skin:WindowTitleSkin;
		
		// Кнопка закрытия
		private var closeBtn:WindowTitleButton;
		
		// Кнопка разворачивания
		private var maximizeBtn:WindowTitleButton;
		
		// Кнопка сворачивания
		private var minimizeBtn:WindowTitleButton;

		// Текстовое поле заголовка
		private var tf:WindowTitleLabel;
		
		// Текст заголовка
		private var _title:String;
		
		// Выравнивание текста заголовка
		private var _titleAlign:uint;
		
		// Контейнер контента окна (вкладки)
		protected var tab:Container;
		
		// Контейнер кнопок управления окном
		protected var controlButtonContainer:Container;
		
		
		public function WindowTitleBase(tab:Container, title:String = null, closable:Boolean = false, minimizeable:Boolean = false, maximizeable:Boolean = false, active:Boolean = false, align:uint = Align.LEFT) {
			
			super();
			
			stretchableH = true;
			
			this.tab = tab;
			_title = (title != null) ? title : "";
			_closable = closable;
			_minimizeable = minimizeable;
			_maximizeable = maximizeable;
			_active = active;
			_titleAlign = align;
			
			// Создаем части графики
			left = new Bitmap();
			center = new Bitmap();
			right = new Bitmap();
			
			// Создаём контейнер графики заголовка
			gfx = new Sprite();
			gfx.mouseEnabled = false;
			gfx.tabEnabled = false;
			with (gfx) {
				addChild(left);
				addChild(center);
				addChild(right);
				cacheAsBitmap = true;
			}
			addChildAt(gfx, 0);
			
			// Создаём текстовое поле
			tf = new WindowTitleLabel(title);
			tf.stretchableH = true;
			addObject(tf);
			
			// Создаем контейнер для кнопок управления окном
			if (_minimizeable || _closable || _maximizeable) {
				controlButtonContainer = new Container();
				controlButtonContainer.stretchableV = true;
				addObject(controlButtonContainer);
				controlButtonContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 0);
			}
			// Создаём кнопку сворачивания
			if (_minimizeable) {
				minimizeBtn = new WindowTitleButton();
				controlButtonContainer.addObject(minimizeBtn);
				minimizeBtn.addEventListener(ButtonEvent.EXPRESS, onMinimize);
			}
			// Создаём кнопку разворачивания
			if (_maximizeable) {
				maximizeBtn = new WindowTitleButton();
				controlButtonContainer.addObject(maximizeBtn);
				maximizeBtn.addEventListener(ButtonEvent.EXPRESS, onMaximize);
			}
			// Создаём кнопку закрытия
			if (_closable) {
				closeBtn = new WindowTitleButton();
				controlButtonContainer.addObject(closeBtn);
				closeBtn.addEventListener(ButtonEvent.EXPRESS, onClose);
			}
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, align, Align.MIDDLE, 0);
		}
		
		override public function updateSkin():void {
			skin = WindowTitleSkin(skinManager.getSkin(getSkinType()));
			super.updateSkin();
			
			_marginLeft = skin.borderThickness + skin.marginLeft;
			_marginRight = skin.borderThickness + skin.marginRight;
			
			CompletelyFillLayoutManager(layoutManager).space = skin.space;
			if (_minimizeable || _closable) {
				CompletelyFillLayoutManager(controlButtonContainer.layoutManager).space = skin.controlButtonSpace;
			} 
			// обновить состояние
			switchState();
			
			// Установка размеров
			minSize.y = skin.activeNC.height;
			// считаем ширину
			calcMinWidth();
		}
		
		// Определение класса для скинования
		protected function getSkinType():Class {
			return WindowTitleBase;
		}
		
		/**
		 * Отрисовка 
		 * @param size
		 * 
		 */	
		override public function draw(size:Point):void {
			super.draw(size);
			// Расставляем края
			right.x = size.x - right.width;
			// Растягиваем фон
			center.x = left.width;
			center.width = size.x - left.width - right.width;
		}
		
		// Рассчет минимальной ширины
		private function calcMinWidth():void {
			minSize.x = skin.marginLeft + skin.marginRight;
			if (_title != null && _title != "")
				minSize.x = minSize.x + Math.round(tf.width - 3);
			if (_closable || _minimizeable) {
				minSize.x = minSize.x + skin.space;
				if (_closable)
					minSize.x = minSize.x + skin.closeNN.width;
				if (_minimizeable)
					minSize.x = minSize.x + skin.minimizeNN.width;
				if (_closable && _minimizeable)
					minSize.x = minSize.x + skin.controlButtonSpace;
			}
		}
		
		// Курсор
		override public function get cursorOverType():uint {
			var cursorType:uint;
			if (_parentWindow.maximized) {
				cursorType = GUI.mouseManager.cursorTypes.NORMAL;
			} else {
				if (_active) {
					cursorType = GUI.mouseManager.cursorTypes.MOVE;
				} else {
					cursorType = GUI.mouseManager.cursorTypes.ACTIVE;
				}
			}
			return cursorType;
		}
		override public function get cursorPressedType():uint {
			var cursorType:uint;
			if (_parentWindow.maximized) {
				cursorType = GUI.mouseManager.cursorTypes.NORMAL;
			} else {
				if (_active) {
					cursorType = GUI.mouseManager.cursorTypes.MOVE;
				} else {
					cursorType = GUI.mouseManager.cursorTypes.ACTIVE;
				}
			}
			return cursorType;
		}
		
		// Изменение флагов состояния
		public function set active(value:Boolean):void {
			_active = value;
			if (isSkined) {
				switchState();	
				draw(currentSize);
			}
		} 
		public function get active():Boolean {
			return _active;
		}
		
		override public function set over(value:Boolean):void {
			super.over = value;
			switchState();	
			draw(currentSize);
		}

		override public function set pressed(value:Boolean):void {
			super.pressed = value;	
			switchState();	
			draw(currentSize);
			if (_pressed) {
				dispatchEvent(new WindowTitleEvent(WindowTitleEvent.SELECT));
			}
		}
		
		override public function set locked(value:Boolean):void {
			super.locked = value;
			switchState();	
			draw(currentSize);
		}
		
		/**
		 * Смена визуального представления состояния 
		 * 
		 */
		protected function switchState():void {		
			if (_pressed) {
				tf.pressed = true;
				if (active) {
					state(skin.activePL, skin.activePC, skin.activePR, skin.closeAP, skin.minimizeAP, _parentWindow.maximized ? skin.restoreAP : skin.maximizeAP);
					tf.active = true;
				} else {
					state(skin.normalPL, skin.normalPC, skin.normalPR, skin.closeNP, skin.minimizeNP, _parentWindow.maximized ? skin.restoreNP : skin.maximizeNP);
					tf.active = false;
				}												
			} else if (_over) {
				tf.pressed = false;
				tf.over = true;
				if (active) {
					state(skin.activeOL, skin.activeOC, skin.activeOR, skin.closeAN, skin.minimizeAN, _parentWindow.maximized ? skin.restoreAN : skin.maximizeAN);
					tf.active = true;
				} else { 
					state(skin.normalOL, skin.normalOC, skin.normalOR, skin.closeNN, skin.minimizeNN, _parentWindow.maximized ? skin.restoreNN : skin.maximizeNN);
					tf.active = false;
				}
			} else {
				tf.pressed = false;
				tf.over = false;
				if (active) {
					state(skin.activeNL, skin.activeNC, skin.activeNR, skin.closeAN, skin.minimizeAN, _parentWindow.maximized ? skin.restoreAN : skin.maximizeAN);
					tf.active = true;
				} else { 
					state(skin.normalNL, skin.normalNC, skin.normalNR, skin.closeNN, skin.minimizeNN, _parentWindow.maximized ? skin.restoreNN : skin.maximizeNN);
					tf.active = false;
				}
			}									
		}
		
		/**
		 * Смена UI при смене состояния
		 */
		private function state(_left:BitmapData,_center:BitmapData,_right:BitmapData, _close:BitmapData, _minimize:BitmapData, _maximize:BitmapData):void {
			left.bitmapData = _left;
			center.bitmapData = _center;
			right.bitmapData = _right;
			if (_closable) {
				closeBtn.normalBitmap = _close;
				closeBtn.overBitmap = _close;
				closeBtn.pressBitmap = _close;
				closeBtn.lockBitmap = _close;
			}
			if (_minimizeable) {
				minimizeBtn.normalBitmap = _minimize;
				minimizeBtn.overBitmap = _minimize;
				minimizeBtn.pressBitmap = _minimize;
				minimizeBtn.lockBitmap = _minimize;
			}
			if (_maximizeable) {
				maximizeBtn.normalBitmap = _maximize;
				maximizeBtn.overBitmap = _maximize;
				maximizeBtn.pressBitmap = _maximize;
				maximizeBtn.lockBitmap = _maximize;
			}
		}
		
		// Обработчики кнопок
		private function onClose(e:ButtonEvent):void {
			dispatchEvent(new WindowTitleEvent(WindowTitleEvent.CLOSE));
		}
		
		private function onMinimize(e:ButtonEvent):void {
			dispatchEvent(new WindowTitleEvent(WindowTitleEvent.MINIMIZE));
		}

		private function onMaximize(e:ButtonEvent):void {
			if (parentWindow.maximized) {
				dispatchEvent(new WindowTitleEvent(WindowTitleEvent.RESTORE));
				
				maximizeBtn.normalBitmap = active ? skin.maximizeAN : skin.maximizeNN;
				maximizeBtn.overBitmap = active ? skin.maximizeAN : skin.maximizeNN;
				maximizeBtn.pressBitmap = active ? skin.maximizeAP : skin.maximizeNP;
				maximizeBtn.lockBitmap = active ? skin.maximizeAN : skin.maximizeNN;
			} else {
				dispatchEvent(new WindowTitleEvent(WindowTitleEvent.MAXIMIZE));
				
				maximizeBtn.normalBitmap = active ? skin.restoreAN : skin.restoreNN;
				maximizeBtn.overBitmap = active ? skin.restoreAN : skin.restoreNN;
				maximizeBtn.pressBitmap = active ? skin.restoreAP : skin.restoreNP;
				maximizeBtn.lockBitmap = active ? skin.restoreAN : skin.restoreNN;
			}
		}
		
		// Родительское окно
		public function set parentWindow(window:WindowBase):void {
			_parentWindow = window;
		}
		public function get parentWindow():WindowBase {
			return _parentWindow;
		}
		
		// Текст заголовка
		public function set title(value:String):void {
			_title = value;
			tf.text = _title;
			/*if (isSkined) {			
				calcMinWidth();
				repaintCurrentSize();
			}*/
		}

		public function get title():String {
			return _title;
		}
		// Выравнивание заголовка
		public function set titleAlign(value:uint):void {
			_titleAlign = value;
			//if (isSkined)
				//drawTitleText();
		}

		public function get titleAlign():uint {
			return _titleAlign;
		}
		
	}
}