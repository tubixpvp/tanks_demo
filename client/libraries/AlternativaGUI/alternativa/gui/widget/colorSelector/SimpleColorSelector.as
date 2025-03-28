package alternativa.gui.widget.colorSelector {
	import alternativa.gui.base.Dummy;
	import alternativa.gui.container.Container;
	import alternativa.gui.container.group.PanelGroup;
	import alternativa.gui.init.GUI;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.skin.widget.ColorSelectorSkin;
	import alternativa.gui.skin.widget.button.ButtonSkin;
	import alternativa.gui.skin.window.WindowSkin;
	import alternativa.gui.widget.Image;
	import alternativa.gui.widget.Input;
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.button.Button;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.slider.Slider;
	import alternativa.gui.widget.slider.SliderEvent;
	import alternativa.gui.window.WindowBase;
	import alternativa.utils.ColorUtils;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	public class SimpleColorSelector extends Button {
		
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
		// Битмап для отображения старого цвета в диалоге
		private var oldColorBd:BitmapData;
		private var oldColorBitmap:Image;
		
		// Кнопки в диалоговом "окне"
		private var okButton:Button;
		private var cancelButton:Button;
		
		private var RContainer:Container;
		private var GContainer:Container;
		private var BContainer:Container;
		
		private var Rslider:Slider;
		private var Gslider:Slider;
		private var Bslider:Slider;
		
		private var Rlabel:Label;
		private var Glabel:Label;
		private var Blabel:Label;
		
		// Выбранный цвет
		private var _selectedColor:uint;
		
		// Смешиваемый цвет
		private var mixedColor:uint;
		
		// Поле ввода цвета в 16-чной системе
		private var hexInput:Input;
		private var oldHexInput:Input;
		
		
		public function SimpleColorSelector(selectedColor:uint = 0xff0000, colorName:String = "") {
			super(colorName, null, Align.CENTER);
			_selectedColor = selectedColor;
			mixedColor = selectedColor;
			
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
			// Индикатор старого цвета
			oldColorBd = new BitmapData(selectorSkin.mixedColorSideSize, selectorSkin.mixedColorSideSize, false, _selectedColor);
			oldColorBitmap.bitmapData = oldColorBd;
			// Индикатор нового цвета
			mixedColorBd = new BitmapData(selectorSkin.mixedColorSideSize, selectorSkin.mixedColorSideSize, false, _selectedColor);
			mixedColorBitmap.bitmapData = mixedColorBd;
			
			super.updateSkin();
		}
		
		protected function addComponents():void {
			
			var mixedColorContainer:Container = new Container();
			mixedColorContainer.stretchableH = true;
			mixedColorContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE);
			selectorContainer.addObject(mixedColorContainer);
			
			mixedColorContainer.addObject(new Dummy(0, 0, true, false));
			
			// old HEX number
			var oldHexContainer:Container = new Container();
			oldHexContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE, 5);
			oldHexContainer.stretchableH = true;
			mixedColorContainer.addObject(oldHexContainer);
			var hexLabel:Label = new Label("#")
			oldHexContainer.addObject(hexLabel);
			oldHexInput = new Input(hexString(_selectedColor), 6);
			oldHexInput.restrict("0123456789ABCDEFabcdef");
			oldHexContainer.addObject(oldHexInput);
			oldHexInput.addEventListener(Event.CHANGE, onHexInputChanged);
			
			oldHexInput.locked = true;
			
			// Квадратик со старым цветом
			oldColorBitmap = new Image();
			mixedColorContainer.addObject(oldColorBitmap);
			// Квадратик с выбранным цветом
			mixedColorBitmap = new Image();
			mixedColorContainer.addObject(mixedColorBitmap);
			
			// HEX number
			hexInput = new Input(hexString(_selectedColor), 6);
			hexInput.restrict("0123456789ABCDEFabcdef");
			mixedColorContainer.addObject(hexInput);
			hexInput.addEventListener(Event.CHANGE, onHexInputChanged);
			
			mixedColorContainer.addObject(new Dummy(hexLabel.minSize.x + 5, 0, true, false));
			mixedColorContainer.addObject(new Dummy(0, 0, true, false));
			
			// R G B
			RContainer = new Container();
			RContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 5);
			selectorContainer.addObject(RContainer);
			GContainer = new Container();
			GContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 5);
			selectorContainer.addObject(GContainer);
			BContainer = new Container();
			BContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 5);
			selectorContainer.addObject(BContainer);
			RContainer.stretchableH = true;
			GContainer.stretchableH = true;
			BContainer.stretchableH = true;
			
			RContainer.addObject(new Image(new BitmapData(10, 10, false, 0xff0000)));
			GContainer.addObject(new Image(new BitmapData(10, 10, false, 0x00ff00)));
			BContainer.addObject(new Image(new BitmapData(10, 10, false, 0x0000ff)));
			
			Rslider = new Slider(Direction.HORIZONTAL, 256, ColorUtils.red(_selectedColor)+1, 1, false);
			Gslider = new Slider(Direction.HORIZONTAL, 256, ColorUtils.green(_selectedColor)+1, 1, false);
			Bslider = new Slider(Direction.HORIZONTAL, 256, ColorUtils.blue(_selectedColor)+1, 1, false);
			
			RContainer.addObject(Rslider);
			GContainer.addObject(Gslider);
			BContainer.addObject(Bslider);
			
			Rslider.addEventListener(SliderEvent.CHANGE_POS, onSlidersChangePos);
			Gslider.addEventListener(SliderEvent.CHANGE_POS, onSlidersChangePos);
			Bslider.addEventListener(SliderEvent.CHANGE_POS, onSlidersChangePos);
			
			Rlabel = new Label(String(ColorUtils.red(_selectedColor)), Align.RIGHT);
			Glabel = new Label(String(ColorUtils.green(_selectedColor)), Align.RIGHT);
			Blabel = new Label(String(ColorUtils.blue(_selectedColor)), Align.RIGHT);
			Rlabel.stretchableH = true;
			Glabel.stretchableH = true;
			Blabel.stretchableH = true;
			
			RContainer.addObject(Rlabel);
			GContainer.addObject(Glabel);
			BContainer.addObject(Blabel);
			
			// Кнопки
			var buttonsContainer:Container = new Container();
			buttonsContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE, 20);
			selectorContainer.addObject(buttonsContainer);
			
			okButton = new Button("Ok", null, Align.CENTER);
			cancelButton = new Button("Cancel", null, Align.CENTER);
			okButton.minSize.x = 50; 
			cancelButton.minSize.x = 50;
			buttonsContainer.addObject(okButton);
			buttonsContainer.addObject(cancelButton);
			// Подписка обработчиков кнопок
			okButton.addEventListener(ButtonEvent.CLICK, onOkButtonClick);
			cancelButton.addEventListener(ButtonEvent.CLICK, onCancelButtonClick);
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
		
		protected function onHexInputChanged(e:Event):void {
			mixedColor = uint("0x" + hexInput.text);
			mixedColorBitmap.bitmapData = new BitmapData(selectorSkin.mixedColorSideSize, selectorSkin.mixedColorSideSize, false, mixedColor);
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
			
			Rslider.currentPos = ColorUtils.red(_selectedColor)+1;
			Gslider.currentPos = ColorUtils.green(_selectedColor)+1;
			Bslider.currentPos = ColorUtils.blue(_selectedColor)+1;
			
			GUI.mouseManager.changeCursor(GUI.mouseManager.cursorTypes.NORMAL);
			// Удаление диалога
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.removeObject(selectorContainer);
			stage.focus = this;
		}
		
		private function onSlidersChangePos(e:SliderEvent):void {
			mixedColor = ColorUtils.rgb(Rslider.currentPos-1, Gslider.currentPos-1, Bslider.currentPos-1);
			mixedColorChanged();
		}
		
		// Смешали новый цвет
		protected function mixedColorChanged():void {
			mixedColorBitmap.bitmapData = new BitmapData(selectorSkin.mixedColorSideSize, selectorSkin.mixedColorSideSize, false, mixedColor);
			
			hexInput.text = hexString(mixedColor);
			
			Rlabel.text = String(Rslider.currentPos-1);
			Glabel.text = String(Gslider.currentPos-1);
			Blabel.text = String(Bslider.currentPos-1);
			
			RContainer.repaintCurrentSize();
			GContainer.repaintCurrentSize();
			BContainer.repaintCurrentSize();
		}
		
		// Смешанный цвет подтвержден
		protected function colorSelected():void {
			_selectedColor = mixedColor;
			
			var selectedColorSideSize:int = Math.round(buttonSkin.nc.height*0.66);
			this.image = new BitmapData(selectedColorSideSize, selectedColorSideSize, false, _selectedColor);
			oldColorBitmap.bitmapData = new BitmapData(selectorSkin.mixedColorSideSize, selectorSkin.mixedColorSideSize, false, mixedColor);
			// Установка хинта и текста
			var s:String = hexString(_selectedColor);
			hexInput.text = s;
			oldHexInput.text = s;
			hint = s;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		// Преобразование цвета в 16-чную систему
		protected function hexString(value:uint):String {
			var s:String = value.toString(16);
			while (s.length < 6) {
				s = "0" + s;
			}
			return s;
		}
		
		public function set selectedColor(value:uint):void {
			mixedColor = value;
			mixedColorBitmap.bitmapData = new BitmapData(selectorSkin.mixedColorSideSize, selectorSkin.mixedColorSideSize, false, mixedColor);
			
			colorSelected();
			
			Rslider.currentPos = ColorUtils.red(_selectedColor)+1;
			Gslider.currentPos = ColorUtils.green(_selectedColor)+1;
			Bslider.currentPos = ColorUtils.blue(_selectedColor)+1;
			
			Rlabel.text = String(Rslider.currentPos-1);
			Glabel.text = String(Gslider.currentPos-1);
			Blabel.text = String(Bslider.currentPos-1);
		}
		public function get selectedColor():uint {
			return _selectedColor;
		}
	
	}
}