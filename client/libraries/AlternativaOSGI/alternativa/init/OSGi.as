package alternativa.init {
	import __AS3__.vec.Vector;
	
	import alternativa.osgi.bundle.Bundle;
	import alternativa.osgi.bundle.IBundleActivator;
	import alternativa.osgi.service.console.ConsoleService;
	import alternativa.osgi.service.console.IConsoleService;
	import alternativa.osgi.service.dump.DumpService;
	import alternativa.osgi.service.dump.IDumpService;
	import alternativa.osgi.service.dump.dumper.BundleDumper;
	import alternativa.osgi.service.dump.dumper.IDumper;
	import alternativa.osgi.service.dump.dumper.ServiceDumper;
	import alternativa.osgi.service.loader.ILoaderService;
	import alternativa.osgi.service.loader.LoaderService;
	import alternativa.osgi.service.mainContainer.IMainContainerService;
	import alternativa.osgi.service.mainContainer.MainContainerService;
	import alternativa.osgi.service.network.INetworkService;
	import alternativa.osgi.service.network.NetworkService;
	import alternativa.osgi.service.storage.IStorageService;
	import alternativa.osgi.service.storage.StorageService;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.net.SharedObject;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	
	/**
	 * Open Services Gateway initiative implementation
	 */
	public class OSGi {
		
		private static var instance:OSGi;
		private var bundles:Dictionary;
		private var _bundleList:Vector.<Bundle>;
		private var services:Dictionary;
		private var _serviceList:Vector.<Object>;
		
		
		public function OSGi() {
			services = new Dictionary(false);
			bundles = new Dictionary(false);
			_bundleList = new Vector.<Bundle>();
			_serviceList = new Vector.<Object>();
		}
		
		/**
		 * Инициализирует библиотеку.
		 * 
		 * @param _stage stage флэшки
		 * @param container базовый контейнер, в котором располагается вся прочая графика 
		 * @param server адрес командного сервера
		 * @param port порт подключения
		 * @param resources базовый URL ресурсов
		 * @param loadedLibraries список загруженных, но не инициализированных базовых библиотек
		 * @param log объект, реализующий функционал консоли
		 * @param sharedObject
		 */
		public static function init(_stage:Stage, container:DisplayObjectContainer, server:String, port:int, resources:String, log:Object, sharedObject:SharedObject):OSGi {
			instance = new OSGi();
			
			// Регистрация базовых сервисов
			instance.registerService(IConsoleService, new ConsoleService(log));
			//instance.registerService(ILogService, new LogService(log));
			instance.registerService(IMainContainerService, new MainContainerService(_stage, container));
			instance.registerService(INetworkService, new NetworkService(server, port, resources));
			instance.registerService(IStorageService, new StorageService(sharedObject));
			var dumpService:IDumpService = new DumpService(instance);
			instance.registerService(IDumpService, dumpService);
			instance.registerService(ILoaderService, new LoaderService());
			
			// Дамперы
			var dumper:IDumper = new BundleDumper(instance);
			dumpService.registerDumper(dumper, dumper.name);
			dumper = new ServiceDumper(instance);
			dumpService.registerDumper(dumper, dumper.name);
			
			return instance;
		}
		
		/**
		 * Установка плагина
		 * @return информация о плагине
		 */		
		public function installBundle(manifest:String):Bundle {
			// Парсинг манефеста
			var bundle:Bundle = parseManifest(manifest);
			if (bundle != null) {
				if (bundles[bundle.name] == null) {
					// Сохранение плагина
					bundles[bundle.name] = bundle;
					_bundleList.push(bundle);
					// Активация плагина
					if (bundle.activator != null) {
						bundle.activator.start(this);
					}
				} else {
					throw new Error("Bundle already installed");
				}
			} else {
				IConsoleService(getService(IConsoleService)).writeToConsole("OSGi bundle = null");
			}
			IConsoleService(getService(IConsoleService)).writeToConsole("OSGi bundle " + bundle.name + " installed");
			return bundle;
		}
		
		/**
		 * Парсинг манифеста
		 * @param manifest
		 * @return структурированные данные манифеста
		 */		
		private function parseManifest(manifest:String):Bundle {
			
			var manifestStrings:Array = manifest.split("\n");
			var manifestParams:Dictionary = new Dictionary(false);
			
			for (var i:int = 0; i < manifestStrings.length; i++) {
				var s:String = String(manifestStrings[i]);
				var parts:Array = s.split(":", 2);
				var value:String = String(parts[1]);
				if (value.charAt(0) == " ") {
					value = value.substr(1, value.length-1);
				}
				manifestParams[parts[0]] = value;
			}
			var name:String = manifestParams["Bundle-Name"];
			var activatorClassName:String = manifestParams["Bundle-Activator"];
			if (ApplicationDomain.currentDomain.hasDefinition(activatorClassName)) {
				var activatorClass:Class = Class(ApplicationDomain.currentDomain.getDefinition(activatorClassName));
				var activator:IBundleActivator = IBundleActivator(new activatorClass());
			}
			if (name != "" && name != null) {
				return new Bundle(name, activator, manifestParams);
			} else {
				throw new Error("Manifest not valid");
			}
		}
		
		/**
		 * Удаление плагина
		 * @return 
		 */
		public function uninstallBundle(bundle:Bundle):void {
			bundle.activator.stop(this);
			
			_bundleList.splice(_bundleList.indexOf(bundle), 1);
			delete bundles[bundle.name];
			
			IConsoleService(getService(IConsoleService)).writeToConsole("OSGi bundle " + bundle.name + " uninstalled");
		}
		
		/**
		 * Регистрация сервиса
		 * @param serviceInterface
		 * @param serviceImplementation 
		 * @return код регистрации
		 * 
		 */		
		public function registerService(serviceInterface:Class, serviceImplementation:Object):void {
			if (services[serviceInterface] == null) {
				services[serviceInterface] = serviceImplementation;
				_serviceList.push(serviceImplementation);
				IConsoleService(getService(IConsoleService)).writeToConsole("OSGi service " + serviceInterface + " registered");
			} else {
				throw new Error("Service already registered");
			}
		}
		
		/**
		 * Удаление регистрации сервиса
		 * @param serviceRegistration код регистрации
		 */		
		public function unregisterService(serviceInterface:Class):void {
			_serviceList.splice(_serviceList.indexOf(services[serviceInterface]), 1);
			delete services[serviceInterface];
			IConsoleService(getService(IConsoleService)).writeToConsole("OSGi service " + serviceInterface + " unregistered");
		}
		
		/**
		 * Получить реализацию сервиса
		 * @param serviceInterface интерфейс сервиса
		 * @return реализация сервиса
		 */		
		public function getService(serviceInterface:Class):Object {
			return services[serviceInterface];
		}
		
		/**
		 * Список плагинов
		 */		
		public function get bundleList():Vector.<Bundle> {
			return _bundleList;
		}
		
		/**
		 * Список сервисов
		 */		
		public function get serviceList():Vector.<Object> {
			return _serviceList;
		}

	}
	
}