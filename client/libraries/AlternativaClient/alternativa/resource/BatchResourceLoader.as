package alternativa.resource {
	import alternativa.init.Main;
	import alternativa.model.IResourceBatchLoadListener;
	import alternativa.osgi.service.network.INetworkService;
	import alternativa.resource.factory.IResourceFactory;
	import alternativa.types.Long;
	import alternativa.types.LongFactory;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * Класс реализует пакетную загрузку ресурсов.
	 */
	public class BatchResourceLoader {

		/**
		 * Идентификатор загружаемого пакета ресурсов.
		 */
		public var batchId:int;
		/**
		 * Массив идентификаторов ресурсов, разбитых по уровням. Каждый уровень представлен своим массивом идентификаторов.
		 * Загрузка уровней выполняется с конца массива.
		 */
		public var resourceIds:Array;
		/**
		 * Слушатель окончания загрузки пакета ресурсов.
		 */
		public var listener:IResourceBatchLoadListener;
		
		/**
		 * Индекс текущего загружаемого уровня.
		 */		
		private var levelIndex:int;
		/**
		 * Массив идентификаторов ресурсов текущего уровня.
		 */
		private var levelResourceIds:Array;
		/**
		 * Индекс текущего ресурса.
		 */
		private var resourceIndex:int;
		/**
		 * Количество незагруженных ресурсов текущего уровня.
		 */		
//		private var remainingResources:int;
		
		/**
		 * Количество обязательных для загрузки ресурсов 
		 */		
		private var resourcesTotalNum:int;
		/**
		 * Количество загруженных ресурсов 
		 */		
		private var resourcesLoadedNum:int;
		
		private var resourcesById:Dictionary;
		
		/**
		 * 
		 */
		public function BatchResourceLoader(batchId:int, resourceIds:Array, listener:IResourceBatchLoadListener) {
			this.batchId = batchId;
			this.resourceIds = resourceIds;
			this.listener = listener;
			
			resourcesById = new Dictionary();
		}
		
		/**
		 * 
		 */
		public function load():void {
			Main.writeVarsToConsole("[BatchResourceLoader::load] batchId: %1, levels count %2", batchId, resourceIds.length);
			
			resourcesTotalNum = 0;
			resourcesLoadedNum = 0;
			for (var i:int = 0; i < resourceIds.length; i++) {
				for (var j:int = 0; j < resourceIds[i].length; j++) {
//					if (!ResourceInfo(resourceIds[i][j]).isOptional) {
						resourcesTotalNum++;
//					}
				}
			}
			LoadingProgress(Main.loadingProgress).setStatus(batchId, "Загрузка группы ресурсов id: " + batchId.toString());
			LoadingProgress(Main.loadingProgress).setProgress(batchId, 0);
			
			levelIndex = resourceIds.length - 1;
			loadLevel();
		}
		
		/**
		 * Загружает следующий уровень ресурсов и оповещает слушателя об окончании загрузки пакета, если уровни кончились.
		 */
		private function loadLevel():void {
			Main.writeVarsToConsole("[BatchResourceLoader.loadNextLevel] level %1", levelIndex);
			levelResourceIds = resourceIds[levelIndex];
			resourceIndex = levelResourceIds.length - 1;
			loadResource();
		}
		
		/**
		 * Загружает ресурс.
		 * 
		 * @param id
		 * @param version
		 * @param type
		 */
		private function loadResource():void {
			var resourceInfo:ResourceInfo = ResourceInfo(levelResourceIds[resourceIndex]);
			// Проверяем наличие ресурса в реестре и пропускаем загрузку, если ресурс найден
			if (Main.resourceRegister.getResource(resourceInfo.id) != null) {
				Main.writeVarsToConsole("[BatchResourceLoader.loadResource] resource with id %1 already exists. Loading skipped.", resourceInfo.id);
				resourcesLoadedNum++;
				// Переходим к загрузке следующего ресурса
				resourceLoaded();
			} else {
				LoadingProgress(Main.loadingProgress).setStatus(batchId, "Загрузка группы ресурсов id: " + batchId + " (resId: " + resourceInfo.id + " start)");
				Main.writeVarsToConsole("[BatchResourceLoader.loadResource] level: %1, type: %2, id: %3", levelIndex, resourceInfo.type, resourceInfo.id);
				// Получаем загрузчик
				var resourceFactory:IResourceFactory = Main.resourceRegister.getResourceFactory(resourceInfo.type);
				if (resourceFactory != null) {
					// Создаём ресурс
					var resource:Resource = resourceFactory.createResource(resourceInfo.type, this);
					
					resourcesById[resourceInfo.id] = resource;
					
					if (resource == null) {
						Main.writeToConsole("[ERROR][BatchResourceLoader.loadResource] resource factory has returned null resource", 0xFF0000);
					}
					resource.id = resourceInfo.id;
					resource.isOptional = resourceInfo.isOptional;
					// Загружаем ресурс
					resource.load(makeResourceUrl(resourceInfo.id, resourceInfo.version, resourceInfo.type));
				} else {
					Main.writeToConsole("[ERROR][BatchResourceLoader::loadResource] Factory not found for resource type " + resourceInfo.type, 0xFF0000);
				}
			}
		}

		/**
		 * Регистрирует загруженный ресурс в реестре и запускает загрузку следующего ресурса или уровня.
		 */
		public function resourceLoaded(resource:IResource = null):void {
			if (resource != null) {
				Main.writeVarsToConsole("[batchResourceLoader.resourceLoaded] Resource [%1][%2:%3] is LOADED", resource.name, resource.id, resource.version);
				// Отображение прогресса
				resourcesLoadedNum++;
				LoadingProgress(Main.loadingProgress).setStatus(batchId, "Загрузка группы ресурсов id: " + batchId.toString() + " (resId: " + resource.id + " finish)");
				LoadingProgress(Main.loadingProgress).setProgress(batchId, resourcesLoadedNum/resourcesTotalNum);
				// Регистрирация ресурса в реестре
				Main.resourceRegister.registerResource(resource);
			}

			if (resourceIndex > 0) {
				// Продолжается загрузка уровня
				resourceIndex--;
				loadResource();
			} else {
				if (levelIndex > 0) {
					// Загрузка следующего уровня
					levelIndex--;
					loadLevel();
				} else {
					// Все ресурсы пакета успешно загружены, информируем слушателя
					Main.writeVarsToConsole("[BatchResourceLoader] batch [%1] is LOADED", batchId);
					if (listener != null) {
						listener.resourceBatchLoaded(this);
					}
				}
			}
		}

		/**
		 * Формирует базовый URL ресурса.
		 * 
		 * @param id
		 * @param version
		 * @param type
		 * @return 
		 */
		private function makeResourceUrl(id:Long, version:Long, type:int):String {
			var url:String = INetworkService(Main.osgi.getService(INetworkService)).resourcesPath;
			var longId:ByteArray = LongFactory.LongToByteArray(id);
			
			url += "/" + longId.readInt().toString(16);
			url += "/" + longId.readShort().toString(16);
			url += "/" + longId.readByte().toString(16);
			url += "/" + longId.readByte().toString(16);
			url += "/";
			
			var longVersion:ByteArray = LongFactory.LongToByteArray(version);
			var versHigh:int = longVersion.readInt();
			var versLow:int = longVersion.readInt();
			if (versHigh != 0) {
				url += versHigh.toString(16);
			}
			url += versLow.toString(16) + "/";
			
			return url;						
		}
		
	}
}