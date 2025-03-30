package alternativa.gui.widget.button {
	import alternativa.iointerfaces.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.iointerfaces.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.gui.widget.Widget;

	/**
	 * Базовая кнопка 
	 */
	public class BaseButton extends Widget implements IButton {
		
		/**
		 * Группа (логическая группа, управляющая несколькими кнопками возможно разных типов)
		 */		
		protected var _group:ButtonGroup;
		
		/**
		 * @private
		 * Действие "НАЖАТИЕ"
		 */
		private const KEY_ACTION_PRESS:String = "BaseButtonPress";
		/**
		 * @private
		 * Действие "ОТЖАТИЕ"
		 */
		private const KEY_ACTION_UNPRESS:String = "BaseButtonUnpress";
		
		
		public function BaseButton() {
			super();
			// Фильтры горячих клавиш
			var pressFilter:FocusKeyFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array(13, 32)));
			keyFiltersConfig.addKeyDownFilter(pressFilter, KEY_ACTION_PRESS);
			keyFiltersConfig.addKeyUpFilter(pressFilter, KEY_ACTION_UNPRESS);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_PRESS, this, keyDown);
			keyFiltersConfig.bindKeyUpAction(KEY_ACTION_UNPRESS, this, keyUp);
		}
		
		/**
		 * Обновление скина 
		 */
		override public function updateSkin():void {
			super.updateSkin();
			// Обновить состояние
			switchState();
		}		
		
		/**
		 * Смена визуального представления состояния 
		 */
		protected function switchState():void {}
		
		/**
		 * Рассылка одинарного щелчка
		 */		
		override public function click():void {
			// Генерация события
			dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, this));
		}
		
		/**
		 * Обработка нажатия кнопки с клавиатуры
		 */	
		public function keyDown():void {
			pressed = true;
		}
		/**
		 * Обработка отжатия кнопки с клавиатуры
		 */
		public function keyUp():void {
			pressed = false;
			// Генерация события
			dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, this));
		}
		
		/**
		 * Флаг наведения
		 */
		override public function set over(value:Boolean):void {
			super.over = value;
			//trace("BaseButton over: " + _over);
			if (isSkined) {
				switchState();			
				draw(currentSize);
			}	
		}
		/**
		 * Флаг нажатия
		 */	
		override public function set pressed(value:Boolean):void {
			super.pressed = value;
			if (isSkined) {
				switchState();			
				draw(currentSize);
			}
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
		 * Флаг блокировки
		 */		
		override public function set locked(value:Boolean):void {
			super.locked = value;
			cursorActive = !value;
			tabEnabled = !value;
						
			// Если залочиваем
			if (value) {
				// Если объект фокусирован, снять с него фокус
				if (stage != null && stage.focus == this) {
					stage.focus = null;
				}
			}
			if (isSkined) {
				switchState();			
				draw(currentSize);
			}		
		}
		
		/**
		 * Логическая группа, к которой принадлежит кнопка 
		 */		
		public function get group():ButtonGroup {
			return _group;
		}
		public function set group(value:ButtonGroup):void {
			_group = value;
		}
		
	}
}