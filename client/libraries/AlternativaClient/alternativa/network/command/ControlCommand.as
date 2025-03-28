package alternativa.network.command {
	
	public class ControlCommand	{
		
		public static const HASH_REQUEST:int = 1;
   	 	public static const HASH_RESPONCE:int = 2;
   	 	public static const OPEN_SPACE:int = 3;
    	public static const HASH_ACCEPT:int = 4;
	    public static const LOAD_RESOURCE:int = 5;
	    public static const UNLOAD_RESOURCES:int = 6;
   	 	public static const RESOURCE_LOADED:int = 7;
   	 	public static const LOG:int = 8;
   	 	public static const COMMAND_REQUEST:int = 9;
   	 	public static const COMMAND_RESPONCE:int = 10;
   	 	public static const SERVER_MESSAGE:int = 11;
		
		/**
		 * Идентификатор команды.
		 */		
		public var id:int;
		/**
		 * Имя команды.
		 */		
		public var name:String;
		/**
		 * Параметры команды.
		 */		
		public var params:Array;
		
		/**
		 * Создаёт новый экземпляр команды.
		 * 
		 * @param id идентификатор команды
		 * @param name имя команды
		 * @param params параметры команды
		 */
		public function ControlCommand(id:int, name:String, params:Array) {
			this.id = id;
			this.name = name;
			this.params = params;
		}

	}
}