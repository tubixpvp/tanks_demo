package alternativa.resource {
	import alternativa.engine3d.core.Object3D;
	import alternativa.init.Main;
	import alternativa.model.general.world3d.A3DParser;
	import alternativa.protocol.Packet;
	import alternativa.protocol.Protocol;
	//import alternativa.protocol.factory.CodecReference;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import platform.models.general.world3d.a3d.A3D;
	import alternativa.engine3d.loaders.Loader3DS;
	
	/**
	 * Ресурс хранит трёхмерную модель Alternativa3D.
	 */
	public class A3DResource extends Resource {
		// Протокол для загрузки ресурса
		//public static var PROTOCOL:Protocol = new Protocol(Main.spaceCodecFactory, new CodecReference(A3D, false));

		private static var protocol:Protocol = null;

		// Загрузчик бинарника в формате A3D
		private var loader:URLLoader;
		// Контейнер, содержащий загруженную модель
		private var _object:Object3D;
		
		/**
		 * Создаёт новый экземпляр ресурса.
		 * 
		 * @param handler
		 */
		public function A3DResource(batchLoader:BatchResourceLoader) {
			super("A3D resource", batchLoader);
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
		}
		
		/**
		 * Контейнер с моделью. В общем случае контейнер может содержать более одного дочернего объекта.
		 */
		public function get object():alternativa.engine3d.core.Object3D {
			return _object;
		}

		/**
		 * @inheritDoc
		 */
		override protected function onInfoLoad(e:Event):void {
			super.onInfoLoad(e);
			loader.load(new URLRequest(url + "object." + _name));
		}

		/**
		 * Метод декодирует бинарный формат и выполняет преобразование серверной 3д-модели в клиентскую.
		 */
		protected function onLoadComplete(e:Event = null):void 
		{
			Main.writeToConsole("A3DResource onLoadComplete loaded data size: " + (loader.data as ByteArray).length);
			var data:ByteArray = loader.data as ByteArray;
			Main.writeToConsole("raw data: " + data.readByte().toString(16) + " " + data.readByte().toString(16) + " " + data.readByte().toString(16) + " " + data.readByte().toString(16));
			data.position = 0;
			
			if(_name == "a3d")
			{
				parseA3D(data);
			}
			else
			{
				parse3DS(data);
			}
		}

		private function parseA3D(data:ByteArray) : void
		{
			var packet:Packet = new Packet();
			var a3dData:ByteArray = new ByteArray();

			packet.unwrapPacket(data, a3dData);
			a3dData.position = 0;
			Main.writeToConsole("A3DResource onLoadComplete a3dData size: " + a3dData.length);

			if(protocol == null)
			{
				protocol = new Protocol(Main.codecFactory, A3D);
			}

			var parser:A3DParser = new A3DParser(protocol.decode(a3dData) as A3D);
			_object = parser.parse();

			completeLoading();
		}

		private function parse3DS(data:ByteArray) : void
		{
			var parser:Loader3DS = new Loader3DS();
			parser.addEventListener(Event.COMPLETE, on3DSLoaded);
			parser.addEventListener(IOErrorEvent.IO_ERROR, onTextureLoadingError);
			parser.loadBytes(data, url);
		}
		private function onTextureLoadingError(e:Event) : void
		{
			Main.writeToConsole("texture not found: " + e);
		}
		private function on3DSLoaded(e:Event) : void
		{
			var parser:Loader3DS = (e.target as Loader3DS);

			parser.removeEventListener(Event.COMPLETE, on3DSLoaded);
			parser.removeEventListener(IOErrorEvent.IO_ERROR, onTextureLoadingError);

			_object = parser.content;

			completeLoading();
		}
		
	}
}