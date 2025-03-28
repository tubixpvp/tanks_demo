package alternativa.register {
	import alternativa.init.Main;
	import alternativa.model.IObjectLoadListener;
	import alternativa.network.ICommandHandler;
	import alternativa.object.ClientObject;
	import alternativa.types.Long;
	import alternativa.types.LongFactory;
	
	import flash.utils.Dictionary;
	
	/**
	 * Реестр загруженных объектов.
	 */	
	public class ObjectRegister	{
		
		/**
		 * Список объектов по id
		 */		
		private var objects:Dictionary;
		/**
		 * Обработчик команд данного спейса
		 */		
		private var commandHandler:ICommandHandler;
		
		/**
		 * Создаёт новый экземпляр реестра объектов.
		 * 
		 * @param commandHandler обработчик команд спейса
		 */		
		public function ObjectRegister(commandHandler:ICommandHandler) {
			this.commandHandler = commandHandler;
			objects = new Dictionary();
		}
		
		/**
		 * Создаёт новый клиентский объект. При этом все модели объекта, реализующие интерфейс IObjectLoadListener, получают
		 * уведомления о загрузке объекта.
		 * 
		 * @param id идентификатор объекта
		 * @param parent родительский объект
		 * @param name имя объекта
		 * @param models список моделей объекта
		 * @param args
		 * 
		 * @return новый объект
		 */
		public function createObject(id:Long, parent:ClientObject, name:String, models:Array = null, args:Array = null):ClientObject {
			if (id == LongFactory.getLong(0, 0) && objects[0] != null) {
				Main.writeToConsole("FATAL ERROR: ПОПЫТКА СОЗДАНИЯ 2-ГО ДИСПЕТЧЕРА!!!", 0xff0000);
				return objects[0];
			} else {
				var object:ClientObject = new ClientObject(id, parent, name, commandHandler, models, null);
				registerObject(object);
				Main.writeToConsole("Объект id: " + id + " добавлен", 0x0000cc);
				return object;
			}
		}
		
		/**
		 * Удаление объекта из реестра. При удалении для всех моделей объекта, реализующих интерфейс IObjectLoadListener, выполняется
		 * рассылка сообщения о выгрузке объекта.
		 * 
		 * @param id идентификатор удаляемого объекта
		 */
		public function destroyObject(id:Long):void {
			Main.writeToConsole("[ObjectRegister.destroyObject] id " + id);
			var clientObject:ClientObject = objects[id];
			Main.writeToConsole("[ObjectRegister.destroyObject] clientObject " + clientObject);
			// TODO: нужна ли проверка на null?
			var models:Array = clientObject.getModels();
			// Рассылка сообщения
			for (var i:int = 0; i < models.length; i++) {
				var m:IObjectLoadListener = Main.modelsRegister.getModel(models[i]) as IObjectLoadListener;
				if (m != null) {
					m.objectUnloaded(clientObject);
				}
			}
			delete objects[id];
			
			Main.writeToConsole("Объект id: " + id + " удален", 0x0000cc);
		}
		
		/**
		 * Регистрирует объект в реестре.
		 * 
		 * @param object клиентский объект
		 */		
		private function registerObject(object:ClientObject):void {
			objects[object.id] = object;
			object.register = this;
		}
		
		/**
		 * Возвращает объект по его идентификатору.
		 * 
		 * @param id идентификатор запрашиваемого объекта
		 * 
		 * @return объект с заданным идентификатором или <code>null</code> при отсутствии такого объекта в реестре
		 */
		public function getObject(id:Long):ClientObject {
			return objects[id];
		}
		
		public function getObjects():Dictionary {
			return objects;
		}			

	}
}