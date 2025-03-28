package alternativa.debug {
	import alternativa.init.Main;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class ErrorWindow extends Sprite {
		
		[Embed(source="images/system-message-window.png")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
		
		[Embed(source="images/system-message-button_ok.png")] private static const okButtonBitmap:Class;
		private static const okButtonBd:BitmapData = new okButtonBitmap().bitmapData;
		
		private var back:Bitmap;
		
		private var message:TextField;
		
		private var buttonOkBitmap:Bitmap;
		private var buttonOk:Sprite;
		
		private var _currentSize:Point;
		
		
		public function ErrorWindow() {
			super();
			mouseEnabled = false;
			tabEnabled = false;
			
			back = new Bitmap(backBd);
			addChild(back);
			back.x = -7;
			back.y = -7;
			
			message = new TextField();
			message.thickness = 50;
			message.sharpness = -50;
			with (message) {
				defaultTextFormat = new TextFormat("Sign", 12, 0x000000);
				defaultTextFormat.leading = 30;
				type = TextFieldType.DYNAMIC;
				autoSize = TextFieldAutoSize.NONE;
				antiAliasType = AntiAliasType.ADVANCED;
				embedFonts = true;
				selectable = false;
				multiline = false;
				mouseEnabled = false;
				tabEnabled = false;
			}
			addChild(message);
			
			buttonOk = new Sprite();
			addChild(buttonOk);
			buttonOkBitmap = new Bitmap(okButtonBd);
			buttonOk.addChild(buttonOkBitmap);
			buttonOk.addEventListener(MouseEvent.CLICK, onOkButtonClick);
			
			_currentSize = new Point(367, 248);
			
			repaint();
		}
		
		public function set text(value:String):void {
			message.width = 300;
			
			message.text = value;
			
			message.x = (_currentSize.x - message.textWidth)*0.5;
			message.y = 38;
		}
		
		public function get currentSize():Point {
			return _currentSize;
		}
		
		private function repaint():void {
			message.autoSize = TextFieldAutoSize.CENTER;
			message.width = 200;
			message.autoSize = TextFieldAutoSize.NONE;
			message.x = (_currentSize.x - message.textWidth)*0.5;
			message.y = 38;
			
			buttonOk.x = (_currentSize.x - buttonOk.width)*0.5;
			buttonOk.y = _currentSize.y - 30 - buttonOk.height;
		}
		
		private function onOkButtonClick(e:MouseEvent):void {
			Main.debug.hideErrorWindow();
		}

	}
}