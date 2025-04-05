package alternativa.model.general.dispatcher {
	import alternativa.init.Main;
	import alternativa.model.IModel;
	import alternativa.model.IObjectLoadListener;
	import alternativa.network.command.ControlCommand;
	import alternativa.object.ClientObject;
	import alternativa.protocol.codec.ICodec;
	import alternativa.protocol.codec.NullMap;
	import alternativa.protocol.codec.complex.ArrayCodec;
	import alternativa.protocol.factory.ICodecFactory;
	import alternativa.register.ObjectRegister;
	import alternativa.register.SpaceInfo;
	import alternativa.resource.Resource;
	import alternativa.resource.ResourceInfo;
	import alternativa.service.ISpaceService;
	import alternativa.types.Long;
	import alternativa.types.LongFactory;
	
	import flash.utils.IDataInput;
	
	/**
	 * Модель корневого объекта спейса. Отвечает за обработку команд загрузки объектов и выгрузки ресурсов и объектов.
	 */
	public class DispatcherModel implements IModel {
		/**
		 * Реестр объектов спейса, команда которого обрабатывается. Ссылка устанавливается обработчиком команд спейса перед обработкой команд
		 * загрузки/выгрузки.
		 */		
		private var _objectRegister:ObjectRegister;
		
		/**
		 * @inheritDoc
		 */
		public function _initObject(clientObject:ClientObject, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void {
		}
		
		/**
		 * @inheritDoc
		 */
		public function invoke(clientObject:ClientObject, methodId:Long, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void {
			var long0:Long = LongFactory.getLong(0, 0);
			var long1:Long = LongFactory.getLong(0, 1);
			var long2:Long = LongFactory.getLong(0, 2);
			
			switch (methodId) {
				case long0:
				// space connected
					var spaceId:Long = Long(codecFactory.getCodec(Long).decode(dataInput, nullMap, true));
					var space:SpaceInfo;
					var spaces:Array = ISpaceService(Main.osgi.getService(ISpaceService)).spaceList;
					for (var i:int = 0; i < spaces.length; i++) {
						if (SpaceInfo(spaces[i]).objectRegister == _objectRegister) {
							space = SpaceInfo(spaces[i]);
						}
					}
					if (space != null) {
						ISpaceService(Main.osgi.getService(ISpaceService)).setIdForSpace(space, spaceId);

						Main.writeToConsole("[DispatcherModel.invoke] space id is set to " + spaceId)
					}
					break;
				// Загрузка объекта
				case long1:
					loadEntities(codecFactory, dataInput, nullMap);
					break;
				// Выгрузка объекта или ресурса
				case long2:
					Main.writeToConsole("[DispatcherModel.invoke] UNLOAD command recieved");
					unloadEntities(codecFactory, dataInput, nullMap);
					break;
			}			
		}
		
		/**
		 * Загружает уазанные в команде сущности.
		 * 
		 * @param methodId
		 * @param codecFactory
		 * @param dataInput
		 * @param nullMap
		 */
		private function loadEntities(codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void {
			// Получение массива идентификаторов загружаемых объектов
			var idArrayCodec:ICodec = Main.codecFactory.getArrayCodec(Long, false);
			
			var objectIds:Array = idArrayCodec.decode(dataInput, nullMap, true) as Array;
			
			var modelIds:Array;
			var idCodec:ICodec = Main.codecFactory.getCodec(Long);
			
			// Загрузка каждого объекта
			var objectsCount:int = objectIds.length;
			for (var i:int = 0; i < objectsCount; i++) {
				var objectId:Long = objectIds[i];
				Main.writeToConsole(" ");
				Main.writeToConsole("load object id: " + objectId);
				var parentId:Long = Long(idCodec.decode(dataInput, nullMap, false));
				Main.writeToConsole("load object parentId: " + parentId);
				modelIds = idArrayCodec.decode(dataInput, nullMap, false) as Array;
				Main.writeToConsole("load object modelId: " + modelIds);
				Main.writeToConsole(" ");
				
				// Создание объекта
				var object:ClientObject = _objectRegister.createObject(objectId, _objectRegister.getObject(parentId), "object " + objectId.toString(), modelIds);
				
				// Инициализация моделей объекта
				var idx:int;
				var modelsCount:int = modelIds.length;
				for (idx = 0; idx < modelsCount; idx++) {
					var model:IModel = Main.modelsRegister.getModel(modelIds[idx]) as IModel;
					if (model == null) {
						Main.writeToConsole("Model with id [" + modelIds[idx] + "] not found in registry", 0xFF0000);
					} else {
						Main.writeToConsole(" ");
						Main.writeToConsole("DispatcherModel initObject model: " + model);
						Main.writeToConsole("DispatcherModel initObject data length: " + dataInput.bytesAvailable);
						Main.writeToConsole("DispatcherModel initObject nullMap size: " + nullMap.getSize());
						Main.writeToConsole(" ");
						model._initObject(object, codecFactory, dataInput, nullMap);
					}
				}
				// Оповещение слушателей о завершении загрузки объекта
				for (idx = 0; idx < modelsCount; idx++) {
					var listener:IObjectLoadListener = Main.modelsRegister.getModel(modelIds[idx]) as IObjectLoadListener;
					if (listener != null) {
						listener.objectLoaded(object);
					}
				}
			}
		}
		
		/**
		 * Выгружает уазанные в команде сущности.
		 * 
		 * @param methodId
		 * @param codecFactory
		 * @param dataInput
		 * @param nullMap
		 */
		private function unloadEntities(codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void {
			var longArrayCodec:ArrayCodec = ArrayCodec(codecFactory.getArrayCodec(Long, true, 1));
			
			var objectIds:Array = longArrayCodec.decode(dataInput, nullMap, true) as Array;
			Main.writeToConsole("[DispatcherModel.invoke] unload " + objectIds);
			
			var resourceArrayCodec:ArrayCodec = ArrayCodec(codecFactory.getArrayCodec(Resource, true, 1));
			var resourceForUnload:Array = resourceArrayCodec.decode(dataInput, nullMap, true) as Array;
			
			// выгрузка объектов
			var i:int;
			for (i = 0; i < objectIds.length; i++) {
				_objectRegister.destroyObject(objectIds[i]);
			}
			var resourceId:Array = new Array();
			var resourceVersion:Array = new Array();
			for (i = 0; i < resourceForUnload.length; i++) {
				resourceId.push(ResourceInfo(resourceForUnload[i]).id);
				resourceVersion.push(ResourceInfo(resourceForUnload[i]).version);
			}
			// выгрузка ресурсов
			Main.controlHandler.executeCommand(new Array([new ControlCommand(ControlCommand.UNLOAD_RESOURCES, "unload resources", new Array(resourceId, resourceVersion))]));
		}
		
		/**
		 * Реестр объектов спейса.
		 */
		public function set objectRegister(register:ObjectRegister):void {
			_objectRegister = register;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get id():Long {
			return LongFactory.getLong(0, 1);
		}

	}
}