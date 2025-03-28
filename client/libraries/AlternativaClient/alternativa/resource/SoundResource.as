package alternativa.resource {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	
	public class SoundResource extends Resource {
		
		private var _sound:Sound;
		
		public function SoundResource(batchLoader:BatchResourceLoader)	{
			super("звук", batchLoader);
			_sound = new Sound();
			
			_sound.addEventListener(Event.COMPLETE, onLoadComplete);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
		}
		
		override public function unload():void {
			super.unload();
			_sound = null;
		}
		
		// Информация загружена
		override protected function onInfoLoad(e:Event):void {
			super.onInfoLoad(e);
			// Загружаем библиотеку
			var context:SoundLoaderContext = new SoundLoaderContext();
			//context.applicationDomain = ApplicationDomain.currentDomain;
			//context.securityDomain = SecurityDomain.currentDomain;
			_sound.load(new URLRequest(url + "sound.mp3"), context);
		}

		// Библиотека загружена
		protected function onLoadComplete(e:Event = null):void {
			// Рассылка события
			completeLoading();
		}
		
		public function get sound():Sound {
			return _sound;
		}

	}
}