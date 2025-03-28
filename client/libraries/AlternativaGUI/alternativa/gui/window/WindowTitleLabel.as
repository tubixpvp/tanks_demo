package alternativa.gui.window {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.skin.window.WindowTitleLabelSkin;
	import alternativa.gui.widget.Label;
	
	import flash.text.TextFormat;
	
	public class WindowTitleLabel extends Label {
		
		protected var _active:Boolean;
		
		private var skin:WindowTitleLabelSkin;
		
		public function WindowTitleLabel(text:String = "", align:uint = Align.LEFT) {
			super(text, align);
		}
		
		/**
		 * Обновить скин 
		 */
		override public function updateSkin():void {
			skin = WindowTitleLabelSkin(skinManager.getSkin(getSkinType()));
			super.updateSkin();
		}
		
		// Определение класса для скинования
		override protected function getSkinType():Class {
			return WindowTitleLabel;
		}
		
		override protected function switchState():void {
			//trace("WindowTitleLabel switchState");
			// Выбор формата
			var format:TextFormat;
			var filters:Array;
			if (!_locked) {
				if (_active) {
					if (_pressed) {
						format = skin.tfActivePress;
					} else if (_over) {
						format = skin.tfActiveOver;
					} else {
						format = skin.tfActiveNormal;
					}
				} else {
					if (_pressed) {
						format = skin.tfPress;
					} else if (_over) {
						format = skin.tfOver;
					} else {
						format = skin.tfNormal;
					}
				}
				filters = skin.filtersNormal;
			} else {
				format = skin.tfLocked;
				filters = skin.filtersLocked;
			}
			// Установка визуального состояния
			state(format, filters);
		}		
		
		override public function set over(value:Boolean):void {
			super.over = value;
			// Перерисовка
			if (isSkined) {
				switchState();
			}
		}
		
		override public function set pressed(value:Boolean):void {
			super.pressed = value;
			// Перерисовка
			if (isSkined) {
				switchState();
			}
		}
		
		public function set active(value:Boolean):void {
			_active = value;
			// Перерисовка
			if (isSkined) {
				switchState();
			}
		}
		
		public function get active():Boolean {
			return _active;
		}

	}
}