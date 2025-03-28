package alternativa.engine3d.loaders {
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.events.LoaderEvent;
	import alternativa.engine3d.loaders.events.LoaderProgressEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * Рассылается в начале очередного этапа загрузки сцены.
	 * 
	 * @eventType alternativa.engine3d.loaders.events.LoaderEvent.LOADING_START
	 */
	[Event (name="loadingStart", type="alternativa.engine3d.loaders.events.LoaderEvent")]
	/**
	 * Рассылается в процессе получения данных во время загрузки.
	 * 
	 * @eventType alternativa.engine3d.loaders.events.LoaderProgressEvent.LOADING_PROGRESS
	 */
	[Event (name="loadingProgress", type="alternativa.engine3d.loaders.events.LoaderProgressEvent")]
	/**
	 * Рассылается после окончания очередного этапа загрузки сцены.
	 * 
	 * @eventType alternativa.engine3d.loaders.events.LoaderEvent.LOADING_COMPLETE
	 */
	[Event (name="loadingComplete", type="alternativa.engine3d.loaders.events.LoaderEvent")]
	/**
	 * Рассылается после окончания загрузки сцены.
	 * 
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event (name="complete", type="flash.events.Event")]
	/**
	 * Рассылается, если в процессе загрузки возникает ошибка, которая прерывает загрузку.
	 * 
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event (name="ioError", type="flash.events.IOErrorEvent")]
	/**
	 * Рассылается, если вызов <code>Loader3D.load()</code> нарушает текущие правила безопасности.
	 * 
	 * @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event (name="securityError", type="flash.events.SecurityErrorEvent")]

	/**
	 * Базовый класс загрузчиков. Реализует загрузку основного файла сцены и включает ряд методов, расширяя которые,
	 * наследники могут реализовывать специфическую функциональность для разбора сцены и загрузки дополнительных данных.
	 */
	public class Loader3D extends EventDispatcher {
		/**
		 * Текущее состояние загрузчика. Показывает наличие активных процессов загрузки. В качестве значений используются объявленные в классе константы.
		 */
		protected var loaderState:int = Loader3DState.IDLE;
		/**
		 * Базовый URL основного файла сцены, не включающий имя файла. Если путь не пустой, то он заканчивается символом "/".
		 */
		protected var baseURL:String;
		/**
		 * LoaderContext для загрузки файлов текстур.
		 */
		protected var loaderContext:LoaderContext;
		/**
		 * Контейнер, который должен содержать объекты, загруженные из файла сцены.
		 */
		protected var _content:Object3D;
		/**
		 * Загрузчик основного файла сцены.
		 */
		private var mainLoader:URLLoader;
		
		/**
		 * Создаёт новый экземпляр класса.
		 */
		public function Loader3D() {
			super(this);
		}
		
		/**
		 * Контейнер, содержащий все загруженные из сцены объекты.
		 */
		public final function get content():Object3D {
			return _content;
		}
		
		/**
		 * Загружает сцену из файла с заданным URL. Метод отменяет текущую загрузку.
		 * Если файл успешно загружен, вызывается метод <code>parse()</code>, который выполняет разбор полученных данных.
		 *  
		 * @param url URL файла со сценой
		 * @param context LoaderContext для загрузки файлов текстур
		 * 
		 * @see #parse()
		 */
		public final function load(url:String, loaderContext:LoaderContext = null):void {
			this.baseURL = url.substring(0, url.lastIndexOf("/") + 1);
			this.loaderContext = loaderContext;
			
			if (mainLoader == null) {
				// Первоначальное создание загрузчика файла сцены
				mainLoader = new URLLoader();
				mainLoader.dataFormat = URLLoaderDataFormat.BINARY;
				mainLoader.addEventListener(Event.COMPLETE, onMainLoadingComplete);
				mainLoader.addEventListener(ProgressEvent.PROGRESS, onMainLoadingProgress);
				mainLoader.addEventListener(IOErrorEvent.IO_ERROR, onMainLoadingError);
				mainLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onMainLoadingError);
			} else {
				// Прекращение активной загрузки
				close();
			}
			_content = null;
			// Загрузка основного файла
			setState(Loader3DState.LOADING_MAIN);
			mainLoader.load(new URLRequest(url));
			if (hasEventListener(LoaderEvent.LOADING_START)) {
				dispatchEvent(new LoaderEvent(LoaderEvent.LOADING_START, LoadingStage.MAIN_FILE));
			}
		}

		/**
		 * Загружает сцену из массива бинарных данных.
		 * Для чтения и разбора данных из массива вызывается метод <code>parse()</code>.
		 * 
		 * @param data данные сцены
		 * @param baseUrl базовый URL для файлов текстур
		 * @param loaderContext LoaderContext для загрузки файлов текстур
		 * 
		 * @see #parse()
		 */
		public final function loadBytes(data:ByteArray, baseUrl:String = null, loaderContext:LoaderContext = null):void {
			if (baseUrl == null) {
				baseUrl = "";
			} else if (baseUrl.length > 0 && baseUrl.charAt(baseUrl.length - 1) != "/") {
				baseUrl += "/";
			}
			this.baseURL = baseUrl;
			this.loaderContext = loaderContext;
			close();
			_content = null;
			parse(data);
		}
		
		/**
		 * Прекращает текущую загрузку. Базовая реализация останавливает процесс загрузки основного файла сцены. Наследники должны расширять метод <code>closeInternal</code> для
		 * прекращения специфических процессов загрузки.
		 * 
		 * @see #closeInternal()
		 */
		public final function close():void {
			if (loaderState == Loader3DState.LOADING_MAIN) {
				mainLoader.close();
			}
			closeInternal();
			clean();
			setState(Loader3DState.IDLE);
		}
		
		/**
		 * Очищает внутренние ссылки на загруженные данные, чтобы сборщик мусора мог освободить занимаемую ими память. Метод не работает
		 * во время процесса загрузки данных. Реализация метода удаляет сылку на контейнер с загруженными объектами и вызывает метод <code>unloadInternal()</code>.
		 * 
		 * @see #unloadInternal() 
		 */
		public final function unload():void {
			if (loaderState != Loader3DState.IDLE) {
				return;
			}
			_content = null;
			unloadInternal();
		}
		
		/**
		 * Метод вызывается из <code>close()</code> и должен прекращать процессы загрузки, инициированные наследниками. Базовая реализация не делает ничего.
		 * 
		 * @see #close()
		 */
		protected function closeInternal():void {
		}

		/**
		 * Вызывается из метода <code>unload()</code>. Наследники должны расширять метод для удаления внутренних ссылок на объекты. Базовая реализация не делает ничего.
		 * 
		 * @see #unload()
		 */
		protected function unloadInternal():void {
		}
		
		/**
		 * Устанавливает внутреннее состояние загрузчика.
		 * 
		 * @param state новое состояние
		 */
		protected function setState(state:int):void {
			loaderState = state;
		}
		
		/**
		 * Наследники должны расширять метод, реализуя функционал по разбору данных. Базовая реализация не делает ничего.
		 *   
		 * @param data данные трёхмерной сцены
		 */
		protected function parse(data:ByteArray):void {
		}

		/**
		 * Обрабатывает ошибку, возникшую при загрузке основного файла. Базовая реализация устанавливает состояние загрузчика в <code>STATE_IDLE</code> и рассылает
		 * полученное событие.
		 * 
		 * @param e событие, описывающего ошибку
		 */
		protected function onMainLoadingError(e:ErrorEvent):void {
			setState(Loader3DState.IDLE);
			dispatchEvent(e);
		}

		/**
		 * Метод должен вызываться после того как все данные сцены успешно загружены. Метод переводит загрузчик в состояние ожидания, вызывает метод очистки
		 * <code>clean()</code> и рассылает событие <code>Event.COMPLETE</code>.
		 * 
		 * @see #clean()  
		 */
		protected final function complete():void {
			setState(Loader3DState.IDLE);
			clean();
			if (hasEventListener(Event.COMPLETE)) {
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * Метод должен очищать внутренние вспомогательные переменные. Вызывается из метода <code>complete</code>. Базовая реализация не делает ничего, наследники должны расширять
		 * метод при необходимости.
		 * 
		 * @see #complete()
		 */
		protected function clean():void {
		}

		/**
		 * Обработчик успешной загрузки основного файла. Запускает функцию parse() для разбора данных.
		 */
		private function onMainLoadingComplete(e:Event):void {
			setState(Loader3DState.IDLE);
			if (hasEventListener(LoaderEvent.LOADING_COMPLETE)) {
				dispatchEvent(new LoaderEvent(LoaderEvent.LOADING_COMPLETE, LoadingStage.MAIN_FILE));
			}
			parse(mainLoader.data);
		}

		/**
		 * Рассылает событие прогресса загрузки основного файла.
		 */
		private function onMainLoadingProgress(e:ProgressEvent):void {
			if (hasEventListener(LoaderProgressEvent.LOADING_PROGRESS)) {
				dispatchEvent(new LoaderProgressEvent(LoaderProgressEvent.LOADING_PROGRESS, LoadingStage.MAIN_FILE, 1, 0, e.bytesLoaded, e.bytesTotal));
			}
		}

	}
}