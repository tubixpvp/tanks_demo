package alternativa.resource {
	import alternativa.init.Main;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 */
	public class A3DCollisionResource extends Resource {

		private var loader:URLLoader;
		private var data:ByteArray;
		
		/**
		 * 
		 * @param batchLoader
		 */
		public function A3DCollisionResource(batchLoader:BatchResourceLoader) {
			super("A3DCollisionResource", batchLoader, false);

			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
		}
		
		/**
		 * 
		 * @param e
		 */
		override protected function onInfoLoad(e:Event):void {
			super.onInfoLoad(e);
			loader.load(new URLRequest(url + "collisions.a3dc"));
		}
		
		/**
		 *
		 */
		protected function onLoadComplete(e:Event = null):void {
			data = loader.data as ByteArray;
			Main.writeToConsole("[A3DCollisionResource.onLoadComplete] data size: " + data.bytesAvailable);
			completeLoading();
		}
		
		/**
		 * 
		 * @return 
		 */		
		public function getData():ByteArray {
			return data;
		}

	}
}