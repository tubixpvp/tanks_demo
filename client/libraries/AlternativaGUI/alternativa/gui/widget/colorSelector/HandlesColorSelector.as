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
	import alternativa.gui.widget.Handle;
	import alternativa.gui.widget.HandleEvent;
	import alternativa.gui.widget.Image;
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.button.Button;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.window.WindowBase;
	import alternativa.utils.ColorUtils;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	
	public class HandlesColorSelector extends Button {
		
		// Шкурка
		protected var selectorSkin:ColorSelectorSkin;
		private var buttonSkin:ButtonSkin;
		private var windowSkin:WindowSkin;
		
		// Контейнер для элементов поверх окна
		protected var selectorContainer:PanelGroup;
		
		// Битмап для отображения выбранного цвета на кнопке
		private var selectedColorBd:BitmapData;
		
		// Битмап для отображения выбраемого цвета в диалоге
		private var mixedColorBd:BitmapData;
		private var mixedColorBitmap:Image;
		
		// Кнопки в диалоговом "окне"
		private var okButton:Button;
		private var cancelButton:Button;
		
		private var okButtonIcon:BitmapData;
		private var cancelButtonIcon:BitmapData;
		
		private var RContainer:Container;
		private var GContainer:Container;
		private var BContainer:Container;
		
		private var Rlabel:Label;
		private var Glabel:Label;
		private var Blabel:Label;
		
		private var Rhandle:Handle;
		private var Ghandle:Handle;
		private var Bhandle:Handle;
		
		private var areaBitmap:BitmapData;
		private var handleBitmapR:BitmapData;
		private var handleBitmapG:BitmapData;
		private var handleBitmapB:BitmapData;
		
		private var areaDiametr:int;
		private var handleDiametr:int;
		
		// Выбранный цвет
		private var _selectedColor:uint;
		
		// Смешиваемый цвет
		private var mixedColor:uint;
		
		
		public function HandlesColorSelector(areaBitmap:BitmapData, handleBitmapR:BitmapData, handleBitmapG:BitmapData, handleBitmapB:BitmapData, areaDiametr:int, handleDiametr:int, okIcon:BitmapData, cancelIcon:BitmapData, selectedColor:uint = 0xff0000) {
			super("", null, Align.CENTER);
			_selectedColor = selectedColor;
			mixedColor = selectedColor;
			
			this.areaBitmap = areaBitmap;
			this.handleBitmapR = handleBitmapR;
			this.handleBitmapG = handleBitmapG;
			this.handleBitmapB = handleBitmapB;
			this.areaDiametr = areaDiametr;
			this.handleDiametr = handleDiametr;
			okButtonIcon = okIcon;
			cancelButtonIcon = cancelIcon;
			
			// Диалоговое "окно"
			selectorContainer = new PanelGroup();
			selectorContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE, 5);
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
			// Индикатор нового цвета
			mixedColorBd = new BitmapData(areaDiametr, areaDiametr, false, _selectedColor);
			mixedColorBitmap.bitmapData = mixedColorBd;
			
			super.updateSkin();
		}
		
		protected function addComponents():void {
			// Квадратик с цветом и кнопки
			var colorBitmapContainer:Container = new Container();
			colorBitmapContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.MIDDLE, 2);
			selectorContainer.addObject(colorBitmapContainer);
			
			mixedColorBitmap = new Image();
			colorBitmapContainer.addObject(mixedColorBitmap);
			
			var buttonsContainer:Container = new Container();
			buttonsContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE, 2);
			colorBitmapContainer.addObject(buttonsContainer);
			
			okButton = new Button("", okButtonIcon, Align.CENTER);
			cancelButton = new Button("", cancelButtonIcon, Align.CENTER);
