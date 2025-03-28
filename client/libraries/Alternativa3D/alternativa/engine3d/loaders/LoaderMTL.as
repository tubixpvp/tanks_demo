package alternativa.engine3d.loaders {
	import alternativa.engine3d.*;
	import alternativa.types.Map;
	import alternativa.utils.ColorUtils;
	
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	use namespace alternativa3d;
	
	/**
	 * Событие рассылается после начала загрузки.
	 * 
	 * @eventType flash.events.Event.OPEN
	 */
	[Event (name="open", type="flash.events.Event")]
	/**
	 * Событие рассылается в процессе получения данных во время загрузки.
	 * 
	 * @eventType flash.events.ProgressEvent.PROGRESS
	 */
	[Event (name="progress", type="flash.events.ProgressEvent")]
	/**
	 * Событие рассылается после завершении загрузки.
	 * 
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event (name="complete", type="flash.events.Event")]
	/**
	 * Событие рассылается при ошибке загрузки.
	 * 
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event (name="ioError", type="flash.events.IOErrorEvent")]
	/**
	 * Событие рассылается при нарушении безопасности.
	 * 
	 * @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event (name="securityError", type="flash.events.SecurityErrorEvent")]
	/**
	 * @private
	 * Загрузчик библиотеки материалов из файлов в формате MTL material format (Lightwave, OBJ).
	 * <p>
	 * На данный момент обеспечивается загрузка цвета, прозрачности и диффузной текстуры материала.
	 * </p>
	 */
	public class LoaderMTL extends EventDispatcher {
		
		private static const COMMENT_CHAR:String = "#";
		private static const CMD_NEW_MATERIAL:String = "newmtl";
		private static const CMD_DIFFUSE_REFLECTIVITY:String = "Kd";
		private static const CMD_DISSOLVE:String = "d";
		private static const CMD_MAP_DIFFUSE:String = "map_Kd";
		private static const CMD_MAP_DISSOLVE:String = "map_d";
		
		private static const REGEXP_TRIM:RegExp = /^\s*(.*?)\s*$/;
		private static const REGEXP_SPLIT_FILE:RegExp = /\r*\n/;
		private static const REGEXP_SPLIT_LINE:RegExp = /\s+/;
		
		private static const STATE_IDLE:int = 0;
		private static const STATE_LOADING:int = 1;
		
		// Загрузчик файла MTL
		private var mtlFileLoader:URLLoader;

		// Библиотека загруженных материалов
		private var _library:Map;
		// Имя текущего материала
		private var materialName:String;
		// параметры текущего материала
		private var currentMaterialInfo:MTLMaterialInfo = new MTLMaterialInfo();
		
		private var loaderState:int = STATE_IDLE;
		
		/**
		 * Создаёт новый экземпляр класса.
		 */
		public function LoaderMTL() {
		}
		
		/**
		 * Прекращение текущей загрузки.
		 */
		public function close():void {
			if (loaderState == STATE_LOADING) {
				mtlFileLoader.close();
			}
			loaderState = STATE_IDLE;
		}
		
		/**
		 * Метод очищает внутренние ссылки на загруженные данные чтобы сборщик мусора мог освободить занимаемую ими память. Метод не работает
		 * во время загрузки.
		 */
		public function unload():void {
			if (loaderState == STATE_IDLE) {
				_library = null;
			}
		}
		
		/**
		 * Библиотека материалов. Ключами являются наименования материалов, значениями -- объекты, наследники класса
		 * <code>alternativa.engine3d.loaders.MaterialInfo</code>.
		 * @see alternativa.engine3d.loaders.MaterialInfo
		 */
		public function get library():Map {
			return _library;
		}
		
		/**
		 * Метод выполняет загрузку файла материалов, разбор его содержимого, загрузку текстур при необходимости и
		 * формирование библиотеки материалов. После окончания работы метода посылается сообщение
		 * <code>Event.COMPLETE</code> и становится доступна библиотека материалов через свойство <code>library</code>.
		 * <p>
		 * При возникновении ошибок, связанных с вводом-выводом или с безопасностью, посылаются сообщения <code>IOErrorEvent.IO_ERROR</code> и
		 * </p> 
		 * <code>SecurityErrorEvent.SECURITY_ERROR</code> соответственно.
		 * <p>
		 * Если происходит ошибка при загрузке файла текстуры, то соответствующая текстура заменяется на текстуру-заглушку.
		 * </p>
		 * <p></p>
		 * @param url URL MTL-файла
		 * @param loaderContext LoaderContext для загрузки файлов текстур
		 *  
		 * @see #library
		 */
		public function load(url:String):void {
			if (mtlFileLoader == null) {
				mtlFileLoader = new URLLoader();
				mtlFileLoader.addEventListener(Event.OPEN, retranslateEvent);
				mtlFileLoader.addEventListener(ProgressEvent.PROGRESS, retranslateEvent);
				mtlFileLoader.addEventListener(Event.COMPLETE, parseMTLFile);
				mtlFileLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
				mtlFileLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			} else {
				close();
			}
			loaderState = STATE_LOADING;
			mtlFileLoader.load(new URLRequest(url));
		}
		
		/**
		 * 
		 */
		private function retranslateEvent(e:Event):void {
			dispatchEvent(e);
		}
		
		/**
		 * Обработка ошибки загрузки MTL-файла.
		 */
		private function onError(e:Event):void {
			loaderState = STATE_IDLE;
			dispatchEvent(e);
		}
		
		/**
		 * Разбор содержимого загруженного файла материалов.
		 */
		private function parseMTLFile(e:Event = null):void {
			loaderState = STATE_IDLE;
			parse(mtlFileLoader.data);
			complete();
		}
		
		/**
		 * 
		 */
		public function parse(data:String):void {
			_library = new Map();
			data.split(REGEXP_SPLIT_FILE).forEach(parseLine);
		}
		
		/**
		 * Разбор строки файла.
		 * 
		 * @param line строка файла
		 */
		private	function parseLine(line:String, index:int, lines:Array):void {
			line = line.replace(REGEXP_TRIM,"$1")
			if (line.length == 0 || line.charAt(0) == COMMENT_CHAR) {
				return;
			}
			var parts:Array = line.split(REGEXP_SPLIT_LINE);
			switch (parts[0]) {
				case CMD_NEW_MATERIAL:
					defineMaterial(parts);
					break;
				case CMD_DIFFUSE_REFLECTIVITY:
					readDiffuseReflectivity(parts);
					break;
				case CMD_DISSOLVE:
					readAlpha(parts);
					break;
				case CMD_MAP_DIFFUSE:
					currentMaterialInfo.diffuseMapInfo = MTLTextureMapInfo.parse(parts);
					break;
				case CMD_MAP_DISSOLVE:
					currentMaterialInfo.dissolveMapInfo = MTLTextureMapInfo.parse(parts);
					break;
			}
		}
		
		/**
		 * Определение нового материала.
		 */		
		private function defineMaterial(parts:Array = null):void {
			materialName = parts[1];
			currentMaterialInfo = new MTLMaterialInfo();
			_library[materialName] = currentMaterialInfo;
		}
		
		/**
		 * Чтение коэффициентов диффузного отражения. Считываются только коэффициенты, заданные в формате r g b. Для текущей
		 * версии движка данные коэффициенты преобразуются в цвет материала.
		 */
		private function readDiffuseReflectivity(parts:Array):void {
			var r:Number = Number(parts[1]);
			// Проверка, заданы ли коэффициенты в виде r g b
			if (!isNaN(r)) {
				var g:Number = Number(parts[2]);
				var b:Number = Number(parts[3]);
				currentMaterialInfo.color = ColorUtils.rgb(255*r, 255*g, 255*b); 
			}
		}

		/**
		 * Чтение коэффициента непрозрачности. Считывается только коэффициент, заданный числом
		 * (не поддерживается параметр -halo).
		 */
		private function readAlpha(parts:Array):void {
			var alpha:Number = Number(parts[1]);
			if (!isNaN(alpha)) {
				currentMaterialInfo.alpha = alpha;
			}
		}
		
		/**
		 * Обработка успешного завершения загрузки.
		 */
		private function complete():void {
			loaderState = STATE_IDLE;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}
}