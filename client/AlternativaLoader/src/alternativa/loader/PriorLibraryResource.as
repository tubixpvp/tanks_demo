package alternativa.loader {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.Dictionary;
	
	public class PriorLibraryResource {
		
		private static const initClassPath:String = "alternativa.init";

		private var _id:Number;
		private var _version:Number;
		private var infoLoader:URLLoader;
		private var manifestLoader:URLLoader;
		private var loader:Loader;
		private var url:String;
		private var _name:String;

		private var console:PriorConsole;
		private var osgi:Object;

		private var librariesInitParams:Dictionary;
		private var librariesData:Object;
		
		private var mainLoader:AlternativaLoader;
		
		
		
		public function PriorLibraryResource(mainLoader:AlternativaLoader, osgi:Object, console:PriorConsole, id:Number, version:Number, librariesInitParams:Dictionary, librariesData:Object) {
			this.mainLoader = mainLoader;
			this.osgi = osgi;
			this.console = console;
			this.librariesInitParams = librariesInitParams;
			this.librariesData = librariesData;
			_id = id;
			_version = version;
			
			infoLoader = new URLLoader();
			infoLoader.addEventListener(Event.COMPLETE, onInfoLoad);
			infoLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			infoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadSecurityError);
			
			manifestLoader = new URLLoader();
			manifestLoader.addEventListener(Event.COMPLETE, onManifestLoadComplete);
			manifestLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			manifestLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadSecurityError);

			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadSecurityError);
		}
		
		public function load(url:String):void {
			this.url = url;
			// Загружаем информацию
			infoLoader.load(new URLRequest(url + "info.xml"));
		}
		
		public function unload():void {
			infoLoader = null;
			loader.unload();
			loader = null;
		}
		
		// Информация загружена
		private function onInfoLoad(e:Event):void {
			// Сохраняем имя библиотеки
			var infoXML:XML = new XML(URLLoader(e.target).data);
			_name = infoXML.@name;
			// Загружаем библиотеку
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			context.securityDomain = SecurityDomain.currentDomain;
			
			//var id:String = LongToString(_id);
			//var version:String = LongToString(_version);
			if (console != null) {
				console.writeToChannel("RESOURCE", "Загружается ресурс " + _name + " ID: " + _id + " версии " + _version +  " из " + url);
			}
			if (mainLoader.debug) {
				loader.load(new URLRequest(url + "debug.swf"), context);
			} else {
				loader.load(new URLRequest(url + "library.swf"), context);
			}
		}

		private function LongToString(value:Number):String {
			/*var longArray:ByteArray = new ByteArray();
			longArray.position = 0;
			longArray.writeDouble(value);
			longArray.position = 0;
			var s:String = "";
			longArray.position = 0;
			while (longArray.bytesAvailable) {
				var signs:String = longArray.readInt().toString(16);
				while (signs.length < 8) {
					signs = "0" + signs;
				}
				s += signs;
				s += " ";
			}*/		
			return value.toString();
		}

		// Библиотека загружена
		private function onLoadComplete(e:Event):void {
			if (console != null) {
				console.writeToChannel("RESOURCE", "Библиотека " + _name + " загружена (" + LoaderInfo(e.target).bytesTotal + " байт)");
			}
			if (_name == "OSGI") {
				osgi = mainLoader.initOSGi();
			} else {
				// Загружаем манифест
				manifestLoader.load(new URLRequest(url + "MANIFEST.MF"));
			}
		}
		
		private function onManifestLoadComplete(e:Event):void {
			// Инициализация библиотеки
			osgi.installBundle(String(URLLoader(e.target).data));
			
			if (_name == "Клиент") {
				if (mainLoader.mainLibrariesLoaded) {
					mainLoader.initMain();
				} else {
					mainLoader.mainLibrariesLoaded = true;
				}
			}
		}
		
		// Ошибка загрузки
		private function onLoadIOError(e:Event):void {
			if (console != null) {
				console.writeToChannel("RESOURCE", "Ошибка загрузки ресурса IOError " + e);
			}
		}
		private function onLoadSecurityError(e:Event):void {
			if (console != null) {
				console.writeToChannel("RESOURCE", "Ошибка загрузки ресурса SecurityError " + e);
			}
		}
		
		// Название типа
		public function get name():String {
			return "библиотека" + ((_name == null) ? "" : (" " + _name));
		}

		public function getLoader():Loader {
			return loader;
		}
		
		public function set id(value:Number):void {
			_id = value;
		}
		public function get id():Number {
			return _id;
		}
		public function get version():Number {
			return _version;
		}

	}
}