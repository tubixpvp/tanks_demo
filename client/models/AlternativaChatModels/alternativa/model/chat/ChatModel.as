package alternativa.model.chat {
	import alternativa.gui.chat.ChatEvent;
	import alternativa.gui.chat.ChatPanel;
	import alternativa.gui.chat.ClientChatMessage;
	import alternativa.gui.chat.skin.ChatSkinManager;
	import alternativa.gui.container.PanelContainer;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.PanelLayoutManager;
	import alternativa.gui.window.WindowEvent;
	import alternativa.init.Main;
	import alternativa.model.IObjectLoadListener;
	import alternativa.object.ClientObject;
	import alternativa.protocol.codec.NullMap;
	import alternativa.protocol.factory.ICodecFactory;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.IDataInput;
	import alternativa.types.Long;

	import projects.tanks.models.chat.ChatModelBase;
	import projects.tanks.models.chat.IChatModelBase;
	import projects.tanks.models.chat.ChatMessage;
	
	/**
	 * Модель поведения панели чата.
	 */	
	public class ChatModel extends ChatModelBase implements IChatModelBase, IObjectLoadListener {
		// Массив соотвествий GUI-панелей их объектных представлений
		//private var clientObjects:Dictionary = new Dictionary(true);
		private var clientObject:ClientObject;
		private var chatContainer:PanelContainer;
		private var chatPanel:ChatPanel;
		
		public function ChatModel() {
			chatPanel = new ChatPanel(this);
		}
		
		/**
		 * 
		 * @param clientObject
		 * @param codecFactory
		 * @param dataInput
		 * @param nullMap
		 */
		override public function _initObject(clientObject:ClientObject, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void {
			super._initObject(clientObject, codecFactory, dataInput, nullMap);
			Main.console.writeToConsole("ChatModel initObject id: " + clientObject.id, 0xff0000);
			
			clientObject.putParams(ChatModelBase, chatPanel);
			//clientObjects[chatPanel] = clientObject;
			
			chatPanel.addEventListener(ChatEvent.SEND_MESSAGE, onSendChatMessage);
			
			chatContainer = new PanelContainer();
			chatContainer.stretchableH = true;
			chatContainer.rootObject = chatContainer;
			chatContainer.skinManager = new ChatSkinManager();
			chatContainer.layoutManager = new PanelLayoutManager(Direction.HORIZONTAL);
			
			chatContainer.addPanel(chatPanel);
			chatPanel.dispatchEvent(new WindowEvent(WindowEvent.SELECT, chatPanel));
			
			Main.systemUILayer.addChild(chatContainer);
			Main.stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		public function objectLoaded(object:ClientObject):void {
			//Main.console.write("ChatModel objectLoaded id: " + clientObject.id);
			clientObject = object; 
		}
		public function objectUnloaded(object:ClientObject):void {
			//Main.console.write("ChatModel objectUnloaded id: " + clientObject.id);
			Main.stage.removeEventListener(Event.RESIZE, onResize);
			chatContainer.removePanel(chatPanel);
			clientObject = null;
		}
		
		public function onResize(e:Event = null):void {
			chatContainer.repaint(new Point(Main.stage.stageWidth - 42, 400));
			if (chatPanel.hiden) {
				chatContainer.y = Main.stage.stageHeight + 1;
			} else {
				chatContainer.y = Main.stage.stageHeight - chatContainer.currentSize.y + 1;
			}
			
		}
		
		public function showMessages(clientObject:ClientObject, messages:Array):void {
			Main.console.writeToConsole("ChatModel showMessages", 0xff0000);
			var chatPanel:ChatPanel = clientObject.getParams(ChatModelBase) as ChatPanel;
			var len:int = messages.length;
			for (var i:int = 0; i < len; i++) {
				var message:ChatMessage = messages[i];
				showChatMessage(chatPanel, clientObject.id, message.selfMessage ? ChatPanel.USER_MESSAGE_COLOR : ChatPanel.NORMAL_MESSAGE_COLOR, message);
			}
		}

		public function showSystemMessage(clientObject:ClientObject, systemMessage:ChatMessage):void {
			Main.console.writeToConsole("ChatModel showSystemMessage", 0xff0000);
			Main.console.writeToConsole("ChatModel clientObject: " + clientObject);
			Main.console.writeToConsole("ChatModel id: " + clientObject.id);
			var chatPanel:ChatPanel = clientObject.getParams(ChatModelBase) as ChatPanel;
			showChatMessage(chatPanel, clientObject.id, ChatPanel.SYSTEM_MESSAGE_COLOR, systemMessage);
		}
		
		private function showChatMessage(chatPanel:ChatPanel, contactId:Long, messageColor:uint, message:ChatMessage):void {
			Main.console.writeToConsole("ChatModel showChatMessage", 0xff0000);
			chatPanel.addMessage(new ClientChatMessage(contactId, message.name, message.text, messageColor));
		}
		
		private function onSendChatMessage(e:ChatEvent):void {
			Main.console.writeToConsole("ChatModel sendMessage clientObjectId: " + clientObject.id, 0xff0000);
			sendMessage(clientObject, e.text);
		}

	}
}