package alternativa.gui.window {
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.WindowAlign;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TabbedWindowBase extends WindowBase {
		
		// Список табов (контейнеров)
		protected var tabList:Array;
		// Индекс активной вкладки
		protected var activeTabIndex:int = -1;
		
		private var tc:Sprite;
	
	
		public function TabbedWindowBase(minWidth:uint = 0, minHeight:uint = 0, resizeEnabled:Boolean = true, titled:Boolean = true, title:String = "", closeable:Boolean = true, minimizeable:Boolean = false, maximizeable:Boolean = false, screenAlign:int = WindowAlign.NONE) {
			super(minWidth, minHeight, resizeEnabled, titled, title, closeable, minimizeable, maximizeable, screenAlign);
			
			// Создаём список вкладок
			tabList = new Array();
			
			tc = new Sprite();
			tc.mouseEnabled = false;
			tc.mouseChildren = false;
			tc.tabEnabled = false;
			tc.tabChildren = false;
		}
		
		override protected function createTitle(contentContainer:Container, titleString:String, closeable:Boolean, minimizeable:Boolean, maximizeable:Boolean):WindowTitleBase {
			return null;
		}
		
		/**
		 * Добавление вкладки
		 * @param tab
		 */		
		public function addTab(tab:Container, title:String, closeable:Boolean):void {
			// Создание и сохранение заголовка
			var tabTitle:WindowTitleBase = new WindowTitleBase(tab, title, closeable, false, false);
			tabTitle.parentWindow = this;
			tabList.push({title:tabTitle, tab:tab});
			
			// Добавление заголовка и подписка обработчиков
			addTitle(tabTitle);
			tabTitle.addEventListener(WindowTitleEvent.SELECT, onTabSelect);
			tabTitle.addEventListener(WindowTitleEvent.CLOSE, onTabClose);
			
			// Если вкладок ещё нет, делаем добавленную активной
			if (tabList.length == 1) {
				setActiveTab(tab);
				//tabTitle.titleAlign = Align.LEFT;
			} else {
				if (tabList.length == 2)
					tabList[0].title.titleAlign = Align.CENTER;
				tabTitle.titleAlign = Align.CENTER;
				if (isSkined)
					repaintCurrentSize();
			}
		}
		
		/**
		 * Удаление вкладки
		 * @param tab
		 * 
		 */		
		public function removeTab(tab:Container):void {
			for each (var i:Object in tabList) {
				if (i.tab == tab) {
					var index:int = tabList.indexOf(i);
					
					// Удаление заголовка вкладки
					tabTitleContainer.removeObject(i.title);
					// Удаление из списка вкладок
					tabList.splice(index, 1);
					
					// Если вкладок больше нет
					if (tabList.length == 0) {
						// Закрытие окна
						
					} else { // Вкладки ещё есть
						//Если осталась одна
						if (tabList.length == 1) {
							setActiveTab(tabList[0].tab);
							tabList[0].title.titleAlign = Align.LEFT;
						} else {
							// Если вкладка активная
							if (i.title.active) {
								// Удаление старого контента
								container.removeObject(i.tab);
								// Установка активной вкладки
								if (index < tabList.length)
									setActiveTab(tabList[index].tab);
								else 
									setActiveTab(tabList[tabList.length-1].tab);
							}	
						}						
						repaintCurrentSize();
					}
				}
			}
		}
		
		/**
		 * Установка активной вкладки
		 * (и загрузка её содержимого в контейнер контента)
		 * @param tab контейнер контента
		 */		
		public function setActiveTab(tab:Container):void {
			// Удаление старого контента
			container.removeObjects();
			for each (var i:Object in tabList) {
				if (i.tab == tab) {
					// Установка активного заголовка
					i.title.active = true;
					moveArea = i.title;
					activeTabIndex = tabList.indexOf(i);
					// Загрузка контента
					container.addObject(tab);
				} else {
					i.title.active = false;
				}
				//if (GUIObject(i.title).isSkined)
					//ICursorActive(i.title).setNormalState();
			}
			if (isSkined)
				repaintCurrentSize();
		}
		
		// Загрузка битмап из скина при его обновлении
		override protected function loadBitmaps():void {
			/*if (skin.titleMargin != 0) {
				cTLbmp.bitmapData = GameWindowSkin(skin).cornerTLmargin;
			} else {
				if (tabList.length <= 1) {
					cTLbmp.bitmapData = GameWindowSkin(skin).cornerTLactive;
				} else {
					if (activeTabIndex == 0) {
						cTLbmp.bitmapData = GameWindowSkin(skin).cornerTLactive;
					} else {
						cTLbmp.bitmapData = skin.cornerTL;
					}
				}
			}*/
			cTLbmp.bitmapData = skin.cornerTL;
			tc.x = cTLbmp.width;
			
			cTRbmp.bitmapData = skin.cornerTR;
			cBLbmp.bitmapData = skin.cornerBL;
			cBRbmp.bitmapData = skin.cornerBR;
			
			eMLbmp.bitmapData = skin.edgeML;
			eMRbmp.bitmapData = skin.edgeMR;
			eBCbmp.bitmapData = skin.edgeBC;
			bgbmp.bitmapData = skin.bgMC;
		}
		
		// Перерисовка частей графики (на входе размеры окна без заголовка)
		override protected function arrangeGraphics(size:Point):void {
			var w1:int;
			var w2:int;
			var w3:int;
			var cornersWidth:int = skin.cornerTL.width + skin.cornerTR.width;
			var buttonsContainerWidth:int = controlButtonContainer.currentSize.x;
			var h:int = skin.edgeTC.height;
			
			if (tabList.length <= 1) {
				// Одна вкладка
				if (skin.titleMargin == 0) {
					cTLbmp.bitmapData = skin.cornerTLactive;
					if (buttonsContainerWidth != 0)
						cTRbmp.bitmapData = skin.cornerTRmargin;
					else 
						cTRbmp.bitmapData = skin.cornerTRactive;
					w1 = 0;
					w2 = size.x - buttonsContainerWidth - skin.cornerTL.width - skin.borderThickness;
					w3 = 0;
					if (buttonsContainerWidth != 0) {
						w3 = buttonsContainerWidth + skin.borderThickness - skin.cornerTR.width;
					}
				} else {
					cTLbmp.bitmapData = skin.cornerTLmargin;
					cTRbmp.bitmapData = skin.cornerTRmargin;
					w1 = skin.titleMargin - skin.cornerTL.width + skin.borderThickness;
					w2 = WindowTitleBase(tabList[0].title).currentSize.x - skin.borderThickness*2;
					w3 = size.x - w1 - w2 - cornersWidth;
				}
			} else {
				// Несколько вкладок
				if (activeTabIndex == 0) {
					// Активна 1-я вкладка
					if (skin.titleMargin == 0) {
						cTLbmp.bitmapData = skin.cornerTLactive;
						if (buttonsContainerWidth != 0)
							cTRbmp.bitmapData = skin.cornerTRmargin;
						else 
							cTRbmp.bitmapData = skin.cornerTR;
						w1 = 0;
						w2 = WindowTitleBase(tabList[0].title).currentSize.x - skin.cornerTL.width - skin.borderThickness;
						w3 = size.x - w1 - w2 - cornersWidth;
						if (buttonsContainerWidth != 0) {
							w3 += buttonsContainerWidth;
						}
					} else { 
						cTLbmp.bitmapData = skin.cornerTLmargin;
						cTRbmp.bitmapData = skin.cornerTRmargin;
						w1 = skin.titleMargin - skin.cornerTL.width + skin.borderThickness;
						w2 = WindowTitleBase(tabList[0].title).currentSize.x - skin.borderThickness*2;
						w3 = size.x - w1 - w2 - cornersWidth;
					}
				} else {
					if (skin.titleMargin == 0) 
						cTLbmp.bitmapData = skin.cornerTL;
					else
						cTLbmp.bitmapData = skin.cornerTLmargin;
					if (activeTabIndex == tabList.length-1) {
						// Активна последняя вкладка
						if (skin.titleMargin == 0) {
							if (buttonsContainerWidth == 0)
								cTRbmp.bitmapData = skin.cornerTRactive;
							else
								cTRbmp.bitmapData = skin.cornerTRmargin;
							w1 = WindowTitleBase(tabList[activeTabIndex].title).x - skin.cornerTL.width + skin.borderThickness;
							w2 = WindowTitleBase(tabList[activeTabIndex].title).currentSize.x - skin.borderThickness*2;
							w3 = size.x - w1 - w2 - cornersWidth;
						} else {
							cTRbmp.bitmapData = skin.cornerTRmargin;
							w1 = WindowTitleBase(tabList[activeTabIndex].title).x + (skin.titleMargin - skin.cornerTL.width) + skin.borderThickness;
							w2 = WindowTitleBase(tabList[activeTabIndex].title).currentSize.x - skin.borderThickness*2;
							w3 = size.x - w1 - w2 - cornersWidth + buttonsContainerWidth;
						}
					} else {
						// Активна вкладка в середине
						if (buttonsContainerWidth == 0)
							if (skin.titleMargin == 0)
								cTRbmp.bitmapData = skin.cornerTR;
							else
								cTRbmp.bitmapData = skin.cornerTRmargin;
						else
							cTRbmp.bitmapData = skin.cornerTRmargin;
						w1 = skin.borderThickness - skin.cornerTL.width;
						if (skin.titleMargin != 0) 
							w1 += skin.titleMargin;
						for (var i:int = 0; i < activeTabIndex; i++) {
							w1 += WindowTitleBase(tabList[i].title).currentSize.x + skin.titleSpace;
						}
						w2 = WindowTitleBase(tabList[activeTabIndex].title).currentSize.x - skin.borderThickness*2;
						w3 = size.x - w1 - w2 - cornersWidth;
					}
				}
			}
			tc.graphics.clear();
			tc.graphics.beginBitmapFill(skin.edgeTCactive);
			tc.graphics.drawRect(w1, 0, w2, h);
			
			tc.graphics.beginBitmapFill(skin.edgeTC);
			tc.graphics.drawRect(0, 0, w1, h);
			tc.graphics.drawRect(w1 + w2, 0, w3, h);
			
			var tcBd:BitmapData = new BitmapData(size.x - skin.cornerTL.width - skin.cornerTR.width, skin.edgeTC.height, false, 0xff0000);
			tcBd.draw(tc);
			tcBd.draw(tc, null, null, null, new Rectangle(0, 0, tcBd.width, tcBd.height));
			
			eTCbmp.bitmapData = tcBd;
			
			super.arrangeGraphics(size);
		}
		
		private function onTabSelect(e:WindowTitleEvent):void {
			setActiveTab(getTabByTitle(WindowTitleBase(e.target)));
		}		
		
		public function getTabByTitle(title:WindowTitleBase):Container {
			var tab:Container;
			for each (var i:Object in tabList) {
				if (i.title == title) {
					tab = i.tab;
				}
			}
			return tab;
		}

		public function getTitleByTab(tab:Container):WindowTitleBase {
			var title:WindowTitleBase;
			for each (var i:Object in tabList) {
				if (i.tab == tab) {
					title = i.title;
				}
			}
			return title;
		}
		
		protected function onTabClose(e:WindowTitleEvent):void {}	
		
	}
}