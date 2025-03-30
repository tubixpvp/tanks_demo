package alternativa.init {
	import alternativa.debug.Debug;
	import alternativa.debug.dump.ObjectDumper;
	import alternativa.debug.dump.SpaceDumper;
	import alternativa.model.IModel;
	import alternativa.model.general.dispatcher.DispatcherModel;
	import alternativa.network.AlternativaNetworkClient;
	import alternativa.network.CommandSocket;
	import alternativa.network.command.ControlCommand;
	import alternativa.network.command.SpaceCommand;
	import alternativa.network.handler.ControlCommandHandler;
	import alternativa.osgi.bundle.IBundleActivator;
	import alternativa.osgi.service.console.IConsoleService;
	import alternativa.osgi.service.dump.IDumpService;
	import alternativa.osgi.service.dump.dumper.IDumper;
	import alternativa.osgi.service.loader.ILoaderService;
	import alternativa.osgi.service.log.ILogService;
	import alternativa.osgi.service.mainContainer.IMainContainerService;
	import alternativa.osgi.service.network.INetworkService;
	import alternativa.osgi.service.loader.LoaderService;
	import alternativa.protocol.Protocol;
	import alternativa.protocol.codec.ControlRootCodec;
	import alternativa.protocol.codec.ResourceCodec;
	import alternativa.protocol.codec.SpaceRootCodec;
	import alternativa.protocol.factory.CodecFactory;
	import alternativa.protocol.factory.ICodecFactory;
	import alternativa.register.ClassRegister;
	import alternativa.register.ModelsRegister;
	import alternativa.register.ResourceRegister;
	import alternativa.register.SpaceRegister;
	import alternativa.resource.LoadingProgress;
	import alternativa.resource.ResourceInfo;
	import alternativa.resource.ResourceType;
	import alternativa.resource.ResourceWrapper;
	import alternativa.resource.factory.LibraryResourceFactory;
	import alternativa.resource.factory.MovieClipResourceFactory;
	import alternativa.resource.factory.SoundResourceFactory;
	import alternativa.resource.factory.TextureResourceFactory;
	import alternativa.service.IClassService;
	import alternativa.service.ISpaceService;
	import alternativa.service.ServerLogService;
	import alternativa.types.Long;
	import alternativa.types.LongFactory;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	
	
	public class Main implements IBundleActivator {
		
		public static var resourceRegister:ResourceRegister;
		
		//public static var spaceRegister:SpaceRegister;
		
		public static var modelsRegister:ModelsRegister;
		
		public static var stage:Stage;
		public static var mainContainer:DisplayObjectContainer;
		public static var backgroundLayer:DisplayObjectContainer;
		public static var contentLayer:DisplayObjectContainer;
		public static var contentUILayer:DisplayObjectContainer;
		public static var systemLayer:DisplayObjectContainer;
		public static var systemUILayer:DisplayObjectContainer;
		public static var dialogsLayer:DisplayObjectContainer;
		public static var noticesLayer:DisplayObjectContainer;
		public static var cursorLayer:DisplayObjectContainer;
		
		private static var controlSocket:CommandSocket;
		public static var controlHandler:ControlCommandHandler;
		private static var networkClient:AlternativaNetworkClient;
		
		public static var codecFactory:ICodecFactory;
		
		public static var loadingProgress:LoadingProgress;
		
		public static var debug:Debug;
		
		public static var osgi:OSGi;
		
		
		public function start(_osgi:OSGi):void {
			osgi = _osgi;
			
			// Сервисы реестров
			osgi.registerService(IClassService, new ClassRegister()); 
			osgi.registerService(ISpaceService, new SpaceRegister()); 
			
			writeToConsole("Main start");
			// Дамперы
			var dumpService:IDumpService = IDumpService(osgi.getService(IDumpService));
			var dumper:IDumper = new SpaceDumper();
			dumpService.registerDumper(dumper, dumper.name);
			dumper = new ObjectDumper();
			dumpService.registerDumper(dumper, dumper.name);
			//dumper = new ModelDumper();
			//dumpService.registerDumper(dumper, dumper.name);
			
			// Фабрика кодеков
			codecFactory = new CodecFactory();
			codecFactory.registerCodec(ControlCommand, new ControlRootCodec(codecFactory));
			codecFactory.registerCodec(SpaceCommand, new SpaceRootCodec(codecFactory));
			codecFactory.registerCodec(ResourceInfo, new ResourceCodec(codecFactory));
			
			// Протокол канала управления
			var controlProtocol:Protocol = new Protocol(codecFactory, ControlCommand);
			
			var server:String = INetworkService(osgi.getService(INetworkService)).server;
			var port:int = INetworkService(osgi.getService(INetworkService)).port;
			writeToConsole("Main server: " + server);
			writeToConsole("Main port: " + port);
			var resourcesURL:String = INetworkService(osgi.getService(INetworkService)).resourcesPath;
			
			// Создаем сетевой клиент
			networkClient = new AlternativaNetworkClient(server, port, controlProtocol);
			
			// Создаем обработчик канала управления
			controlHandler = new ControlCommandHandler(server, port, resourcesURL);
			
			// Сохраняем реестры ресурсов, моделей и спэйсов
			resourceRegister = controlHandler.resourceRegister;
			modelsRegister = controlHandler.modelsRegister;
			//spaceRegister = controlHandler.spaceRegister;
			
			// Регистрация диспетчер модели
			var long1:Long = LongFactory.getLong(0, 1);
			var long2:Long = LongFactory.getLong(0, 2);
			var long3:Long = LongFactory.getLong(0, 3);
			modelsRegister.register(long1, long1);
			modelsRegister.register(long1, long2);
			modelsRegister.register(long1, long3);
			var model:IModel = new DispatcherModel();
			modelsRegister.add(model, new Array([IModel]));
			
			stage = IMainContainerService(osgi.getService(IMainContainerService)).stage;
			mainContainer = IMainContainerService(osgi.getService(IMainContainerService)).mainContainer;
			
			// Создаем слои
			backgroundLayer = addLayerSprite();
			contentLayer = addLayerSprite();
			contentUILayer = addLayerSprite();
			systemLayer = addLayerSprite();
			systemUILayer = addLayerSprite();
			dialogsLayer = addLayerSprite();
			noticesLayer = addLayerSprite();
			cursorLayer = addLayerSprite();
			
			// Регистрация фабрик ресурсов
			resourceRegister.registerResourceFactory(new LibraryResourceFactory(), ResourceType.LIBRARY);
			resourceRegister.registerResourceFactory(new TextureResourceFactory(), ResourceType.TEXTURE);
			resourceRegister.registerResourceFactory(new SoundResourceFactory(), ResourceType.MP3);
			resourceRegister.registerResourceFactory(new MovieClipResourceFactory(), ResourceType.MOVIE_CLIP);
			
			loadingProgress = new LoadingProgress();
			
			debug = new Debug();
		}

		public static function get console() : IConsoleService
		{
			return osgi.getService(IConsoleService) as IConsoleService;
		}
		
		public function stop(osgi:OSGi):void {
			
		}
		
		private static function addLayerSprite():Sprite {
			var sprite:Sprite = new Sprite();
			sprite.mouseEnabled = false;
			sprite.tabEnabled = false;
			mainContainer.addChild(sprite);
			return sprite;
		}
		
		public static function onMainLibrariesLoaded(loadedLibraries:Array):void {
			writeToConsole("Main onMainLibrariesLoaded");
			// Регистрируем загруженные базовые библиотеки
			for (var i:int = 0; i < loadedLibraries.length; i++) {
				var libraryWrapper:ResourceWrapper = new ResourceWrapper(loadedLibraries[i]);
				resourceRegister.registerResource(libraryWrapper);
			}
			//osgi.registerService(ILoaderService, new LoaderService(/*loadedLibraries*/));
			
			// Открываем канал управления
			controlSocket = networkClient.newConnection(Main.controlHandler);
			
			// Сервис логирования
			osgi.registerService(ILogService, new ServerLogService(controlSocket));
		}
		
		public static function writeToConsole(message:String, color:uint = 0):void {
			IConsoleService(Main.osgi.getService(IConsoleService)).writeToConsole(message);
		}

		public static function writeVarsToConsole(message:String, ... vars):void {
			for (var i:int = 0; i < vars.length; i++) {
				message = message.replace("%" + (i + 1), vars[i]);
			}
			IConsoleService(Main.osgi.getService(IConsoleService)).writeToConsole(message);
		}
		
		public static function hideConsole():void {
			IConsoleService(Main.osgi.getService(IConsoleService)).hideConsole();
		}

		public static function showConsole():void {
			IConsoleService(Main.osgi.getService(IConsoleService)).showConsole();
		}
		

	}
}