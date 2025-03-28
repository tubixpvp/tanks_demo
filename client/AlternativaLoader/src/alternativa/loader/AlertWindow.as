package alternativa.loader {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class AlertWindow extends Sprite {
		
		private var window:Shape;
		private var size:Point;
		private var message:TextField;
		
		
		public function AlertWindow(text:String) {
			super();
			mouseEnabled = false;
			tabEnabled = false;
			
			size = new Point(300, 150);
			
			window = new Shape();
			window.graphics.beginFill(0x999999, 1);
			window.graphics.drawRoundRect(0, 0, size.x, size.y, 5, 5);
			addChild(window);
			
			message = new TextField();
			message.defaultTextFormat = new TextFormat("Tahoma", 12, 0x000000, true);
			message.text = text;
			message.multiline = true;
			message.wordWrap = true;
			message.selectable = false;
			message.width = 250;
			//message.thickness = 50;
			//message.sharpness = -50;
			/*with (message) {
				width = 250;
				y = 25;
				defaultTextFormat = new TextFormat("Tahoma", 12, 0x000000);
				autoSize = TextFieldAutoSize.CENTER;
				antiAliasType = AntiAliasType.ADVANCED;
				embedFonts = false;
				selectable = false;
				multiline = true;
				wordWrap = true;
				mouseEnabled = false;
				tabEnabled = false;
				text = text;
			}*/
			addChild(message);
			
			message.x = Math.round((size.x - message.textWidth)*0.5);
			message.y = 25;
		}

	}
}