//			okButton.minSize.x = 30; 
//			cancelButton.minSize.x = 30;
			buttonsContainer.addObject(okButton);
			buttonsContainer.addObject(cancelButton);
			// Подписка обработчиков кнопок
			okButton.addEventListener(ButtonEvent.CLICK, onOkButtonClick);
			cancelButton.addEventListener(ButtonEvent.CLICK, onCancelButtonClick);
			
			// R G B
			RContainer = new Container();
			RContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.MIDDLE, 4);
			selectorContainer.addObject(RContainer);
			GContainer = new Container();
			GContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.MIDDLE, 4);
			selectorContainer.addObject(GContainer);
			BContainer = new Container();
			BContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.MIDDLE, 4);
			selectorContainer.addObject(BContainer);
			RContainer.stretchableV = true;
			GContainer.stretchableV = true;
			BContainer.stretchableV = true;
			
			
			Rlabel = new Label(String(ColorUtils.red(_selectedColor)), Align.CENTER);
			Glabel = new Label(String(ColorUtils.green(_selectedColor)), Align.CENTER);
			Blabel = new Label(String(ColorUtils.blue(_selectedColor)), Align.CENTER);
			Rlabel.stretchableH = true;
			Glabel.stretchableH = true;
			Blabel.stretchableH = true;
			
			RContainer.addObject(Rlabel);
			GContainer.addObject(Glabel);
			BContainer.addObject(Blabel);
			
			
			Rhandle = new Handle(areaBitmap, handleBitmapR, areaDiametr, handleDiametr, -128, 127, ColorUtils.red(_selectedColor)-128);
			Ghandle = new Handle(areaBitmap, handleBitmapG, areaDiametr, handleDiametr, -128, 127, ColorUtils.green(_selectedColor)-128);
			Bhandle = new Handle(areaBitmap, handleBitmapB, areaDiametr, handleDiametr, -128, 127, ColorUtils.blue(_selectedColor)-128);
			
			RContainer.addObject(Rhandle);
			GContainer.addObject(Ghandle);
			BContainer.addObject(Bhandle);
			
			Rhandle.addEventListener(HandleEvent.CHANGE_POS, onHandlesChangePos);
			Ghandle.addEventListener(HandleEvent.CHANGE_POS, onHandlesChangePos);
			Bhandle.addEventListener(HandleEvent.CHANGE_POS, onHandlesChangePos);
		}
		
		override public function click():void {
			super.click();
			
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.addObject(selectorContainer);
			selectorContainer.repaint(new Point());
			
			var localMouseCoord:Point = new Point(mouseX, mouseY);
			var globalMouseCoord:Point = localToGlobal(localMouseCoord);
			var inTopContainerLocalMouseCoord:Point = topContainer.globalToLocal(globalMouseCoord);
			
			selectorContainer.x = inTopContainerLocalMouseCoord.x - Math.round(selectorContainer.currentSize.x/2);
			selectorContainer.y = inTopContainerLocalMouseCoord.y - Math.round(selectorContainer.currentSize.y/2);
		}
		
		protected function onOkButtonClick(e:ButtonEvent):void {
			GUI.mouseManager.changeCursor(GUI.mouseManager.cursorTypes.NORMAL);
			colorSelected();
			// Удаление диалога
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.removeObject(selectorContainer);
			stage.focus = this;
			
			dispatchEvent(new Event(Event.CHANGE, true, true));
		}
		protected function onCancelButtonClick(e:ButtonEvent):void {
			mixedColorBitmap.bitmapData = new BitmapData(selectorSkin.mixedColorSideSize, selectorSkin.mixedColorSideSize, false, _selectedColor);
			
			Rhandle.currentPos = ColorUtils.red(_selectedColor)-128;
			Ghandle.currentPos = ColorUtils.green(_selectedColor)-128;
			Bhandle.currentPos = ColorUtils.blue(_selectedColor)-128;
			
			GUI.mouseManager.changeCursor(GUI.mouseManager.cursorTypes.NORMAL);
			// Удаление диалога
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.removeObject(selectorContainer);
			stage.focus = this;
		}
		
		private function onHandlesChangePos(e:HandleEvent):void {
			mixedColor = ColorUtils.rgb(Rhandle.currentPos+128, Ghandle.currentPos+128, Bhandle.currentPos+128);
			mixedColorChanged();
		}
		
		// Смешали новый цвет
		protected function mixedColorChanged():void {
			mixedColorBitmap.bitmapData = new BitmapData(areaDiametr, areaDiametr, false, mixedColor);
			
			Rlabel.text = String(Rhandle.currentPos+128);
			Glabel.text = String(Ghandle.currentPos+128);
			Blabel.text = String(Bhandle.currentPos+128);
			RContainer.repaintCurrentSize();
			GContainer.repaintCurrentSize();
			BContainer.repaintCurrentSize();
			
			dispatchEvent(new Event(Event.CHANGE, true, true));
		}
		
		// Смешанный цвет подтвержден
		protected function colorSelected():void {
			_selectedColor = mixedColor;
			
			var selectedColorSideSize:int = Math.round(buttonSkin.nc.height*0.66);
			this.image = new BitmapData(selectedColorSideSize, selectedColorSideSize, false, _selectedColor);
			// Установка хинта и текста
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

	}
}