package alternativa.tanks.model {
	import alternativa.gui.container.WindowContainer;
	import alternativa.init.Main;
	import alternativa.model.IModel;
	import alternativa.model.IObjectLoadListener;
	import alternativa.model.general.child.IChildListener;
	import alternativa.model.general.world3d.IObject3DListener;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import projects.tanks.models.lobby.ILobbyModelBase;
	import projects.tanks.models.battlefield.IBattlefieldModelBase;
	import projects.tanks.models.users.user.IUserModelBase;
	
	
	public class TanksModels {
		
		[Embed(source="../resources/lobby_bg.jpg")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
		
		/*[Embed(source="../font/STMPRBRK.ttf", fontName="Stamper", mimeType="application/x-font-truetype")]
		private static const stamperTTFNormal:Class;
		
		[Embed(source="../font/AlternativaNormal.ttf", fontName="Alternativa", mimeType="application/x-font-truetype")]
		private static const alternativaTTFNormal:Class;

		[Embed(source="../font/AlternativaBold.ttf", fontName="Alternativa", mimeType='application/x-font', fontWeight="bold")]
		private static const alternativaTTFBold:Class;*/
		
		/*[Embed(source="../font/MACH_NC.ttf", fontName="Alternativa", mimeType='application/x-font')]
		private static const ttf2:Class;*/
		
		private static var backFill:Shape;
		
		public static var windowContainer:WindowContainer;
		public static var systemWindowContainer:WindowContainer;
		
		
		public static function init():void {
			//Main.console.write("TankModels init");
			
			windowContainer = new WindowContainer();
			windowContainer.rootObject = windowContainer;
			Main.contentUILayer.addChild(windowContainer);
			
			systemWindowContainer = new WindowContainer();
			systemWindowContainer.rootObject = systemWindowContainer;
			Main.systemUILayer.addChild(systemWindowContainer);
			
			// Добавление реализаций моделей
			var lobbyModel:LobbyModel = new LobbyModel();
			Main.modelsRegister.add(lobbyModel, new Array(IModel, ILobbyModelBase, IObjectLoadListener));
			
			var userModel:UserModel = new UserModel();
			Main.modelsRegister.add(userModel, new Array(IModel, IUserModelBase, IObjectLoadListener));
			
			var model:IModel = new BattleFieldModel();
			Main.modelsRegister.add(model, [IModel, IBattlefieldModelBase, IObjectLoadListener, IChildListener, IObject3DListener]);
			
			// инициализации
			//Font.registerFont(stamperTTFNormal);
			//Font.registerFont(alternativaTTFNormal);
			//Font.registerFont(alternativaTTFBold);
			//IOInterfaces.initStage(Main.stage);
			//MouseUtils.init(Main.stage);
			
			//IOInterfaces.focusManager.focus = lobbyModel.lobbyWindow.startButton;
			
			// Заливка фона
			backFill = new Shape();
			Main.backgroundLayer.addChild(backFill);
			repaintBackground();
			resizeContainer();
			Main.stage.addEventListener(Event.RESIZE, repaintBackground);
			Main.stage.addEventListener(Event.RESIZE, resizeContainer);
		}
		
		public static function repaintBackground(e:Event = null):void {
			backFill.graphics.clear();
			backFill.graphics.beginBitmapFill(backBd, new Matrix(), true, false);
			backFill.graphics.drawRect(0, 0, Main.stage.stageWidth, Main.stage.stageHeight);
		}
		public static function resizeContainer(e:Event = null):void {
			windowContainer.repaint(new Point(Main.stage.stageWidth, Main.stage.stageHeight));
			systemWindowContainer.repaint(new Point(Main.stage.stageWidth, Main.stage.stageHeight));
		}

	}
}