package alternativa.gui.widget.button {
	import alternativa.gui.base.ActiveShapeObject;
	
	public class ShapeButton extends ActiveShapeObject implements IButton {
		
		/**
		 * Группа (логическая группа, управляющая несколькими кнопками возможно разных типов)
		 */		
		protected var _group:ButtonGroup;
		
		
		public function ShapeButton() {
			super();
		}
		
		/**
		 * Управление нажатием
		 */	
		override public function set pressed(value:Boolean):void {
			super.pressed = value;
			
			// Генерация события
			if (_pressed) {
				dispatchEvent(new ButtonEvent(ButtonEvent.PRESS, this));
			} else {
				dispatchEvent(new ButtonEvent(ButtonEvent.EXPRESS, this));
			}
			// Рассылка для группы
			if (group != null) {
				if (_pressed) {
					group.buttonPressed(this);
				} else {
					group.buttonExpressed(this);
				}
			}
		}
		
		/**
		 * Рассылка одинарного щелчка
		 */		
		override public function click():void {
			// Генерация события
			dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, this));
		}
		
		/**
		* Установка логической группы
		 * @param value - группа кнопок
		 */
		public function set group(value:ButtonGroup):void {
			_group = value;
		}
		/**
		 * Получить логическую группу, к которой принадлежит кнопка 
		 * @return логическая группа
		 */		
		public function get group():ButtonGroup {
			return _group;
		}
	}
}
