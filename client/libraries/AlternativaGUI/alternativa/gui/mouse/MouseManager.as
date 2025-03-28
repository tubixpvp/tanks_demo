package alternativa.gui.mouse {
	
	import alternativa.gui.skin.cursor.baseSkin.BaseCursorSkin;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	
	
	public class MouseManager implements IMouseManager {
		
		private var cursorTypesList:ICursorTypes;
		
		private var mouseConstList:IMouseConst; 
		
		
		public function MouseManager() {}
		
		public function init(stage:Stage, GUIcursorEnabled:Boolean = false, cursorContainer:DisplayObjectContainer = null):void {
			cursorTypesList = new DefaultCursorTypes();
			
			mouseConstList = new CursorDelay();
			
			Cursor.init(stage, GUIcursorEnabled, cursorContainer);
			if (GUIcursorEnabled) {
				Cursor.updateSkin(new BaseCursorSkin());
			}
		}
		
		/**
		 * Смена курсора
		 * @param cursorId - идентификатор курсора
		 */		
		public function changeCursor(cursorId:uint):void {
			Cursor.change(cursorId);
		}
		
		/**
		 * Добавить слушателя изменения координат мыши
		 * @param listener
		 */		
		public function addMouseCoordListener(listener:IMouseCoordListener):void {
			Cursor.addMouseCoordListener(listener);
		}
		/**
		 * Удалить слушателя изменения координат мыши
		 * @param listener
		 */		
		public function removeMouseCoordListener(listener:IMouseCoordListener):void {
			Cursor.removeMouseCoordListener(listener);
		}
		
		/**
		 * Добавить слушателя прокрутки колесика мыши
		 * @param listener
		 */		
		public function addMouseWheelListener(listener:IMouseWheelListener):void {
			Cursor.addMouseWheelListener(listener);
		}
		/**
		 * Удалить слушателя прокрутки колесика мыши
		 * @param listener
		 */		
		public function removeMouseWheelListener(listener:IMouseWheelListener):void {
			Cursor.removeMouseWheelListener(listener);
		}
		
		/**
		 * Перепроверить список объектов под курсором 
		 */		
		public function updateCursor():void {
			Cursor.update();
		}
		
		/**
		 * Получить список стандартных типов курсоров 
		 * @return список стандартных типов курсоров 
		 */		
		public function get cursorTypes():ICursorTypes {
			return cursorTypesList;
		}
		
		/**
		 * Получить константы мыши 
		 * @return константы мыши
		 */	
		public function get mouseConst():IMouseConst {
			return mouseConstList;
		}
		
		/**
		 * Объект, над которым находится курсор
		 */		
		public function get overed():ICursorActive {
			return Cursor.overed;
		}
		/**
		 * Иерархия объектов с overed = true
		 */		
		public function get overedTree():Array {
			return Cursor.overedTree;
		}
		
		/**
		 * Объекты под курсором
		 */		
		public function get objectsUnderCursor():Array {
			return Cursor.objectsUnderCursor;
		}		
		
		/**
		 * Нажатый объект 
		 * @return 
		 */		
		public function get pressed():ICursorActive {
			return Cursor.pressed;
		}
		
		

	}
}