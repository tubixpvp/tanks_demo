package alternativa.tanks.gui.registration {
	import alternativa.gui.base.Dummy;
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.WindowAlign;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.Text;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.window.WindowBase;
	import alternativa.tanks.gui.lobby.LobbyImageButton;
	import alternativa.tanks.gui.login.LongInput;
	import alternativa.tanks.gui.skin.RegistrationSkinManager;
	import alternativa.tanks.gui.widget.WindowHeader;
	import alternativa.tanks.model.UserModel;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	public class RegistrationWindow extends WindowBase {
		
		[Embed(source="../../resources/small-window.png")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
		
		[Embed(source="../../resources/reg-ok-button_n.png")] private static const okButtonBitmapNormal:Class;
		private static const okButtonNormalBd:BitmapData = new okButtonBitmapNormal().bitmapData;
		[Embed(source="../../resources/reg-ok-button_p.png")] private static const okButtonBitmapPress:Class;
		private static const okButtonPressBd:BitmapData = new okButtonBitmapPress().bitmapData;
		
		[Embed(source="../../resources/reg-back-button_n.png")] private static const backButtonBitmapNormal:Class;
		private static const backButtonNormalBd:BitmapData = new backButtonBitmapNormal().bitmapData;
		[Embed(source="../../resources/reg-back-button_p.png")] private static const backButtonBitmapPress:Class;
		private static const backButtonPressBd:BitmapData = new backButtonBitmapPress().bitmapData;
		
		private var model:UserModel;
		
		private var back:Bitmap;
		
		private var nameContainer:Container;
		private var mailContainer:Container;
		private var loginContainer:Container;
		private var passwordContainer:Container;
		private var repPasswordContainer:Container;
		private var buttonContainer:Container;
		
		private var nameInput:LongInput;
		private var mailInput:LongInput;
		private var loginInput:LongInput;
		private var passwordInput:LongInput;
		private var repPasswordInput:LongInput;
			
		private var okButton:LobbyImageButton;
		private var backButton:LobbyImageButton;
		
		
		public function RegistrationWindow(model:UserModel) {
			//super(0, 15, 0, 0);
			super(325, 270, false, false, "", false, false, false, WindowAlign.MIDDLE_CENTER);
			
			this.model = model;
			//this.rootObject = this;
			
			skinManager = new RegistrationSkinManager();
			
			layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.TOP, 5);
			
			//minSize.x = 325;
			//minSize.y = 270;
			
			back = new Bitmap(backBd);
			addChildAt(back, 0);
			back.x = -40;
			back.y = -89;
			
			addObject(new WindowHeader("REGISTRATION", Align.CENTER));
			addObject(new Dummy(0, 10));
			
			nameContainer = new Container(0, 0, 20, 0);
			nameContainer.stretchableH = true;
			nameContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE, 14);
			addObject(nameContainer);
			
			mailContainer = new Container(0, 0, 20, 0);
			mailContainer.stretchableH = true;
			mailContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE, 14);
			addObject(mailContainer);
			
			loginContainer = new Container(0, 0, 20, 0);
			loginContainer.stretchableH = true;
			loginContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE, 14);
			addObject(loginContainer);
			
			passwordContainer = new Container(0, 0, 20, 0);
			passwordContainer.stretchableH = true;
			passwordContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE, 14);
			addObject(passwordContainer);
			
			repPasswordContainer = new Container(0, -3, 20, 0);
			repPasswordContainer.stretchableH = true;
			repPasswordContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE, 5);
			addObject(repPasswordContainer);
			
			buttonContainer = new Container(0, 0, 20, 0);
			buttonContainer.stretchableH = true;
			buttonContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE);
			addObject(buttonContainer);
			
			var nameLabel:Label = new Label("NAME", Align.RIGHT);
			nameLabel.minSize.x = 90;
			nameContainer.addObject(nameLabel);
			nameInput = new LongInput("");
			nameContainer.addObject(nameInput);
			
			var mailLabel:Label = new Label("E-MAIL", Align.RIGHT);
			mailLabel.minSize.x = 90;
			mailContainer.addObject(mailLabel);
			mailInput = new LongInput("");
			mailContainer.addObject(mailInput);
			
			var loginLabel:Label = new Label("LOGIN", Align.RIGHT);
			loginLabel.minSize.x = 90;
			loginContainer.addObject(loginLabel);
			loginInput = new LongInput("");
			loginContainer.addObject(loginInput);
			
			var passwordLabel:Label = new Label("PASSWORD", Align.RIGHT);
			passwordLabel.minSize.x = 90;
			passwordContainer.addObject(passwordLabel);
			passwordInput = new LongInput("");
			passwordInput.passwordMode = true;
			passwordContainer.addObject(passwordInput);
			
			var repPasswordLabel:Text = new Text(90, "      REPEAT PASSWORD", Align.RIGHT, true);
			repPasswordContainer.addObject(new Dummy(0, 0, true, false));
			repPasswordContainer.addObject(repPasswordLabel);
			repPasswordInput = new LongInput("");
			repPasswordInput.passwordMode = true;
			repPasswordContainer.addObject(repPasswordInput);
			
			backButton = new LobbyImageButton(backButtonNormalBd, backButtonNormalBd, backButtonPressBd, backButtonNormalBd);
			okButton = new LobbyImageButton(okButtonNormalBd, okButtonNormalBd, okButtonPressBd, okButtonNormalBd);
			backButton.addEventListener(ButtonEvent.CLICK, onBackButtonClick);
			okButton.addEventListener(ButtonEvent.CLICK, onOkButtonClick);
			buttonContainer.addObject(backButton);
			buttonContainer.addObject(okButton);
			
			tabIndexes = new Array(nameInput, mailInput, loginInput, passwordInput, repPasswordInput, backButton, okButton);
			
			draw(computeSize(computeMinSize()));
		}
		
		override public function updateSkin():void {
			super.updateSkin();
			
			contentContainer.marginTop = 15; 
		}
		
		public function set userName(name:String):void {
			nameInput.text = name;
		}
		
		private function onBackButtonClick(e:ButtonEvent):void {
			model.hideRegistrationWindow();
			model.showLoginWindow();
		}
		private function onOkButtonClick(e:ButtonEvent):void {
			//model.hideRegistrationWindow();
			model.newRegistration(nameInput.text, mailInput.text, loginInput.text, passwordInput.text, repPasswordInput.text);
		}
		
	}
}