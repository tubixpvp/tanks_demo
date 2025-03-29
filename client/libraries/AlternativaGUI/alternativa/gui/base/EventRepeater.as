package alternativa.gui.base {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	/**
	 * Повторитель, срабатывающий по событиям и вызывающий заданную функцию в заданном объекте
	 */	
	public class EventRepeater {
		/**
		 * @private
		 * Объект, рассылающий события 
		 */		
		private var eventDispatcher:EventDispatcher;
		/**
		 * @private
		 * Объект, в котором вызывается повторяемая функция 
		 */		
		private var funcObject:Object;
		/**
		 * @private
		 * Повторяемая функция 
		 */		
		private var func:Function;
		/**
		 * @private
		 * Параметры вызываемой функции 
		 */		
		private var args:Array;
		/**
		 * @private
		 * Задержка срабатывания в мс
		 */		
		private var delay:Number;
		/**
		 * @private
		 * Период повторения в мс
		 */		
		private var repeatInterval:Number;
		/**
		 * @private
		 * id таймера задержки 
		 */		
		private var delayId:uint;
		/**
		 * @private
		 * id таймера повторений
		 */		
		private var repeatId:uint;
		
		
		/**
		 * @param eventDispatcher объект, рассылающий события
		 * @param startEvent событие, начинающее повторение
		 * @param stopEvent событие, останавливающее повторение
		 * @param funcObject объект, содержащий вызываемую функцию
		 * @param func вызываемая при повторении функция
		 * @param delay задержка перед началом повторений в мс
		 * @param repeatInterval период повторения в мс
		 */	
		public function EventRepeater(eventDispatcher:EventDispatcher, startEvent:String, stopEvent:String, funcObject:Object, func:Function, args:Array = null, delay:Number = 200, repeatInterval:Number = 50) {
			this.eventDispatcher = eventDispatcher;
			this.funcObject = funcObject;
			this.func = func;
			this.args = args;
			this.delay = delay;
			this.repeatInterval = repeatInterval;
			// Подписка на события начала и конца
			eventDispatcher.addEventListener(startEvent, onStart);
			eventDispatcher.addEventListener(stopEvent, onStop);
		}
		
		/**
		 * Отсчет задержки до начала повторений
		 */		
		private function onStart(e:Event):void {
			delayId = setInterval(startRepeat, delay);
		}
		/**
		 * Начало повторения
		 */		
		private function startRepeat():void {
			clearInterval(delayId);
			repeatId = setInterval(repeat, repeatInterval);
		}
		/**
		 * Вызов повторяемой функции
		 */		
		private function repeat():void {
			func.apply(funcObject, args);
		}
		/**
		 * Остановка повторений
		 */		
		private function onStop(e:Event):void {
			clearInterval(delayId);
			clearInterval(repeatId);
		}

	}
}