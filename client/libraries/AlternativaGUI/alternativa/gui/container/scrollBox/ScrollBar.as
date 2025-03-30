package alternativa.gui.container.scrollBox {
	import alternativa.gui.base.EventRepeater;
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.iointerfaces.mouse.IMouseCoordListener;
	import alternativa.iointerfaces.mouse.IMouseWheelListener;
	import alternativa.gui.skin.container.scrollBox.ScrollBarSkin;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.widget.button.ShapeButton;
	import alternativa.utils.MouseUtils;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	
	/**
	 * Полоса прокрутки скроллируемого контейнера 
	 */	
	public class ScrollBar extends Container implements IMouseCoordListener, IMouseWheelListener {
		
		/**
		 * Скин 
		 */		
		private var skin:ScrollBarSkin;
		/**
		 * Начало полосы (ближе к кнопке "назад") 
		 */		
		private var back:Bitmap;
		/**
		 * Середина полосы 
		 */		
		private var bg:Bitmap;
		/**
		 * Конец полосы (ближе к кнопке "вперед") 
		 */		
		private var front:Bitmap;
		
		/**
		 * Кнопка "назад" 
		 */		
		private var backButton:ImageButton;
		/**
		 * Кнопка "вперед" 
		 */
		private var forwardButton:ImageButton;
		/**
		 * Кнопка "страница назад" 
		 */
		private var pageBackButton:ShapeButton;
		/**
		 * Кнопка "страница вперед" 
		 */
		private var pageForwardButton:ShapeButton;
		/**
		 * Длина кнопки "назад" 
		 */		
		private var backLength:int;
		/**
		 * Длина кнопки "вперед" 
		 */		
		private var forwardLength:int;
		
		/**
		 * Ползунок 
		 */		
		public var scroller:Scroller;
		/**
		 * Экстранавигация 
		 */		
		private var extraNavigation:Sprite;
		
		/**
		 * Минимальная длина скроллбара
		 */		
		private var _minLength:int;
		
		/**
		 * Текущая длина скроллбара
		 */		
		private var currentLength:int;
		/**
		 * Длина ползунка
		 */		
		private var currentScrollLength:int = 0;
		/**
		 * Длина скроллируемой области 
		 */		
		private var currentArea:int = 0;
		/**
		 * Длина видимой части прокручиваемой области 
		 */		
		private var currentView:int = 0;
		/**
		 * Позиция видимой части от начала прокручиваемой области
		 */		
		private var currentPosition:int = 0;
		/**
		 * Шаг скроллирования 
		 */		
		private var _step:int;
		
		/**
		 * Направление 
		 */		
		private var direction:Boolean;
		/**
		 * Координата, соответствующая направлению 
		 */		
		private var coord:String;
		/**
		 * Размер, соответствующий направлению 
		 */		
		private var size:String;
		
		
		/**
		 * @param direction направление
		 * @param step шаг прокрутки
		 */		
		public function ScrollBar(direction:Boolean, step:int = 10) {
			super();
			
			// Создаём части полосы
			back = new Bitmap();
			bg = new Bitmap();
			front = new Bitmap();
			
			// Создаём кнопки и скроллер
			backButton = new ImageButton(0, 0);
			forwardButton = new ImageButton(0, 0);
			scroller = new Scroller(4, direction);
			scroller.scrollBar = this;
			
			// Сохраняем настройки
			this.direction = direction;
			coord = direction ? "y" : "x";
			size = direction ? "height" : "width";
			_step = step;
			
			// Создаём кнопки постраничной перемотки
			pageBackButton = new ShapeButton();
			pageForwardButton = new ShapeButton();
			pageBackButton.alpha = 0;
			pageForwardButton.alpha = 0;
			
			// Создаём экстра-навигацию
			extraNavigation = new Sprite();
			extraNavigation.mouseEnabled = false;
			extraNavigation.tabEnabled = false;
			extraNavigation.mouseChildren = false;
			extraNavigation.tabChildren = false;

			// Добавляем элементы
			addChildAt(back, 0);
			addChildAt(bg, 1);
			addChildAt(front, 2);
			addChildAt(extraNavigation, 3);
			
			addObject(scroller);
			addObject(pageBackButton);
			addObject(pageForwardButton);
			addObject(backButton);
			addObject(forwardButton);
			
			// Подписываем на события
			backButton.addEventListener(ButtonEvent.PRESS, onBackButtonPress);
			forwardButton.addEventListener(ButtonEvent.PRESS, onForwardButtonPress);
			pageBackButton.addEventListener(ButtonEvent.PRESS, onPageBackButtonPress);
			pageBackButton.addEventListener(ButtonEvent.EXPRESS, onPageBackButtonExpress);
			pageForwardButton.addEventListener(ButtonEvent.PRESS, onPageForwardButtonPress);
			pageForwardButton.addEventListener(ButtonEvent.EXPRESS, onPageForwardButtonExpress);
			
			// Подключаем повторители
			var backRepeater:EventRepeater = new EventRepeater(backButton, ButtonEvent.PRESS, ButtonEvent.EXPRESS, this, onBackButtonPress);
			var forwardRepeater:EventRepeater = new EventRepeater(forwardButton, ButtonEvent.PRESS, ButtonEvent.EXPRESS, this, onForwardButtonPress);
			var pageBackRepeater:EventRepeater = new EventRepeater(pageBackButton, ButtonEvent.PRESS, ButtonEvent.EXPRESS, this, onPageBackButtonPress);
			var pageForwardRepeater:EventRepeater = new EventRepeater(pageForwardButton, ButtonEvent.PRESS, ButtonEvent.EXPRESS, this, onPageForwardButtonPress);
			
			currentPosition = 0;
		}
		
		/**
		 * Обновление скина 
		 */
		override public function updateSkin():void {
			skin = ScrollBarSkin(skinManager.getSkin(ScrollBar));
			
			// Фон
			back.bitmapData = (direction) ? skin.bmpT : skin.bmpL;
			bg.bitmapData = (direction) ? skin.bmpM : skin.bmpC;
			front.bitmapData = (direction) ? skin.bmpB : skin.bmpR;
			
			// Графика кнопок
			backButton.normalBitmap = (direction) ? skin.bmpUN : skin.bmpLN;
			backButton.overBitmap = (direction) ? skin.bmpUO : skin.bmpLO;
			backButton.pressBitmap = (direction) ? skin.bmpUP : skin.bmpLP;
			backButton.lockBitmap = (direction) ? skin.bmpUL : skin.bmpLL;
			
			forwardButton.normalBitmap = (direction) ? skin.bmpDN : skin.bmpRN; 
			forwardButton.overBitmap = (direction) ? skin.bmpDO : skin.bmpRO;
			forwardButton.pressBitmap = (direction) ? skin.bmpDP : skin.bmpRP;
			forwardButton.lockBitmap = (direction) ? skin.bmpDL : skin.bmpRL;
			
			pageBackButton.graphics.beginFill(skin.pageButtonFillColor, skin.pageButtonFillAlpha);
			pageBackButton.graphics.drawRect(0, 0, 1, 1);
			
			pageForwardButton.graphics.beginFill(skin.pageButtonFillColor, skin.pageButtonFillAlpha);
			pageForwardButton.graphics.drawRect(0, 0, 1, 1);
			
			super.updateSkin();
			
			// Определяем длины кнопок скроллбара и его самого
			backLength = (backButton != null) ? backButton[size] : 0;
			forwardLength = (forwardButton != null) ? forwardButton[size] : 0;
			_minLength = (backButton != null || forwardButton != null) ? (backLength + forwardLength) : scroller.length;
			currentLength = _minLength;
			length = currentLength;
			
			// Размещение недвижимой графики
			back[coord] = backLength;
			bg[coord] = backLength + back[size]; 
			extraNavigation[coord] = backLength;
			pageBackButton[coord] = backLength;
			
			// Определяем размеры кнопок постраничной перемотки
			pageBackButton.width = bg.width;
			pageBackButton.height = bg.height;
			pageForwardButton.width = bg.width;
			pageForwardButton.height = bg.height;
		}
		
		/**
		 * Рассылка изменения координат мыши (прокрутка)
		 * @param mouseCoord координаты мыши
		 */		
		public function mouseMove(mouseCoord:Point):void {
			var p:Point = MouseUtils.localCoords(this);

			// Находим необходимые координаты скроллера
			p[coord] -= scroller.dragPoint;
			
			// Проверка на деление на ноль
			var newPos:Number;
			if ((currentScrollLength - scroller.length) == 0 || (currentArea - currentView) == 0) {
				newPos = 0;
			} else {
				// Расчитываем позицию скроллера из координат
				newPos = ((p[coord] - backLength)/(currentScrollLength - scroller.length))*(currentArea - currentView);
			}
			if (position != newPos) position = newPos; 
			
			//updateScrollPosition();
			//updateLock();
		}
		
		/**
		 * Прокрутка колеса мыши
		 * @param delta поворот
		 */		
		public function mouseWheel(delta:int):void {
			position = currentPosition - _step * delta;
		}
		
		/**
		 * Обработка нажатия кнопки "назад" 
		 * @param e событие кнопки
		 */		
		private function onBackButtonPress(e:ButtonEvent = null):void {
			position = currentPosition - step;
		}
		/**
		 * Обработка нажатия кнопки "вперёд"
		 * @param e событие кнопки
		 */		
		private function onForwardButtonPress(e:ButtonEvent = null):void {
			position = currentPosition + step;
		}

		/**
		 * Обработка нажатия кнопки "страница назад"
		 * @param e событие кнопки
		 */		
		private function onPageBackButtonPress(e:ButtonEvent = null):void {
			position -= view - step;
			pageBackButton.alpha = 1;
		}
		/**
		 * Обработка отжатия кнопки "страница назад"
		 * @param e событие кнопки
		 */
		private function onPageBackButtonExpress(e:ButtonEvent = null):void {
			pageBackButton.alpha = 0;
		}
		/**
		 * Обработка нажатия кнопки "страница вперёд"
		 * @param e событие кнопки
		 */ 
		private function onPageForwardButtonPress(e:ButtonEvent = null):void {
			position += view - step;
			pageForwardButton.alpha = 1;
		}
		/**
		 * Обработка отжатия кнопки "страница вперёд"
		 * @param e событие кнопки
		 */ 
		private function onPageForwardButtonExpress(e:ButtonEvent = null):void {
			pageForwardButton.alpha = 0;
		}

		/**
		 * Обновление позиции скроллера
		 */		
		private function updateScrollPosition():void {
			// Проверка на границы
			if (currentPosition > currentArea - currentView) currentPosition = currentArea - currentView;
			if (currentPosition < 0) currentPosition = 0;
			
			// Проверка на деление на ноль
			var ratio:Number = (currentArea == currentView) ? 0 : (currentPosition/(currentArea - currentView));
			var offset:int = (ratio)*(currentScrollLength - scroller.length);
			scroller[coord] = backLength + offset;
			pageBackButton[size] = offset;
			pageForwardButton[coord] = scroller[coord] + scroller.length;
			pageForwardButton[size] = backLength + currentScrollLength - pageForwardButton[coord];
		}

		/**
		 * Обновление длины скроллера
		 */		
		private function updateScrollLength():void {
			// Проверка на деление на ноль
			var ratio:Number = (currentArea == 0) ? 0 : currentView/currentArea;
			scroller.length = ratio*currentScrollLength;
		}
		
		/**
		 * Обновление залоченности
		 */		
		private function updateLock():void {
			// Скроллер в начале
			var backEnd:Boolean = (currentPosition <= 0);
			// Скролпер в конце
			var forwardEnd:Boolean = (currentPosition >= currentArea - currentView);
			// Для скроллера хватает места
			var scrollHaveSpace:Boolean = (scroller.length <= currentScrollLength);
			// Окно больше контейнера
			var viewExceedArea:Boolean = (currentView >= currentArea);
			
			if (backButton != null) backButton.locked = backEnd || viewExceedArea;
			if (forwardButton != null) forwardButton.locked = forwardEnd || viewExceedArea;
			scroller.visible = scrollHaveSpace && !viewExceedArea;
			pageBackButton.visible = !backEnd && !viewExceedArea;
			pageForwardButton.visible = !forwardEnd && !viewExceedArea;

		}
		
		/**
		 * Текущая длина 
		 */		
		public function get length():int {
			return currentLength;
		}
		public function set length(value:int):void {
			// Проверка на минимальный размер
			if (value < _minLength) value = _minLength;
			currentLength = value;
			currentScrollLength = currentLength - backLength - forwardLength;
			// Расставляем графику
			if (forwardButton != null) forwardButton[coord] = currentLength - forwardLength;
			
			//trace("ScrollBar length: " + currentLength + "  /direction: " + direction);
			// Растягиваем фон
			bg[size] = currentScrollLength - back[size] - front[size];
			
			
			bg[coord] = back[coord] + back[size];
			front[coord] = bg[coord] + bg[size];
			
			updateScrollLength();
			updateScrollPosition();
			updateLock();
		}
		
		/**
		 * Минимальная длина
		 */		
		public function get minLength():int {
			return _minLength;
		}
		
		/**
		 * Текущая длина ползунка
		 */		
		public function get scrollerLength():int {
			return currentScrollLength;
		}
		
		/**
		 * Шаг прокрутки 
		 */		
		public function get step():int {
			return _step;
		}

		/**
		 * Толщина.
		 * При горизонтальном направлении - высота,
		 * при вертикальном - ширина  
		 */		
		public function get thickness():int {
			return (direction==Direction.HORIZONTAL) ? bg.height : bg.width;
		}
		
		/**
		 * Полная длина скроллируемого контейнера по направлению прокрутки
		 */		
		public function get area():Number {
			return currentArea;
		}
		public function set area(value:Number):void {
			currentArea = value;
			updateScrollLength();
			updateScrollPosition();
			updateLock();
		}
		
		/**
		 * Длина видимой части скроллируемого контейнера по направлению прокрутки
		 */		
		public function get view():Number {
			return currentView;
		}
		public function set view(value:Number):void {
			currentView = value;
			updateScrollLength();
			updateScrollPosition();
			updateLock();
		}
		
		/**
		 * Позиция видимой части
		 */		
		public function get position():Number {
			return currentPosition;
		}
		public function set position(value:Number):void {
			//trace("ScrollBar set position: " + value + "  /direction: " + direction);
			currentPosition = value;
			// Обновляем позицию скроллпада
			updateScrollPosition();
			updateLock();

			dispatchEvent(new Event(Event.SCROLL, true));
		}
		
		/**
		 * Экстранавигация
		 */		
		public function get extra():Sprite {
			return extraNavigation;
		}

		/**
		 * Длина экстранавигации
		 */		
		public function get extraLength():int {
			return currentScrollLength;
		}

		/**
		 * Толщина экстранавигации.
		 * При горизонтальном направлении - высота,
		 * при вертикальном - ширина  
		 */		
		public function get extraThickness():int {
			return thickness;
		}
				
	}
}