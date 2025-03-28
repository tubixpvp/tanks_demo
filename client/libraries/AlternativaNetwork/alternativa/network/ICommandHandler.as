package alternativa.network {
	
	/**
	 * Интерфейс обработчика команд
	 */	
	public interface ICommandHandler {
		
		/**
		 * Рассылка события "соединение открыто" 
		 */		
		function open():void;
		
		/**
		 * Рассылка события "соединение закрыто"  
		 */		
		function close():void;
		
		/**
		 * Обработка команды
		 * @param command команда
		 */		
		function executeCommand(command:Object):void;
		
		/**
		 * Передатчик команд 
		 */		
		function get commandSender():ICommandSender;
		function set commandSender(commandSender:ICommandSender):void;
		
	}
}