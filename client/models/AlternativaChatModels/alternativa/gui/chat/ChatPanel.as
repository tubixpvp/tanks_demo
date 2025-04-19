package alternativa.gui.chat {
	import alternativa.gui.base.Dummy;
	import alternativa.gui.container.Container;
	import alternativa.gui.container.scrollBox.ScrollBox;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.ScrollMode;
	import alternativa.gui.layout.enums.WindowAlign;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.window.panel.ResizeablePanelBase;
	import alternativa.init.IOInterfaces;
	import alternativa.model.chat.ChatModel;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;

	[Event (name="sendMessage", type="alternativa.gui.chat.ChatEvent")]
	
	public class ChatPanel extends ResizeablePanelBase {
		
		[Embed(source="skin/resources/panel.png")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
		
		[Embed(source="skin/resources/send-button_n.png")] private static const sendButtonNormalBitmap:Class;
		private static const sendButtonNormalBd:BitmapData = new sendButtonNormalBitmap().bitmapData;
		[Embed(source="skin/resources/send-button_n.png")] private static const sendButtonPressBitmap:Class;
		private static const sendButtonPressBd:BitmapData = new sendButtonPressBitmap().bitmapData;
		
		[Embed(source="skin/resources/chat_button_hide.png")] private static const hideButtonBitmap:Class;
		private static const hideButtonBd:BitmapData = new hideButtonBitmap().bitmapData;
		[Embed(source="skin/resources/chat_button_show.png")] private static const showButtonBitmap:Class;
		private static const showButtonBd:BitmapData = new showButtonBitmap().bitmapData;
		
		public static const SYSTEM_MESSAGE_COLOR:uint = 0xff0000;
		public static const NORMAL_MESSAGE_COLOR:uint = 0xffffff;
		public static const USER_MESSAGE_COLOR:uint = 0x33ff33;
		
		private var back:Bitmap;
		
		//private var deviderLine:Line;
		private var textInput:TextInput;
		private var textOutput:ScrollBox;
		private var sendButton:SendButton;
		
		private var hideButton:ChatImageButton;
		public var hiden:Boolean;
		
		private var model:ChatModel;
		
		/**
		 * Панель чата
		 */
		public function ChatPanel(model:ChatModel) {
			super(Direction.HORIZONTAL, WindowAlign.BOTTOM_RIGHT, 584, 102, false, false, false, "", false, false, false);
			
			this.model = model;
			
			back = new Bitmap(backBd);
			addChildAt(back, 0);
			
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE, 5);
			
			/*super(Direction.HORIZONTAL, WindowAlign.BOTTOM_CENTER, 450, 150, true, false, false, null, false, true, false);
			
			layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.BOTTOM);
			
			var textOutputContainer:Container = new Container(4, 3, 4, 4);
			textOutputContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.TOP, 4);
			addObject(textOutputContainer);
			textOutputContainer.stretchableH = true;
			textOutputContainer.stretchableV = true;
			
			textOutput = new ScrollBox(0, 0, ScrollMode.AUTO, ScrollMode.AUTO, 1, 5, 5, 5, 5);
			textOutput.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.TOP, 4);
			textOutput.stretchableH = true;
			textOutput.stretchableV = true;
			textOutputContainer.addObject(textOutput);
			
			deviderLine = new Line(Direction.HORIZONTAL);
			addObject(deviderLine);
			
			var Vspace:Dummy = new Dummy(0, 10, true, false);
			addObject(Vspace);	
			
			var textInputContainer:Container = new Container(4, 6, 4, 4);
			textInputContainer.stretchableH = true;
			textInputContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.TOP, 4); 
			addObject(textInputContainer);
			
			textInput = new Input();
			textInput.stretchableH = true;
			volumeSwitch = new ButtonSwitch(3, 2, 2*InterfaceIcon.CHAT_VOLUME1.width, false, new Array("Прошептать","Сказать","Прокричать"), new Array(InterfaceIcon.CHAT_VOLUME1, InterfaceIcon.CHAT_VOLUME2, InterfaceIcon.CHAT_VOLUME3), 2);
			
			textInputContainer.addObject(textInput);
			textInputContainer.addObject(volumeSwitch);
			
			textInput.addEventListener(Event.COMPLETE, onKeyDown);
			volumeSwitch.addEventListener(SwitchEvent.STOP_DRAG, onSwitchChangePos);*/
			
			addObject(new Dummy(85, 0));
			
			textOutput = new ScrollBox(0, 0, ScrollMode.AUTO, ScrollMode.AUTO, 1, 5, 5, 5, 5);
			textOutput.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.TOP, 4);
			//textOutput.stretchableH = true;
			textOutput.minSize.x = 269;
			textOutput.stretchableV = true;
			addObject(textOutput);
			
			var inputContainer:Container = new Container();
			inputContainer.stretchableH = true;
			inputContainer.stretchableV = true;
			inputContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.RIGHT, Align.TOP, 11); 
			addObject(inputContainer);
			
			//textInput = new TextArea(200, 41, "", Align.LEFT, true, true, 200, 1, ScrollMode.AUTO, ScrollMode.AUTO, 5, 5, 5, 5);
			textInput = new TextInput();
			textInput.stretchableH = true;
			inputContainer.addObject(textInput);
			textInput.addEventListener(Event.CHANGE, onChangeText);
			textInput.addEventListener(KeyboardEvent.KEY_DOWN, onEnter);
			
			sendButton = new SendButton(sendButtonNormalBd, sendButtonNormalBd, sendButtonPressBd, sendButtonNormalBd);
			sendButton.addEventListener(ButtonEvent.CLICK, onSendButtonClick);
			inputContainer.addObject(sendButton);
			
			hideButton = new ChatImageButton(0, 1, showButtonBd, showButtonBd, showButtonBd, showButtonBd);
			hideButton.addEventListener(ButtonEvent.CLICK, onHideButtonClick);
			addChildAt(hideButton, 0);
			hiden = true;
			
			tabIndexes = new Array(textInput, sendButton);
		}
		
		private function onHideButtonClick(e:ButtonEvent):void {
			hiden = !hiden;
			if (hiden) {
				hideButton.normalBitmap = showButtonBd;
				hideButton.overBitmap = showButtonBd;
				hideButton.pressBitmap = showButtonBd;
				hideButton.lockBitmap = showButtonBd;
				
				model.onResize();
				
				IOInterfaces.focusManager.focus = null;
				IOInterfaces.mouseManager.updateCursor();
			} else {
				hideButton.normalBitmap = hideButtonBd;
				hideButton.overBitmap = hideButtonBd;
				hideButton.pressBitmap = hideButtonBd;
				hideButton.lockBitmap = hideButtonBd;
				
				model.onResize();
				
				IOInterfaces.focusManager.focus = null;
				IOInterfaces.mouseManager.updateCursor();
			}
		}
		
		private function onChangeText(e:Event):void {
			//textInput.repaintCurrentSize();
		}
		
		// Обработчик клавиатуры
		private function onEnter(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER && textInput.text != "" && textInput.text != null) {
				sendMessage();
			}
		}
		
		private function onSendButtonClick(e:ButtonEvent):void {
			sendMessage();
		}
		
		/**
		 * Отсылаем сообщение
		 */
		private function sendMessage():void {
			if (textInput.text != "" && textInput.text != null) {
				// отсылаем сообщение
				dispatchEvent(new ChatEvent(ChatEvent.SEND_MESSAGE, textInput.text));
				//addMessage(new ChatMessage(0, "некто", textInput.text, 0));
				// стираем сообщение из поля ввода
				textInput.text = "";
				
				IOInterfaces.focusManager.focus = null;
			}	
		} 
		
		/**
		 * Добавлено новое сообщение
		 */
		public function addMessage(message:ClientChatMessage):void {
			// Создание объекта для вывода в чат
			var item:ChatListItem = new ChatListItem(null, message.name, message.contactId, message.message, message.textColor);
			// Добавление сообщения
			textOutput.addObject(item);
			// удаляем первый элемент - ограничение по количеству элементов
			if (textOutput.objects.length > 10) { 
				textOutput.removeObjectAt(0);
			}
			textOutput.minSizeChanged = true;
			textOutput.repaintCurrentSize();
			textOutput.repaintCurrentSize();
			textOutput.positionVertical = textOutput.lengthVertical - textOutput.scrollerVerticalLength;
		}
		
		override public function draw(size:Point):void {
			super.draw(size);
			
			hideButton.x = (_currentSize.x - hideButton.minSize.x)*0.5;
			hideButton.y = -hideButton.minSize.y;
		}

	}
}