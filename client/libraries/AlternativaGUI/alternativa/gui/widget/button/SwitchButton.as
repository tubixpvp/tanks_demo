package alternativa.gui.widget.button {
	import alternativa.gui.init.GUI;
	import alternativa.utils.MouseUtils;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class SwitchButton extends Button {
		
		private var _parentSwitch:ButtonSwitch;
		
		private var _dragON:Boolean = false;
		
		// Точка хватания мышью
		private var _dragPoint:Point;
		
		
		public function SwitchButton(text:String = null, image:BitmapData = null, align:uint = 1) {
			super(text, image, align);
			
			// Инициализация фокуса
			tabEnabled = false;
		}
		
		/**
		 *  Установка флага наведенности
		 */
		override public function set over(value:Boolean):void {
			if (!_dragON) {
				super.over = value;
				switchState();			
				draw(currentSize);
			}	
		}
		
		/**
		 *  Установка флага нажатия
		 */
		override public function set pressed(value:Boolean):void {
			super.pressed = value;
			if (_pressed) {
				_dragON = true;
				// Сохранение точки захвата бегунка
				_dragPoint = MouseUtils.localCoords(this);
				
				GUI.mouseManager.addMouseCoordListener(_parentSwitch);
				
				// Генерация события
				_parentSwitch.dispatchEvent(new SwitchEvent(SwitchEvent.START_DRAG, this));
			} else {
				GUI.mouseManager.removeMouseCoordListener(_parentSwitch);
				
				_dragON = false;
				_dragPoint = null;
				
				// Генерация события
				_parentSwitch.dispatchEvent(new SwitchEvent(SwitchEvent.STOP_DRAG, this));
			}
		}
		
		/**
		 * Смена визуального представления состояния 
		 * 
		 */
		override protected function switchState():void {		
			if (locked) 
				state(skin.ll, skin.lc, skin.lr, 0, skin.tfLocked, skin.colorLocked);								
			else 
			if (pressed)
				state(skin.ol, skin.oc, skin.or, 0, skin.tfOver, skin.colorOver);	
			else 
			if (over) 
				state(skin.ol, skin.oc, skin.or, 0, skin.tfOver, skin.colorOver); 
			else
			if (_focused)
				state(skin.fl, skin.fc, skin.fr, 0, skin.tfNormal, skin.colorNormal);
			else 										
				state(skin.nl, skin.nc, skin.nr, 0, skin.tfNormal, skin.colorNormal);										
		}
		
		public function set parentSwitch(s:ButtonSwitch):void {
			_parentSwitch = s;
		}
		
		public function get dragPoint():Point {
			return _dragPoint;
		}
		
	}
}