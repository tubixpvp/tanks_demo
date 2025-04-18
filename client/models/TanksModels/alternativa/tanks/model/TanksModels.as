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
	import alternativa.osgi.bundle.IBundleActivator;
	import alternativa.init.OSGi;
	import flash.text.Font;
	
	
	public class TanksModels implements IBundleActivator {
		
		[Embed(source="../resources/lobby_bg.jpg")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
		
		[Embed(source="../font/STMPRBRK.ttf", fontName="Stamper", mimeType="application/x-font", embedAsCFF="false")]
		private static const stamperTTFNormal:Class;

		//'Sign' font is lost, so I had to replace it
		[Embed(source="../font/STMPRBRK.ttf", fontName="Sign", mimeType="application/x-font", embedAsCFF="false")]
		private static const signTTFNormal:Class;

		[Embed(source="../font/Chicago.ttf", fontName="Chicago", mimeType='application/x-font', embedAsCFF="false")]
		private static const chicagoTTFNormal:Class;

		[Embed(source="../font/Digital.ttf", fontName="Digital", mimeType='application/x-font', embedAsCFF="false")]
		private static const digitalTTFNormal:Class;
		
		/*[Embed(source="../font/AlternativaNormal.ttf", fontName="Alternativa", mimeType="application/x-font-truetype")]
		private static const alternativaTTFNormal:Class;

		[Embed(source="../font/AlternativaBold.ttf", fontName="Alternativa", mimeType='application/x-font', fontWeight="bold")]
		private static const alternativaTTFBold:Class;*/
		
		/*[Embed(source="../font/MACH_NC.ttf", fontName="Alternativa", mimeType='application/x-font')]
		private static const ttf2:Class;*/
		
		private static var backFill:Shape;
		
		public static var windowContainer:WindowContainer;
		public static var systemWindowContainer:WindowContainer;
		
		
		public function start(osgi:OSGi):void 
		{
			//Main.console.write("TankModels init");

			Font.registerFont(stamperTTFNormal);
			Font.registerFont(signTTFNormal);
			Font.registerFont(chicagoTTFNormal);
			Font.registerFont(digitalTTFNormal);
			
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

		public function stop(osgi:OSGi):void
		{
			
		}
	}
}