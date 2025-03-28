package alternativa.utils {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	/**
	 * Компонент для наглядного отображения некоторых параметров программы.
	 * Компонент отображает численные значения и графики изменений для частоты кадров в секунду и потребляемой памяти.
	 * Также возможно отображение количества:
	 * <ul>
	 * <li> байтов, полученных через сокет;
	 * <li> байтов, отправленных через сокет;
	 * <li> загруженных байтов.
	 * </ul>
	 */
	public final class FPS extends Sprite {
		private static var instance:FPS;

		private var fpsTextField:TextField = new TextField();
		private var fpsDelay:int = 0;
		private var fpsStart:int;
		private var fpsTimer:int;
		private var fpsText:Number;
		private var fpsDiagram:Number;
		private var fpsFraction:int;

		private var memory:int = 0;
		private var maxMemory:int = 0;
		private var memoryTextField:TextField = new TextField();
		
		private var skinsTextField:TextField = new TextField();
		private var skins:int = -1;
		private var skinsChanged:int = 0;
		
		private var downloadedTextField:TextField = new TextField();
		private var downloadedBytes:int = -1;
		
		private static const maxSocket:int = 4200; // модемная скорость на 33600
		private var socketInTextField:TextField = new TextField();
		private var socketInLast:int = 0;
		private var socketInBytes:int = -1;
		private var socketOutTextField:TextField = new TextField();
		private var socketOutLast:int = 0;
		private var socketOutBytes:int = -1;
		
		private var diagram:BitmapData;
		private var diagramTimer:int;
		private var currentY:int;
		private var rect:Rectangle = new Rectangle(0, 0, 1, 40);
		private var timer:int;
		private var frameRate:int;
		
		/**
		 * Создание экземпляра класса. Класс является синглтоном, поэтому при попытке повторного вызова конструктора
		 * будет выдана ошибка.  
		 * 
		 * @param parent контейнер, на котором размещается компонент
		 * 
		 * @throws Error при повторном вызове конструктора
		 */		
		public function FPS(parent:DisplayObjectContainer) {
			if (instance == null) {
				mouseEnabled = false;
				mouseChildren = false;

				parent.addChild(this);
				
				fpsTextField.defaultTextFormat = new TextFormat("Tahoma", 10, 0xCCCCCC);
				fpsTextField.autoSize = TextFieldAutoSize.LEFT;
				fpsTextField.text = "FPS: " + Number(stage.frameRate).toFixed(2);
				fpsTextField.selectable = false;
				fpsTextField.x = -63;
				addChild(fpsTextField);
				
				memoryTextField.defaultTextFormat = new TextFormat("Tahoma", 10, 0xCCCC00);
				memoryTextField.autoSize = TextFieldAutoSize.LEFT;
				memoryTextField.text = "MEM: " + bytesToString(System.totalMemory);
				memoryTextField.selectable = false;
				memoryTextField.x = -63;
				memoryTextField.y = 9;
				addChild(memoryTextField);

				currentY = 19;

				skinsTextField.defaultTextFormat = new TextFormat("Tahoma", 10, 0xFF6600);
				skinsTextField.autoSize = TextFieldAutoSize.LEFT;
				skinsTextField.text = "MEM: " + bytesToString(System.totalMemory);
				skinsTextField.selectable = false;
				skinsTextField.x = -63;

				downloadedTextField.defaultTextFormat = new TextFormat("Tahoma", 10, 0xCC00CC);
				downloadedTextField.autoSize = TextFieldAutoSize.LEFT;
				downloadedTextField.selectable = false;
				downloadedTextField.x = -63;

				socketInTextField.defaultTextFormat = new TextFormat("Tahoma", 10, 0x00FF00);
				socketInTextField.autoSize = TextFieldAutoSize.LEFT;
				socketInTextField.selectable = false;
				socketInTextField.x = -63;

				socketOutTextField.defaultTextFormat = new TextFormat("Tahoma", 10, 0x0066FF);
				socketOutTextField.autoSize = TextFieldAutoSize.LEFT;
				socketOutTextField.selectable = false;
				socketOutTextField.x = -63;
				
				diagram = new BitmapData(60, 40, true, 0x20FFFFFF);
				var d:Bitmap = new Bitmap(diagram);
				d.y = currentY + 4;
				d.x = -60;
				addChildAt(d, 0);

				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				stage.addEventListener(Event.RESIZE, onResize);
				onResize();

				frameRate = stage.frameRate;

				diagramTimer = fpsTimer = fpsStart = getTimer();
			} else {
				throw new Error("FPS is a Singleton. Use FPS.init to create FPS instance");
			}
		}
		
		/**
		 * Создание компонента. Вызов <code>FPS.init(container)</code> создаёт в правом верхнем углу контейнера индикатор,
		 * отображающий показатели.
		 * 
		 * @param parent контейнер, на котором размещается компонент
		 * 
		 * @throws Error при повторном вызове метода
		 */		
		public static function init(parent:DisplayObjectContainer):void {
			instance = new FPS(parent);
		}

		/**
		 * @private
		 */
		public static var offsetX:int = -2;
		/**
		 * @private
		 */
		public static var offsetY:int = -3;

		private function onResize(e:Event = null):void {
			var size:Point = parent.globalToLocal(new Point(stage.stageWidth + offsetX, offsetY));
			x = size.x;
			y = size.y;
		}

		private function onEnterFrame(e:Event):void {
			// Считываем время
			timer = getTimer();
			
			// Текстовый FPS
			if (++fpsDelay == 10) {
				fpsText = 10000/(timer - fpsTimer);
				if (fpsText > frameRate) {
					fpsTextField.text = "FPS: " + frameRate + ".00";
				} else {
					fpsFraction = fpsText*100 % 100;
					fpsTextField.text = "FPS: " + int(fpsText) + "." + ((fpsFraction > 10) ? fpsFraction : ((fpsFraction > 0) ? ("0" + fpsFraction) : "00"));
				}
				fpsTimer = timer;
				fpsDelay = 0;
			}
			
			// Отрисовка FPS
			fpsText = 1000/(timer - diagramTimer);
			diagram.scroll(1, 0);
			diagram.fillRect(rect, 0x20FFFFFF);
			if (fpsText > frameRate) diagram.setPixel32(0, 40, 0xFFCCCCCC);
			else diagram.setPixel32(0, 40*(1 - fpsText/frameRate), 0xFFCCCCCC);
			diagramTimer = timer;

			// Текст памяти
			memory = System.totalMemory;
			memoryTextField.text = "MEM: " + bytesToString(memory);
			
			// Отрисовка графика памяти
			if (memory > maxMemory) maxMemory = memory;
			diagram.setPixel32(0, 40*(1 - memory/maxMemory), 0xFFCCCC00);

			// Отрисовка показателей камеры
			if (skins >= 0) {
				var s:Number = (skins == 0) ? 0 : (skinsChanged / skins);
				diagram.setPixel32(0, 40*(1 - s), 0xFFFF6600);
			}

			// Отрисовка сокет-приём
			if (socketInBytes >= 0) {
				var si:Number = (socketInBytes - socketInLast)/maxSocket;
				socketInLast = socketInBytes;
				diagram.setPixel32(0, 40*(1 - si), 0xFF00FF00);
			}

			// Отрисовка сокет-отправка
			if (socketOutBytes >= 0) {
				var so:Number = (socketOutBytes - socketOutLast)/maxSocket;
				socketOutLast = socketOutBytes;
				diagram.setPixel32(0, 40*(1 - so), 0xFF0066FF);
			}
		}

		/**
		 * @param bytes
		 * @return 
		 */
		private function bytesToString(bytes:int):String {
			if (bytes < 1024) return bytes + "b";
			else if (bytes < 10240) return Number(bytes / 1024).toFixed(2) + "kb";
			else if (bytes < 102400) return Number(bytes / 1024).toFixed(1) + "kb";
			else if (bytes < 1048576) return (bytes >> 10) + "kb";
			else if (bytes < 10485760) return Number(bytes / 1048576).toFixed(2) + "mb";
			else if (bytes < 104857600) return Number(bytes / 1048576).toFixed(1) + "mb";
			else return (bytes >> 20) + "mb";
		}

		/**
		 * @private
		 */
		static public function addSkins(num:uint, changed:uint):void {
			if (instance.skins < 0) {
				instance.skinsTextField.y = instance.currentY;
				instance.currentY += 10;
				instance.addChild(instance.skinsTextField);
				instance.getChildAt(0).y = instance.currentY + 4;
			}
			instance.skins = num;
			instance.skinsChanged = changed;
			instance.skinsTextField.text = "SKN: " + ((changed > 0) ? (num.toString() + "-" + changed.toString()) : num.toString());
		}

		/**
		 * Увеличение количества полученных из сокета байт.
		 * 
		 * @param bytes количество байт
		 */
		static public function addSocketInBytes(bytes:uint):void {
			if (instance.socketInBytes < 0) {
				instance.socketInBytes = 0;
				instance.socketInTextField.y = instance.currentY;
				instance.currentY += 10;
				instance.addChild(instance.socketInTextField);
				instance.getChildAt(0).y = instance.currentY + 4;
			}
			instance.socketInBytes += bytes;
			instance.socketInTextField.text = "IN: " + instance.bytesToString(instance.socketInBytes);
		}

		/**
		 * Увеличение количества переданных в сокет байт.
		 * 
		 * @param bytes количество байт
		 */
		static public function addSocketOutBytes(bytes:uint):void {
			if (instance.socketOutBytes < 0) {
				instance.socketOutBytes = 0;
				instance.socketOutTextField.y = instance.currentY;
				instance.currentY += 10;
				instance.addChild(instance.socketOutTextField);
				instance.getChildAt(0).y = instance.currentY + 4;
			}
			instance.socketOutBytes += bytes;
			instance.socketOutTextField.text = "OUT: " + instance.bytesToString(instance.socketOutBytes);
		}

		/**
		 * Увеличение количества загруженных байт.
		 * 
		 * @param bytes количество байт
		 */
		static public function addDownloadBytes(bytes:uint):void {
			if (instance.downloadedBytes < 0) {
				instance.downloadedBytes = 0;
				instance.downloadedTextField.y = instance.currentY;
				instance.currentY += 10;
				instance.addChild(instance.downloadedTextField);
				instance.getChildAt(0).y = instance.currentY + 4;
			}
			instance.downloadedBytes += bytes;
			instance.downloadedTextField.text = "DWL: " + instance.bytesToString(instance.downloadedBytes);
		}

		/**
		 * Видимость счётчика. 
		 */
		static public function get visible():Boolean {
			return instance == null ? false : instance.visible;
		}

		/**
		 * Устанавливает видимость счётчика аналогично функциям show() и hide().
		 * 
		 * @see #show()
		 * @see #hide()
		 */
		static public function set visible(value:Boolean):void {
			value ? show() : hide();
		}

		/**
		 * Прячет счётчик и останавливает его работу. 
		 */
		static public function hide():void {
			if (instance == null || !instance.visible) return;
			instance.visible = false;
			instance.removeEventListener(Event.ENTER_FRAME, instance.onEnterFrame);
			instance.stage.removeEventListener(Event.RESIZE, instance.onResize);
		}

		/**
		 * Показывет спрятанный счётчик и возобновляет его работу.
		 */
		static public function show():void {
			if (instance == null || instance.visible) return;
			instance.diagramTimer = instance.fpsTimer = instance.fpsStart = getTimer();
			instance.visible = true;
			instance.addEventListener(Event.ENTER_FRAME, instance.onEnterFrame);
			instance.stage.addEventListener(Event.RESIZE, instance.onResize);
			instance.onResize(null);
		}

	}
}
