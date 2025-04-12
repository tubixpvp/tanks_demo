package alternativa.tanks.model {
	
	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.window.WindowEvent;
	import alternativa.init.Main;
	import alternativa.model.IObjectLoadListener;
	import alternativa.model.general.child.IChildListener;
	import alternativa.model.general.world3d.IObject3DListener;
	import alternativa.object.ClientObject;
	import alternativa.resource.MovieClipResource;
	import alternativa.resource.SoundResource;
	import alternativa.skin.SkinManager;
	import alternativa.tanks.gui.lifelevel.LifeLevelPanel;
	import alternativa.tanks.gui.loader.IndicatorWindow;
	import alternativa.tanks.gui.lobby.LobbyImageButton;
	import alternativa.tanks.gui.radar.Radar;
	import alternativa.tanks.gui.scores.ScoresPanel;
	import alternativa.tanks.gui.skin.BattleFieldSkinManager;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import alternativa.types.Long;

	import projects.tanks.models.battlefield.BattlefieldModelBase;
	import projects.tanks.models.battlefield.IBattlefieldModelBase;
	import projects.tanks.models.battlefield.struct.TankHealth;
	import projects.tanks.models.battlefield.struct.TankScore;
	
	use namespace alternativa3d;
	
	public class BattleFieldModel extends BattlefieldModelBase implements IBattlefieldModelBase, IObjectLoadListener, IChildListener, IObject3DListener {
		
		[Embed(source="../resources/button_sound_n.png")] private static const soundNormalBitmap:Class;
		private static const soundNormalBd:BitmapData = new soundNormalBitmap().bitmapData;
		[Embed(source="../resources/button_sound_p.png")] private static const soundPressBitmap:Class;
		private static const soundPressBd:BitmapData = new soundPressBitmap().bitmapData;
		
		[Embed(source="../resources/button_nosound_n.png")] private static const nosoundNormalBitmap:Class;
		private static const nosoundNormalBd:BitmapData = new nosoundNormalBitmap().bitmapData;
		[Embed(source="../resources/button_nosound_p.png")] private static const nosoundPressBitmap:Class;
		private static const nosoundPressBd:BitmapData = new nosoundPressBitmap().bitmapData;
		
		[Embed(source="../resources/button_exit_n.png")] private static const exitNormalBitmap:Class;
		private static const exitNormalBd:BitmapData = new exitNormalBitmap().bitmapData;
		[Embed(source="../resources/button_exit_p.png")] private static const exitPressBitmap:Class;
		private static const exitPressBd:BitmapData = new exitPressBitmap().bitmapData;
		
		private var clientObject:ClientObject;
		
		private var radar:Radar;
		private var lifelevel:LifeLevelPanel;
		private var scoresPanel:ScoresPanel;
		
		private var skinManager:SkinManager;
		
		// Массив данных для танков
		private var tanksInfo:Dictionary;
		private var selfId:Long = null;
		
		private var updateInt:int;
		private var updateDelay:int = 250;

		private var localMatrix:Matrix3D = new Matrix3D();
		private var localTankCoords:Point3D = new Point3D();
		
		private var track:SoundChannel;
		private var trackSound:Sound;
		private var soundMute:Boolean = false;
		private var soundPos:int;
		
		private var buttonSound:LobbyImageButton;
		private var buttonExit:LobbyImageButton;
		private var buttonContainer:Container;
		
		private var camera:Camera3D;
		private var mapLB:Point = new Point(-1789, -1690);
		private var mapTR:Point = new Point(2212, 1621);
		private var minimapSize:Point;
		private var mapScaleX:Number;
		private var mapScaleY:Number;
		
		private var indicatorWindow:IndicatorWindow; 
		private var timeCounter:int;
		
		private var exitInt:int;
		private var exitDelay:int = 3000;
		private var updateInidicatorDelay:int = 100;
		
		public function BattleFieldModel() {
			super();
			
			timeCounter = exitDelay;
			
			skinManager = new BattleFieldSkinManager();
			
			tanksInfo = new Dictionary();
			
			buttonSound = new LobbyImageButton(soundNormalBd, soundNormalBd, soundPressBd, soundNormalBd);
			buttonExit = new LobbyImageButton(exitNormalBd, exitNormalBd, exitPressBd, exitNormalBd);
			buttonSound.addEventListener(ButtonEvent.CLICK, onSoundButtonClick);
			buttonExit.addEventListener(ButtonEvent.CLICK, onExitButtonClick);
			
			buttonContainer = new Container();
			buttonContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE);
			buttonContainer.skinManager = skinManager;
			buttonContainer.addObject(buttonSound);
			buttonContainer.addObject(buttonExit);
			
			updateInt = -1;
		}
		
		private function onResize(e:Event = null):void {
			if (radar != null) {
				radar.y = Main.stage.stageHeight - radar.currentSize.y;
			}
			buttonContainer.x = Main.stage.stageWidth - buttonContainer.currentSize.x;
			
			if (lifelevel != null) {
				lifelevel.x = Main.stage.stageWidth - lifelevel.currentSize.x;
				lifelevel.y = Main.stage.stageHeight - lifelevel.currentSize.y;
			}
		}
		
		public function initObject(clientObject:ClientObject,
								 environmentSoundResourceId:Long,
								 minimapResourceId:Long,								 
								 tanksHealth:Array,
								 tanksScores:Array):void {
								 	
			/*Main.console.write(" ");
			Main.console.write(" ");
			Main.console.write("BattleFieldModel initData ");
			Main.console.write(" ");
			Main.console.write(" ");*/
			
			
			// Радар
			radar = new Radar();
			radar.skinManager = skinManager;
			Main.contentUILayer.addChild(radar);
			radar.draw(radar.computeSize(radar.computeMinSize()));
			
			// Очки
			scoresPanel = new ScoresPanel();
			Main.contentUILayer.addChild(scoresPanel);
			
			// Звучок
			var resource:SoundResource = SoundResource(Main.resourceRegister.getResource(environmentSoundResourceId));
			if (resource != null) {
				//Main.console.write("BattleFieldModel soundResource id: " + resource.id);
				trackSound = resource.sound;
				//Main.console.write("BattleFieldModel resource.sound: " + resource.sound);
				track = new SoundChannel();
				track = trackSound.play(0, 1000);
			} else {
				//Main.console.write("BattleFieldModel soundResource = null");
			}
			
			// Карта на радаре
			var minimapMc:MovieClip = MovieClipResource(Main.resourceRegister.getResource(minimapResourceId)).mc;
			radar.minimapMc = minimapMc;
			minimapSize = new Point(minimapMc.width, minimapMc.height);
			
			mapScaleX = minimapSize.x/(mapTR.x - mapLB.x);
			mapScaleY = minimapSize.y/(mapTR.y - mapLB.y);
			radar.areaRadius = radar.radius/mapScaleX;
			
			Main.console.writeToConsole("tanksHealth length: " + tanksHealth.length);
			
			// Сохранение уровней жизни
			for (var i:int = 0; i < tanksHealth.length; i++) {
				var health:int = TankHealth(tanksHealth[i]).health;
				var id:Long = TankHealth(tanksHealth[i]).tankId;
				Main.console.writeToConsole("tanksHealth for id: " + id + " = " + health);
				if (tanksInfo[id] == null) {
					tanksInfo[id] = new TankInfo(null, null, new Point3D(), 0, 0, health, 0);
				} else {
					TankInfo(tanksInfo[id]).health = health;
				}
				// Установка уровня жизни своего танка
				/*if (selfId != -1 && id == selfId) {
					if (lifelevel == null) {
						lifelevel.level = health;
					}
				}*/
			}
			for (i = 0; i < tanksScores.length; i++) {
				var scores:int = TankScore(tanksScores[i]).score;
				var id:Long = TankScore(tanksScores[i]).tankId;
				if (tanksInfo[id] == null) {
					tanksInfo[id] = new TankInfo(null, null, new Point3D(), 0, 0, 0, scores);
				} else {
					TankInfo(tanksInfo[id]).scores = scores;
				}
			}
		}
		
		public function tankHealthChanged(clientObject:ClientObject, tankId:Long, newHealth:int):void {
			if (tanksInfo[tankId] != null) {
				TankInfo(tanksInfo[tankId]).health = newHealth;
			}
			if (tankId == selfId) {
				lifelevel.level = newHealth;
			}
		}
		
		public function tankScoreChanged(clientObject:ClientObject, tankId:Long, newScore:int):void {
			Main.console.writeToConsole(" ");
			Main.console.writeToConsole("tankScoreChanged tankId: " + tankId + " newScore: " + newScore);
			Main.console.writeToConsole(" ");
			if (tankId == selfId && scoresPanel != null) {
				scoresPanel.scores = newScore;
			}
		}
		
		// Загружен спейс битвы
		public function objectLoaded(object:ClientObject):void {
			Main.loadingProgress.closeLoadingWindow();
			
			clientObject = object;
			
			Main.contentUILayer.addChild(buttonContainer);
			buttonContainer.draw(buttonContainer.computeSize(buttonContainer.computeMinSize()));
			
			Main.stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		// Спэйс битвы выгружен
		public function objectUnloaded(object:ClientObject):void {
			
			/*Main.console.write(" ");
			Main.console.write("BattleFieldModel objectUnloaded");
			Main.console.write(" ");
			*/
			track.stop();
			
			clientObject = null;
			
			//Main.console.write("BattleFieldModel TanksModels.windowContainer.contains(radar): " + TanksModels.windowContainer.contains(radar));
			if (Main.contentUILayer.contains(radar)) {
				Main.contentUILayer.removeChild(radar);
			}
			if (Main.contentUILayer.contains(buttonContainer)) {
				Main.contentUILayer.removeChild(buttonContainer);
			}
			if (lifelevel != null && Main.contentUILayer.contains(lifelevel)) {
				Main.contentUILayer.removeChild(lifelevel);
			}
			if (Main.contentUILayer.contains(scoresPanel)) {
				Main.contentUILayer.removeChild(scoresPanel);
			}
			Main.stage.removeEventListener(Event.RESIZE, onResize);
		}
		
		// 3D объект загружен в сцену
		public function object3DLoaded(clientObject:ClientObject, clientObject3D:ClientObject, object3d:Object3D):void {
			if (clientObject3D != null) {
				
				var tankModel:ITankParams = ITankParams(Main.modelsRegister.getModelForObject(clientObject3D, ITankParams));
				if (tankModel != null) {
				// В игру вошёл ещё один танк
					var tankParams:TankParams = tankModel.getTankParams(clientObject3D);
					
					var health:int = tankParams.health;
					var scores:int = tankParams.score;
					
					var id:Long = clientObject3D.id;
					
					if (tanksInfo[id] == null) {
						tanksInfo[id] = new TankInfo(clientObject3D, object3d, new Point3D(), 0, 0, health, scores);
					} else {
						TankInfo(tanksInfo[id]).clientObject = clientObject3D;
						TankInfo(tanksInfo[id]).object3D = object3d;
						TankInfo(tanksInfo[id]).health = health;
						TankInfo(tanksInfo[id]).scores = scores;
					}
					
					// Добавление точки на радар
					radar.addTarget(id, 0, 0);
					
					if (tankParams.player) {
						// Это свой танк
						selfId = id;
						Main.console.writeToConsole("BattleFieldModel свой танк добавлен с уровнем жизни: " + health + "(id:" + id + ")");
						radar.power = true;
						
						lifelevel = new LifeLevelPanel(health);
						lifelevel.skinManager = skinManager;
						Main.contentUILayer.addChild(lifelevel);
						lifelevel.draw(lifelevel.computeSize(lifelevel.computeMinSize()));
						onResize();
						lifelevel.level = health;
						
						scoresPanel.scores = scores;
						
						if (camera != null) {
							updateCamInfo();
							updateInt = setInterval(updateCamInfo, updateDelay);
						}
					} else {
						// Это чужой танк
						Main.console.writeToConsole("BattleFieldModel чужой танк добавлен (id:" + id + ")");
						radar.playersNum = radar.playersNum + 1;
						//radar.selectTarget(id);
					}
					
				} else {
					if (object3d is Camera3D) {
						camera = Camera3D(object3d);
						/*if (selfId != -1) {
							updateCamInfo();
							updateInt = setInterval(updateCamInfo, updateDelay);
						}*/					
					}
				}
			} else {
				/*Main.console.write(" ");
				Main.console.write("BattleFieldModel object3DLoaded   clientObject3D = null", 0xff0000);
				Main.console.write(" ");*/
			}
		}
		// 3D объект выгружен
		public function object3DUnloaded(clientObject:ClientObject, clientObject3D:ClientObject, object3d:Object3D):void {
			var tankModel:ITankParams = ITankParams(Main.modelsRegister.getModelForObject(clientObject3D, ITankParams));
			if (tankModel != null) {
				var tankParams:TankParams = tankModel.getTankParams(clientObject3D);
				
				var id:Long = clientObject3D.id;
				// Удаление данных о танке
				delete tanksInfo[id];
				// Удаление точки с радара
				radar.removeTarget(id);
				
				radar.playersNum = radar.playersNum - 1;
				
				if (id == selfId) {
					clearInterval(updateInt);
					Main.console.writeToConsole("BattleFieldModel свой танк выгружен");
				} else {
					Main.console.writeToConsole("BattleFieldModel чужой танк выгружен (id:" + id + ")");
				}
			}
		}
		
		
		public function addChild(child:ClientObject, parent:ClientObject):void {}
		
		public function removeChild(child:ClientObject, parent:ClientObject):void {}
		
		// Обновление информации по всем танкам и отображение на радаре относительно положения камеры
		private function updateCamInfo():void {
			// Поворот компаса
			radar.updateCompasAngle(camera.rotationZ);
			
			var selfTank:Object3D = tanksInfo[selfId].object3D;
			if (selfTank == null) {
				return;
			}
			//localMatrix.copy(tank._transformation);
			//localMatrix.invert();
			
			for each (var info:TankInfo in tanksInfo) {
				if (info.clientObject != null) {
					var id:Long = info.clientObject.id;
					if (id == selfId) {
						// Свой танк
						var shift:Point = new Point(-(selfTank.x - mapLB.x)*mapScaleX, -(mapTR.y - selfTank.y)*mapScaleY);
						if (camera != null) {
							radar.updateMinimap(shift, camera.rotationZ);
						}					
					} else {
						// Чужой танк
						
						var tank:Object3D = info.object3D;
							
						var dist:Number; 
						var angle:Number;
						
						if (tank != null && camera != null) {
							//localTankCoords.copy(tank._coords);
							//localTankCoords.transform(localMatrix);
							
							var dx:Number = selfTank.x - tank.x;
							var dy:Number = - selfTank.y + tank.y;
							
							dist = Math.sqrt(dx*dx + dy*dy);
							angle = -Math.atan2(dx, dy) + camera.rotationZ;
							
							info.coords = localTankCoords;
							info.angle = angle;
							info.dist = dist;
							
							radar.updateTargetPosition(id, angle, dist);
						}
					}
				}
			}
		}
		// Обновление информации по всем танкам
		/*private function updateInfo():void {
			var tank:Object3D = tanksInfo[selfId].object3D;
			
			localMatrix.copy(tank._transformation);
			localMatrix.invert();
			
			// Поворот компаса
			radar.updateCompasAngle(tank.rotationZ);
			
			for each (var info:TankInfo in tanksInfo) {
				var id:Number = info.clientObject.id;
				
				if (tank != null) {
					if (id == selfId) {
						// Свой танк
						
					} else {
						// Чужой танк
						tank = info.object3D;
						
						var dist:Number; 
						var angle:Number;
						
						if (tank != null) {
							localTankCoords.copy(tank._coords);
							localTankCoords.transform(localMatrix);
							
							dist = localTankCoords.length;
							angle = Math.PI*0.5 - Math.atan2(localTankCoords.y, localTankCoords.x);
							if (angle < 0) {
								angle += Math.PI*2;
							}
							info.coords = localTankCoords;
							info.angle = angle;
							info.dist = dist;
							
							radar.updateTargetPosition(id, angle, dist);
						}
						
					}
				}
			}
			
		}*/
		
		private function onSoundButtonClick(e:ButtonEvent):void {
			if (!soundMute) {
				soundMute = true;
				soundPos = track.position;
				track.stop();
				
				buttonSound.normalBitmap = nosoundNormalBd;
				buttonSound.overBitmap = nosoundNormalBd;
				buttonSound.pressBitmap = nosoundPressBd;
				buttonSound.lockBitmap = nosoundNormalBd;
			} else {
				soundMute = false;
				track = trackSound.play(soundPos);
				
				buttonSound.normalBitmap = soundNormalBd;
				buttonSound.overBitmap = soundNormalBd;
				buttonSound.pressBitmap = soundPressBd;
				buttonSound.lockBitmap = soundNormalBd;
			}
		}
		private function onExitButtonClick(e:ButtonEvent):void {
			indicatorWindow = new IndicatorWindow("03,0");
			TanksModels.windowContainer.addWindow(indicatorWindow);
			indicatorWindow.dispatchEvent(new WindowEvent(WindowEvent.SELECT, indicatorWindow));
			indicatorWindow.x = Math.round((Main.stage.stageWidth - indicatorWindow.minSize.x)*0.5);
	    	indicatorWindow.y = Math.round((Main.stage.stageHeight - indicatorWindow.minSize.y)*0.5);
	    	
	    	exitInt = setInterval(updateIndicator, updateInidicatorDelay);
		}
		
		private function updateIndicator():void {
			timeCounter -= updateInidicatorDelay;
			
			var time:Number = Math.round(timeCounter/100)/10;
			if (time < 10) {
				indicatorWindow.value = "0" + time.toString();
			} else {
				indicatorWindow.value = time.toString();
			}
			if (timeCounter == 0) {
				clearInterval(exitInt);
				timeCounter = exitDelay;
				TanksModels.windowContainer.removeWindow(indicatorWindow);
				
				Main.loadingProgress.unlockLoadingWindow();
			
				Main.console.writeToConsole(" ");
				Main.console.writeToConsole(" ");
				Main.console.writeToConsole("Elvis left the building...", 0xff0000);
				Main.console.writeToConsole(" ");
				Main.console.writeToConsole(" ");
				leave(clientObject);
			}
		}
	
	}
	
}