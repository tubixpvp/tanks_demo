package alternativa.debug {
	import alternativa.init.Main;
	import alternativa.osgi.service.console.IConsoleService;
	import alternativa.osgi.service.dump.IDumpService;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	
	public class Debug implements IDebugCommandProvider, IDebugCommandHandler {
		
		private var _handlers:Dictionary;
		private var _commandList:Array;
		
		private static var errorWindow:ErrorWindow;
		private static var serverMessageWindow:ServerMessageWindow;
		
		public function Debug() {
			errorWindow = new ErrorWindow();
			serverMessageWindow = new ServerMessageWindow();
			
			_handlers = new Dictionary();
			_commandList = new Array();
			
			registerCommand("dump", this);
			registerCommand("hide", this);
			registerCommand("show", this);
			registerCommand("help", this);
			
			EventDispatcher(IConsoleService(Main.osgi.getService(IConsoleService)).console).addEventListener(Event.COMPLETE, consoleCommand);
			
			Main.stage.addEventListener(Event.RESIZE, onStageResize);
		}
		
		private function consoleCommand(e:Event):void {
			var command:String = IConsoleService(Main.osgi.getService(IConsoleService)).console.getCommand();
			var result:String = executeCommand(command);
			if (result != null && result != "") {
				IConsoleService(Main.osgi.getService(IConsoleService)).writeToConsole(result);
			}			
		}
		
		public function execute(command:String):String {
			var result:String;
			var strings:Vector.<String> = Vector.<String>(command.split(" "));
			var name:String = strings.shift();
			switch (name) {
				case "help":
					result = "\n";
					for (var i:int = 0; i < _commandList.length; i++) {
						result += "	  " + _commandList[i] + "\n";
					}
					result += "\n";
					break;
				case "dump":
					var dumpService:IDumpService = IDumpService(Main.osgi.getService(IDumpService));
					if (dumpService != null) {
						result = dumpService._dump(strings);
					}
					break;
				case "hide":
					IConsoleService(Main.osgi.getService(IConsoleService)).hideConsole();
					break;
				case "show":
					IConsoleService(Main.osgi.getService(IConsoleService)).showConsole();
					break;
				default:
					result = "Unknown command";
					break;
			}
			return result;
		}
		
		public function executeCommand(command:String):String {
			var result:String;
			var name:String = command.split(" ")[0];
			if (_handlers[name] != null) {
				result = IDebugCommandHandler(_handlers[name]).execute(command);
			} else {
				result = "Unknown command";
			}
			return result;
		}
		
		public function registerCommand(command:String, handler:IDebugCommandHandler):void {
			_handlers[command] = handler;
			_commandList.push(command);
		}
		
		public function unregisterCommand(command:String):void {
			_commandList.splice(_commandList.indexOf(command), 1);
			delete _handlers[command];
		}
		
		private function onStageResize(e:Event = null):void {
			if (Main.mainContainer.contains(errorWindow)) {
				errorWindow.x = Math.round((Main.stage.stageWidth - errorWindow.currentSize.x)*0.5);
	    		errorWindow.y = Math.round((Main.stage.stageHeight - errorWindow.currentSize.y)*0.5);
	  		}
	  		if (Main.mainContainer.contains(serverMessageWindow)) {
	  			serverMessageWindow.x = Math.round((Main.stage.stageWidth - serverMessageWindow.currentSize.x)*0.5);
	    		serverMessageWindow.y = Math.round((Main.stage.stageHeight - serverMessageWindow.currentSize.y)*0.5);
	  		}
		}
		
		private function openWindow():void {
			if (!Main.mainContainer.contains(errorWindow)) {
				Main.mainContainer.addChildAt(errorWindow, Main.mainContainer.getChildIndex(Main.noticesLayer));
				onStageResize();
			}
		}
		private function closeWindow():void {
			if (Main.mainContainer.contains(errorWindow)) {
				Main.mainContainer.removeChild(errorWindow);
			}
		}
		
		public function showErrorWindow(message:String):void {
			errorWindow.text = message;
			openWindow();
		}
		public function hideErrorWindow():void {
			closeWindow();
		}
		
		public function showServerMessageWindow(message:String):void {
			serverMessageWindow.text = message;
			if (!Main.mainContainer.contains(serverMessageWindow)) {
				Main.mainContainer.addChildAt(serverMessageWindow, Main.mainContainer.getChildIndex(Main.noticesLayer));
				onStageResize();
			}
		}
		public function hideServerMessageWindow():void {
			if (Main.mainContainer.contains(serverMessageWindow)) {
				Main.mainContainer.removeChild(serverMessageWindow);
			}
		}
		
	}
}