package alternativa.gui.widget.button {
	import alternativa.gui.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.gui.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.mouse.IMouseCoordListener;
	import alternativa.gui.skin.widget.button.ButtonSkin;
	import alternativa.gui.skin.widget.button.SwitchSkin;
	import alternativa.gui.widget.Widget;
	import alternativa.utils.MouseUtils;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * Многопозиционный переключатель с кнопкой и иконками позиций
	 */	
	public class ButtonSwitch extends Widget implements IMouseCoordListener {
		
		/**
		 * Графика трэка переключателя 
		 */		
		private var gfx:Sprite;
		/**
		 * Верхний-левый угол трэка 
		 */		
		private var cTLbmp:Bitmap;
		/**
		 * Верхний-правый угол трэка 
		 */
		private var cTRbmp:Bitmap;
		/**
		 * Нижний-левый угол трэка 
		 */
		private var cBLbmp:Bitmap;
		/**
		 * Нижний-правый угол трэка 
		 */
		private var cBRbmp:Bitmap;
		/**
		 * Верхний край трэка 
		 */		
		private var eTCbmp:Bitmap;
		/**
		 * Левый край трэка 
		 */
		private var eMLbmp:Bitmap;
		/**
		 * Правый край трэка 
		 */
		private var eMRbmp:Bitmap;
		/**
		 * Нижний край трэка 
		 */
		private var eBCbmp:Bitmap;
		/**
		 * Центр трэка 
		 */
		private var bgbmp:Bitmap;
		/**
		 * Кнопка переключателя
		 */		
		private var switchButton:SwitchButton;
		/**
		 * Указатель на иконку позиции
		 */		
		private var switchArrow:Bitmap;
		/**
		 * Шкурка
		 */		
		private var skin:SwitchSkin;
		/**
		 * Скин кнопки
		 */		
		private var buttonSkin:ButtonSkin;
		/**
		 * Количество позиций
		 */		
		private var posNum:int;
		/**
		 * Текущая позиция
		 */		
		private var _currentPos:int;
		/**
		 * Текущее расстояние между позициями
		 */		
		private var posSpace:int;
		/**
		 * Отношение posMinSpace : minSize.x
		 */		
		private var posSpaceRatio:Number;
		/**
		 * Минимальное расстояние между позициями
		 */		
		private var posMinSpace:int;
		/**
		 * Иконки позиций над переключателем
		 */		
		private var posIcons:Array;
		
		// Пространство между иконками
		//private var iconsHSpace:int;
		
		/**
		 * Подъем иконок над кнопокой переключателя
		 */		
		private var iconsVSpace:int;
		/**
		 * Текст на кнопке переключателя в каждой из позиций
		 */		
		private var posNames:Array;
		/**
		 * Точка хватания мышью
		 */		
		private var dragPoint:Point;
		/**
		 * Минимальная ширина (зависит от скина, текста, иконок)
		 */		
		private var minWidth:int;
		/**
		 * Минимальная ширина кнопки
		 */		
		private var buttonMinWidth:int;
		/**
		 * Действие "УСТАНОВИТЬ ПРЕДЫДУЩУЮ ПОЗИЦИЮ"
		 */
		private static const KEY_ACTION_PREV:String = "ButtonSwitchPrev";
		/**
		 * Действие "УСТАНОВИТЬ СЛЕДУЩУЮ ПОЗИЦИЮ"
		 */
		private static const KEY_ACTION_NEXT:String = "ButtonSwitchNext";
		
		
		/**
		 * @param posNum количество позиций
		 * @param currentPos текущая позиция
		 * @param minHeight минимальная высота
		 * @param stretchable растягиваемость по горизонтали
		 * @param posNames текст на кнопке в каждой позиции
		 * @param posIcons иконка над кнопкой в каждой позиции
		 * @param iconsHSpace отступы между иконками
		 * @param iconsVSpace отступ от кнопки до иконок
		 */		
		public function ButtonSwitch(posNum:int, currentPos:int, posMinSpace:int, stretchableH:Boolean, posNames:Array, posIcons:Array = null, iconsVSpace:int = 3) {
			super();
			
			// Создаём части области для кнопки
			cTLbmp = new Bitmap();
			cTRbmp = new Bitmap();
			cBLbmp = new Bitmap();
			cBRbmp = new Bitmap();
			eTCbmp = new Bitmap();
			eMLbmp = new Bitmap();
			eMRbmp = new Bitmap();
			eBCbmp = new Bitmap();
			bgbmp = new Bitmap();
			
			gfx = new Sprite();
			gfx.mouseEnabled = false;
			gfx.tabEnabled = false;
			addChildAt(gfx, 0);
			
			gfx.addChild(cTLbmp);
			gfx.addChild(cTRbmp);
			gfx.addChild(cBLbmp);
			gfx.addChild(cBRbmp);
			gfx.addChild(eTCbmp);
			gfx.addChild(eMLbmp);
			gfx.addChild(eMRbmp);
			gfx.addChild(eBCbmp);
			gfx.addChild(bgbmp);
			
			// Сохранение параметров
			this.posNum = posNum;
			_currentPos = currentPos;
			this.posMinSpace = posMinSpace;
			this.posSpace = posMinSpace;
			this.stretchableH = stretchableH;
			this.stretchableV = false;
			//this.iconsHSpace = iconsHSpace;
			this.iconsVSpace = iconsVSpace;
			
			// Создание кнопки-переключателя
			switchButton = new SwitchButton("Сказать", null, Align.CENTER);
			switchButton.parentSwitch = this;
			addChild(switchButton);
			
			// Создание указателя на иконку позиции
			switchArrow = new Bitmap();
			addChild(switchArrow);
			
			// Создание иконок позиций
			this.posIcons = new Array();
			if (posIcons != null && posIcons.length != 0) {
				for (var i:int = 0; i < posIcons.length; i++) {
					this.posIcons.push(new Bitmap(posIcons[i]));
					addChild(this.posIcons[i]);
					var h:int = Bitmap(this.posIcons[i]).height;
					this.posIcons[i].y = -iconsVSpace - h;
				}
			} else {
				switchArrow.visible = false;
			}
			// Сохранение названий
			this.posNames = new Array();
			for (var j:int = 0; j < posNames.length; j++) {
				this.posNames.push(posNames[j]);
			}
			
			// Фильтры горячих клавиш
			var prevFilter:FocusKeyFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array([37])));
			var nextFilter:FocusKeyFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array([39])));
			keyFiltersConfig.addKeyDownFilter(prevFilter, KEY_ACTION_PREV);
			keyFiltersConfig.addKeyDownFilter(nextFilter, KEY_ACTION_NEXT);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_PREV, this, setPrevPos);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_NEXT, this, setNextPos);
		}
		
		/**
		 * Рассылка изменения координат мыши 
		 * @param mouseCoord координаты мыши
		 */		
		public function mouseMove(mouseCoord:Point):void {
			var mouseCoords:Point = MouseUtils.localCoords(this);
			var buttonCord:int = mouseCoords.x - switchButton.dragPoint.x;
			// Номер позиции
			var n:int = Math.round((buttonCord - skin.borderThickness)/posSpace) + 1;
			// Краевые ограничения
			if (n > posNum) n = posNum;
			if (n < 1) n = 1;
			// Eсли необходимо устанавливаем переключатель
			if (n != _currentPos) {
				currentPos = n;
			}
		}
		
		/**
		 * Обновить скин 
		 */
		override public function updateSkin():void {
			skin = SwitchSkin(skinManager.getSkin(ButtonSwitch));
			buttonSkin = ButtonSkin(skinManager.getSkin(Button));
			
			// Загрузка битмап
			cTLbmp.bitmapData = skin.cornerTL;
			cTRbmp.bitmapData = skin.cornerTR;
			cBLbmp.bitmapData = skin.cornerBL;
			cBRbmp.bitmapData = skin.cornerBR;
			eTCbmp.bitmapData = skin.edgeTC;
			eMLbmp.bitmapData = skin.edgeML;
			eMRbmp.bitmapData = skin.edgeMR;
			eBCbmp.bitmapData = skin.edgeBC;
			bgbmp.bitmapData = skin.bgMC;
			switchArrow.bitmapData = skin.arrow;
			
			// Установка флага заскинованности
			super.updateSkin();
			
			// Рассчет минимальной высоты
			minSize.y = buttonSkin.nc.height + 2*skin.borderThickness;
			
			// Рассчет минимальной ширины кнопки
			/*var w:int = 0;
			var n:int = 0;
			for (var i:int = 0; i < posNames.length; i++) {
				if (w < String(posNames[i]).length) {
					w = String(posNames[i]).length;
					n = i;
				}
			}
			switchButton.text = posNames[n];
			
			// Рассчет минимальной ширины всего переключателя
			calcMinWidth();*/
			
			// Установка кнопки
			switchButton.y = skin.borderThickness;
			if (posIcons.length > 0)
				switchArrow.y = switchButton.y - Math.round(switchArrow.height*0.5);
			
			// Установка переключателя в текущую позицию
			//currentPos = _currentPos;
		}
		
		/**
		 * Расчет минимальных размеров объекта
		 * @return минимальные размеры
		 */	
		override public function computeMinSize():Point {
			// Рассчет минимальной ширины кнопки
			var w:int = 0;
			var n:int = 0;
			for (var i:int = 0; i < posNames.length; i++) {
				if (w < String(posNames[i]).length) {
					w = String(posNames[i]).length;
					n = i;
				}
			}
			switchButton.text = posNames[n];
			buttonMinWidth = switchButton.computeMinSize().x;
			//switchButton.text = posNames[_currentPos-1];
			
			calcMinWidth();
			minSizeChanged = false;
			return new Point(Math.max(_minSize.x, minWidth), minSize.y);
		}
		
		/**
		 * Расчет предпочтительных размеров с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */				
		override public function computeSize(size:Point):Point {
			var newSize:Point = new Point(Math.max(_minSize.x, minWidth), minSize.y);
			if (size != null) {
				if (_stretchableH) newSize.x = Math.max(size.x, _minSize.x, minWidth);
				if (_stretchableV) newSize.y = Math.max(size.y, _minSize.y);
			} 
			return newSize;
		}
		
		/**
		 * Рассчет минимальной ширины
		 */		
		private function calcMinWidth():void {
			//minSize.x = switchButton.minSize.x + posMinSpace*(posNum-1) + 2*skin.borderThickness;
			//posSpaceRatio = posMinSpace/minSize.x;
			minWidth = buttonMinWidth + posMinSpace*(posNum-1) + 2*skin.borderThickness;
			posSpaceRatio = posMinSpace/minWidth;
		}
		
		override public function draw(size:Point):void {
			//trace("ButtonSwitch draw");
			// Находим координаты нижнего правого угла
			var farX:int = size.x - cBRbmp.width;
			var farY:int = size.y - cBRbmp.height;
				
			// Расставляем углы
			cTRbmp.x = farX;
			cBLbmp.y = farY;
			cBRbmp.x = farX;
			cBRbmp.y = farY;
			
			var newWidth:int = size.x - cTLbmp.width - cTRbmp.width;
			var newHeight:int = size.y - cTLbmp.height - cBLbmp.height;
				
			eTCbmp.x = cTLbmp.width;
			eTCbmp.width = newWidth;
			
			eMLbmp.y = cTLbmp.height;
			eMLbmp.height = newHeight;
			
			eMRbmp.x = farX;
			eMRbmp.y = cTRbmp.height;
			eMRbmp.height = newHeight;
			
			eBCbmp.x = cBLbmp.width;
			eBCbmp.y = farY;
			eBCbmp.width = newWidth;
			
			bgbmp.x = cTLbmp.width;
			bgbmp.y = cTLbmp.height;
			bgbmp.width = newWidth;
			bgbmp.height = newHeight;
			
			// Перерассчет расстояния между позициями
			posSpace = Math.round(posSpaceRatio*size.x);
			
			// Кнопка
			// ? 
			switchButton.setText(posNames[_currentPos-1]);
			// ?
			switchButton.draw(new Point(size.x - 2*skin.borderThickness - posSpace*(posNum-1), buttonSkin.nc.height));
			switchButton.x = (_currentPos-1)*posSpace + skin.borderThickness;
			
			// Иконки
			var l:int = posIcons.length;
			if (l > 0) {
				var w:int = Bitmap(posIcons[0]).width;
				var h:int = Bitmap(posIcons[0]).height;
				for (var i:int = 0; i < l; i++) {
					posIcons[i].x = Math.round((size.x - w)*0.5 + (i - (l-1)/2)*posSpace);
					//posIcons[i].y = -iconsVSpace - h;
				}
				// Стрелка указателя
				switchArrow.x = Math.round(switchButton.x + switchButton.width/2 - switchArrow.width/2);
			}
			super.draw(size);
		}
		
		/**
		 * Установить предыдущую позицию
		 */		
		private function setPrevPos():void {
			currentPos = _currentPos - 1;
			dispatchEvent(new SwitchEvent(SwitchEvent.PREV, switchButton));
		}
		/**
		 * Установить следущую позицию
		 */
		private function setNextPos():void {
			currentPos = _currentPos + 1;
			dispatchEvent(new SwitchEvent(SwitchEvent.NEXT, switchButton));
		}
		
		/**
		 * Текущая позиция
		 */		
		public function get currentPos():int {
			return _currentPos;
		}
		public function set currentPos(num:int):void {
			if (num < 1) num = 1;
			if (num > posNum) num = posNum;
			
			if (_currentPos != num) {
				if (num > _currentPos) {
					_currentPos = num;
					dispatchEvent(new SwitchEvent(SwitchEvent.NEXT, switchButton));
				} else {
					_currentPos = num;
					dispatchEvent(new SwitchEvent(SwitchEvent.PREV, switchButton));
				}
				 // Установка кнопки переключателя
				switchButton.x = (num-1)*posSpace + skin.borderThickness;
				if (posIcons.length > 0)
					switchArrow.x = Math.round(switchButton.x + switchButton.width/2 - switchArrow.width/2);
				// Установка текста
				switchButton.setText(posNames[num-1]);
				switchButton.draw(switchButton.currentSize);
			}
		}
		
		/**
		 * Текст всплывающей подсказки
		 */		
		override public function set hint(value:String):void {
			super.hint = value;
			switchButton.hint = value;
		}
		
	}
}