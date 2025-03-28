package alternativa.tanks.gui.login {
	import alternativa.gui.base.Dummy;
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.WindowAlign;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.Line;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.ImageButton;
	import alternativa.gui.window.WindowBase;
	import alternativa.tanks.gui.lobby.LobbyImageButton;
	import alternativa.tanks.gui.skin.LoginSkinManager;
	import alternativa.tanks.model.UserModel;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	public class LoginWindow extends WindowBase {
		
		[Embed(source="../../resources/small-window.png")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
		
		[Embed(source="../../resources/login-go-button_n.png")] private static const buttonBitmapNormal:Class;
		private static const buttonNormalBd:BitmapData = new buttonBitmapNormal().bitmapData;
		[Embed(source="../../resources/login-go-button_p.png")] private static const buttonBitmapPress:Class;
		private static const buttonPressBd:BitmapData = new buttonBitmapPress().bitmapData;
		
		[Embed(source="../../resources/reg-button_n.png")] private static const regButtonBitmapNormal:Class;
		private static const regButtonNormalBd:BitmapData = new regButtonBitmapNormal().bitmapData;
		[Embed(source="../../resources/reg-button_p.png")] private static const regButtonBitmapPress:Class;
		private static const regButtonPressBd:BitmapData = new regButtonBitmapPress().bitmapData;
		
		private var model:UserModel;
		
		private var back:Bitmap;
		
		private var nameContainer:Container;
		private var loginContainer:Container;
		private var passwordContainer:Container;
		private var bottomContainer:Container;
		private var regContainer:Container;
		
		private var nameGoButton:LobbyImageButton;
		private var loginGoButton:LobbyImageButton;
		
		private var nameLabel:Label;
		private var loginLabel:Label;
		private var loginHeader:LoginHeader;
		private var passwordLabel:Label;
		
		private var nameInput:ShortInput;
		private var loginInput:LongInput;
		private var passwordInput:LongInput;
		
		private var regButton:LobbyImageButton;
		
		
		public function LoginWindow(model:UserModel) {
			//super(0, 0, 10, 0);
			super(325, 270, false, false, "", false, false, false, WindowAlign.MIDDLE_CENTER);
			
			
			this.model = model;
			//this.rootObject = this;
			
			skinManager = new LoginSkinManager();
			
			layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.RIGHT, Align.TOP, 5);
			
			//minSize.x = 325;
			//minSize.y = 270;
			
			back = new Bitmap(backBd);
			addChildAt(back, 0);
			back.x = -40;
			back.y = -89;
			
			// Вход по имени
			nameContainer = new Container(0, 8, 0, 3);
			nameContainer.stretchableH = true;
			nameContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE, 4);
			addObject(nameContainer);
			
			nameLabel = new Label("YOUR NAME");
			nameContainer.addObject(nameLabel);
			
			nameContainer.addObject(new Dummy(6, 0));
			
			nameInput = new ShortInput();
			nameContainer.addObject(nameInput);
			
			nameGoButton = new LobbyImageButton(buttonNormalBd, buttonNormalBd, buttonPressBd, buttonNormalBd);
			nameGoButton.addEventListener(ButtonEvent.CLICK, goByName);
			nameContainer.addObject(nameGoButton);
			
			addObject(new Line(Direction.HORIZONTAL));
			addObject(new Dummy(0, 7));
			
			// Вход по логину и паролю
			loginHeader = new LoginHeader("FOR REGISTERED USERS", Align.CENTER);
			loginHeader.stretchableH = true;
			addObject(loginHeader);
			
			loginContainer = new Container(0, 18, 6, 0);
			loginContainer.stretchableH = true;
			loginContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE, 13);
			addObject(loginContainer);
			
			loginLabel = new Label("LOGIN");
			//loginLabel.stretchableH = true;
			loginContainer.addObject(loginLabel);
			
			loginInput = new LongInput();
			loginContainer.addObject(loginInput);
			
			passwordContainer = new Container(0, 0, 6, 0);
			passwordContainer.stretchableH = true;
			passwordContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE, 13);
			addObject(passwordContainer);
			
			bottomContainer = new Container(0, 0, 0, 0);
			bottomContainer.stretchableH = true;
			bottomContainer.stretchableV = true;
			bottomContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE);
			addObject(bottomContainer);
			
			/*regContainer = new Container(0, 0, 0, 0);
			regContainer.stretchableH = true;
			regContainer.stretchableV = true;
			regContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.BOTTOM);
			bottomContainer.addObject(regContainer);*/
			
			passwordLabel = new Label("PASSWORD");
			passwordContainer.addObject(passwordLabel);
			
			passwordInput = new LongInput();
			passwordContainer.addObject(passwordInput);
			passwordInput.passwordMode = true;
			
			regButton = new LobbyImageButton(regButtonNormalBd, regButtonNormalBd, regButtonPressBd, regButtonNormalBd);
			regButton.addEventListener(ButtonEvent.CLICK, register);
			bottomContainer.addObject(regButton);
			
			bottomContainer.addObject(new Dummy(0, 0, true, false));
			
			loginGoButton = new LobbyImageButton(buttonNormalBd, buttonNormalBd, buttonPressBd, buttonNormalBd);
			loginGoButton.addEventListener(ButtonEvent.CLICK, goByLogin);
			bottomContainer.addObject(loginGoButton);
			
			tabIndexes = new Array(nameInput, nameGoButton, loginInput, passwordInput, loginGoButton, regButton);
			
			draw(computeSize(computeMinSize()));
		}
		
		override public function updateSkin():void {
			super.updateSkin();
			
			contentContainer.marginRight = 10; 
		}
		
		private function goByName(e:ButtonEvent):void {
			model.goByName(nameInput.text);
		}
		private function goByLogin(e:ButtonEvent):void {
			model.goByLogin(loginInput.text, passwordInput.text);
		}
		private function register(e:ButtonEvent):void {
			model.showRegistrationWindow();
		}
		
		
		public function clearNameInput():void {
			nameInput.text = "";
			if (nameInput.wrongData) {
				nameInput.wrongData = false;
			}
		}
		public function clearLoginInput():void {
			loginInput.text = "";
			if (loginInput.wrongData) {
				loginInput.wrongData = false;
			}
		}
		public function clearPasswordInput():void {
			passwordInput.text = "";
			if (passwordInput.wrongData) {
				passwordInput.wrongData = false;
			}
		}

	}
}