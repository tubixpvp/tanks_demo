package alternativa.iointerfaces.keyboard {
	
	/**
	 * Функция в некотором объекте с параметрами ее вызова
	 */	
	public class BindedFunction	{
		
		/**
		 * Объект, в котором находится функция 
		 */		
		public var object:Object;
		
		/**
		 * Функция
		 */
		public var func:Function;
		/**
		 * Параметры вызова 
		 */		
		public var args:Array;
		
		/**
		 * @param object объект, в котором находится функция
		 * @param func функция
		 * @param args параметры вызова 
		 */		
		public function BindedFunction(object:Object, func:Function, args:Array) {
			this.object = object;
			this.func = func;
			this.args = args;
		}

	}
}