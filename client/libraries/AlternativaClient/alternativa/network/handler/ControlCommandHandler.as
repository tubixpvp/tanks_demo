package alternativa.network.handler {
	
	import alternativa.debug.IDebugCommandProvider;
	import alternativa.init.Main;
	import alternativa.model.IResourceBatchLoadListener;
	import alternativa.network.AlternativaNetworkClient;
	import alternativa.network.ICommandHandler;
	import alternativa.network.ICommandSender;
	import alternativa.network.command.ControlCommand;
	import alternativa.network.command.SpaceCommand;
	import alternativa.osgi.service.console.IConsoleService;
	import alternativa.protocol.Protocol;
	import alternativa.register.ModelsRegister;
	import alternativa.register.ResourceRegister;
	import alternativa.register.SpaceInfo;
	import alternativa.register.SpaceRegister;
	import alternativa.resource.BatchResourceLoader;
	import alternativa.resource.IResource;
	import alternativa.resource.ResourceInfo;
	import alternativa.service.ISpaceService;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	
	public class ControlCommandHandler implements ICommandHandler, IResourceBatchLoadListener {
		
		private var sender:ICommandSender;
		
		private var hashCode:ByteArray;
		
		private var _modelRegister:ModelsRegister;
		
		private var _resourceRegister:ResourceRegister;
		
		private var _spaceRegister:ISpaceService;
		
		private var librariesPath:String;
		
		private var spaceClient:AlternativaNetworkClient;
		
		private var batchLoaders:Dictionary = new Dictionary();
		
		
		//public function ControlCommandHandler(server:String, port:int, librariesPath:String, loadedLibraries:Array) {
		public function ControlCommandHandler(server:String, port:int, librariesPath:String) {
			
			this.librariesPath = librariesPath; 
			
			// Сохранение реестра моделей
			_resourceRegister = new ResourceRegister();
			
			// Сохранение реестра моделей
			_modelRegister = new ModelsRegister();
			
			// Сохранение реестра спэйсов
			_spaceRegister = ISpaceService(Main.osgi.getService(ISpaceService));
			
			var spaceProtocol:Protocol = new Protocol(Main.codecFactory, SpaceCommand);
			
			spaceClient = new AlternativaNetworkClient(server, port, spaceProtocol);
		}
		
		/**
		 * Рассылка события "соединение открыто" 
		 */
		public function open():void {
			IConsoleService(Main.osgi.getService(IConsoleService)).writeToConsole("ControlCommandHandler socket opened");
			sender.sendCommand(new ControlCommand(ControlCommand.HASH_REQUEST, "hashRequest", new Array()), false);
		}
		
		/**
		 * Рассылка события "соединение закрыто"  
		 */
		public function close():void {
			IConsoleService(Main.osgi.getService(IConsoleService)).writeToConsole("ControlCommandHandler socket closed");
		}
		
		/**
		 * Обрабатывает поступившие команды.
		 * @param commandsList список команд
		 */
		public function executeCommand(commandsList:Object):void {
			Main.writeToConsole("ControlCommandHandler executeCommand");
			var commands:Array = commandsList as Array;
			var len:int = commands.length;
			for (var i:int = 0; i < len; i++) {
				var command:Object = commands[i];
				if (command is ByteArray) {
					if (hashCode == null) {
						hashCode = command as ByteArray;
						hashCode.position = 0;
						Main.writeToConsole("Hash принят (" + hashCode.bytesAvailable + " bytes)", 0x0000cc);
						sender.sendCommand(new ControlCommand(ControlCommand.HASH_ACCEPT, "hashAccepted", new Array()), false);
					}
				} else if (command is ControlCommand) {
					var controlCommand:ControlCommand = ControlCommand(command);
					Main.writeToConsole(controlCommand.name + " params: " + controlCommand.params, 0x0000cc);
					switch (controlCommand.id) {
						case ControlCommand.OPEN_SPACE:
							Main.writeToConsole("[ControlCommandHandler.executeCommand] OPEN SPACE NEW", 0x0000cc);
							var handler:ICommandHandler = new SpaceCommandHandler(hashCode, _modelRegister, librariesPath);
							var spaceSocket:ICommandSender = ICommandSender(spaceClient.newConnection(handler));
							var info:SpaceInfo = new SpaceInfo(handler, spaceSocket, SpaceCommandHandler(handler).objectRegister);
							ISpaceService(Main.osgi.getService(ISpaceService)).addSpace(info);
							break;
						case ControlCommand.LOAD_RESOURCE:
							// Загрузка пакета ресурсов
							var batchId:int = int(controlCommand.params[0]);
							Main.writeVarsToConsole("\n[ControlCommandHandler.executeCommand] LOAD [%1]", batchId);
							var resourceIds:Array = controlCommand.params[1] as Array;

							for (var k:int = 0; k < resourceIds.length; k++) {
								for (var l:int = 0; l < resourceIds[k].length; l++) {
									Main.writeToConsole("[ControlCommandHandler.executeCommand] load resource id: " + ResourceInfo(resourceIds[k][l]).id);
								}
							}							
							var batchLoader:BatchResourceLoader = new BatchResourceLoader(batchId, resourceIds, this);
							batchLoaders[batchId] = batchLoader;
							batchLoader.load();
							break;
						case ControlCommand.UNLOAD_RESOURCES:
							// unload
							unloadResources(controlCommand.params[0] as Array, controlCommand.params[1] as Array);
							break;
						case ControlCommand.COMMAND_REQUEST:
							var request:String = String(controlCommand.params[0]);
							Main.writeToConsole("COMMAND_REQUEST: " + request);
							Main.writeToConsole("debug: " + Main.debug);
							Main.writeToConsole("sender: " + sender);
							sender.sendCommand(new ControlCommand(ControlCommand.COMMAND_RESPONCE, "commandResponce", [IDebugCommandProvider(Main.debug).executeCommand(request)]));
							
							/*var dumpService:IDumpService = IDumpService(Main.osgi.getService(IDumpService));
							if (dumpService != null) {
								if (request == "") {
									var dumpersList:Array = dumpService.dumpersList;
									var dump:String = "\nDUMPER LIST:\n";
									for (var n:int = 0; n < dumpersList.length; n++) {
										dump += (n+1).toString() + " " + IDumper(dumpersList[n]).name + "\n";
									}									
									sender.sendCommand(new ControlCommand(ControlCommand.DUMP_RESPONCE, "dumpResponce", [dump]));
								} else {
									var strings:Array = request.split(" ");
									var dumper:IDumper = IDumper(dumpService.dumpers[strings.shift()]);
									if (dumper != null) {
										sender.sendCommand(new ControlCommand(ControlCommand.DUMP_RESPONCE, "dumpResponce", [dumper._dump(strings)]));
									}
								}
							}*/
							break;
						case ControlCommand.SERVER_MESSAGE:
							var type:int = int(controlCommand.params[0]);
							Main.debug.showServerMessageWindow(String(controlCommand.params[1]));
							break;
					}
				}
			}
		}
		
		
		// Выгрузить ресурсы
		private function unloadResources(id:Array, version:Array):void {
			var length:uint = id.length;
			var resource:IResource;
			for (var i:uint = 0; i < length; i++) {
				resource = Main.resourceRegister.getResource(id[i]);
				resource.unload();
				Main.resourceRegister.unregisterResource(id[i]);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function resourceBatchLoaded(batchLoader:BatchResourceLoader):void {
			Main.writeToConsole("ControlCommandHandler resourcesLoaded batchId: " + batchLoader.batchId, 0x0000ff);
			delete batchLoaders[batchLoader.batchId];
			Main.writeToConsole("ControlCommandHandler sendCommand resourcesLoaded", 0x0000ff);
			sender.sendCommand(new ControlCommand(ControlCommand.RESOURCE_LOADED, "resourcesLoaded", [batchLoader.batchId]));
		}
		
		/**
		 * Передатчик команд 
		 */		
		public function get commandSender():ICommandSender {
			return sender;
		}
		public function set commandSender(sender:ICommandSender):void {
			Main.writeToConsole("ControlCommandHandler set sender: " + sender);
			this.sender = sender;
		}
		
		
		public function get resourceRegister():ResourceRegister {
			return _resourceRegister;
		}
		public function get modelsRegister():ModelsRegister {
			return _modelRegister;
		}
		/*public function get spaceRegister():SpaceRegister {
			return _spaceRegister;
		}*/
		
	}
}