package alternativa.osgi.service.mainContainer {
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	
	
	public class MainContainerService implements IMainContainerService {
		
		private var _stage:Stage;
		private var _mainContainer:DisplayObjectContainer;
		
		private var _backgroundLayer:DisplayObjectContainer;
		private var _contentLayer:DisplayObjectContainer;
		private var _contentUILayer:DisplayObjectContainer;
		private var _systemLayer:DisplayObjectContainer;
		private var _systemUILayer:DisplayObjectContainer;
		private var _dialogsLayer:DisplayObjectContainer;
		private var _noticesLayer:DisplayObjectContainer;
		private var _cursorLayer:DisplayObjectContainer;
		
		
		public function MainContainerService(s:Stage, container:DisplayObjectContainer) {
			_stage = s;
			_mainContainer = container;
			
			_backgroundLayer = addLayerSprite();
			_contentLayer = addLayerSprite();
			_contentUILayer = addLayerSprite();
			_systemLayer = addLayerSprite();
			_systemUILayer = addLayerSprite();
			_dialogsLayer = addLayerSprite();
			_noticesLayer = addLayerSprite();
			_cursorLayer = addLayerSprite();
		}
		
		private function addLayerSprite():Sprite {
			var sprite:Sprite = new Sprite();
			sprite.mouseEnabled = false;
			sprite.tabEnabled = false;
			mainContainer.addChild(sprite);
			return sprite;
		}
		
		public function get stage():Stage {
			return _stage;
		}
		
		public function get mainContainer():DisplayObjectContainer {
			return _mainContainer;
		}
		
		
		public function get backgroundLayer():DisplayObjectContainer {
			return _backgroundLayer;
		}
		public function get contentLayer():DisplayObjectContainer {
			return _contentLayer;
		}
		public function get contentUILayer():DisplayObjectContainer {
			return _contentUILayer;
		}
		public function get systemLayer():DisplayObjectContainer {
			return _systemLayer;
		}
		public function get systemUILayer():DisplayObjectContainer {
			return _systemUILayer;
		}
		public function get dialogsLayer():DisplayObjectContainer {
			return _dialogsLayer;
		}
		public function get noticesLayer():DisplayObjectContainer {
			return _noticesLayer;
		}
		public function get cursorLayer():DisplayObjectContainer {
			return _cursorLayer;
		}

	}
}