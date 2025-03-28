package alternativa.gui.widget.slider {
	import alternativa.gui.container.Container;
	import alternativa.gui.container.group.PanelGroup;
	import alternativa.gui.focus.IFocus;
	import alternativa.gui.keyboard.IKeyboardListener;
	import alternativa.gui.keyboard.KeyFiltersConfig;
	import alternativa.gui.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.gui.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.skin.widget.slider.SliderInputSkin;
	import alternativa.gui.widget.Input;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.window.WindowBase;
	
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	
	/**
	 * Поле ввода чисел со слайдером 
	 */	
	public class SliderInput extends Container implements IKeyboardListener, IFocus {
		
		/**
		 * Минимальное значение 
		 */		
		private var minValue:Number;
		/**
		 * Максимальное значение 
		 */		
		private var maxValue:Number;
		/**
		 * Шаг изменения
		 */		
		private var step:Number;
		/**
		 * Поле ввода
		 */		
		private var input:Input;
		/**
		 * Слайдер
		 */		
		private var slider:Slider;
		/**
		 * Контейнер слайдера (подложка)
		 */		
		private var sliderContainer:PanelGroup;
		/**
		 * Введенное значение 
		 */		
		private var inputValue:Number;
		/**
		 * Кнопка вызова слайдера 
		 */		
		private var sliderButton:ImageButton;
		/**
		 * Скин
		 */		
		private var skin:SliderInputSkin;
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
		/**
		 * Действие "УСТАНОВИТЬ СЛЕДУЩУЮ ПОЗИЦИЮ" 
		 */		
		public static const KEY_ACTION_INC:String = "SliderInputInc";
		/**
		 * Действие "УСТАНОВИТЬ ПРЕДЫДУЩУЮ ПОЗИЦИЮ"
		 */		
		public static const KEY_ACTION_DEC:String = "SliderInputDec";
		/**
		 * Действие "СОХРАНЕНИЕ ЗНАЧЕНИЯ" 
		 */		
		public static const KEY_ACTION_ENTER:String = "SliderInputEnter";
		
		
		/**
		 * @param minValue минимальное значение
		 * @param maxValue максимальное значение
		 * @param step шаг для слайдера
		 */		
		public function SliderInput(minValue:Number, maxValue:Number, step:Number) {
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
			var d:Number = step - Math.floor(step);
			if (d > 0) {
				input.text = minValue.toFixed(String(d).length - 2);
			} else {
				input.text = String(minValue);
			}
			inputValue = minValue;
			input.stretchableH = true;
			input.tf.restrict = "0123456789.";
			
			// Добавление кнопок
			sliderButton = new ImageButton(0, 0);
			addObject(sliderButton);
			sliderButton.tabEnabled = false;
			
			// Подложка под слайдер
			sliderContainer = new PanelGroup(4, 6, 4, 6);
			sliderContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL);
			
			// Тень
			sliderContainer.filters = new Array(new DropShadowFilter(4, 70, 0, 1, 4, 4, 0.3, BitmapFilterQuality.MEDIUM));
			
			// Создание слайдера
			slider = new Slider(Direction.VERTICAL, Math.round((maxValue - minValue)/step)+1, 1, 3, false);
			sliderContainer.addObject(slider);
			
			// Подписка обработчиков
			sliderButton.addEventListener(ButtonEvent.PRESS, onSliderButtonMouseDown);
			sliderButton.addEventListener(ButtonEvent.EXPRESS, onSliderButtonMouseUp);
			slider.addEventListener(SliderEvent.CHANGE_POS, onSliderChangePos);
			
			// Инициализация событий клавиатуры 
			_keyFiltersConfig = new KeyFiltersConfig();
			
			// Фильтры горячих клавиш
			var enterFilter:FocusKeyFilter = new FocusKeyFilter(input.tf, new SimpleKeyFilter(new Array([13])));
			var incFilter:FocusKeyFilter = new FocusKeyFilter(input.tf, new SimpleKeyFilter(new Array(107, 187)));
			var decFilter:FocusKeyFilter = new FocusKeyFilter(input.tf, new SimpleKeyFilter(new Array(109, 189)));
			keyFiltersConfig.addKeyDownFilter(enterFilter, KEY_ACTION_ENTER);
			keyFiltersConfig.addKeyDownFilter(incFilter, KEY_ACTION_INC);
			keyFiltersConfig.addKeyDownFilter(decFilter, KEY_ACTION_DEC);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_ENTER, this, onKeyEnter);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_INC, this, onKeyInc);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_DEC, this, onKeyDec);
		}
		
		/**
		 * Обновить скин 
		 */
		override public function updateSkin():void {
			skin = SliderInputSkin(skinManager.getSkin(SliderInput));
			super.updateSkin();
			
			sliderButton.normalBitmap = skin.sliderButtonNormal;
			sliderButton.overBitmap = skin.sliderButtonOver;
			sliderButton.pressBitmap = skin.sliderButtonPress;
			sliderButton.lockBitmap = skin.sliderButtonLock;
		}
		
		/**
		 * Обработка изменения позиции бегунка слайдера
		 * @param e событие слайдера
		 */		
		private function onSliderChangePos(e:SliderEvent):void {
			value = minValue + (e.pos-1)*step;
		}
		
		/**
		 * Обработка нажатия кнопки вызова слайдера
		 * @param e событие кнопки
		 */		
		private function onSliderButtonMouseDown(e:ButtonEvent):void {
			// Установка слайдера
			var pos:Number = (inputValue - minValue)/step + 1;
			if (slider.currentPos != pos) {
				slider.currentPos = pos;
			}
			// Добавление слайдера
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.addObject(sliderContainer);
			sliderContainer.repaint(new Point());
			
			var localMouseCoord:Point = new Point(mouseX, mouseY);
			var globalMouseCoord:Point = localToGlobal(localMouseCoord);
			var inTopContainerLocalMouseCoord:Point = topContainer.globalToLocal(globalMouseCoord);
			
			sliderContainer.x = inTopContainerLocalMouseCoord.x - (sliderContainer.marginLeft + slider.runnerButton.x + Math.round(slider.runnerButton.width/2));
			sliderContainer.y = inTopContainerLocalMouseCoord.y - (sliderContainer.marginTop + slider.runnerButton.y + Math.round(slider.runnerButton.height/2));
			slider.runnerButton.pressed = true;
		}
		private function onSliderButtonMouseUp(e:ButtonEvent):void {
			slider.runnerButton.pressed = false;
			
			// Удаление слайдера из контейнера окна
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.removeObject(sliderContainer);
		}
		
		/**
		 * Сохранение введенного значения
		 */
		private function onKeyEnter():void {
			value = Number(input.text);
		}
		/**
		 * Декремент по нажатию клавиш
		 */		
		private function onKeyDec():void {
			value = Number(input.text) - step;
		}
		/**
		 * Инкремент по нажатию клавиш
		 */
		private function onKeyInc():void {
			value = Number(input.text) + step;
		}
		
		//----- IFocused
		/**
		 * Фокусировка
		 */		
		protected function focus():void {}
		/**
		 * Расфокусировка
		 */		
		protected function unfocus():void {}
		
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
		 * Установка индекса для табуляции 
		 * @param index индекса для табуляции
		 */		
		override public function set tabIndex(index:int):void {
			input.tf.tabIndex = index;
		}
		
		/**
		 * Значение поля ввода
		 */		
		public function get value():Number {
			return inputValue;
		}
		public function set value(value:Number):void {
			var n:Number = value;
			if (n < minValue) {
				n = minValue;
			} else if (n > maxValue) {
				n = maxValue;
			}
			// Сохранение нового значения
			var d:Number = step - Math.floor(step);
			if (d > 0) {
				input.text = n.toFixed(String(d).length - 2);
			} else {
				input.text = n.toString();
			}
			inputValue = n;
			// Генерация события
			dispatchEvent(new Event(Event.CHANGE, true, true));
		}
		
		/**
		 * Флаг блокировки
		 */		
		public function set locked(value:Boolean):void {
			_locked = value;
			input.locked = value;
			sliderButton.locked = value;
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