package alternativa.gui.widget.colorSelector {
	import alternativa.gui.container.Container;
	import alternativa.gui.container.group.PanelGroup;
	import alternativa.gui.init.GUI;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.skin.widget.ColorSelectorSkin;
	import alternativa.gui.skin.widget.button.ButtonSkin;
	import alternativa.gui.skin.window.WindowSkin;
	import alternativa.gui.widget.button.Button;
	import alternativa.gui.window.WindowBase;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	
	public class PalletteColorSelector extends Button {
		
		private var _pallette:ColorPallette;
		
		// Шкурка
		protected var selectorSkin:ColorSelectorSkin;
		private var buttonSkin:ButtonSkin;
		private var windowSkin:WindowSkin;
		
		// Контейнер для элементов поверх окна
		protected var selectorContainer:PanelGroup;
		
		// Битмап для отображения выбранного цвета на кнопке
		private var selectedColorBd:BitmapData;
		
		// Выбранный цвет
		private var _selectedColor:uint;
		
		
		public function PalletteColorSelector(pallette:ColorPallette, selectedColor:uint) {
			super("", null, Align.CENTER);
			_pallette = pallette;
			_selectedColor = selectedColor;
			
			hint = hexString(_selectedColor);
			
			// Диалоговое "окно"
			selectorContainer = new PanelGroup();
			selectorContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.TOP, 3);
			// Тень
			selectorContainer.filters = new Array(new DropShadowFilter(4, 70, 0, 1, 4, 4, 0.3, BitmapFilterQuality.MEDIUM));
			
			// Наполнение компонентами
			addComponents();
		}
		
		override public function updateSkin():void {
			selectorSkin = ColorSelectorSkin(skinManager.getSkin(ColorSelector));
			buttonSkin = ButtonSkin(skinManager.getSkin(Button));
			windowSkin = WindowSkin(skinManager.getSkin(WindowBase));
			
			// Отступы в диалоговом "окне"
			selectorContainer.marginLeft = Math.floor(windowSkin.containerMargin*0.5);
			selectorContainer.marginTop = Math.floor(windowSkin.containerMargin*0.5);
			selectorContainer.marginRight = Math.floor(windowSkin.containerMargin*0.5);
			selectorContainer.marginBottom = Math.floor(windowSkin.containerMargin*0.5);
			
			// Индикатор выбранного цвета
			var selectedColorSideSize:int = Math.round(buttonSkin.nc.height*0.66);
			selectedColorBd = new BitmapData(selectedColorSideSize, selectedColorSideSize, false, _selectedColor);
			this.image = selectedColorBd;
			
			super.updateSkin();
		}
		
		protected function addComponents():void {
			selectorContainer.addObject(_pallette);
			_pallette.addEventListener(Event.CHANGE, onSelectColor);
		}
		
		override public function click():void {
			super.click();
			
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.addObject(selectorContainer);
			selectorContainer.repaint(new Point());
			
			var localMouseCoord:Point = new Point(mouseX, mouseY);
			var globalMouseCoord:Point = localToGlobal(localMouseCoord);
			var inTopContainerLocalMouseCoord:Point = topContainer.globalToLocal(globalMouseCoord);
			
			var localSelectorCoords:Point = new Point(inTopContainerLocalMouseCoord.x - Math.round(selectorContainer.currentSize.x/2), inTopContainerLocalMouseCoord.y - Math.round(selectorContainer.currentSize.y/2));
			var globalSelectorCoords:Point = topContainer.localToGlobal(localSelectorCoords);
			// Краевые ограничения
			if (globalSelectorCoords.x < 0) {
				globalSelectorCoords.x = 0;
			} else if (globalSelectorCoords.x + selectorContainer.currentSize.x > stage.stageWidth) {
				globalSelectorCoords.x = stage.stageWidth - selectorContainer.currentSize.x;
			}
			if (globalSelectorCoords.y < 0) {
				globalSelectorCoords.y = 0;
			} else if (globalSelectorCoords.y + selectorContainer.currentSize.y > stage.stageHeight) {
				globalSelectorCoords.y = stage.stageHeight - selectorContainer.currentSize.y;
			}
			localSelectorCoords = topContainer.globalToLocal(globalSelectorCoords);
			
			selectorContainer.x = localSelectorCoords.x;
			selectorContainer.y = localSelectorCoords.y;
		}
		
		private function onSelectColor(e:Event):void {
			GUI.mouseManager.changeCursor(GUI.mouseManager.cursorTypes.NORMAL);
			
			// Удаление диалога
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.removeObject(selectorContainer);
			stage.focus = this;
			
			_selectedColor = _pallette.selectedColor;
			
			var selectedColorSideSize:int = Math.round(buttonSkin.nc.height*0.66);
			this.image = new BitmapData(selectedColorSideSize, selectedColorSideSize, false, _selectedColor);
			// Установка хинта
			var s:String = hexString(_selectedColor);
			hint = s;
		}
		
		// Преобразование цвета в 16-чную систему
		protected function hexString(value:uint):String {
			var s:String = value.toString(16);
			while (s.length < 6) {
				s = "0" + s;
			}
			return s;
		}
		
		public function get selectedColor():uint {
			return _selectedColor;
		}

	}
}