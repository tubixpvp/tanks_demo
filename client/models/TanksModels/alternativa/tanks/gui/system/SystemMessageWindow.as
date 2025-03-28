package alternativa.tanks.gui.system {
	import alternativa.gui.base.Dummy;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.WindowAlign;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.window.WindowBase;
	import alternativa.tanks.gui.skin.SystemMessageSkinManager;
	import alternativa.tanks.model.UserModel;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	public class SystemMessageWindow extends WindowBase {
		
		[Embed(source="../../resources/system-message-window.png")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
		[Embed(source="../../resources/system-message-button_ok.png")] private static const okButtonBitmap:Class;
		private static const okButtonBd:BitmapData = new okButtonBitmap().bitmapData;
		
		private var model:UserModel;
		
		private var back:Bitmap;
		
		//private var messageLabel:Text;
		private var messageString1:Label;
		private var messageString2:Label;
		private var messageString3:Label;
		private var messageString4:Label;
		
		private var okButton:ImageButton;
		
		
		public function SystemMessageWindow(model:UserModel) {
			//super(0, 38, 0, 0);
			super(367, 248, false, false, "", false, false, false, WindowAlign.MIDDLE_CENTER);
			
			this.model = model;
			//this.rootObject = this;
			
			skinManager = new SystemMessageSkinManager();
			
			layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.TOP, 16);
			
			//minSize.x = 367;
			//minSize.y = 248;
			
			back = new Bitmap(backBd);
			addChildAt(back, 0);
			back.x = -7;
			back.y = -7;
			
			//messageLabel = new Text(250, "", Align.CENTER, true, false);
			//addObject(messageLabel);
			
			messageString1 = new Label(" ", Align.CENTER);
			messageString2 = new Label(" ", Align.CENTER);
			messageString3 = new Label(" ", Align.CENTER);
			messageString4 = new Label(" ", Align.CENTER);
	
			addObject(messageString1);
			addObject(messageString2);
			addObject(messageString3);
			addObject(messageString4);
			
			addObject(new Dummy(0, -11, false, false));
			
			okButton = new ImageButton(0, 0, okButtonBd);
			okButton.addEventListener(ButtonEvent.CLICK, onOkButtonLick);
			addObject(okButton);
			
			tabIndexes = new Array(okButton);
			
			draw(computeSize(computeMinSize()));
		}
		
		override public function updateSkin():void {
			super.updateSkin();
			
			contentContainer.marginTop = 38; 
		}
		
		private function onOkButtonLick(e:ButtonEvent):void {
			model.hideMessageWindow();
		}
		
		public function set message(text:String):void {
			//messageLabel.text = text;
		}
		public function set string1(text:String):void {
			messageString1.text = text;
			repaintCurrentSize();
		}
		public function set string2(text:String):void {
			messageString2.text = text;
			repaintCurrentSize();
		}
		public function set string3(text:String):void {
			messageString3.text = text;
			repaintCurrentSize();
		}
		public function set string4(text:String):void {
			messageString4.text = text;
			repaintCurrentSize();
		}

	}
}