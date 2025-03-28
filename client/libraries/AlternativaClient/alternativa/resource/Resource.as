package alternativa.resource {
	import alternativa.init.Main;
	import alternativa.model.IResourceLoadListener;
	import alternativa.types.Long;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * Базовый класс для ресурсов.
	 */
	public class Resource implements IResource {

		private var _id:Long;
		private var _version:int;
		private var _typeName:String;
		private var _isOptional:Boolean;

		protected var _name:String;
		protected var url:String;
		protected var infoLoader:URLLoader;
		
		protected var batchLoader:BatchResourceLoader;
		
		/**
		 * 
		 * @param typeName
		 * @param batchLoader
		 * @param isOptional
		 */
		public function Resource(typeName:String, batchLoader:BatchResourceLoader, isOptional:Boolean = false) {
			_typeName = typeName;
			this.batchLoader = batchLoader;
			_isOptional = isOptional;
			
			infoLoader = new URLLoader();
			infoLoader.addEventListener(Event.COMPLETE, onInfoLoad);
			infoLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			infoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
		}
		
		/**
		 * Загружает файл описания ресурса для дальнейшей загрузки данных ресурса.
		 * 
		 * @param url базовый URL ресурса
		 */
		public function load(url:String):void {
			this.url = url;
			infoLoader.load(new URLRequest(url + "info.xml"));
		}

		/**
		 * Выгружает ресурс, оповещает слушателей о выгрузке.
		 */		
		public function unload():void {
			infoLoader = null;
			var listeners:Array = Main.modelsRegister.getModelsByInterface(IResourceLoadListener) as Array;
			for (var i:int = 0; i < listeners.length; i++) {
				IResourceLoadListener(listeners[i]).resourceUnloaded(_id);
			}
		}
		
		/**
		 * Обрабатывает успешную загрузку файла описания ресурса и вызывает метод loadResourceData() для загрузки самого ресурса.
		 */
		protected function onInfoLoad(e:Event):void {
			// Сохраняем имя
			var infoXML:XML = new XML(URLLoader(e.target).data);
			_name = infoXML.@name;
			Main.writeVarsToConsole("[Resource.onInfoLoad] Loading resource [%1][%2:%3] from [%4]", name, _id, _version, url);
			loadResourceData();
		}
		
		/**
		 * Потомки должны переопределять этот метод, реализуя в нём запуск процесса загрузки данных ресурса.
		 */
		protected function loadResourceData():void {
		}

		/**
		 * Обрабатывает успешную загрузку ресурса.
		 */
		protected function completeLoading():void {
			if (batchLoader != null) {
				batchLoader.resourceLoaded(this);
				batchLoader = null;
			}
			var listeners:Array = Main.modelsRegister.getModelsByInterface(IResourceLoadListener) as Array;
			if (listeners != null) {
				for (var i:int = 0; i < listeners.length; i++) {
					IResourceLoadListener(listeners[i]).resourceLoaded(this);
				}
			}
		}
		
		/**
		 * Обрабатывает ошибки при загрузке.
		 */
		protected function onLoadError(e:Event):void {
			Main.writeVarsToConsole("[ERROR] Resource [%1] load error: %2", name, e);
		}
		
		/**
		 * Имя ресурса.
		 */
		public function get name():String {
			return _typeName + ((_name == null) ? "" : (" " + _name));
		}

		/**
		 * Идентификатор ресурса.
		 */
		public function get id():Long {
			return _id;
		}

		/**
		 * @private
		 */
		public function set id(value:Long):void {
			_id = value;
		}
		
		/**
		 * Версия ресурса.
		 */
		public function get version():int {
			return _version;
		}

		/**
		 * @private
		 */
		public function set version(value:int):void {
			_version = value;
		}
		
		/**
		 * Признак необходимости отчёта о загрузке ресурса.
		 */
		public function get isOptional():Boolean {
			return _isOptional;
		}

		/**
		 * @private
		 */
		public function set isOptional(value:Boolean):void {
			_isOptional = value;
		}

	}
}