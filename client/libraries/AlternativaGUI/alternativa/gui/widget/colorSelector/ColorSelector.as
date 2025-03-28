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
	import alternativa.gui.widget.button.RadioButton;
	import alternativa.gui.widget.button.RadioButtonGroup;
	import alternativa.gui.widget.slider.BitmapSlider;
	import alternativa.gui.widget.slider.SliderEvent;
	import alternativa.gui.window.WindowBase;
	import alternativa.utils.ColorUtils;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	public class ColorSelector extends Button {
		
		// Шкурка
		private var selectorSkin:ColorSelectorSkin;
		private var buttonSkin:ButtonSkin;
		private var windowSkin:WindowSkin;
		
		// Контейнер для элементов поверх окна
		private var selectorContainer:PanelGroup;
		
		// Битмап для отображения выбранного цвета на кнопке
		private var selectedColorBd:BitmapData;
		
		// Битмап для отображения выбраемого цвета в диалоге
		private var mixedColorBd:BitmapData;
		private var mixedColorBitmap:Image;
		
		// Битмап для выбора яркости и насыщенности цвета
		private var BSfieldBd:BitmapData;
		private var BSfield:Image;
		
		// Слайдер выбора Hue
		private var spectrSlider:BitmapSlider;
		
		// Кнопки в диалоговом "окне"
		private var okButton:Button;
		private var cancelButton:Button;
		
		// Цвета спектра
		private var colors:Array;
		
		// Выбранный цвет
		private var _selectedColor:uint;
		
		// Смешиваемый цвет
		private var mixedColor:uint;
		
		// Поле ввода цвета в 16-чной системе
		private var hexInput:Input;
		
		public function ColorSelector(selectedColor:uint = 0xff0000) {
			super(hexString(selectedColor), null, Align.CENTER);
			_selectedColor = selectedColor;
			mixedColor = selectedColor;
			
			// Диалоговое "окно"
			selectorContainer = new PanelGroup();
			selectorContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.TOP, 10);
			// Тень
			selectorContainer.filters = new Array(new DropShadowFilter(4, 70, 0, 1, 4, 4, 0.3, BitmapFilterQuality.MEDIUM));
			
			colors = new Array();
		}
		
		override public function updateSkin():void {
			selectorSkin = ColorSelectorSkin(skinManager.getSkin(ColorSelector));
			buttonSkin = ButtonSkin(skinManager.getSkin(Button));
			windowSkin = WindowSkin(skinManager.getSkin(WindowBase));
			
			// Отступы в диалоговом "окне"
			selectorContainer.marginLeft = windowSkin.containerMargin;
			selectorContainer.marginTop = windowSkin.containerMargin;
			selectorContainer.marginRight = windowSkin.containerMargin;
			selectorContainer.marginBottom = windowSkin.containerMargin;
			
			// Индикатор выбранного цвета
			var selectedColorSideSize:int = Math.round(buttonSkin.nc.height*0.66);
			selectedColorBd = new BitmapData(selectedColorSideSize, selectedColorSideSize, false, _selectedColor);
			this.image = selectedColorBd;
			
			// Наполнение компонентами
			if (selectorContainer.objects.length == 0) {
				addComponents();
			}
			
			// Подписка обработчиков кнопок
			okButton.addEventListener(ButtonEvent.CLICK, onOkButtonClick);
			cancelButton.addEventListener(ButtonEvent.CLICK, onCancelButtonClick);
			spectrSlider.addEventListener(SliderEvent.CHANGE_POS, onChangeHue);
			
			super.updateSkin();
		}
		
		private function addComponents():void {
			trace("ColorSelector addComponents");
			var colorSetContainer:Container = new Container();
			colorSetContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.TOP, 10);
			colorSetContainer.stretchableH = true;
			
			var numberSetContainer:Container = new Container();
			numberSetContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.TOP, 4);
			colorSetContainer.addObject(numberSetContainer);
			numberSetContainer.stretchableH = true;
			numberSetContainer.stretchableV = true;
			
			var buttonsContainer:Container = new Container();
			buttonsContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE, 20);
			
			// Квадратик с выбранным цветом
			mixedColorBd = new BitmapData(selectorSkin.mixedColorSideSize, selectorSkin.mixedColorSideSize, false, _selectedColor);
			mixedColorBitmap = new Image(mixedColorBd);
			numberSetContainer.addObject(mixedColorBitmap);
			
			numberSetContainer.addObject(new Dummy(0, 7, false, false));
			
			// H S B
			var hueContainer:Container = new Container();
			hueContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 2);
			numberSetContainer.addObject(hueContainer);
			var saturationContainer:Container = new Container();
			saturationContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 2);
			numberSetContainer.addObject(saturationContainer);
			var brightnessContainer:Container = new Container();
			brightnessContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 2);
			numberSetContainer.addObject(brightnessContainer);
			hueContainer.stretchableH = true;
			saturationContainer.stretchableH = true;
			brightnessContainer.stretchableH = true;
			
			var hueRadioButton:RadioButton = new RadioButton("H");
			var saturationRadioButton:RadioButton = new RadioButton("S");
			var brightnessRadioButton:RadioButton = new RadioButton("B");
			var hueNumberInput:Input = new Input("0", 3);
			var saturationNumberInput:Input = new Input("0", 3);
			var brightnessNumberInput:Input = new Input("0", 3);
			hueNumberInput.restrict("0123456789");
			saturationNumberInput.restrict("0123456789");
			brightnessNumberInput.restrict("0123456789");
			hueNumberInput.minSize.x = 30;
			saturationNumberInput.minSize.x = 30;
			brightnessNumberInput.minSize.x = 30;
			
			hueContainer.addObject(hueRadioButton);
			hueContainer.addObject(new Dummy(0, 0, true, false));
			hueContainer.addObject(hueNumberInput);
			
			saturationContainer.addObject(saturationRadioButton);
			saturationContainer.addObject(new Dummy(0, 0, true, false));
			saturationContainer.addObject(saturationNumberInput);
			
			brightnessContainer.addObject(brightnessRadioButton);
			brightnessContainer.addObject(new Dummy(0, 0, true, false));
			brightnessContainer.addObject(brightnessNumberInput);
			
			numberSetContainer.addObject(new Dummy(0, 8, false, false));
			
			// R G B
			var RContainer:Container = new Container();
			RContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 2);
			numberSetContainer.addObject(RContainer);
			var GContainer:Container = new Container();
			GContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 2);
			numberSetContainer.addObject(GContainer);
			var BContainer:Container = new Container();
			BContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 2);
			numberSetContainer.addObject(BContainer);
			RContainer.stretchableH = true;
			GContainer.stretchableH = true;
			BContainer.stretchableH = true;
			
			var RRadioButton:RadioButton = new RadioButton("R");
			var GRadioButton:RadioButton = new RadioButton("G");
			var BRadioButton:RadioButton = new RadioButton("B");
			var RNumberInput:Input = new Input("0", 3);
			var GNumberInput:Input = new Input("0", 3);
			var BNumberInput:Input = new Input("0", 3);
			RNumberInput.restrict("0123456789");
			GNumberInput.restrict("0123456789");
			BNumberInput.restrict("0123456789");
			RNumberInput.minSize.x = 30;
			GNumberInput.minSize.x = 30;
			BNumberInput.minSize.x = 30;
			
			RContainer.addObject(RRadioButton);
			RContainer.addObject(new Dummy(0, 0, true, false));
			RContainer.addObject(RNumberInput);
			
			GContainer.addObject(GRadioButton);
			GContainer.addObject(new Dummy(0, 0, true, false));
			GContainer.addObject(GNumberInput);
			
			BContainer.addObject(BRadioButton);
			BContainer.addObject(new Dummy(0, 0, true, false));
			BContainer.addObject(BNumberInput);
			
			// Радио-группа
			var radioButtonGroup:RadioButtonGroup = new RadioButtonGroup();
			radioButtonGroup.addButton(hueRadioButton);
			radioButtonGroup.addButton(saturationRadioButton);
			radioButtonGroup.addButton(brightnessRadioButton);
			radioButtonGroup.addButton(RRadioButton);
			radioButtonGroup.addButton(GRadioButton);
			radioButtonGroup.addButton(BRadioButton);
			
			numberSetContainer.addObject(new Dummy(0, 8, false, false));
			
			// HEX number
			var hexContainer:Container = new Container();
			hexContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE, 5);
			hexContainer.stretchableH = true;
			numberSetContainer.addObject(hexContainer);
			hexContainer.addObject(new Label("#"));
			hexInput = new Input(hexString(_selectedColor), 6);
			hexInput.restrict("0123456789ABCDEFabcdef");
			hexContainer.addObject(hexInput);
			hexInput.addEventListener(Event.CHANGE, onHexInputChanged);
			
			// HUE slider
			spectrSlider = new BitmapSlider(Direction.VERTICAL, generateSpectr(), selectorSkin.sliderVertRunner, 256, 1, 0, false, false);
			colorSetContainer.addObject(spectrSlider);
			
			// Поле выбора яркости и насыщенности
			BSfieldBd = new BitmapData(selectorSkin.sliderLength, selectorSkin.sliderLength, false, 0);
			BSfield = new Image(BSfieldBd);
			colorSetContainer.addObject(BSfield);
			
			// Кнопки
			okButton = new Button("Ok", null, Align.CENTER);
			cancelButton = new Button("Cancel", null, Align.CENTER);
			okButton.minSize.x = 50; 
			cancelButton.minSize.x = 50;
			buttonsContainer.addObject(okButton);
			buttonsContainer.addObject(cancelButton);
			
			selectorContainer.addObject(colorSetContainer);
			selectorContainer.addObject(buttonsContainer);
		}
		
		// Созадание битмапы со спектром для hue
		private function generateSpectr():BitmapData {
			var step:int = 6;
			var spectrBd:BitmapData;
			var spectr:Sprite = new Sprite();
			var colorR:int = 255;
			var colorG:int = 0;
			var colorB:int = 0;
			var color:uint;
			var posY:int = 255;
			var n:int;
			
			for (var i:int = 0; i < 256; i+=step) {
				colorG = i;
				color = ColorUtils.rgb(colorR, colorG, colorB);
				//trace("i: " + i);
				//trace("spectr color1: " + color.toString(16));
				colors.push(color);
				spectr.graphics.beginFill(color, 1);
				spectr.graphics.drawRect(0, posY, 15, 1);
				posY -= 1;
			}
			//trace("i1: " + i);
			n = i - 255;
			if (n == 0) n += step;
			colorG = 255;
			for (i = n; i < 256; i+=step) {
				colorR = 255 - i;
				color = ColorUtils.rgb(colorR, colorG, colorB);
				//trace("i: " + i);
				//trace("spectr color2: " + color.toString(16));
				colors.push(color);
				spectr.graphics.beginFill(color, 1);
				spectr.graphics.drawRect(0, posY, 15, 1);
				posY -= 1;
			}
			//trace("i2: " + i);
			n = i - 255;
			if (n == 0) n += step;
			colorR = 0;
			for (i = n; i < 256; i+=step) {
				colorB = i;
				color = ColorUtils.rgb(colorR, colorG, colorB);
				//trace("i: " + i);
				//trace("spectr color3: " + color.toString(16));
				colors.push(color);
				spectr.graphics.beginFill(color, 1);
				spectr.graphics.drawRect(0, posY, 15, 1);
				posY -= 1;
			}
			//trace("i3: " + i);
			n = i - 255;
			if (n == 0) n += step;
			colorB = 255;
			for (i = n; i < 256; i+=step) {
				colorG = 255 - i;
				color = ColorUtils.rgb(colorR, colorG, colorB);
				//trace("i: " + i);
				//trace("spectr color4: " + color.toString(16));
				colors.push(color);
				spectr.graphics.beginFill(color, 1);
				spectr.graphics.drawRect(0, posY, 15, 1);
				posY -= 1;
			}
			//trace("i4: " + i);
			n = i - 255;
			if (n == 0) n += step;
			colorG = 0;
			for (i = n; i < 256; i+=step) {
				colorR = i;
				color = ColorUtils.rgb(colorR, colorG, colorB);
				//trace("i: " + i);
				//trace("spectr color5: " + color.toString(16));
				colors.push(color);
				spectr.graphics.beginFill(color, 1);
				spectr.graphics.drawRect(0, posY, 15, 1);
				posY -= 1;
			}
			//trace("i5: " + i);
			n = i - 255;
			if (n == 0) n += step;
			colorR = 255;
			for (i = n; i < 256; i+=step) {
				colorB = 255 - i;
				color = ColorUtils.rgb(colorR, colorG, colorB);
				//trace("i: " + i);
				//trace("spectr color6: " + color.toString(16));
				colors.push(color);
				spectr.graphics.beginFill(color, 1);
				spectr.graphics.drawRect(0, posY, 15, 1);
				posY -= 1;
			}
			spectrBd = new BitmapData(selectorSkin.sliderThickness, selectorSkin.sliderLength, false, 0);
			spectrBd.draw(spectr);
			
			return spectrBd;
		}
		
		
		// Созадание битмапы со спектром для saturation
		/*private function generateSaturation():BitmapData {
			
		}*/
		
		
		// Смешанный цвет подтвержден
		private function colorSelected():void {
			_selectedColor = mixedColor;
			
			var selectedColorSideSize:int = Math.round(buttonSkin.nc.height*0.66);
			this.image = new BitmapData(selectedColorSideSize, selectedColorSideSize, false, _selectedColor);
			
			// Установка хинта и текста
			var s:String = hexInput.text;
			text = s;
			hint = s;
		}
		
		// Обработчики кнопок
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
		
		
		private function onHexInputChanged(e:Event):void {
			mixedColor = uint("0x" + hexInput.text);
			mixedColorBitmap.bitmapData = new BitmapData(selectorSkin.mixedColorSideSize, selectorSkin.mixedColorSideSize, false, mixedColor);
		}
		
		private function onOkButtonClick(e:ButtonEvent):void {
			GUI.mouseManager.changeCursor(GUI.mouseManager.cursorTypes.NORMAL);
			colorSelected();
			// Удаление диалога
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.removeObject(selectorContainer);
			stage.focus = this;
		}
		private function onCancelButtonClick(e:ButtonEvent):void {
			GUI.mouseManager.changeCursor(GUI.mouseManager.cursorTypes.NORMAL);
			// Удаление диалога
			var topContainer:Container = WindowBase(_rootObject).topContainer;
			topContainer.removeObject(selectorContainer);
			stage.focus = this;
		}
		
		private function onChangeHue(e:SliderEvent):void {
			mixedColor = colors[spectrSlider.currentPos-1];
			
			mixedColorChanged();
		}
		
		// Смешали новый цвет
		private function mixedColorChanged():void {
			mixedColorBitmap.bitmapData = new BitmapData(selectorSkin.mixedColorSideSize, selectorSkin.mixedColorSideSize, false, mixedColor);
			
			hexInput.text = hexString(mixedColor);
			
			dispatchEvent(new Event(Event.CHANGE, true, true));
		}
		
		// Преобразование цвета в 16-чную систему
		private function hexString(value:uint):String {
			var s:String = value.toString(16);
			while (s.length < 6) {
				s = "0" + s;
			}
			return s;
		}
		
		public function set color(value:uint):void {
			_selectedColor = value;
			
			var selectedColorSideSize:int = Math.round(buttonSkin.nc.height*0.66);
			this.image = new BitmapData(selectedColorSideSize, selectedColorSideSize, false, _selectedColor);
			
			// Установка хинта и текста
			var s:String = hexString(value);
			text = s;
			hint = s;
		}
		
		public function get color():uint {
			return _selectedColor;
		}
		
	}
}