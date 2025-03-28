package alternativa.tanks.gui.lobby {
	import alternativa.gui.widget.button.ITriggerButton;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.tanks.gui.skin.LobbyMapIconSkin;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.geom.Point;
	
	
	public class LobbyMapIcon extends ImageButton implements ITriggerButton {
		
		private var outline:Shape;
		private var frame:Shape;
		private var circle:Shape;
		
		private var playersNumLabel:LobbyMapIconLabel;
		private var _mapName:String;
		private var _mapDescription:String;
		
		private var _selected:Boolean;
		
		private var _maxPlayersNum:int;
		
		private var skin:LobbyMapIconSkin;
		
		
		
		public function LobbyMapIcon(mapName:String, mapDescription:String, image:BitmapData=null, maxPlayersNum:int = 10) {
			super(0, 0, image);
			_mapName = mapName;
			_mapDescription = mapDescription;
			_maxPlayersNum = maxPlayersNum;
			
			frame = new Shape();
			addChildAt(frame, 0);
			frame.blendMode = BlendMode.DIFFERENCE;
			
			outline = new Shape();
			addChild(outline);
			
			circle = new Shape();
			addChild(circle);
			circle.graphics.beginFill(0xffffff, 1);
			circle.graphics.drawCircle(0, 0, 15);
			
			playersNumLabel = new LobbyMapIconLabel("0");
			addChild(playersNumLabel);
		}
		
		override public function updateSkin():void {
			skin = LobbyMapIconSkin(skinManager.getSkin(LobbyMapIcon));
			super.updateSkin();
		}
		
		/**
		 * Фокусировка
		 */		
		override protected function focus():void {}
		/**
		 * Расфокусировка
		 */		
		override protected function unfocus():void {}
		
		override public function computeMinSize():Point {
			playersNumLabel.computeMinSize();
			
			return super.computeMinSize();
		}
		
		override public function draw(size:Point):void {
			super.draw(size);
			
			drawBorder(size);
			
			circle.x = currentSize.x - 9;
			circle.y = currentSize.y - 9;
			
			playersNumLabel.draw(playersNumLabel.computeSize(playersNumLabel.minSize));
			playersNumLabel.x = circle.x - playersNumLabel.currentSize.x*0.5;
			playersNumLabel.y = circle.y - playersNumLabel.currentSize.y*0.5;
		}
		
		private function drawBorder(size:Point):void {
			outline.graphics.clear();
			outline.graphics.lineStyle(1, 0xffffff, 1);
			outline.graphics.drawRect(0, 0, size.x, size.y);
			
			frame.graphics.clear();
			if (_selected) {
				frame.graphics.beginFill(0x6e6e44, 0.5);
				frame.graphics.drawRect(-6, -6, currentSize.x + 12, currentSize.y + 12);
				frame.graphics.drawRect(0, 0, currentSize.x, currentSize.y);
			}
		}
		
		override protected function switchState():void {
			if (locked) {
				bitmap.bitmapData = _lockBitmap;
				bitmap.transform.colorTransform = skin.colorLock;
				bitmap.alpha = 0.5;
				//bitmap.y = yNormal;
			} else if (pressed) {
				bitmap.bitmapData = _pressBitmap;
				bitmap.transform.colorTransform = skin.colorPress;
				bitmap.alpha = 1;
				//bitmap.y = yPress;
			} else if (focused) {
				bitmap.bitmapData = _overBitmap;
				bitmap.transform.colorTransform = skin.colorFocus;
				bitmap.alpha = 1;
				//bitmap.y = yNormal;
			}  else if (over) {
				bitmap.bitmapData = _overBitmap;
				bitmap.transform.colorTransform = skin.colorOver;
				bitmap.alpha = 1;
				//bitmap.y = yNormal;
			} else {
				bitmap.bitmapData = _normalBitmap;
				bitmap.transform.colorTransform = skin.colorNormal;
				bitmap.alpha = 1;
				//bitmap.y = yNormal;	
			}
		}
		
		public function set selected(value:Boolean):void {
			_selected = value;
			
			drawBorder(_currentSize);
		}
		public function get selected():Boolean {
			return _selected;
		}
		
		public function set playersNum(value:int):void {
			playersNumLabel.text = value.toString() + "/" + _maxPlayersNum.toString();
			
			playersNumLabel.draw(playersNumLabel.computeSize(playersNumLabel.minSize));
			playersNumLabel.x = (circle.width - playersNumLabel.currentSize.x)*0.5;
			playersNumLabel.y = (circle.height - playersNumLabel.currentSize.y)*0.5;
		}
		public function get mapName():String {
			return _mapName;
		}
		public function get mapDescription():String {
			return _mapDescription;
		}
		public function get maxPlayersNum():int {
			return _maxPlayersNum;
		}

	}
}