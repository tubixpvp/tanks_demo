package alternativa.engine3d.events {

	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.display.View;
	
	import flash.events.Event;
	
	/**
	 * Событие, возникающее при взаимодействии мыши с объектами сцены.
	 */
	public class MouseEvent3D extends Event {
		/**
		 * Значение свойства <code>type</code> для объекта события <code>click</code>.
		 * @eventType click
		 */		
		public static const CLICK:String = "click";
		/**
		 * Значение свойства <code>type</code> для объекта события <code>mouseDown</code>.
		 * @eventType mouseDown
		 */		
		public static const MOUSE_DOWN:String = "mouseDown";
		/**
		 * Значение свойства <code>type</code> для объекта события <code>mouseUp</code>.
		 * @eventType mouseUp
		 */		
		public static const MOUSE_UP:String = "mouseUp";
		/**
		 * Значение свойства <code>type</code> для объекта события <code>mouseOver</code>.
		 * @eventType mouseOver
		 */		
		public static const MOUSE_OVER:String = "mouseOver";
		/**
		 * Значение свойства <code>type</code> для объекта события <code>mouseOut</code>.
		 * @eventType mouseOut
		 */		
		public static const MOUSE_OUT:String = "mouseOut";
		/**
		 * Значение свойства <code>type</code> для объекта события <code>mouseMove</code>.
		 * @eventType mouseMove
		 */		
		public static const MOUSE_MOVE:String = "mouseMove";
		/**
		 * Значение свойства <code>type</code> для объекта события <code>mouseWheel</code>.
		 * @eventType mouseWheel
		 */		
		public static const MOUSE_WHEEL:String = "mouseWheel";
		
		/**
		 * Объект сцены, с которым связано событие.
		 */
		public var object:Object3D;
		/**
		 * Поверхность объекта сцены, с которой связано событие.
		 */
		public var surface:Surface;
		/**
		 * Грань объекта сцены, с которой связано событие.
		 */
		public var face:Face;
		/**
		 * Область вывода, в которой произошло событие.
		 */
		public var view:View;

		/**
		 * X-координата мышиного курсора в сцене.
		 */
		public var globalX:Number;
		/**
		 * Y-координата мышиного курсора в сцене.
		 */
		public var globalY:Number;
		/**
		 * Z-координата мышиного курсора в сцене.
		 */
		public var globalZ:Number;

		/**
		 * X-координата мышиного курсора в системе координат объекта.
		 */
		public var localX:Number;
		/**
		 * Y-координата мышиного курсора в системе координат объекта.
		 */
		public var localY:Number;
		/**
		 * Z-координата мышиного курсора в системе координат объекта.
		 */
		public var localZ:Number;
		
		/**
		 * Текстурная координата U в точке нахождения мышиного курсора. При отсутствии текстурных координат у грани, поле содержит значение <code>NaN</code>.
		 */
		public var u:Number;
		/**
		 * Текстурная координата V в точке нахождения мышиного курсора. При отсутствии текстурных координат у грани, поле содержит значение <code>NaN</code>.
		 */
		public var v:Number;
		/**
		 * Индикатор нажатой (<code>true</code>) или отпущенной (<code>false</code>) клавиши Alt.
		 */		
		public var altKey:Boolean;
		/**
		 * Индикатор нажатой (<code>true</code>) или отпущенной (<code>false</code>) клавиши Control.
		 */		
		public var ctrlKey:Boolean;
		/**
		 * Индикатор нажатой (<code>true</code>) или отпущенной (<code>false</code>) клавиши Shift.
		 */		
		public var shiftKey:Boolean;
		/**
		 * Количество линий прокрутки при вращении колеса мыши.
		 */		
		public var delta:int;

		/**
		 * Создаёт новый экземпляр события.
		 * 
		 * @param type тип события
		 * @param view область вывода, в которой произошло событие
		 * @param object объект сцены, с которым связано событие
		 * @param surface поверхность, с которой связано событие
		 * @param face грань, с которой связано событие
		 * @param globalX X-координата мышиного курсора в сцене
		 * @param globalY Y-координата мышиного курсора в сцене
		 * @param globalZ Z-координата мышиного курсора в сцене
		 * @param localX X-координата мышиного курсора в системе координат объекта
		 * @param localY Y-координата мышиного курсора в системе координат объекта
		 * @param localZ Z-координата мышиного курсора в системе координат объекта
		 * @param u текстурная координата U в точке нахождения мышиного курсора
		 * @param v текстурная координата V в точке нахождения мышиного курсора
		 */
		public function MouseEvent3D(type:String, view:View, object:Object3D, surface:Surface, face:Face,	globalX:Number = NaN, globalY:Number = NaN, globalZ:Number = NaN, localX:Number = NaN, localY:Number = NaN, localZ:Number = NaN, u:Number = NaN, v:Number = NaN, altKey:Boolean = false, ctrlKey:Boolean = false, shiftKey:Boolean = false, delta:int = 0) {
			super(type);
			this.view = view;
			this.object = object;
			this.surface = surface;
			this.face = face;
			this.globalX = globalX;
			this.globalY = globalY;
			this.globalZ = globalZ;
			this.localX = localX;
			this.localY = localY;
			this.localZ = localZ;
			this.u = u;
			this.v = v;
			this.altKey = altKey;
			this.ctrlKey = ctrlKey;
			this.shiftKey = shiftKey;
			this.delta = delta;
		}
		
		/**
		 * Получение строкового представления объекта.
		 * 
		 * @return строковое представление объекта
		 */
		override public function toString():String {
			return formatToString("MouseEvent3D", "object", "surface", "face", "globalX", "globalY", "globalZ", "localX", "localY", "localZ", "u", "v", "delta", "altKey", "ctrlKey", "shiftKey");
		}
		
		/**
		 * Возвращает клон объекта.
		 * 
		 * @return клон события
		 */
		override public function clone():Event {
			return new MouseEvent3D(type, view, object, surface, face, globalX, globalY, globalZ, localX, localY, localZ, u, v, altKey, ctrlKey, shiftKey, delta);
		}

	}
}
