package alternativa.gui.widget {
	import alternativa.gui.base.EventRepeater;
	import alternativa.gui.container.Container;
	import alternativa.gui.focus.IFocus;
	import alternativa.gui.keyboard.IKeyboardListener;
	import alternativa.gui.keyboard.KeyFiltersConfig;
	import alternativa.gui.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.gui.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.skin.widget.NumberInputSkin;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ImageButton;
	
	import flash.events.Event;
	
	/**
	 * Поле ввода чисел с кнопками декремента и инкремента
	 */	
	public class NumberInput extends Container implements IKeyboardListener, IFocus {
		
		/**
		 * Поле ввода
		 */		
		private var input:Input;
		/**
		 * Введенное значение
		 */		
		private var inputValue:Number;
		/**
		 * Контейнер кнопок "+" "-" 
		 */		
		private var buttonsContainer:Container;
		/**
		 * Кнопка инкремента
		 */		
		private var incButton:ImageButton;
		/**
		 * Кнопка декремента
		 */		
		private var decButton:ImageButton;
		/**
		 * Шаг изменения кнопками
		 */		
		private var step:Number;
		/**
		 * Минимальное значение
		 */		
		private var minValue:Number;
		/**
		 * Максимальное значение 
		 */		
		private var maxValue:Number;
		/**
		 * Скин 
		 */		
		private var skin:NumberInputSkin;
		/**
		 * Флаг блокировки
		 */		
		private var _locked:Boolean;
		/**
		 * Флаг фокусировки на объекте (устанавливается, если tabEnabled)
		 */		
		protected var _focused:Boolean;
		/**
		 * Флаг фокусировки на ком-то из детей
		 */	
		protected var _childFocused:Boolean;
		
		/**
		 * Конфигурация фильтров клавиатуры 
		 */		
		private var _keyFiltersConfig:KeyFiltersConfig;
		// Названия действий
		public static const KEY_ACTION_INC:String = "NumberInputInc";
		public static const KEY_ACTION_DEC:String = "NumberInputDec";
		public static const KEY_ACTION_ENTER:String = "NumberInputEnter";
		
		
		public function NumberInput(minValue:Number, maxValue:Number, step:Number) {
			super();
			// Инициализация фокуса
			tabEnabled = true;
			
			this.minValue = minValue;
			this.maxValue = maxValue;
			this.step = step;
			
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 0);
			
			// Добавление поля ввода
			input = new Input();
			addObject(input);
			input.text = String(minValue);
			inputValue = minValue;
			input.stretchableH = true;
			input.restrict("0123456789.");
			
			// Создание контейнера кнопок
			buttonsContainer = new Container();
			buttonsContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.MIDDLE, 0);
			addObject(buttonsContainer);
			
			// Добавление кнопок
			incButton = new ImageButton(0, 0);
			decButton = new ImageButton(0, 0);
			buttonsContainer.addObject(incButton);
			buttonsContainer.addObject(decButton);
			incButton.tabEnabled = false;
			decButton.tabEnabled = false;
				
			// Подписка обработчиков кнопок
			incButton.addEventListener(ButtonEvent.PRESS, onIncButtonPressed);
			decButton.addEventListener(ButtonEvent.PRESS, onDecButtonPressed);
			
			// Подключение повторителей
			var incButtonRepeater:EventRepeater = new EventRepeater(incButton, ButtonEvent.PRESS, ButtonEvent.EXPRESS, this, onIncButtonPressed);
			var decButtonRepeater:EventRepeater = new EventRepeater(decButton, ButtonEvent.PRESS, ButtonEvent.EXPRESS, this, onDecButtonPressed);
			
			// Инициализация событий клавиатуры 
			_keyFiltersConfig = new KeyFiltersConfig();
			
			// Фильтры горячих клавиш
			var enterFilter:FocusKeyFilter = new FocusKeyFilter(input.tf, new SimpleKeyFilter(new Array([13])));
			var incFilter:FocusKeyFilter = new FocusKeyFilter(input.tf, new SimpleKeyFilter(new Array(107, 187)));
			var decFilter:FocusKeyFilter = new FocusKeyFilter(input.tf, new SimpleKeyFilter(new Array(109, 189)));
			
			_keyFiltersConfig.addKeyDownFilter(enterFilter, KEY_ACTION_ENTER);
			_keyFiltersConfig.addKeyDownFilter(incFilter, KEY_ACTION_INC);
			_keyFiltersConfig.addKeyDownFilter(decFilter, KEY_ACTION_DEC);
			
			_keyFiltersConfig.bindKeyDownAction(KEY_ACTION_DEC, this, onDecButtonPressed);
			_keyFiltersConfig.bindKeyDownAction(KEY_ACTION_INC, this, onIncButtonPressed);
			_keyFiltersConfig.bindKeyDownAction(KEY_ACTION_ENTER, this, onEnter);
		}
		
		//----- IFocused
		/**
		 * Установка флага фокусировки
		 */	
		public function set focused(value:Boolean):void {
			if (_focused != value) {
				_focused = value;
				if (_focused) {
					focus();
				} else {
					unfocus();
				}
			}
		}
		/**
		 * Получить флаг фокусировки
		 * @return флаг фокусировки
		 * 
		 */		
		public function get focused():Boolean {
			return _focused;
		}
		/**
		 * Установка флага фокусировки (при фокусировке на ком-то из детей)
		 */	
		public function set childFocused(value:Boolean):void {
			if (_childFocused != value) {
				_childFocused = value;
			}
		}
		/**
		 * Получить флаг фокусировки (на ком-то из детей)
		 * @return флаг фокусировки
		 */		
		public function get childFocused():Boolean {
			return _childFocused;
		}
		/**
		 * Фокусировка
		 */		
		protected function focus():void {}
		/**
		 * Расфокусировка
		 */		
		protected function unfocus():void {}
		
		
		// Установка скина
		override public function updateSkin():void {
			skin = NumberInputSkin(skinManager.getSkin(NumberInput));
			super.updateSkin();
			
			incButton.normalBitmap = skin.incButtonNormal;
			incButton.overBitmap = skin.incButtonOver;
			incButton.pressBitmap = skin.incButtonPress;
			incButton.lockBitmap = skin.incButtonLock;
			
			decButton.normalBitmap = skin.decButtonNormal;
			decButton.overBitmap = skin.decButtonOver;
			decButton.pressBitmap = skin.decButtonPress;
			decButton.lockBitmap = skin.decButtonLock;
			
			if (inputValue == minValue)
				decButton.locked = true;
			if (inputValue == maxValue)
				incButton.locked = true;
		}
		
		// Обработчики кнопок
		private function onIncButtonPressed(e:ButtonEvent = null):void {
			value = Number(input.text) + step;
		}
		private function onDecButtonPressed(e:ButtonEvent = null):void {
			value = Number(input.text) - step;
		}
		
		/**
		 * Сохранение введенного значения
		 */
		private function onEnter():void {
			value = Number(input.text);
		}
		
		/**
		 * Передача индекса табуляции текстовому полю
		 * @param index индекс табуляции
		 */		
		override public function set tabIndex(index:int):void {
			input.tabIndex = index;
		}
		
		/**
		 * Ограничение на ввод символов
		 * @param simbols допустимые для ввода числа
		 */		
		public function restrict(simbols:String):void {
			input.tf.restrict = simbols;
		}
		
		/*protected function onFocusIn(e:FocusEvent):void {
			// если фокус на нас - то переадресуем его тексту
			if (e.target==this)
			if (stage!=null)			
				stage.focus = input;
				input.selectAll();
		}
		protected function onFocusOut(e:FocusEvent):void {
			value = Number(input.text);
		}*/
		
		/**
		 * Введенное значение
		 */		
		public function get value():Number {
			return inputValue;
		}		
		public function set value(value:Number):void {
			var n:Number = value;
			if (n < minValue)
				n = minValue;
			else if (n > maxValue)
				n = maxValue;
			// сохраняем новое значение
			input.text = String(n);
			inputValue = n;
			
			if (n != minValue) {
				if (decButton.locked)
					decButton.locked = false;
			} else {
				decButton.locked = true;
			} 				
			if (n != maxValue) {
				if (incButton.locked)
					incButton.locked = false;
			} else {
				incButton.locked = true;
			}
			// Генерируем событие
			dispatchEvent(new Event(Event.CHANGE, true, true));
		}
		
		/**
		 * Флаг блокировки
		 */		
		public function get locked():Boolean {
			return _locked;
		}		
		public function set locked(value:Boolean):void {
			_locked = value;
			input.locked = value;
			incButton.locked = value;
			decButton.locked = value;
		}
		
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