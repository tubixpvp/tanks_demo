package alternativa.loader {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	final public class PriorConsole extends Sprite {

		private var tf:TextFormat;
		public var log:TextField;
		public var input:TextField;
		private var counter:int;
		private var command:String;
		
		private var align:Boolean;
		private const ALIGN_LEFT:Boolean = false;
		private const ALIGN_RIGHT:Boolean = true;
		private var blockedChannels:Object = {};
		private var visibleChannels:Object = {};
		private var blockChannels:Boolean = false;
		private var showChannels:Boolean = false;
		
		private var linuxChars:Array = new Array();
		
		public function PriorConsole() {
			this.tabEnabled = false;
			this.tabChildren = false;
			this.mouseEnabled = false;
			
			// Формат текста
			tf = new TextFormat("Tahoma", 11, 0);

			// Создаём поле консоли
			log = new TextField();
			log.defaultTextFormat = tf;
			log.type = TextFieldType.DYNAMIC;
			log.multiline = true;
			log.wordWrap = true;
			log.background = true;
			log.backgroundColor = 0xFFFFFF;
			addChild(log);
			
			// Создаём поле ввода
			input = new TextField();
			input.defaultTextFormat = tf;
			input.type = TextFieldType.INPUT;
			input.multiline = false;
			input.wordWrap = false;
			input.background = true;
			input.backgroundColor = 0xcccccc;
			input.border = true;
			input.borderColor = 0x666666;
			addChild(input);
			input.addEventListener(KeyboardEvent.KEY_DOWN, onEnterCommand);
			
			
			linuxChars[202] = 0x0439;
			linuxChars[195]  = 0x0446;
			linuxChars[213]  = 0x0443;
			linuxChars[203]  =  0x043A;
			linuxChars[197]  =  0x0435;
			linuxChars[206]  =  0x043D;
		}
		
		public function initConsole(blockedChannelsStr:String, visibleChannelsStr:String):void {
			// По умолчанию не показывать консоль
			//hide();
			if (visibleChannelsStr != null) {
				showChannels = true;
				channels = visibleChannelsStr.split(",");
				for each (s in channels) {
					visibleChannels[s] = true;
				}
			} else {
				if (blockedChannelsStr != null) {
					blockChannels = true;
					var channels:Array = blockedChannelsStr.split(",");
					for each (var s:String in channels) {
						blockedChannels[s] = true;
					}
				}
			}
			stage.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
			write("Консоль загружена");
			write(" ");
			
			stage.focus = input;
		}
		
		public function dispose():void {
			hide();
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown, true);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onStageKeyUp, true);
			stage.removeEventListener(Event.RESIZE, onResize);
		}
		
		public function show():void {
			visible = true;
		}

		public function hide():void {
			visible = false;
			//log.text = "";
			//log.htmlText = "";
		}
		
		public function clear():void {
			log.text = "";
			counter = 0;
			write(" Консоль очищена");
		}
		
		private function onEnterCommand(event:KeyboardEvent):void {
			if (event.keyCode == 13) {
				command = input.text;
				input.text = "";
				
				log.appendText((counter++) + " " + command + "\n");
				log.scrollV = log.maxScrollV;
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function getCommand():String {
			return command;
		}
		
		private function onStageKeyUp(event:KeyboardEvent):void {
			/*if(Boolean(Capabilities.os.search("Linux")!=-1)){
				event.keyCode = linuxChars[event.keyCode];
			}*/
		}
		private function onStageKeyDown(event:KeyboardEvent):void {
			/*if(Boolean(Capabilities.os.search("Linux")!=-1)){
				writeToChannel("KEYCODE", "code: " + event.keyCode.toString() + " char: " + String.fromCharCode(linuxChars[event.keyCode]));
				event.keyCode = linuxChars[event.keyCode];
			} else {
				writeToChannel("KEYCODE", "code: " + event.keyCode.toString());
			}*/
			
			
			if ((event.keyCode == Keyboard.BACKQUOTE && event.ctrlKey) || (event.keyCode == Keyboard.NUMPAD_0)) {
			//if (event.keyCode == Keyboard.SPACE && event.ctrlKey) {
				visible ? hide() : show();
			}
			if ( event.ctrlKey && event.shiftKey) {
				if (event.keyCode == Keyboard.LEFT) {
					align = ALIGN_LEFT;
					onResize();
				} else if (event.keyCode == Keyboard.RIGHT) {
					align = ALIGN_RIGHT;
					onResize();
				}
			}
		}
		
		private function onResize(e:Event = null):void {
			log.width = stage.stageWidth >>> 1;
			log.height = stage.stageHeight - 18;
			
			
			input.width = stage.stageWidth >>> 1;
			input.height = 18;
			input.y = stage.stageHeight - 18;
			
			if (align == ALIGN_LEFT) {
				log.x = 0;
				input.x = 0;
			} else {
				log.x = log.width;
				input.x = log.width;
			}
		}
		
		public function write(message:String, color:int = 0):void {
			writeToChannel("SYS", message);
		}
		
		public function writeToChannel(channel:String, message:String):void {
			if (visible) {
				if (showChannels) {
					if (visibleChannels[channel] == true) {
						addMessage(channel, message);
					}
				} else if (blockChannels) {
					if (blockedChannels[channel] == null) {
						addMessage(channel, message);
					}
				} else {
					addMessage(channel, message);
				}
			}
		}
		
		private function addMessage(channel:String, message:String):void {
			var strings:Array = ("[" + channel + "] " + message).split("\n");
			for (var i:int = 0; i < strings.length; i++) {
				log.appendText((counter++) + " " + String(strings[i]) + "\n");
			} 
			log.scrollV = log.maxScrollV;
		}
		
	}
}