package alternativa.gui.container.group {
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.skin.container.group.FrameGroupSkin;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * Контейнер с рамкой и заголовком
	 */	
	public class FrameGroup extends Container {
		
		/**
		 * Рамка
		 */		
		private var frame:Sprite;
		/**
		 * @private
		 * Верхний-левый угол рамки 
		 */		
		protected var cTLbmp:Bitmap;
		/**
		 * @private
		 * Верхний-правый угол рамки 
		 */
		protected var cTRbmp:Bitmap;
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
		 * Верхний край рамки до заголовка
		 */
		protected var eTCbmpLeft:Bitmap;
		/**
		 * @private
		 * Верхний край рамки после заголовка 
		 */		
		protected var eTCbmpRight:Bitmap;
		/**
		 * @private
		 * Кончик рамки до заголовка
		 */		
		protected var eTCbmpBefore:Bitmap;
		/**
		 * @private
		 * Кончик рамки после заголовка
		 */		
		protected var eTCbmpAfter:Bitmap;
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
		 * @private
		 * Текстовое поле заголовка
		 */		
		protected var tf:TextField;
		/**
		 * @private
		 * Заголовок
		 */		
		protected var _title:String;
		/**
		 * Скорректированная ширина заголовка
		 */		
		private var titleWidth:int;
		/**
		 * Скорректированная высота заголовка
		 */		
		private var titleHeight:int;
		/**
		 * @private
		 * Выравнивание заголовка
		 */		
		protected var _titleAlign:uint;
		
		/**
		 * Скин 
		 */		
		private var skin:FrameGroupSkin;
		
		
		/**
		 * @param title заголовок
		 * @param titleAlign выравнивание заголовка
		 * @param marginLeft отступ слева
		 * @param marginTop отступ сверху
		 * @param marginRight отступ справа
		 * @param marginBottom отступ снизу
		 */		
		public function FrameGroup(title:String = null, titleAlign:uint = Align.LEFT, marginLeft:int = 0, marginTop:int = 0, marginRight:int = 0, marginBottom:int = 0) {
			super(marginLeft, marginTop, marginRight, marginBottom);
			
			// Сохранение параметров
			_title = title;
			_titleAlign = titleAlign;
			
			// Сборка рамки
			frame = new Sprite();
			frame.mouseEnabled = false;
			frame.tabEnabled = false;
			addChild(frame);
			cTLbmp = new Bitmap();
			cTRbmp = new Bitmap();
			cBLbmp = new Bitmap();
			cBRbmp = new Bitmap();
			eTCbmpLeft = new Bitmap();
			eTCbmpRight = new Bitmap();
			eTCbmpBefore = new Bitmap();
			eTCbmpAfter = new Bitmap();
			eMLbmp = new Bitmap();
			eMRbmp = new Bitmap();
			eBCbmp = new Bitmap();
			frame.addChild(cTLbmp);
			frame.addChild(cTRbmp);
			frame.addChild(cBLbmp);
			frame.addChild(cBRbmp);
			frame.addChild(eTCbmpLeft);
			frame.addChild(eTCbmpRight);
			frame.addChild(eTCbmpBefore);
			frame.addChild(eTCbmpAfter);
			frame.addChild(eMLbmp);
			frame.addChild(eMRbmp);
			frame.addChild(eBCbmp);
			
			// Добавление текстового поля
			tf = new TextField();
			with (tf) {
				autoSize = TextFieldAutoSize.LEFT;
				antiAliasType = AntiAliasType.ADVANCED;
				embedFonts = true;
				selectable = false;
				multiline = false;
				tabEnabled = false;
				mouseEnabled = false;
				visible = true;
				text = _title;
			}
			addChild(tf);
		}
		
		/**
		 * Обновление скина 
		 */
		override public function updateSkin():void {
			skin = FrameGroupSkin(skinManager.getSkin(FrameGroup));
			super.updateSkin();
			// Загрузка битмап
			cTLbmp.bitmapData = skin.cornerTL;
			cTRbmp.bitmapData = skin.cornerTR;
			cBLbmp.bitmapData = skin.cornerBL;
			cBRbmp.bitmapData = skin.cornerBR;
			eTCbmpLeft.bitmapData = skin.edgeTC;
			eTCbmpRight.bitmapData = skin.edgeTC;
			eTCbmpBefore.bitmapData = skin.edgeTCbefore;
			eTCbmpAfter.bitmapData = skin.edgeTCafter;
			eMLbmp.bitmapData = skin.edgeML;
			eMRbmp.bitmapData = skin.edgeMR;
			eBCbmp.bitmapData = skin.edgeBC;
			// Установка формата заголовка
			tf.thickness = skin.titleThickness;
			tf.sharpness = skin.titleSharpness;
			tf.setTextFormat(skin.titleTextFormat);
			tf.defaultTextFormat = skin.titleTextFormat;
			// Пересчет минимальной ширины и высоты
			//calcMinWidth();
		}
		
		/**
		 * @private
		 * Расчёт минимальных размеров
		 */
		protected function calcMinWidth():void {
			titleWidth = Math.round(tf.width) - 3;
			titleHeight = Math.round(tf.height) - 6;
			
			// Выбор минимальной ширины и высоты (по тексту или по рамке и отступам)
			var titleMinWidth:int = 2*skin.borderThickness + titleWidth + skin.titleMarginLeft + skin.titleMarginRight;// Вынужденное шаманство на 3px из-за странности текстовых полей
			var frameMinWidth:int = marginLeft + marginRight + 2*skin.borderThickness;
			
			//var titleMinHeight:int = Math.round(titleHeight/2) + marginTop +  marginBottom + skin.borderThickness;// Вынужденное шаманство на 6px из-за странности текстовых полей
			//var frameMinHeight:int = marginTop + marginBottom + 2*skin.borderThickness;
			
			_minSize.x = Math.max(titleMinWidth, frameMinWidth);
			_minSize.y = titleHeight + marginTop +  marginBottom + skin.borderThickness;
		}
		
		/**
		 * Расчет минимальных размеров контейнера
		 * @return минимальные размеры
		 */
		override public function computeMinSize():Point {
			var newSize:Point = new Point();
			
			titleWidth = Math.round(tf.width) - 3;
			titleHeight = Math.round(tf.height) - 6;
			
			// Выбор минимальной ширины и высоты (по тексту или по рамке и отступам)
			var titleMinWidth:int = 2*skin.borderThickness + titleWidth + skin.titleMarginLeft + skin.titleMarginRight;// Вынужденное шаманство на 3px из-за странности текстовых полей
			//var frameMinWidth:int = marginLeft + marginRight + 2*skin.borderThickness;
			
			// Определяем размер контейнера с отступами
			var contentSize:Point = Point(layoutManager.computeMinSize()).add(new Point(_marginLeft + _marginRight, _marginTop + _marginBottom));
			
			newSize.x = Math.max(titleMinWidth, contentSize.x + 2*skin.borderThickness);
			newSize.y = contentSize.y + titleHeight + skin.borderThickness;
			
			minSizeChanged = false;
			//trace("FrameGroup computerMinSize: " + newSize);
			return newSize;
		}
		
		/**
		 * Расчет предпочтительных размеров контейнера с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */
		override public function computeSize(size:Point):Point {
			// проверка на минимум
			//var _size = size.clone();
			//_size.x = Math.max(minSize.x,_size.x);
			//_size.y = Math.max(minSize.y,_size.y);
			
			var _size:Point = new Point();
			// проверка на минимум
			_size.x = isStretchable(Direction.HORIZONTAL) ? Math.max(size.x, _minSize.x, layoutManager.minSize.x) : Math.max(_minSize.x, layoutManager.minSize.x);
			_size.y = isStretchable(Direction.VERTICAL) ? Math.max(size.y, _minSize.y, layoutManager.minSize.y) : Math.max(_minSize.y, layoutManager.minSize.y);
			
			// Определяем размер контента
			var contentSize:Point = layoutManager.computeSize(_size.clone().subtract(new Point(marginLeft + marginRight + 2*skin.borderThickness, titleHeight + marginTop + marginBottom + skin.borderThickness)));
			// Определяем минимальный размер контейнера
			var newSize:Point = new Point(contentSize.x + marginLeft + marginRight + 2*skin.borderThickness, contentSize.y + titleHeight + marginTop + marginBottom + skin.borderThickness);
			// Пытаемся принять предлагаемый размер (не меньше размера с учетом контента)
			newSize.x = isStretchable(Direction.HORIZONTAL) ? Math.max(_size.x, newSize.x) : newSize.x; 
			newSize.y = isStretchable(Direction.VERTICAL) ? Math.max(_size.y, newSize.y) : newSize.y;
			
			// контент все равно может оказатся меньше минимальных размеров
			newSize.x = Math.max(_minSize.x,newSize.x);
			newSize.y = Math.max(_minSize.y,newSize.y);
			
			return newSize;
		}
		
		/**
		 * Отрисовка контейнера в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			var newSize:Point = size.clone();
			// Отрисовка контента
			canvas.x = skin.borderThickness + marginLeft;
			canvas.y = marginTop + titleHeight;
			var contentSize:Point = layoutManager.draw(new Point(newSize.x - marginLeft - marginRight - 2*skin.borderThickness, newSize.y - titleHeight - marginTop - marginBottom - skin.borderThickness));
			
			// Устанавливаем текстовое поле
			tf.x = -2;// Вынужденное шаманство из-за разницы в 3px с настоящей шириной текстового поля
			tf.y = -3;
			switch (_titleAlign) {
				case Align.LEFT:
					tf.x += skin.borderThickness + skin.titleMarginLeft;
					break;
				case Align.CENTER:
					tf.x += Math.round((size.x - titleWidth)/2);
					break;
				case Align.RIGHT:
					tf.x += size.x - skin.borderThickness - skin.titleMarginRight - titleWidth;
					break; 	
			}
						
			// Сохраняем размер
			_currentSize = size.clone();
			
			// Перерисовываем рамку (выравнивая по нижней части контейнера)
			arrangeGraphics(new Point(size.x, size.y - Math.floor((titleHeight - skin.borderThickness)*0.5)));
		}
		
		/**
		 * @private
		 * Перерисовка частей графики
		 * @param size размер рамки
		 */		
		protected function arrangeGraphics(size:Point):void {
			
			// Расставляем углы
			cTLbmp.y = _currentSize.y - size.y;
			
			cTRbmp.x = size.x - cTRbmp.width;
			cTRbmp.y = cTLbmp.y;
			
			cBLbmp.y = _currentSize.y - cBLbmp.height;
			
			cBRbmp.x = cTRbmp.x;
			cBRbmp.y = cBLbmp.y;
			
			// Верхняя полоска
			eTCbmpBefore.y = cTLbmp.y;
			eTCbmpAfter.y = cTLbmp.y;
			eTCbmpLeft.y = cTLbmp.y;
			eTCbmpRight.y = cTLbmp.y;
			eTCbmpBefore.x = tf.x + 2 - eTCbmpBefore.width - 1;// Вынужденное шаманство на 3px из-за странности текстовых полей
			eTCbmpAfter.x = tf.x + 2 + titleWidth + 1;
			eTCbmpLeft.x = cTLbmp.width;
			eTCbmpLeft.width = eTCbmpBefore.x - eTCbmpLeft.x;
			eTCbmpRight.x = eTCbmpAfter.x + eTCbmpAfter.width;
			eTCbmpRight.width = cTRbmp.x - eTCbmpRight.x;
			
			// Ширина без углов
			var newWidth:int = size.x - cTLbmp.width - cTRbmp.width;
			var newHeight:int = size.y - cTLbmp.height - cBLbmp.height;
			
			eMLbmp.y = cTLbmp.y + cTLbmp.height;
			eMLbmp.height = newHeight;
			
			eMRbmp.x = cTRbmp.x;
			eMRbmp.y = cTRbmp.y + cTRbmp.height;
			eMRbmp.height = newHeight;
			
			eBCbmp.x = cBLbmp.width;
			eBCbmp.y = cBLbmp.y;
			eBCbmp.width = newWidth;
		}
		
	}
}