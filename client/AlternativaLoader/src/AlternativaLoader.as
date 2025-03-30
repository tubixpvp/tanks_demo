package {
	
	import alternativa.loader.AlertWindow;
	import alternativa.loader.PriorConsole;
	import alternativa.loader.PriorLibraryResource;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import alternativa.loader.Long;
	
	//import swfaddress.SWFAddress;
	//import swfaddress.SWFAddressEvent;
	
	
	public class AlternativaLoader extends Sprite {

		[Embed(source="./../../socket.cfg", mimeType="application/octet-stream")]
		private static const SOCKET_DATA_Class:Class;

		private static const SOCKET_DATA:Object = JSON.parse((new SOCKET_DATA_Class()).toString());

		
		private static const initClassPath:String = "alternativa.init";
		
		// Адрес сервера
		private var server:String;
		
//		private var hash:String;
//		private var emailConfirmHash:String;
//		private var email:String;
		
		// Путь к конфигурации доступа
		private var crossdomain:String;

		// Порт для соединения
		private var ports:Array;
		
		// Путь к ресурсам
		private var resources:String;
		
		private var libraryId:Vector.<Long>;
		private var libraryVersion:Vector.<Long>;
		private var library:Array;
		
		private var console:PriorConsole;
		
		private var librariesData:Object;
		private var librariesInitParams:Dictionary;
		
		private var mainContainer:Sprite;
		
		private var osgi:Object;
		
		public var debug:Boolean;
		
		private var alertWindow:AlertWindow;
		
		private var statusURL:String;
		private var configURL:String;
		private var checkServerTimer:Timer;
		private const checkServerDelay:int = 10000;
		private var statusLoader:URLLoader;
		private var statusRequest:URLRequest;
		
		//private var serverUpdateMessage:String = "Извините, сервер временно недоступен, но скоро будет запущен с обновлениями.";
		//private var serverUpdateMessageEng:String = "Sorry, server isn't available, but it starts with updates soon.";
		private var serverUpdateMessage:String = "На сервере ведутся работы по обновлению игры. Приходите позже!";
		private var serverUpdateMessageEng:String = "Game server is being updated. Please come back later!";
		
		private var serverOverloadMessage:String = "Сервер перегружен танкистами. Приходите позже!";
		private var serverOverloadMessageEng:String = "Game server is overloaded with fighters. Please come back later!";
		
		
		public function AlternativaLoader() {
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageFocusRect = false;
			stage.quality = StageQuality.LOW;
			
			mouseEnabled = true;
			tabEnabled = true;
			
			library = new Array();
			libraryId = new Vector.<Long>();
			libraryVersion = new Vector.<Long>();
			librariesInitParams = new Dictionary();
			librariesData = new Object();
			
			debug = loaderInfo.parameters["debug"];
			
			// Создаём базовый контейнер
			mainContainer = new Sprite();
			addChild(mainContainer);
			mainContainer.mouseEnabled = false;
			mainContainer.tabEnabled = false;
			
			// Создаём консоль
			if (debug) {
				console = new PriorConsole();
				addChild(console);
				console.initConsole(loaderInfo.parameters["block"], loaderInfo.parameters["show"]);
				//console.hide();
			}
			// Определяем адрес сервера
			//server = "http://" + new LocalConnection().domain;
			server = SOCKET_DATA.resources;
			
			// Разрешаем доступ к серверу
			Security.allowDomain("*");
			
			statusURL = server + "/status.xml?rnd=" + Math.random();

			if(debug)
			{
				console.write(statusURL);
			}

			statusRequest = new URLRequest(statusURL);
			statusLoader = new URLLoader();
			statusLoader.addEventListener(Event.COMPLETE, onStasusLoadComplete);
			statusLoader.addEventListener(IOErrorEvent.IO_ERROR, onStasusLoadError);
			statusLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onStasusLoadError);
			
			configURL = server + "/alternativa.cfg?rnd=" + Math.random();
			
			// Проверяем доступность сервера
			checkServerStatus();
		}
		
		private function onStasusLoadComplete(e:Event):void {
			var statusXML:XML = new XML(URLLoader(e.target).data);
			
			var status:String = statusXML.code[0];
			if (debug) {
				console.write("Status: " + status);
			}
			if (statusXML.date != null) {
				var upTimeString:String = statusXML.date[0];
			}
			switch (status) {
				case "available":
					startLoading();
					break;
				case "overload":
					openAlertWindow(serverOverloadMessage + "\n\n" + serverOverloadMessageEng);
					break;
				case "update":
					openAlertWindow(serverUpdateMessage + "\n\n" + serverUpdateMessageEng);
					break;
				case "debug":
					if (debug) {
						startLoading();
					} else {
						openAlertWindow(serverUpdateMessage + "\n\n" + serverUpdateMessageEng);
					}
					break;
			}
		}
		private function startLoading():void {
			if (checkServerTimer != null) {
				checkServerTimer.stop();
			}
			if (alertWindow != null) {
				closeAlertWindow();
			}
				
			// Загружаем конфигурацию
			if (debug) {
				console.write("configURL: " + configURL);
			}
			var configLoader:URLLoader = new URLLoader(new URLRequest(configURL));
			configLoader.addEventListener(Event.COMPLETE, onConfigLoadComplete);
			configLoader.addEventListener(IOErrorEvent.IO_ERROR, onConfigLoadError);
			configLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onConfigLoadError);
		}
		
		private function onStasusLoadError(e:Event):void {
			if (debug) {
				console.write("Status load failed");
			}
		}
		private function openAlertWindow(text:String):void {
			if (alertWindow == null) {
				alertWindow = new AlertWindow(text);
				addChild(alertWindow);
				
				alignAlertWindow();
				stage.addEventListener(Event.RESIZE, alignAlertWindow);
				
				checkServerTimer = new Timer(checkServerDelay, int.MAX_VALUE);
				checkServerTimer.addEventListener(TimerEvent.TIMER, checkServerStatus);
				checkServerTimer.start();
			} else {
				// Установить текст
			}
		}		
		private function closeAlertWindow():void {
			if (alertWindow != null) {
				removeChild(alertWindow);
				alertWindow = null;
				stage.removeEventListener(Event.RESIZE, alignAlertWindow);
			}
		}
		private function alignAlertWindow(e:Event = null):void {
			alertWindow.x = Math.round((stage.stageWidth - alertWindow.width)*0.5);
			alertWindow.y = Math.round((stage.stageHeight - alertWindow.height)*0.5);
		}
		private function checkServerStatus(e:TimerEvent = null):void {
			// Проверяем доступность сервера
			statusLoader.load(statusRequest);
		}
		
		
		// Завершилась загрузка конфигурации
		private function onConfigLoadComplete(e:Event):void {
			if (debug) {
				console.write("config loaded");
			}
			var configXML:XML = new XML(URLLoader(e.target).data);
			
			// Сохраняем конфигурацию
			//hash = this.loaderInfo.parameters["hash"];
			//emailConfirmHash = this.loaderInfo.parameters["emailConfirmHash"];
			//email = this.loaderInfo.parameters["email"];
			crossdomain = (this.loaderInfo.parameters["server"] != null) ? this.loaderInfo.parameters["server"] : configXML.server.@ip;
			
			ports = new Array();
			for each (var p:XML in configXML.server.ports.elements("port")) {
				ports.push(int(p));
			}
			if (debug) {
				for (var i:int = 0; i < ports.length; i++) {
					console.writeToChannel("RESOURCE", "port " + i + ": " + ports[i]);
				}	
			}
			
			resources = "resources";//configXML.@plugins;
			
			// Загружаем библиотеки
			for each (var lib:XML in configXML.plugins.elements("plugin")) {
				var id:Long = new Long(0, int(lib.@id));
				if (debug) {
					console.writeToChannel("RESOURCE", "   library name: " + lib.@name + "  id: (" + id.high + "," + id.low+")");
				}
				libraryId.push(id);
				libraryVersion.push(new Long(0, int(lib.@version)));
			}
			library.push(loadResource(libraryId.shift(), libraryVersion.shift(), 0));
		}
		
		private function onloadLibrary(e:Event):void {
			// Инициализация библиотеки	
			var name:String = PriorLibraryResource(library[library.length-1]).name;
			
			if (libraryId.length > 0) {
				// Загрузка следующей библиотеки
				library.push(loadResource(libraryId.shift(), libraryVersion.shift(), 0));
			} else {
				if (debug) {
					console.write("\nБазовые библиотеки загружены\n", 0x0000cc);
				}
				this.onMainLibrariesLoaded();
			}
		}
		
		public function onMainLibrariesLoaded():void {
			// Рассылка события в Main
			/*for (var i:int = 0; i < library.length; i++) {
				if (PriorLibraryResource(library[i]).name == "библиотека Клиент") {
					ApplicationDomain.currentDomain.getDefinition(initClassPath + ".Main").onMainLibrariesLoaded(library);
				}
			}*/
			ApplicationDomain.currentDomain.getDefinition(initClassPath + ".Main").onMainLibrariesLoaded(library);
		}
		
		public function initOSGi():Object {
			if (ApplicationDomain.currentDomain.hasDefinition(initClassPath + "." + "OSGi")) {
				var shared:SharedObject = SharedObject.getLocal("name");
				/*if (hash != null && hash != "") {
					shared.data.userHash = hash;
				}
				if (emailConfirmHash != null && emailConfirmHash != "") {
					shared.data.emailConfirmHash = emailConfirmHash;
				}
				if (email != null && email != "") {
					shared.data.userEmail = email;
				}*/
				osgi = ApplicationDomain.currentDomain.getDefinition(initClassPath + "." + "OSGi").init(stage, mainContainer, crossdomain, ports[0], server + "/" + resources, console, shared);
			} else {
				if (debug) {
					console.writeToChannel("OSGI", "initOSGi не прошел!!!");
				}
			}
			return osgi;
		}
		
		/**
		 * Сформировать путь до ресурса
		 */
		private function makeResourceUrl(id:Long, version:Long):String {
			//console.write("makeResourceUrl resources: " + resources);
			//var url:String = "http://" + server + "/" + resources  + "/libraries/" + Number(id).toString() + "/" + version.toString() + "/";
			
			var url:String = server + "/" + resources;
			
			var longId:ByteArray = longToByteArray(id);
			
			url += "/" + longId.readUnsignedInt().toString(16);
			url += "/" + longId.readUnsignedShort().toString(16);
			url += "/" + longId.readUnsignedByte().toString(16);
			url += "/" + longId.readUnsignedByte().toString(16);
			
			url += "/";
			
			var longVersion:ByteArray = longToByteArray(version);
			var versHigh:uint = longVersion.readUnsignedInt();
			var versLow:uint = longVersion.readUnsignedInt();
			if (versHigh != 0) {
				url += versHigh.toString(16);
			}
			url += versLow.toString(16) + "/";
			
			//console.write("versHigh: " + versHigh, 0xff0000);
			//console.write("versLow: " + versLow, 0xff0000);
			
			/*var url:String = "http://" + server + "/" + resources + int(id/4294967296).toString(16);
				url += "/" + ((id & 0xFFFF0000) >> 16).toString(16);
				url += "/" + ((id & 0xFF00) >> 8).toString(16);
				url += "/" + (id & 0xFF).toString(16);
				url += "/" + version.toString(10) + "/";*/
			//var url:String = resources + "/" + Number(id).toString() + "/" + version.toString() + "/";
			//console.write("url: " + url);
			return url;						
		}

		private static function longToByteArray(val:Long) : ByteArray
		{
			var longArray:ByteArray = new ByteArray();
			longArray.writeInt(val.high);
			longArray.writeInt(val.low);
			longArray.position = 0;
			return longArray;
		}
		
		// Загрузка ресурса
		private function loadResource(id:Long, version:Long, type:int):PriorLibraryResource {
			// Определяем тип ресурса
			var resourceClass:Class = PriorLibraryResource;
			/*switch (type) {
				// Библиотека
				case 0:
					resourceClass = LibraryResource;
					break;
				// Спрайт
				case 1:
					resourceClass = SpriteResource;
					break;
				// Текстура
				case 4:
					resourceClass = TextureResource;
					break;
				default:
					resourceClass = null;
			}*/

			if (resourceClass != null) {
				// Создаём ресурс
				var resource:PriorLibraryResource = new PriorLibraryResource(this, osgi, console, id, version, librariesInitParams, librariesData);
				resource.getLoader().contentLoaderInfo.addEventListener(Event.COMPLETE, onloadLibrary);
								
				// Формируем путь 
				var url:String = makeResourceUrl(id, version);
				// Загружаем ресурс
				resource.load(url);
			} else {
				if (debug) {
					console.write("Тип ресурса с кодом " + type + " не описан");
				}
			}
			return resource;
		}
		
		// Ошибка загрузки конфигурации
		private function onConfigLoadError(e:Event):void {
			if (debug) {
				console.write("Config load failed");
			}
			//throw new Error("Config load failed");
		}

	}
}