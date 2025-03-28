package alternativa.debug {
	import alternativa.init.Main;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	
	public class ServerMessageWindow extends Sprite {
		
		private var message:TextField;
		
		private var buttonOk:Sprite;
		private var buttonText:TextField;
		
		private var _currentSize:Point;
		
		public function ServerMessageWindow() {
			super();
			mouseEnabled = false;
			tabEnabled = false;
			
			message = new TextField();
			message.thickness = 50;
			message.sharpness = -50;
			with (message) {
				width = 250;
				y = 25;
				defaultTextFormat = new TextFormat("Tahoma", 12, 0x000000);
				type = TextFieldType.DYNAMIC;
				autoSize = TextFieldAutoSize.CENTER;
				antiAliasType = AntiAliasType.ADVANCED;
				embedFonts = false;
				selectable = false;
				multiline = true;
				wordWrap = true;
				mouseEnabled = false;
				tabEnabled = false;
			}
			addChild(message);
			
			buttonOk = new Sprite();
			buttonOk.graphics.beginFill(0xffffff, 1);
			buttonOk.graphics.lineStyle(1, 0x666666);
			buttonOk.graphics.drawRoundRect(0, 0, 60, 30, 5, 5);
			addChild(buttonOk);
			buttonOk.addEventListener(MouseEvent.CLICK, onOkButtonClick);
			
			buttonText = new TextField();
			buttonText.thickness = 50;
			buttonText.sharpness = -50;
			with (buttonText) {
				defaultTextFormat = new TextFormat("Tahoma", 12, 0x000000, true);
				type = TextFieldType.DYNAMIC;
				autoSize = TextFieldAutoSize.NONE;
				antiAliasType = AntiAliasType.ADVANCED;
				embedFonts = false;
				selectable = false;
				multiline = false;
				mouseEnabled = false;
				tabEnabled = false;
				text = "OK";
			}
			addChild(buttonText);
			
			_currentSize = new Point(300, 200);
			
			this.filters = [new DropShadowFilter(3, 70, 0, 0.5, 2, 2, 1, BitmapFilterQuality.MEDIUM, false, false, false)];
			
			repaint();
		}
		
		public function set text(value:String):void {
			message.text = value;
			
			message.x = Math.round((_currentSize.x - message.textWidth)*0.5);
			
			repaint();
		}
		
		public function get currentSize():Point {
			return _currentSize;
		}
		
		private function repaint():void {
			_currentSize.y = 25 + message.textHeight + 30 + buttonOk.height;
			
			this.graphics.beginFill(0xcccccc, 1);
			this.graphics.drawRoundRect(0, 0, _currentSize.x, _currentSize.y, 5, 5);
			
			buttonOk.x = Math.round((_currentSize.x - buttonOk.width)*0.5);
			buttonOk.y = Math.round(_currentSize.y - 15 - buttonOk.height);
			
			buttonText.x = Math.round(buttonOk.x + (buttonOk.width - buttonText.textWidth)*0.5 - 2);
			buttonText.y = Math.round(buttonOk.y + (buttonOk.height - (buttonText.textHeight-3))*0.5 - 3);
		}
		
		private function onOkButtonClick(e:MouseEvent):void {
			Main.debug.hideServerMessageWindow();
		}

	}
}