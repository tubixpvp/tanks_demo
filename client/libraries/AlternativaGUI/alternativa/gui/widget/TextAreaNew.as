package alternativa.gui.widget {
	import alternativa.gui.base.IGUIObject;
	import alternativa.gui.container.scrollBox.ScrollBox;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.ScrollMode;
	import alternativa.gui.skin.widget.LabelSkin;
	
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	
	
	public class TextAreaNew extends ScrollBox {
		
		private var tf:ActiveTextField;
		
		private var labelSkin:LabelSkin;
		
		
		public function TextAreaNew(minWidth:int = 0,
								  	minHeight:int = 0,
								  	text:String = "",
								 	align:uint = Align.LEFT,
								 	wordWrap:Boolean = true,
								 	editable:Boolean = true,
								 	maxChars:uint=0,
								  	scrollHorizontalMode:int = ScrollMode.AUTO,
								  	scrollVerticalMode:int = ScrollMode.AUTO,
								  	step:int = 1,
								  	marginLeft:int = 0,
								  	marginTop:int = 0,
								  	marginRight:int = 0,
								  	marginBottom:int = 0) {
			super(minWidth,
				  minHeight,
				  scrollHorizontalMode,
				  scrollVerticalMode,
				  step,
				  marginLeft,
				  marginTop,
				  marginRight,
				  marginBottom);
				  
			tf = new ActiveTextField();
			addChild(tf);
			
			with (tf) {
				cursorActive = editable;
				tabEnabled = editable;
				autoSize = TextFieldAutoSize.LEFT;
				antiAliasType = AntiAliasType.ADVANCED;
				embedFonts = true;
				selectable = false;
				multiline = true;
				mouseEnabled = false;
				tabEnabled = false;
				text = text;
			}
		}
		
		/**
		 * Обновить скин 
		 */	
		override public function updateSkin():void {
			super.updateSkin();
			
			labelSkin = LabelSkin(skinManager.getSkin(Label));
			
			tf.setTextFormat(labelSkin.tfNormal);
			tf.defaultTextFormat = labelSkin.tfNormal;
			if (labelSkin.filtersNormal.length > 0) {
				tf.filters = labelSkin.filtersNormal;
			}
			
			tf.x = skin.borderThickness;
			tf.y = skin.borderThickness;
		}
		
		/**
		 * @private
		 * Получить минимальный размер контента
		 * @return минимальный размер контента
		 */		
		override protected function getContentMinSize():Point {
			// Определяем размер контейнера с отступами
			var newSize:Point = Point(layoutManager.computeMinSize()).add(new Point(_marginLeft + _marginRight, _marginTop + _marginBottom));
			
			return newSize;
		}		
		
		/**
		 * @private
		 * Получить полный размер контента при заданном размере
		 * @param size заданный размер
		 * @return полный размер контента
		 */		
		override protected function getContentFullSize(size:Point):Point {
			// Определяем размер контента
			var contentSize:Point = layoutManager.computeSize(size.subtract(new Point(_marginLeft + _marginRight, _marginTop + _marginBottom)));
			// Определяем размер контейнера с отступами
			var newSize:Point = new Point(contentSize.x + _marginLeft + _marginRight, contentSize.y + _marginTop + _marginBottom);
			
			newSize.x = Math.max(size.x, newSize.x);
			newSize.y = Math.max(size.y, newSize.y);
			
			return newSize;
		}
		
		/**
		 * Отрисовка контейнера в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			//trace("ScrollBox draw size: " + size);
			_currentSize = size.clone();
			
			// Отрисовка рамки
			if (bgEnable) {	
				drawBox();
			}
			// Отрисовка контента
			drawContent();
			
			// Если есть скролл
			if (scrollVertical || scrollHorizontal) {
				// Установка маски
				setMask();
				
				// Размещение скроллеров
				if (scrollVertical && scrollBarVertical.visible) {
					scrollBarVertical.length = viewSize.y;
					
					scrollBarVertical.x = viewSize.x + skin.borderThickness;
					scrollBarVertical.area = contentFullSize.y;
					scrollBarVertical.view = viewSize.y;
					scrollBarVertical.position = -(skin.borderThickness - canvasMaskRect.y - skin.borderThickness - _marginTop);
				}
				if (scrollHorizontal && scrollBarHorizontal.visible) {
					scrollBarHorizontal.length = viewSize.x;
					
					scrollBarHorizontal.y = viewSize.y + skin.borderThickness;
					scrollBarHorizontal.area = contentFullSize.x;
					scrollBarHorizontal.view = viewSize.x;
					scrollBarHorizontal.position = -(skin.borderThickness - canvasMaskRect.x - skin.borderThickness - _marginLeft);
				}
				// Размещение углового квадрата
				if (scrollCorner != null) {
					if (scrollVertical && scrollHorizontal)
						scrollCorner.visible = scrollBarVertical.visible && scrollBarHorizontal.visible;
					else
						scrollCorner.visible = false;
					scrollCorner.x = viewSize.x + skin.borderThickness;
					scrollCorner.y = viewSize.y + skin.borderThickness;
				}
			}
			
			
			// Границы viewSize и contentFullSize
			/*with (containerBorder.graphics) {
				clear();
				
				lineStyle(1, 0x0000cc, 1);
				drawRect(skin.borderThickness, skin.borderThickness, contentFullSize.x-1, contentFullSize.y-1);
				
				lineStyle(1, 0xcc0066, 1);
				drawRect(skin.borderThickness, skin.borderThickness, viewSize.x-1, viewSize.y-1);
			}*/
		}
		
		override protected function focus():void {
			// если фокус на нас - то переадресуем его тексту
			stage.focus = tf;						
		}
		
		override public function addObject(object:IGUIObject):void {}
		
		override public function addObjectAt(object:IGUIObject, index:int):void {}
		
		public function set text(value:String):void {
			tf.text = value;
		}

		public function get text():String {
			return tf.text;
		}

	}
}