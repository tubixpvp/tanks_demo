package alternativa.gui.container.scrollBox {
	import alternativa.gui.container.WidgetContainer;
	import alternativa.gui.init.GUI;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.ScrollMode;
	import alternativa.gui.skin.container.scrollBox.ScrollBoxSkin;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Скроллируемый контейнер 
	 */	
	public class ScrollBox extends WidgetContainer {
		
		/**
		 * @private
		 * Скин 
		 */		
		protected var skin:ScrollBoxSkin;
		
		/**
		 * Верхний-левый угол рамки
		 */
		private var tl:Bitmap;
		/**
		 * Верхний край рамки
		 */
		private var tc:Bitmap;
		/**
		 * Верхний-правый угол рамки 
		 */
		private var tr:Bitmap;
		/**
		 * Левый край рамки
		 */
		private var ml:Bitmap;
		/**
		 * Фон
		 */		
		private var mc:Bitmap;
		/**
		 * Правый край рамки
		 */
		private var mr:Bitmap;
		/**
		 * Нижний-левый угол рамки 
		 */
		private var bl:Bitmap;
		/**
		 * Нижний край рамки
		 */
		private var bc:Bitmap;
		/**
		 * Нижний-правый угол рамки 
		 */
		private var br:Bitmap;
		
		/**
		 * @private
		 * Режим скроллирования по вертикали 
		 */		
		protected var scrollVerticalMode:int;
		/**
		 * @private
		 * Режим скроллирования по горизонтали
		 */
		protected var scrollHorizontalMode:int;
		
		/**
		 * @private
		 * Вертикальный скроллбар
		 */		
		protected var scrollBarVertical:ScrollBar;
		/**
		 * @private
		 * Горизонтальный скроллбар
		 */		
		protected var scrollBarHorizontal:ScrollBar;
		
		/**
		 * @private
		 * Уголок между скроллбарами
		 */		
		protected var scrollCorner:Bitmap;
		
		/**
		 * @private
		 * Наличие вертикального скроллбара
		 */		
		protected var scrollVertical:Boolean = false;
		/**
		 * @private
		 * Наличие горизонтального скроллбара
		 */		
		protected var scrollHorizontal:Boolean = false;
		
		/**
		 * @private
		 * Постоянное наличие вертикального скроллбара
		 */		
		protected var showVertical:Boolean = false;
		/**
		 * @private
		 * Постоянное наличие горизонтального скроллбара
		 */		
		protected var showHorizontal:Boolean = false;
		
		/**
		 * @private
		 * Вычитаемое для computerSize при отсутствии скроллбаров 
		 */		
		protected var subtrahend:Point;
		/**
		 * @private
		 * Вычитаемое для computerSize при наличии горизонтального скроллбара
		 */
		protected var subtrahendH:Point;
		/**
		 * @private
		 * Вычитаемое для computerSize при наличии вертикального скроллбара
		 */
		protected var subtrahendV:Point;
		/**
		 * @private
		 * Вычитаемое для computerSize при наличии обоих скроллбаров
		 */
		protected var subtrahendHV:Point;
		
		/**
		 * @private
		 * Минимальный размер при наличии горизонтального скроллбара
		 */		
		protected var minScrollSizeH:Point;
		/**
		 * @private
		 * Минимальный размер при наличии вертикального скроллбара
		 */
		protected var minScrollSizeV:Point;
		/**
		 * @private
		 * Минимальный размер при наличии обоих скроллбаров
		 */
		protected var minScrollSizeHV:Point;
		/**
		 * @private
		 * Минимальная ширина, рассчитаная в computeMinSize 
		 */		
		protected var minWidth:int;
		/**
		 * @private
		 * Минимальная высота, рассчитаная в computeMinSize 
		 */
		protected var minHeight:int;
		
		/**
		 * Рисовать или нет фон
		 */
		protected var bgEnable:Boolean = true;
		
		/**
		 * @private
		 * Полный размер контента
		 */		
		protected var contentFullSize:Point;
		/**
		 * @private
		 * Размер видимой области
		 */
		protected var viewSize:Point;
		
		/**
		 * @private
		 * Размер и координаты маски 
		 */		
		protected var canvasMaskRect:Rectangle;
		
		//public var containerBorder:Shape;
		
		
		/**
		 * @param minWidth минимальная ширина
		 * @param minHeight минимальная высота
		 * @param scrollHorizontalMode режим скроллирования по горизонтали
		 * @param scrollVerticalMode режим скроллирования по вертикали
		 * @param step шаг скроллирования
		 * @param marginLeft отступ слева
		 * @param marginTop отступ сверху
		 * @param marginRight отступ справа
		 * @param marginBottom отступ снизу
		 */		
		public function ScrollBox(minWidth:int = 0,
								  minHeight:int = 0,
								  scrollHorizontalMode:int = ScrollMode.SHOW,
								  scrollVerticalMode:int = ScrollMode.SHOW,
								  step:int = 1,
								  marginLeft:int = 0,
								  marginTop:int = 0,
								  marginRight:int = 0,
								  marginBottom:int = 0) {
								  	
			super(marginLeft, marginTop, marginRight, marginBottom);
			
			_sidesCorrelated = true;
			
			minSize.x = minWidth;
			minSize.y = minHeight;
			
			// Создаём фон
			tl = new Bitmap();
			tc = new Bitmap();
			tr = new Bitmap();
			ml = new Bitmap();
			mc = new Bitmap();
			mr = new Bitmap();
			bl = new Bitmap();
			bc = new Bitmap();
			br = new Bitmap();
			
			// Добавляем фон в себя в самый низ
			addChildAt(tl, 0);
			addChildAt(tc, 0);
			addChildAt(tr, 0);
			addChildAt(ml, 0);
			addChildAt(mc, 0);
			addChildAt(mr, 0);
			addChildAt(bl, 0);
			addChildAt(bc, 0);
			addChildAt(br, 0);
			
			// Разбираем режим скроллирования по вертикали
			this.scrollVerticalMode = scrollVerticalMode;
			
			if (scrollVerticalMode != ScrollMode.NONE) {
				scrollVertical = true;
				if (scrollVerticalMode == ScrollMode.SHOW) {
					showVertical = true;
				} 
				scrollBarVertical = new ScrollBar(Direction.VERTICAL);
				scrollBarVertical.addEventListener(Event.SCROLL, onScrollVertical);
				scrollBarVertical.visible = showVertical;
				addChild(scrollBarVertical);
			}
			
			// Разбираем режим скроллирования по горизонтали
			this.scrollHorizontalMode = scrollHorizontalMode;
			
			if (scrollHorizontalMode != ScrollMode.NONE) {
				scrollHorizontal = true;
				if (scrollHorizontalMode == ScrollMode.SHOW) {
					showHorizontal = true;
				} 
				scrollBarHorizontal = new ScrollBar(Direction.HORIZONTAL);
				scrollBarHorizontal.addEventListener(Event.SCROLL, onScrollHorizontal);
				scrollBarHorizontal.visible = showHorizontal;
				addChild(scrollBarHorizontal);
			}
			if (scrollVertical || scrollHorizontal) {
				// Добавляем маску
				canvasMaskRect = new Rectangle(0, 0, 0, 0);
				// Добавляем уголок
				scrollCorner = new Bitmap();
				scrollCorner.visible = showVertical && showHorizontal;
				addChild(scrollCorner);
			}
			
// Для вспомогательной отрисовки
			//containerBorder = new Shape();
			//addChild(containerBorder);
			
			// Во viewSize хранится размер видимой области (скроллируемой)
			viewSize = new Point();
			contentFullSize = new Point();
		}
		
		/**
		 * Обновить скин 
		 */	
		override public function updateSkin():void {
			skin = ScrollBoxSkin(skinManager.getSkin(ScrollBox));
			
			if (scrollVertical) {
				scrollBarVertical.y = skin.borderThickness;
			}
			if (scrollHorizontal) {
				scrollBarHorizontal.x = skin.borderThickness;
			}
			if (scrollCorner != null)
				scrollCorner.bitmapData = skin.corner;
			
			if (scrollVertical || scrollHorizontal) {
				canvas.x = skin.borderThickness;
				canvas.y = skin.borderThickness;
			} else {
				canvas.x = skin.borderThickness + _marginLeft;
				canvas.y = skin.borderThickness + _marginTop;
			}
			subtrahend = new Point(2*skin.borderThickness, 2*skin.borderThickness);
			if (scrollHorizontal) {
				subtrahendH = new Point(2*skin.borderThickness, 2*skin.borderThickness + scrollBarHorizontal.thickness);
				minScrollSizeH = new Point(scrollBarHorizontal.minLength + 2*skin.borderThickness, 0);	
			}
			if (scrollVertical) {
				subtrahendV = new Point(2*skin.borderThickness + scrollBarVertical.thickness, 2*skin.borderThickness);
				minScrollSizeV = new Point(0, scrollBarVertical.minLength + 2*skin.borderThickness);
			}
			if (scrollHorizontal && scrollVertical) {
				subtrahendHV = new Point(2*skin.borderThickness + scrollBarVertical.thickness, 2*skin.borderThickness + scrollBarHorizontal.thickness);
				minScrollSizeHV = new Point(scrollBarHorizontal.minLength + scrollCorner.width + 2*skin.borderThickness, scrollBarVertical.minLength + scrollCorner.height + 2*skin.borderThickness);			
			}
			
			super.updateSkin();
			switchState();
		}
		
		
		/**
		 * Расчет минимальных размеров контейнера
		 * @return минимальные размеры
		 */
		override public function computeMinSize():Point {
			//trace("ScrollBox computeMinSize");
			var newSize:Point = new Point();
			
			var contentMinSize:Point = getContentMinSize();
			
			if (scrollVertical || scrollHorizontal) {
				if (scrollHorizontal) {
					if (scrollVertical) {
						if (showVertical) {
							if (showHorizontal) {
								// SHOW - SHOW
								newSize = new Point(_marginLeft + _marginRight, _marginTop + _marginBottom).add(subtrahendHV);
								newSize.x = Math.max(newSize.x, minScrollSizeHV.x);
								newSize.y = Math.max(newSize.y, minScrollSizeHV.y);
							} else {
								// AUTO - SHOW
								if ((_currentSize.x - 2*skin.borderThickness) >= contentMinSize.x) {
									newSize = new Point(_marginLeft + _marginRight, _marginTop + _marginBottom).add(subtrahendV);
									newSize.y = Math.max(newSize.y, minScrollSizeV.y);
								} else {
									newSize = new Point(_marginLeft + _marginRight, _marginTop + _marginBottom).add(subtrahendHV);
									newSize.x = Math.max(newSize.x, minScrollSizeHV.x);
									newSize.y = Math.max(newSize.y, minScrollSizeHV.y);
									scrollBarHorizontal.visible = true;
								}
							}
						} else {
							if (showHorizontal) {
							// SHOW - AUTO
								if ((_currentSize.y - 2*skin.borderThickness) >= contentMinSize.y) {
									newSize = new Point(_marginLeft + _marginRight, _marginTop + _marginBottom).add(subtrahendH);
									newSize.x = Math.max(newSize.x, minScrollSizeH.x);
								} else {
									newSize = new Point(_marginLeft + _marginRight, _marginTop + _marginBottom).add(subtrahendHV);
									newSize.x = Math.max(newSize.x, minScrollSizeHV.x);
									newSize.y = Math.max(newSize.y, minScrollSizeHV.y);
									scrollBarVertical.visible = true;
								}
							} else {
							// AUTO - AUTO
								if ((_currentSize.x - 2*skin.borderThickness) >= contentMinSize.x) {
									if ((_currentSize.y - 2*skin.borderThickness) >= contentMinSize.y) {
										newSize = new Point(_marginLeft + _marginRight, _marginTop + _marginBottom).add(subtrahend);
									} else {
										newSize = new Point(_marginLeft + _marginRight, _marginTop + _marginBottom).add(subtrahendV);
										newSize.y = Math.max(newSize.y, minScrollSizeV.y);
										scrollBarVertical.visible = true;
									}
								} else {
									scrollBarHorizontal.visible = true;
									if ((_currentSize.y - 2*skin.borderThickness) >= contentMinSize.y) {
										newSize = new Point(_marginLeft + _marginRight, _marginTop + _marginBottom).add(subtrahendH);
										newSize.x = Math.max(newSize.x, minScrollSizeH.x);
									} else {
										newSize = new Point(_marginLeft + _marginRight, _marginTop + _marginBottom).add(subtrahendHV);
										newSize.x = Math.max(newSize.x, minScrollSizeHV.x);
										newSize.y = Math.max(newSize.y, minScrollSizeHV.y);
										scrollBarVertical.visible = true;
									}
								}
							}
						}
					} else {
						if (showHorizontal) {
							// SHOW - NONE
							newSize = new Point(_marginLeft + _marginRight, contentMinSize.y).add(subtrahendH);
							newSize.x = Math.max(newSize.x, minScrollSizeH.x);
						} else {
							// AUTO - NONE
							if ((_currentSize.x - 2*skin.borderThickness) >= contentMinSize.x) {
								newSize = new Point(_marginLeft + _marginRight, contentMinSize.y).add(subtrahend);
							} else {
								newSize = new Point(_marginLeft + _marginRight, contentMinSize.y).add(subtrahendH);
								newSize.x = Math.max(newSize.x, minScrollSizeH.x);
								scrollBarHorizontal.visible = true;
							}
						}
					}
				} else {
					if (showVertical) {
						// NONE - SHOW
						newSize = new Point(contentMinSize.x, _marginTop + _marginBottom).add(subtrahendV);
						newSize.y = Math.max(newSize.y, minScrollSizeV.y);
					} else {
						// NONE - AUTO
						if ((_currentSize.y - 2*skin.borderThickness) >= contentMinSize.y) {
							newSize = new Point(contentMinSize.x, _marginTop + _marginBottom).add(subtrahend);
						} else {
							newSize = new Point(contentMinSize.x, _marginTop + _marginBottom).add(subtrahendV);
							newSize.y = Math.max(newSize.y, minScrollSizeV.y);
							scrollBarVertical.visible = true;
						}
					}
				}
			} else {
				// NONE - NONE
				newSize = contentMinSize.add(subtrahend);
			}
			newSize.x = Math.max(newSize.x, _minSize.x);
			newSize.y = Math.max(newSize.y, _minSize.y);
			
			minWidth = newSize.x;
			minHeight = newSize.y;
			
			//trace("ScrollBox computeMinSize newSize: " + newSize);
			minSizeChanged = false;
			return newSize;
		}
		
		/**
		 * Расчет предпочтительных размеров контейнера с учетом заданных
		 * @param size заданные размеры
		 * @return предпочтительные размеры
		 */
		override public function computeSize(size:Point):Point {
			//trace("ScrollBox computeSize size: " + size);
			var newSize:Point = new Point();
			// Проверка на минимум
			newSize.x = isStretchable(Direction.HORIZONTAL) ? Math.max(size.x, _minSize.x, minWidth) : Math.max(_minSize.x, minWidth);
			newSize.y = isStretchable(Direction.VERTICAL) ? Math.max(size.y, _minSize.y, minHeight) : Math.max(_minSize.y, minHeight);
			//newSize.x = isStretchable(Direction.HORIZONTAL) ? Math.max(size.x, _minSize.x) : _minSize.x;
			//newSize.y = isStretchable(Direction.VERTICAL) ? Math.max(size.y, _minSize.y) : _minSize.y;
			
			if (scrollVertical || scrollHorizontal) {
				
				if (scrollHorizontal) {
					// Скроллируем по горизонтали
					if (scrollVertical) {
						// Скроллируем по обеим сторонам
						if (showVertical) {
							// Вертикальный скроллер есть всегда
							if (showHorizontal) {
								// SHOW - SHOW
								// Оба скроллера есть всегда
								viewSize = newSize.subtract(subtrahendHV);
								contentFullSize = getContentFullSize(viewSize);
							} else {
								// AUTO - SHOW
								viewSize = newSize.subtract(subtrahendV);
								contentFullSize = getContentFullSize(viewSize);
								// Проверка на появление горизонтального скроллера
								if (contentFullSize.x > viewSize.x) {
									if (!scrollBarHorizontal.visible) {
										scrollBarHorizontal.visible = true;
									}
									viewSize = newSize.subtract(subtrahendHV);
									contentFullSize = getContentFullSize(viewSize);
								} else {
									if (scrollBarHorizontal.visible) {
										scrollBarHorizontal.visible = false;
									}
								}
							}
						} else {
							if (showHorizontal) {
								// SHOW - AUTO 
								// Горизонтальный скроллер есть всегда
								viewSize = newSize.subtract(subtrahendH);
								contentFullSize = getContentFullSize(viewSize);
								
								// Проверка на появление вертикального скроллера
								if (contentFullSize.y > viewSize.y) {
									if (!scrollBarHorizontal.visible) {
										scrollBarVertical.visible = true;
									}
									viewSize = newSize.subtract(subtrahendHV);
									contentFullSize = getContentFullSize(viewSize);
								} else {
									if (scrollBarHorizontal.visible) {
										scrollBarVertical.visible = false;
									}
								}
							} else {
								// AUTO - AUTO 
								viewSize = newSize.subtract(subtrahend);
								contentFullSize = getContentFullSize(viewSize);
								// проверка на появление горизонтального скроллера
								if (contentFullSize.x > viewSize.x) {
									if (!scrollBarHorizontal.visible) {
										minSizeChanged = true;
										scrollBarHorizontal.visible = true;
									}
									viewSize = newSize.subtract(subtrahendH);
									contentFullSize = getContentFullSize(viewSize);
									
									// проверка на появление вертикального скроллера
									if (contentFullSize.y > viewSize.y) {
										if (!scrollBarVertical.visible) {
											minSizeChanged = true;
											scrollBarVertical.visible = true;
										}
										viewSize = newSize.subtract(subtrahendHV);
										contentFullSize = getContentFullSize(viewSize);
									} else {
										if (scrollBarVertical.visible) {
											minSizeChanged = true;
											scrollBarVertical.visible = false;
										}
									}
								} else {
									if (scrollBarHorizontal.visible) {
										minSizeChanged = true;
										scrollBarHorizontal.visible = false;
									}
									// проверка на появление вертикального скроллера
									if (contentFullSize.y > viewSize.y) {
										if (!scrollBarVertical.visible) {
											minSizeChanged = true;
											scrollBarVertical.visible = true;
										}
										viewSize = newSize.subtract(subtrahendV);
										contentFullSize = getContentFullSize(viewSize);
									} else {
										if (scrollBarVertical.visible) {
											minSizeChanged = true;
											scrollBarVertical.visible = false;
										}
									}
								}		
							}
						}
					} else {
						// вертикального скроллера точно нет
						if (showHorizontal) {
							// SHOW - NONE
							// горизонтальный скроллер есть всегда
							viewSize = newSize.subtract(subtrahendH);
							contentFullSize = getContentFullSize(viewSize);
							newSize.y = contentFullSize.y + scrollBarHorizontal.thickness + 2*skin.borderThickness;
						} else {
							// AUTO - NONE
							contentFullSize = getContentFullSize(newSize.subtract(new Point(2*skin.borderThickness, 2*skin.borderThickness)));
							
							viewSize.x = newSize.x - 2*skin.borderThickness;
							// проверка на появление горизонтального скроллера
							if (contentFullSize.x > viewSize.x) {
								if (!scrollBarHorizontal.visible) {
									minSizeChanged = true;
									scrollBarHorizontal.visible = true;
								}
								contentFullSize = getContentFullSize(newSize.subtract(new Point(2*skin.borderThickness, 2*skin.borderThickness + scrollBarHorizontal.thickness)));
								viewSize.y = contentFullSize.y;
								newSize.y = contentFullSize.y + scrollBarHorizontal.thickness + 2*skin.borderThickness;
								
							} else {
								if (scrollBarHorizontal.visible) {
									minSizeChanged = true;
									scrollBarHorizontal.visible = false;
								}
								viewSize.y = contentFullSize.y;
								newSize.y = contentFullSize.y + 2*skin.borderThickness;
							}
						}
					}
				} else {
					// горизонтального скроллера точно нет
					// значит скроллируем по вертикали
					if (showVertical) {
						// NONE - SHOW
						// вертикальный скроллер есть всегда
						viewSize = newSize.subtract(subtrahendV);
						contentFullSize = getContentFullSize(viewSize);
						newSize.x = contentFullSize.x + scrollBarVertical.thickness + 2*skin.borderThickness;
					} else {
						// NONE - AUTO
						contentFullSize = getContentFullSize(newSize.subtract(subtrahend));
						viewSize.y = newSize.y - 2*skin.borderThickness;
						// проверка на появление вертикального скроллера
						if (contentFullSize.y > viewSize.y) {
							//if (size.x > 0 && size.y > 0) {
								if (!scrollBarVertical.visible) {
									minSizeChanged = true;
									scrollBarVertical.visible = true;
								}
							//}
							contentFullSize = getContentFullSize(newSize.subtract(subtrahendV));
							viewSize.x = contentFullSize.x;
							newSize.x = contentFullSize.x + scrollBarVertical.thickness + 2*skin.borderThickness;
						} else {
							//if (size.x > 0 && size.y > 0) {
								if (scrollBarVertical.visible) {
									minSizeChanged = true;
									scrollBarVertical.visible = false;
								}
							//}
							viewSize.x = contentFullSize.x;
							newSize.x = contentFullSize.x + 2*skin.borderThickness;
						}
						
						/*viewSize = newSize.subtract(subtrahend);
						trace("viewSize: " + viewSize);
						contentFullSize = getContentFullSize(viewSize);
						trace("contentFullSize: " + contentFullSize);
						// проверка на появление вертикального скроллера
						if (contentFullSize.y > viewSize.y) {
							scrollBarVertical.visible = true;
							
							viewSize = newSize.subtract(subtrahendV);
							trace("viewSize: " + viewSize);
							contentFullSize = getContentFullSize(viewSize);
							trace("contentFullSize: " + contentFullSize);
							newSize.x = contentFullSize.x + scrollBarVertical.thickness + 2*skin.borderThickness;
							trace("newSize: " + newSize);
						} else {
							scrollBarVertical.visible = false;
						}*/
						
					}
				}
			} else {
				// NONE - NONE
				// нет ни одного скроллера
				contentFullSize = getContentFullSize(newSize.subtract(subtrahend));
				viewSize = contentFullSize.clone();
				newSize = contentFullSize.add(subtrahend);
			}
			//trace("ScrollBox computeSize newSize: " + newSize);
			return newSize;
		}
		
		/**
		 * @private
		 * Получить минимальный размер контента
		 * @return минимальный размер контента
		 */		
		protected function getContentMinSize():Point {
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
		protected function getContentFullSize(size:Point):Point {
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
		
		/**
		 * @private
		 * Отрисовка контента 
		 */		
		protected function drawContent():void {
			layoutManager.draw(new Point(contentFullSize.x - _marginLeft - _marginRight, contentFullSize.y - _marginTop - _marginBottom));
		}
		
		/**
		 * @private
		 * Установка маски
		 */		
		protected function setMask():void {
			canvasMaskRect.x = -_marginLeft + (scrollHorizontal ? scrollBarHorizontal.position : 0);
			canvasMaskRect.y = -_marginTop + (scrollVertical ? scrollBarVertical.position : 0);
			canvasMaskRect.width = viewSize.x;
			canvasMaskRect.height = viewSize.y;
			canvas.scrollRect = canvasMaskRect;
		}
		
		/**
		 * @private
		 * Отрисовка кусочков бокса
		 */		
		protected function drawBox():void {
			tc.x = tl.width;
			tc.width = _currentSize.x - tl.width - tr.width;
			tr.x = tc.x + tc.width;
		
			ml.y = tl.height;
			ml.height = _currentSize.y - tl.height - bl.height;
			mc.x = tc.x;
			mc.y = ml.y;
			mc.width = tc.width;
			mc.height = ml.height;
			mr.x = tr.x;
			mr.y = ml.y;
			mr.height = ml.height;
		
			bl.y = ml.y + ml.height;
			bc.x = tc.x;
			bc.y = bl.y;
			bc.width = tc.width;
			br.x = tr.x;
			br.y = bl.y;
		}
		
		/**
		 * Отображение состояний (перегрузка bitmap)
		 */	
		private function switchState():void {
			if (_locked) {
				tl.bitmapData = skin.ltl;
				tc.bitmapData = skin.ltc;
				tr.bitmapData = skin.ltr;
				ml.bitmapData = skin.lml;
				mc.bitmapData = skin.lmc;
				mr.bitmapData = skin.lmr;
				bl.bitmapData = skin.lbl;
				bc.bitmapData = skin.lbc;
				br.bitmapData = skin.lbr;	
			}
			else if (_over) {
				tl.bitmapData = skin.otl;
				tc.bitmapData = skin.otc;
				tr.bitmapData = skin.otr;
				ml.bitmapData = skin.oml;
				mc.bitmapData = skin.omc;
				mr.bitmapData = skin.omr;
				bl.bitmapData = skin.obl;
				bc.bitmapData = skin.obc;
				br.bitmapData = skin.obr;
			} else {
				tl.bitmapData = skin.ntl;
				tc.bitmapData = skin.ntc;
				tr.bitmapData = skin.ntr;
				ml.bitmapData = skin.nml;
				mc.bitmapData = skin.nmc;
				mr.bitmapData = skin.nmr;
				bl.bitmapData = skin.nbl;
				bc.bitmapData = skin.nbc;
				br.bitmapData = skin.nbr;				
			}
		}
		
		/**
		 * @private
		 * Обработка сколлирования по вертикали 
		 * @param e событие сколлирования
		 */		
		protected function onScrollVertical(e:Event):void {
			canvasMaskRect.y = -_marginTop + (scrollVertical ? scrollBarVertical.position : 0);
			canvas.scrollRect = canvasMaskRect;
			
			//trace("onScrollVertical scrollBarVertical.position " + scrollBarVertical.position);
			//trace("onScrollVertical scrollBarVertical.length " + scrollBarVertical.length);
		}
		/**
		 * @private
		 * Обработка сколлирования по горизонтали
		 * @param e событие сколлирования
		 */
		protected function onScrollHorizontal(e:Event):void {
			canvasMaskRect.x = -_marginLeft + (scrollHorizontal ? scrollBarHorizontal.position : 0);
			canvas.scrollRect = canvasMaskRect;
		}
		
		/**
		 * Показать точку (заданную в координатах контента) в центре скроллируемой области
		 * @param p точка (x, y)
		 */		
		/*public function lookAtPoint(p:Point):void {
			// По горизонтали
			if (scrollHorizontal) {
				var newPos:Number;
				if ((scrollBarHorizontal.length - scrollBarHorizontal.scrollerLength) == 0 || (scrollBarHorizontal.area - scrollBarHorizontal.view) == 0) {
					newPos = 0;
				} else {
					// Расчитываем позицию скроллера из координат
					newPos = (p.x/(currentScrollLength - scrollBarHorizontal.scrollerLength))*(scrollBarHorizontal.area - scrollBarHorizontal.view);
				}
				if (scrollBarHorizontal.position != newPos) {
					scrollBarHorizontal.position = newPos;
				} 
			}
			// По вертикали
		}*/	
		
		/**
		 * Флаг актуальности минимального размера
		 */
		override public function set minSizeChanged(value:Boolean):void {
			//trace("ScrollBox minSizeChanged: " + value);
			//_minSizeChanged = value;
			super.minSizeChanged = value;
		}
		
		/**
		 * Флаг наведения
		 */
		override public function set over(value:Boolean):void {
			if (_over != value) {
				super.over = value;
				if (isSkined) switchState();
				if (_over && scrollVertical && !(GUI.mouseManager.overed == scrollBarHorizontal || GUI.mouseManager.overed == scrollBarVertical)) {
					GUI.mouseManager.addMouseWheelListener(scrollBarVertical);
				} else {
					GUI.mouseManager.removeMouseWheelListener(scrollBarVertical);
				}
			}
		}
		/**
		 * Флаг блокировки
		 */
		override public function set locked(value:Boolean):void {
			if (_locked != value) {
				super.locked = value;
				if (isSkined) switchState();
			}
		}
		
		/**
		 * Внешний вид курсора при наведении на объект
		 */
		override public function get cursorOverType():uint {
			return GUI.mouseManager.cursorTypes.NORMAL;
		}
		/**
		 * Внешний вид курсора при нажатии на объект или наведении на нажатый объект
		 */
		override public function get cursorPressedType():uint {
			return GUI.mouseManager.cursorTypes.NORMAL;
		}
		
		public function get positionVertical():int {
			return scrollBarVertical.position;
		}
		public function set positionVertical(value:int):void {
			//trace("ScrollBox set positionVertical: " + value);
			scrollBarVertical.position = value;
		}
		
		public function get positionHorizontal():int {
			return scrollBarHorizontal.position;
		}
		public function set positionHorizontal(value:int):void {
			//trace("ScrollBox set positionHorizontal: " + value);
			scrollBarHorizontal.position = value;
		}
		
		public function get lengthVertical():int {
			return scrollBarVertical.scrollerLength;
		}		
		public function get lengthHorizontal():int {
			return scrollBarHorizontal.scrollerLength;
		}		
		
		public function get scrollerVerticalLength():int {
			return scrollBarVertical.scroller.length;
		}		
		public function get scrollerHorizontalLength():int {
			return scrollBarHorizontal.scroller.length;
		}		
		
	}
}