package alternativa.tanks.model {
	import alternativa.gui.window.WindowEvent;
	import alternativa.init.Main;
	import alternativa.model.IObjectLoadListener;
	import alternativa.object.ClientObject;
	import alternativa.protocol.codec.NullMap;
	import alternativa.protocol.factory.ICodecFactory;
	import alternativa.tanks.gui.login.LoginWindow;
	import alternativa.tanks.gui.registration.RegistrationWindow;
	import alternativa.tanks.gui.system.SystemMessageWindow;
	
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.utils.IDataInput;
	import alternativa.osgi.service.storage.IStorageService;

	import projects.tanks.models.users.user.UserModelBase;
	import projects.tanks.models.users.user.IUserModelBase;
	import projects.tanks.models.users.user.LoginErrorsEnum;
	import projects.tanks.models.users.user.RegisterErrorsEnum;
	
	
	public class UserModel extends UserModelBase implements IUserModelBase, IObjectLoadListener {
		
		private var clientObject:ClientObject;
		
		public var loginWindow:LoginWindow;
		public var systemWindow:SystemMessageWindow;
		public var registrationWindow:RegistrationWindow;
		
		
		public function UserModel() {
			loginWindow = new LoginWindow(this);
			systemWindow = new SystemMessageWindow(this);
			systemWindow.moveArea = null;
			registrationWindow = new RegistrationWindow(this);
		}
		
		public function objectLoaded(object:ClientObject):void {
			Main.loadingProgress.closeLoadingWindow();
			
			Main.console.writeToConsole("UserModel objectLoaded", 0x0000cc);
			this.clientObject = object;
		}
		
		public function objectUnloaded(object:ClientObject):void {
			Main.console.writeToConsole("UserModel objectUnloaded", 0x0000cc);
			hideLoginWindow();
			clientObject = null;
		}
		
		override public function _initObject(clientObject:ClientObject, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void {
			var storage:SharedObject = (Main.osgi.getService(IStorageService) as IStorageService).getStorage();
			Main.console.writeToConsole("UserModel initObject userHash: " + storage.data.userHash, 0x0000cc);
			if (storage.data.userHash != null) {
				// Войти по hash коду
				Main.console.writeToConsole("UserModel loginByHash", 0x0000cc);
				loginByHash(clientObject, storage.data.userHash);
			} else {
				// Показать окно логина
				showLoginWindow();
			}
		}
		
		public function hideWindows(clientObject:ClientObject):void {
			hideLoginWindow();
			hideRegistrationWindow();
			hideMessageWindow();
		}
		
		public function showRegisterWindow(clientObject:ClientObject, name:String):void {
			Main.console.writeToConsole("UserModel showRegisterWindow clientObject: " + clientObject);
			Main.console.writeToConsole("UserModel showRegisterWindow name: " + name);
			showRegistrationWindow();
			registrationWindow.userName = name;
		}
		
		public function showLoginWindow():void {
			if (!TanksModels.windowContainer.contains(loginWindow)) {
				TanksModels.windowContainer.addWindow(loginWindow);
			}
			loginWindow.dispatchEvent(new WindowEvent(WindowEvent.SELECT, loginWindow));
			
			loginWindow.x = Math.round((Main.stage.stageWidth - loginWindow.minSize.x)*0.5);
	    	loginWindow.y = Math.round((Main.stage.stageHeight - loginWindow.minSize.y)*0.5);
			//Main.stage.addEventListener(Event.RESIZE, onStageResize);
		}
		public function hideLoginWindow():void {
			//Main.stage.removeEventListener(Event.RESIZE, onStageResize);
			if (TanksModels.windowContainer.contains(loginWindow)) {
				TanksModels.windowContainer.removeWindow(loginWindow);
				loginWindow.dispatchEvent(new WindowEvent(WindowEvent.UNSELECT, loginWindow));
			}
		}
		
		public function showMessageWindow(string1:String = "", string2:String = "", string3:String = "", string4:String = ""):void {
			if (!TanksModels.windowContainer.contains(systemWindow)) {
				TanksModels.windowContainer.addWindow(systemWindow);
			}
			systemWindow.dispatchEvent(new WindowEvent(WindowEvent.SELECT, systemWindow));
			
			systemWindow.string1 = string1;
			systemWindow.string2 = string2;
			systemWindow.string3 = string3;
			systemWindow.string4 = string4;
			
			onStageResize();
			Main.stage.addEventListener(Event.RESIZE, onStageResize);
		}
		public function hideMessageWindow():void {
			Main.stage.removeEventListener(Event.RESIZE, onStageResize);
			if (TanksModels.windowContainer.contains(systemWindow)) {
				TanksModels.windowContainer.removeWindow(systemWindow);
				systemWindow.dispatchEvent(new WindowEvent(WindowEvent.UNSELECT, systemWindow));
			}
		}
		
		public function showRegistrationWindow():void {
			hideLoginWindow();
			
			if (!TanksModels.windowContainer.contains(registrationWindow)) {
				TanksModels.windowContainer.addWindow(registrationWindow);
			}
			registrationWindow.dispatchEvent(new WindowEvent(WindowEvent.SELECT, registrationWindow));
			
			registrationWindow.x = Math.round((Main.stage.stageWidth - registrationWindow.minSize.x)*0.5);
	    	registrationWindow.y = Math.round((Main.stage.stageHeight - registrationWindow.minSize.y)*0.5);
			//Main.stage.addEventListener(Event.RESIZE, onStageResize);
		}
		public function hideRegistrationWindow():void {
			if (TanksModels.windowContainer.contains(registrationWindow)) {
				TanksModels.windowContainer.removeWindow(registrationWindow);
				registrationWindow.dispatchEvent(new WindowEvent(WindowEvent.UNSELECT, registrationWindow));
			}
		}
		
		
		private function onStageResize(e:Event = null):void {
	    	systemWindow.x = Math.round((Main.stage.stageWidth - systemWindow.minSize.x)*0.5);
	    	systemWindow.y = Math.round((Main.stage.stageHeight - systemWindow.minSize.y)*0.5);
	    }
		
		public function loginFailed(clientObject:ClientObject, error:LoginErrorsEnum):void {
			Main.console.writeToConsole("UserModel loginFailed error: " + error, 0xff0000);
			switch (error) {
				case LoginErrorsEnum.CRITICAL_LOGIN_ERROR:
					Main.console.writeToConsole("UserModel CRITICAL_LOGIN_ERROR", 0xff0000);
					
					break;
				case LoginErrorsEnum.HASH_LOGIN_FAILED:
					Main.console.writeToConsole("UserModel HASH_LOGIN_FAILED", 0xff0000);
					// Показать loginWindow
					showLoginWindow();
					break;
				case LoginErrorsEnum.UID_LOGIN_FAILED:
					Main.console.writeToConsole("UserModel UID_LOGIN_FAILED", 0xff0000);
					// Вывести сообщение "Неверное имя пользователя или пароль"
					showMessageWindow("INCORRECT LOGIN OR PASSWORD");
					break;
				case LoginErrorsEnum.NAME_MIN_LENGTH:
					Main.console.writeToConsole("UserModel NAME_MIN_LENGTH", 0xff0000);
					showMessageWindow("NAME IS TOO SHORT");
					break;
				case LoginErrorsEnum.NAME_MAX_LENGTH:
					Main.console.writeToConsole("UserModel NAME_MIN_LENGTH", 0xff0000);
					showMessageWindow("NAME IS TOO LONG");
					break;
				case LoginErrorsEnum.USER_ALREADY_LOGGED_IN:
					Main.console.writeToConsole("UserModel USER_ALREADY_LOGGED_IN", 0xff0000);
					showMessageWindow("USER ALREADY LOGGED IN");
					break;
			}
		}
		
		public function registrFailed(clientObject:ClientObject, error:RegisterErrorsEnum):void {
			Main.console.writeToConsole("UserModel registrFailed error: " + error);
			switch (error) {
				case RegisterErrorsEnum.EMAIL_LDAP_UNIQUE:
					showMessageWindow("THIS E-MAIL ALREADY EXIST");
					break;
				case RegisterErrorsEnum.EMAIL_NOT_VALID:
					showMessageWindow("INCORRECT E-MAIL");
					break;
				case RegisterErrorsEnum.NAME_MAX_LENGTH:
					showMessageWindow("NAME IS TOO LONG");
					break;
				case RegisterErrorsEnum.NAME_MIN_LENGTH:
					showMessageWindow("NAME IS TOO SHORT");
					break;
				case RegisterErrorsEnum.PASSWORD_MAX_LENGTH:
					showMessageWindow("PASSWORD IS TOO LONG");
					break;
				case RegisterErrorsEnum.PASSWORD_MIN_LENGTH:
					showMessageWindow("PASSWORD IS TOO SHORT");
					break;
				case RegisterErrorsEnum.UID_LDAP_UNIQUE:
					showMessageWindow("THIS LOGIN ALREADY EXIST");
					break;
				case RegisterErrorsEnum.UID_MAX_LENGTH:
					showMessageWindow("LOGIN IS TOO LONG");
					break;
				case RegisterErrorsEnum.UID_MIN_LENGTH:
					showMessageWindow("LOGIN IS TOO SHORT");
					break;
				case RegisterErrorsEnum.UID_NOT_VALID:
					showMessageWindow("INCORRECT LOGIN");
					break;
				case RegisterErrorsEnum.PASSWORDS_NOT_EQUAL:
					showMessageWindow("PASSWORDS NOT EQUALS");
					break;
			}
		}
		
		public function setHash(clientObject:ClientObject = null, hash:String = null):void {
			Main.console.writeToConsole("UserModel setHash: " + hash, 0x0000cc);
			
			var storage:SharedObject = (Main.osgi.getService(IStorageService) as IStorageService).getStorage();
			storage.data.userHash = hash;
			var result:String = storage.flush(100000);
			
			Main.console.writeToConsole("UserModel setHash result: " + result, 0x0000cc);
		}
		
		public function goByName(name:String):void {
			loginByName(clientObject, name);
		}
		public function goByLogin(login:String, password:String):void {
			loginByUid(clientObject, login, password);
		}
		public function newRegistration(name:String, mail:String, login:String, password:String, repPassword:String):void {
			registerUser(clientObject, name, login, mail, password, repPassword);
		}
		
		
	}
}