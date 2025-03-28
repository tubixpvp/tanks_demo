package alternativa.utils {
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	
	/**
	 * Утилиты для работы с мышью. Перед началом использования методов данного класса необходимо вызвать метод
	 * <code>MouseUtils.init()</code>.
	 * 
	 * @see #init()
	 */	
	public class MouseUtils {
		
		private static var _stage:Stage = null;
		
		/**
		 * Инициализация класса. Необходимо вызвать данный метод перед началом использования методов класса.
		 *  
		 * @param stage сцена
		 */		
		public static function init(stage:Stage):void {
			_stage = stage;
		}
		
		/**
		 * Получение локальных координат мыши на указанном объекте.
		 * 
		 * @param object объект, на котором определяются координаты
		 * 
		 * @return локальные координаты мыши на указанном объекте
		 */
		public static function localCoords(object:DisplayObject):Point {
			return object.globalToLocal(globalCoords());
		}

		/**
		 * Получение глобальных координат мыши.
		 * 
		 * @param stageLimit ограничивать ли координаты размерами сцены
		 * 
		 * @return глобальные координаты мыши
		 * 
		 * @throws Error в случае, если не был пердварительно вызван метод <code>MouseUtility.init()</code>
		 */		
		public static function globalCoords(stageLimit:Boolean = true):Point {
			var res:Point = null;
			if (_stage != null) {
				var mx:int = _stage.mouseX;
				var my:int = _stage.mouseY;
				if (stageLimit) {
					mx = (mx < 0) ? 0 : ((mx > _stage.stageWidth) ? _stage.stageWidth : mx);
					my = (my < 0) ? 0 : ((my > _stage.stageHeight) ? _stage.stageHeight : my);
				}
				res = new Point(mx, my);
			} else {
				throw new Error("MouseUtility don't have link to stage. Use MouseUtility.init(stage) before.");				
			}
			return res;
		} 

	}
}
