package alternativa.gui.container.scrollBox {
	import alternativa.gui.base.ActiveObject;
	import alternativa.gui.init.GUI;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.skin.container.scrollBox.ScrollerSkin;
	import alternativa.utils.MouseUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	/**
	 * Ползунок полосы прокрутки
	 */	
	public class Scroller extends ActiveObject {
		
		/**
		 * Скин 
		 */		
		private var skin:ScrollerSkin;
		
		/**
		 * Левый (или верхний) край 
		 */		
		private var back:Bitmap;
		/**
		 * Центр 
		 */		
		private var bg:Bitmap;
		/**
		 * Правый (или нижний) край 
		 */		
		private var front:Bitmap;
		
		/**
		 * Направление 
		 */		
		private var direction:Boolean;
		/**
		 * Минимальная длина 
		 */		
		private var minLength:int;
		/**
		 * Текущая длина 
		 */		
		private var currentLength:int;
		/**
		 * Название координаты (в зависимости от направления) 
		 */		
		private var coord:String;
		/**
		 * Название размера (в зависимости от направления) 
		 */
		private var size:String;
		/**
		 * Координата точки захвата мышью 
		 */		
		private var _dragPoint:int = -1;
		/**
		 * Ссылка на скроллбар 
		 */		
		private var _scrollBar:ScrollBar;
		
		
		/**
		 * @param minLength минимальная длина
		 * @param direction направление
		 */				
		public function Scroller(minLength:int, direction:Boolean) {
			super();

			// Указываем изменяемые координату и размер в зависимости от типа скроллера
			this.direction = direction;
			coord = direction ? "y" : "x";
			size = direction ? "height" : "width";

			// Создаём части кнопки
			back = new Bitmap();
			bg = new Bitmap();
			front = new Bitmap();

			// Добавляем всё в себя
			addChild(back);
			addChild(bg);
			addChild(front);
			
			// Скроллер не участвует в переходах по Tab
			tabEnabled = false;
			
			// Установка длины по умолчанию и отрисовка нормального состояния
			this.minLength = minLength;
			currentLength = minLength;
		}
		
		/**
		 * Обновление скина 
		 */
		override public function updateSkin():void {
			skin = ScrollerSkin(skinManager.getSkin(Scroller));
			super.updateSkin();
			switchState();
		}
		
		/**
		 * Размещение графики
		 */		
		private function drawScroller():void {
			if (isSkined) {
				bg[coord] = back[size];
				bg[size] = currentLength - back[size] - front[size];
				front[coord] = currentLength - front[size];
			}
		}
		
		/**
		 * Смена визуального представления состояния 
		 */
		protected function switchState():void {
			if (direction == Direction.HORIZONTAL) {
				if (_pressed) {
					state(skin.pl, skin.pc, skin.pr);
				} else if (_over) { 
					state(skin.ol, skin.oc, skin.or); 
				} else { 
					state(skin.nl, skin.nc, skin.nr);	
				}
			} else {
				if (_pressed) {
					state(skin.pt, skin.pm, skin.pb);
				} else if (_over) { 
					state(skin.ot, skin.om, skin.ob); 
				} else { 
					state(skin.nt, skin.nm, skin.nb);	
				}
			}
		}
		
		/**
		 * Смена UI при смене состояния
		 */
		private function state(backBitmap:BitmapData, bgBitmap:BitmapData, frontBitmap:BitmapData):void {
			back.bitmapData = backBitmap;
			bg.bitmapData = bgBitmap;
			front.bitmapData = frontBitmap;
		}
		
		/**
		 * Текущая длина
		 */		
		public function get length():int {
			return currentLength;
		}
		public function set length(value:int):void {
			//trace("Scroller set length: " + value + "  /direction: " + direction);
			// Проверка на минимальный размер
			if (value < minLength) value = minLength;
			currentLength = value;

			drawScroller();
		}
		
		/**
		 * Флаг наведения
		 */
		override public function set over(value:Boolean):void {
			_over = value;
			switchState();
			drawScroller();
		}
		/**
		 * Флаг нажатия
		 */
		override public function set pressed(value:Boolean):void {
			_pressed = value;
			switchState();
			drawScroller();
			
			if (_pressed) {
				// Сохранение точки захвата
				_dragPoint = MouseUtils.localCoords(this)[coord];
				
				GUI.mouseManager.addMouseCoordListener(_scrollBar);
			} else {
				GUI.mouseManager.removeMouseCoordListener(_scrollBar);
				
				_dragPoint = -1;
			}
		}
		/**
		 * Флаг блокировки
		 */
		override public function set locked(value:Boolean):void {
			_locked = value;
			if (value)
				_over = false;
			switchState();
			drawScroller();
		}
		
		/**
		 * Ссылка на скроллбар 
		 */		
		public function set scrollBar(bar:ScrollBar):void {
			_scrollBar = bar;
		}
		
		/**
		 * Точка захвата мышью при перетаскивании 
		 */		
		public function get dragPoint():int {
			return _dragPoint;
		}
		
	}
}