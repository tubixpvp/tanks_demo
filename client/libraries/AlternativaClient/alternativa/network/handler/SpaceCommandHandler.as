package alternativa.network.handler {
	
	import alternativa.init.Main;
	import alternativa.model.general.dispatcher.DispatcherModel;
	import alternativa.network.ICommandHandler;
	import alternativa.network.ICommandSender;
	import alternativa.protocol.codec.ICodec;
	import alternativa.protocol.codec.NullMap;
	import alternativa.register.ModelsRegister;
	import alternativa.register.ObjectRegister;
	import alternativa.types.Long;
	import alternativa.types.LongFactory;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	import alternativa.service.ISpaceService;
	import alternativa.register.SpaceInfo;
	import flash.utils.Dictionary;
	import alternativa.object.ClientObject;
	
	/**
	 * Обработчик команд спейса.
	 */
	public class SpaceCommandHandler implements ICommandHandler {

		public var spaceInfo:SpaceInfo;
		
		private var sender:ICommandSender;
		
		private var hashCode:ByteArray;
		private var librariesPath:String;
		
		private var modelRegister:ModelsRegister;
		private var _objectRegister:ObjectRegister;
		
		/**
		 * Создать новый обработчик команд спейса.
		 * 
		 * @param hashCode хэш-код сессии клиента
		 * @param modelRegister центральный реестр моделей
		 * @param librariesPath
		 */
		public function SpaceCommandHandler(hashCode:ByteArray, modelRegister:ModelsRegister, librariesPath:String) {
			this.hashCode = hashCode;
			this.modelRegister = modelRegister;
			this.librariesPath = librariesPath;
			
			// Создание реестра объектов спейса
			_objectRegister = new ObjectRegister(this);
			
			// Создание корневого объекта спейса. Объект имеет модель DispatcherModel с идентификатором 1. Эта
			// модель принимает команды на загрузку и выгрузку объектов спейса.
			_objectRegister.createObject(LongFactory.getLong(0, 0), null, "rootObject", new Array([1]));
		}
			
		/**
		 * Рассылка события "соединение открыто". 
		 */
		public function open():void {
			Main.writeToConsole("[SpaceCommandHandler.open] SPACE OPENED", 0x0000cc);
			sender.sendCommand(Object(hashCode), false);
		}
		
		/**
		 * Рассылка события "соединение закрыто".  
		 */
		public function close():void 
		{
			//not original code:
			var spaceRegister:ISpaceService = Main.osgi.getService(ISpaceService) as ISpaceService;
			spaceRegister.removeSpace(spaceInfo);

			var objects:Dictionary = _objectRegister.getObjects();

			for(var id:Long in objects)
			{
				_objectRegister.destroyObject(id);
			}
		}
		
		/**
		 * Обработка команды.
		 * 
		 * @param command команда
		 */
		public function executeCommand(command:Object):void {
			var data:IDataInput = IDataInput(command[0]);
			var nullMap:NullMap = NullMap(command[1]);
			
			while (data.bytesAvailable) {
				var longCodec:ICodec = Main.codecFactory.getCodec(Long);		
				var objectId:Long = Long(longCodec.decode(data, nullMap, true));
				var methodId:Long = Long(longCodec.decode(data, nullMap, true));
				if (methodId.high == 0) {
					if (methodId.low == 0 || methodId.low == 1 || methodId.low == 2) {
						// Если вызван метод загрузки или выгрузки объекта, для DispatcherModel устанавливается реестр объектов текущего спейса.
						var dispatcherModel:DispatcherModel = modelRegister.getModel(LongFactory.getLong(0, 1)) as DispatcherModel;
						dispatcherModel.objectRegister = _objectRegister;
					} 
				}    	
				Main.modelsRegister.invoke(_objectRegister.getObject(objectId), methodId, data, nullMap);
			}
		}
		
		/**
		 * Передатчик команд 
		 */		
		public function get commandSender():ICommandSender {
			return sender;
		}
		
		/**
		 * @private
		 */
		public function set commandSender(sender:ICommandSender):void {
			this.sender = sender;
		}
		
		public function get objectRegister():ObjectRegister {
			return _objectRegister;
		}
		
	}
}