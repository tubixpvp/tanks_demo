package alternativa.network {
	
	/**
	 * Интерфейс передатчика команд.
	 */	
	public interface ICommandSender	{
		
		/**
		 * Отправляет команду.
		 * 
		 * @param command команда
		 * @param zipped флаг принудительного сжатия посылаемых данных (в случае <code>false</code> сжатие выполняется только для больших пакетов)
		 */		
		function sendCommand(command:Object, zipped:Boolean = false):void;
		
	}
}