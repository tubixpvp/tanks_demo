package alternativa.gui.container.rollout {
	import alternativa.gui.base.GUIObject;
	import alternativa.gui.container.Container;
	import alternativa.gui.container.WidgetContainer;
	import alternativa.gui.container.group.FrameGroup;
	import alternativa.iointerfaces.keyboard.keyfilter.FocusKeyFilter;
	import alternativa.iointerfaces.keyboard.keyfilter.SimpleKeyFilter;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.skin.container.group.FrameGroupSkin;
	import alternativa.gui.skin.container.rollout.RolloutSkin;
	import alternativa.gui.widget.Image;
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.window.WindowBase;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * Свиток (сворачивающийся контейнер с заголовком)
	 */	
	public class Rollout extends WidgetContainer {
		
		/**
		 * Скин 
		 */		
		private var skin:RolloutSkin;
		/**
		 * Скин рамки 
		 */		
		private var frameSkin:FrameGroupSkin;
		/**
		 * Рамка
		 */		
		private var frame:Sprite;
		/**
		 * @private
		 * Нижний-левый угол рамки 
		 */
		protected var cBLbmp:Bitmap;
		/**
		 * @private
		 * Нижний-правый угол рамки 
		 */
		protected var cBRbmp:Bitmap;
		/**
		 * @private
		 * Левый край рамки
		 */
		protected var eMLbmp:Bitmap;
		/**
		 * @private
		 * Правый край рамки
		 */
		protected var eMRbmp:Bitmap;
		/**
		 * @private
		 * Нижний край рамки
		 */
		protected var eBCbmp:Bitmap;
		
		/**
		 * Графика заголовка
		 */		
		private var titleGfx:Sprite;
		/**
		 * Левая часть графики заголовка 
		 */		
		private var left:Bitmap;
		/**
		 * Центральная часть графики заголовка 
		 */
		private var center:Bitmap;
		/**
		 * Правая часть графики заголовка 
		 */
		private var right:Bitmap;
		
		/**
		 * @private
		 * Контейнер заголовка
		 */		
		protected var titleContainer:Container;
		/**
		 * @private
		 * Контейнер контента
		 */	
		protected var contentContainer:Container;
		/**
		 * @private
		 * Контент
		 */
		protected var content:Container;
		
		/**
		 * @private
		 * Иконка состояния (развернуто-свернуто) 
		 */		
		protected var icon:Image;
		
		/**
		 * @private
		 * Текстовое поле заголовка 
		 */		
		protected var titleLabel:Label;
		/**
		 * @private
		 * Заголовок 
		 */		
		protected var _title:String;
		/**
		 * @private
		 * Кнопка закрывания
		 */		
		protected var closeButton:ImageButton;
		
		/**
		 * @private
		* Закрываемость
		*/				
		protected var _closeable:Boolean;
		
		/**
		 * @private
		 * Флаг сворачивания
		 */		
		protected var _minimized:Boolean;
		
		/**
		 * Список объектов в контейнере в порядке их таб-индексов
		 */		
		private var _tabIndexes:Array;
		
		/**
		 * @private
		 * Действие "НАЖАТИЕ"
		 */
		protected const KEY_ACTION_PRESS:String = "RolloutPress";
		/**
		 * @private
		 * Действие "ОТЖАТИЕ"
		 */
		protected const KEY_ACTION_UNPRESS:String = "RolloutUnpress";
		
		
		/**
		 * @param minimized свернутость при создании
		 */
		public function Rollout(title:String, closeable:Boolean = false, minimized:Boolean = true) {
			super();
			
			// Сохранение параметров
			_title = title;
			_closeable = closeable;
			_minimized = minimized;
			
			// Сборка рамки
			frame = new Sprite();
			frame.mouseEnabled = false;
			frame.mouseChildren = false;
			frame.tabEnabled = false;
			frame.tabChildren = false;
			addChild(frame);
			cBLbmp = new Bitmap();
			cBRbmp = new Bitmap();
			eMLbmp = new Bitmap();
			eMRbmp = new Bitmap();
			eBCbmp = new Bitmap();
			frame.addChild(cBLbmp);
			frame.addChild(cBRbmp);
			frame.addChild(eMLbmp);
			frame.addChild(eMRbmp);
			frame.addChild(eBCbmp);
			
			// Сборка заголовка
			titleGfx = new Sprite();
			titleGfx.mouseEnabled = false;
			titleGfx.mouseChildren = false;
			titleGfx.tabEnabled = false;
			titleGfx.tabChildren = false;
			addChildAt(titleGfx, 0);
			left = new Bitmap();
			center = new Bitmap();
			right = new Bitmap();
			titleGfx.addChild(left);
			titleGfx.addChild(center);
			titleGfx.addChild(right);
			
			// Устанавливаем компоновщика
			layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.TOP, 0);
			
			// Создаем контейнер контента заголовка
			titleContainer = new Container();
			addObject(titleContainer);
			titleContainer.stretchableH = true;
			
			// Наполнение заголовка 
			createTitle();
			
			// Создаем контейнер контента
			contentContainer = new Container();
			addObject(contentContainer);
			contentContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.TOP, 0);
			contentContainer.stretchableH = true;
			contentContainer.stretchableV = true;
			
			_tabIndexes = new Array(); 
			
			// Фильтры горячих клавиш
			var pressFilter:FocusKeyFilter = new FocusKeyFilter(this, new SimpleKeyFilter(new Array(13, 32)));
			keyFiltersConfig.addKeyDownFilter(pressFilter, KEY_ACTION_PRESS);
			keyFiltersConfig.addKeyUpFilter(pressFilter, KEY_ACTION_UNPRESS);
			keyFiltersConfig.bindKeyDownAction(KEY_ACTION_PRESS, this, pressAction, true);
			keyFiltersConfig.bindKeyUpAction(KEY_ACTION_UNPRESS, this, pressAction, false);
		}
		
		/**
		 * Создание заголовка 
		 */		
		protected function createTitle():void {
			// Создание иконки состояния
			icon = new Image();
			titleContainer.addObject(icon);
			icon.cursorActive = false;
			// Создание текстового поля заголовка
			titleLabel = new Label(_title);
			titleLabel.stretchableH = true;
			titleContainer.addObject(titleLabel);
			titleContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 0);
			// Создание кнопки закрывания
			if (_closeable) {
				closeButton = new ImageButton(0, 1);
				titleContainer.addObject(closeButton);
				closeButton.addEventListener(ButtonEvent.EXPRESS, onClose);
			}
		}
		
		/**
		 * Обновление скина 
		 */
		override public function updateSkin():void {
			skin = RolloutSkin(skinManager.getSkin(Rollout));
			frameSkin = FrameGroupSkin(skinManager.getSkin(FrameGroup));
			super.updateSkin();
			
			icon.bitmapData = (_minimized) ? skin.minimized : skin.maximized;
			
			if (_closeable) {
				closeButton.normalBitmap = skin.close;
				closeButton.overBitmap = skin.close;
				closeButton.pressBitmap = skin.close;
				closeButton.lockBitmap = skin.close;
			}
			
			// Загрузка битмап (для рамки)
			cBLbmp.bitmapData = frameSkin.cornerBL;
			cBRbmp.bitmapData = frameSkin.cornerBR;
			eMLbmp.bitmapData = frameSkin.edgeML;
			eMRbmp.bitmapData = frameSkin.edgeMR;
			eBCbmp.bitmapData = frameSkin.edgeBC;
			
			// Установка размеров и отступов контейнера заголовка
			titleContainer.minSize.y = skin.nc.height;
			
			titleContainer.marginLeft = skin.titleMarginLeft;
			titleContainer.marginTop = skin.titleMarginTop;
			titleContainer.marginRight = skin.titleMarginRight;
			titleContainer.marginBottom = skin.titleMarginBottom;
			
			titleContainer.y = skin.yNormal;
			titleGfx.y = skin.yNormal;
			
			// Установка размеров и отступов контейнера контента
			contentContainer.marginLeft = frameSkin.borderThickness;
			contentContainer.marginRight = frameSkin.borderThickness;
			contentContainer.marginBottom = frameSkin.borderThickness;
			
			if (content != null) {
				content.marginLeft = skin.contentMarginLeft;
				content.marginTop = skin.contentMarginTop;
				content.marginRight = skin.contentMarginRight;
				content.marginBottom = skin.contentMarginBottom;
			}
			
			// Обновить состояние
			switchState();
			
			// Считаем ширину
			calcMinWidth();
		}
		
		/**
		 *  Расчёт минимальной ширины
		 */
		private function calcMinWidth():void {
			var w:int = skin.nl.width + skin.nr.width;
			minSize.x = w;
		}
		
		/**
		 * Загрузка контента (уложенного в контейнер)
		 * @param container контейнер с контентом
		 */		
		public function setContainer(container:Container):void {
			if (content != null) {
				contentContainer.removeObject(content);
			}
			contentContainer.addObject(container);
			content = container;
			
			if (isSkined) {
				content.marginLeft = skin.contentMarginLeft;
				content.marginTop = skin.contentMarginTop;
				content.marginRight = skin.contentMarginRight;
				content.marginBottom = skin.contentMarginBottom;
			}
			// Начальное сворачивание/разворачивание
			minimized = _minimized;			
		}
		
		/**
		 * Расчет минимальных размеров контейнера
		 * @return минимальные размеры
		 */
		override public function computeMinSize():Point {
			var newSize:Point;
			if (_minimized) {
				newSize = titleContainer.computeMinSize();
			} else {
				newSize = super.computeMinSize();
			}
			return newSize;
		}	
		
		/**
		 * Расчет предпочтительных размеров контейнера с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */
		override public function computeSize(size:Point):Point {
			var newSize:Point;
			if (_minimized) {
				newSize = titleContainer.computeSize(new Point(size.x, titleContainer.minSize.y));
			} else {
				newSize = super.computeSize(size);
			}
			return newSize;
		}
		
		/**
		 * Проверка на растягиваемость
		 * @param direction направление проверки
		 * @return растягиваемость по заданному направлению
		 */				
		override public function isStretchable(direction:Boolean):Boolean {
			var result:Boolean;
			if (_minimized) {
				result = direction == Direction.VERTICAL ? false : _stretchableH;
			} else {
				result = direction == Direction.VERTICAL ? _stretchableV : _stretchableH;
			}
			return result;
		}
		
		/**
		 * Отрисовка контейнера в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			// Отрисовываем заголовок
			titleContainer.draw(new Point(size.x, skin.nc.height));
			
			// Отрисовывем контент и сохраняем размеры
			if (!_minimized) {
				super.draw(size);
				// Перерисовываем рамку (выравнивая по нижней части контейнера)
				arrangeGraphics(new Point(size.x, size.y - titleContainer.minSize.y));
				frame.visible = true;
			} else {
				_currentSize = size.clone();
				frame.visible = false;
			}
			
			// Расставляем части кнопки заголовка
			center.x = left.width;
			center.width = currentSize.x - left.width - right.width;
			right.x = currentSize.x - right.width;
			
			//titleContainer.minSize.x = size.x;
			
			// Устанавливаем область кнопки заголовка
			//titleButton.setHitArea(new Rectangle(0, 0, size.x, titleContainer.minSize.y));
		}
		
		/**
		 * Перерисовка частей графики
		 * @param size размер контейнера без заголовка
		 */		
		protected function arrangeGraphics(size:Point):void {
			// Расставляем углы
			cBLbmp.y = _currentSize.y - cBLbmp.height;
			
			cBRbmp.x = size.x - cBRbmp.width;
			cBRbmp.y = cBLbmp.y;
			
			// Размеры области без углов
			var newWidth:int = size.x - cBLbmp.width - cBRbmp.width;
			var newHeight:int = size.y - cBLbmp.height;
			
			eMLbmp.y = titleContainer.minSize.y;
			eMLbmp.height = newHeight;
			
			eMRbmp.x = size.x - eMRbmp.width;
			eMRbmp.y = titleContainer.minSize.y;
			eMRbmp.height = newHeight;
			
			eBCbmp.x = cBLbmp.width;
			eBCbmp.y = cBLbmp.y;
			eBCbmp.width = newWidth;
		}
		
		/**
		 * Смена визуального состояния 
		 */
		protected function switchState():void {
			if (_locked) {
				state(skin.ll, skin.lc, skin.lr);								
			} else
			if (_pressed) {
				state(skin.pl, skin.pc, skin.pr);
			} else
			if (_focused) {
				state(skin.fl, skin.fc, skin.fr);
			} else
			if (_over) {
				state(skin.ol, skin.oc, skin.or); 
			} else {									
				state(skin.nl, skin.nc, skin.nr);
			}										
		}
		
		/**
		 * Перегрузка битмап при смене состояния
		 */
		private function state(_left:BitmapData,_center:BitmapData,_right:BitmapData):void {
			left.bitmapData = _left;
			center.bitmapData = _center;
			right.bitmapData = _right;
		}
		
		/**
		 * Фокусировка
		 */
		override protected function focus():void {
			switchState();
		}
		/**
		 * Расфокусировка
		 */		
		override protected function unfocus():void {
			switchState();
		}
		
		/**
		 * Обработка нажатия с клавиатуры
		 * @param pressedValue значение флага нажатия
		 */		
		private function pressAction(pressedValue:Boolean):void {
			pressed = pressedValue;
		}
		
		/**
		 * Обработка нажатия кнопки закрывания
		 * @param e событие кнопки
		 */		
		private function onClose(e:ButtonEvent):void {
			dispatchEvent(new RolloutEvent(RolloutEvent.CLOSE, this));
		}
		
		/**
		 * @private
		 * Разворачивание
		 */		
		protected function maximize():void {
			if (contentContainer != null) {
				minSizeChanged = true;
				_minimized = false;
				contentContainer.visible = true;
				contentContainer.scaleY = 1;
				if (rootObject != null) {
					// Растягивание окна
					if (isSkined) GUIObject(rootObject).repaintCurrentSize();
					// Добавление объектов в таб-индексы окна
					if (rootObject is WindowBase) {
						var index:int = WindowBase(rootObject).tabIndexes.indexOf(this) + 1;
						if (index != -1) {
							for (var i:int = 0; i < _tabIndexes.length; i++) {
								WindowBase(rootObject).tabIndexes.splice(index + i, 0, _tabIndexes[i]);
							}
							for (i = 0; i < WindowBase(rootObject).tabIndexes.length; i++) {
								InteractiveObject(WindowBase(rootObject).tabIndexes[i]).tabIndex = i;
							}
						}
					}
				}
			}
			if (isSkined)
				icon.bitmapData = skin.maximized;
				
			trace("maximize window tabIndexes: " + WindowBase(rootObject).tabIndexes);
		}
		/**
		 * @private
		 * Сворачивание
		 */
		protected function minimize():void {
			if (contentContainer != null) {
				minSizeChanged = true;
				_minimized = true;
				if (rootObject != null) {
					// Сжатие окна
					if (isSkined) GUIObject(rootObject).repaint(new Point(GUIObject(rootObject).currentSize.x, GUIObject(rootObject).currentSize.y - (currentSize.y - titleContainer.currentSize.y)));
					// Удаление объектов из таб-индексов окна
					if (rootObject is WindowBase) {
						var index:int = WindowBase(rootObject).tabIndexes.indexOf(this) + 1;
						if (index != -1) {
							WindowBase(rootObject).tabIndexes.splice(index, _tabIndexes.length);
							for (var i:int = 0; i < WindowBase(rootObject).tabIndexes.length; i++) {
								InteractiveObject(WindowBase(rootObject).tabIndexes[i]).tabIndex = i;
							}
						}
					}
				}
				contentContainer.scaleY = 0;
				contentContainer.visible = false;
			}
			if (isSkined)
				icon.bitmapData = skin.minimized;
		}
		
		/**
		 * @private
		 * Анимация при нажатии заголовка
		 */		
		protected function titleDownAnimation():void {
			titleContainer.y = skin.yPress;
			titleGfx.y = skin.yPress;
		}
		/**
		 * @private
		 * Анимация при отжатии заголовка
		 */
		protected function titleUpAnimation():void {
			titleContainer.y = skin.yNormal;
			titleGfx.y = skin.yNormal;
		}
		
		/**
		 * Флаг наведения
		 */
		override public function set over(value:Boolean):void {
			super.over = value;
			if (!_focused) {
				switchState();			
			}	
		}
		/**
		 * Флаг нажатия
		 */
		override public function set pressed(value:Boolean):void {
			super.pressed = value;
			switchState();
			if (_pressed) {
				titleDownAnimation();
			} else {
				titleUpAnimation();
				minimized = !_minimized;
				if (_minimized) {
					dispatchEvent(new RolloutEvent(RolloutEvent.MINIMIZE, this));
				} else {
					dispatchEvent(new RolloutEvent(RolloutEvent.MAXIMIZE, this));
				}
			}
		}
		
		/**
		 * Флаг блокировки
		 */
		override public function set locked(value:Boolean):void {
			super.locked = value;
			tabEnabled = !value;
			cursorActive = !value;
			
			icon.locked = value;
			titleLabel.locked = value;
			if (_closeable) {
				closeButton.locked = value;
			}
			
			// Если залочиваем
			if (value) {
				minimize();
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
		 * Свернутость
		 */
		public function get minimized():Boolean {
			return _minimized;
		}	
		public function set minimized(value:Boolean):void {
			if (value) {
				minimize();
			} else {
				maximize()
			}
		}
		
		public function get container():Container {
			return content;
		}
		
		/**
		 * Массив объектов, участвующих в табуляции, в порядке их индексов
		 */		
		public function get tabIndexes():Array {
			return _tabIndexes;
		}		
		public function set tabIndexes(objects:Array):void {
			if (objects.length != 0) {
				for (var i:int = 0; i < objects.length; i++) {
					InteractiveObject(objects[i]).tabIndex = i;
					tabIndexes.push(objects[i]);
				}
			}
		}
		
		public function get title():String {
			return _title;
		}
		
	}
}