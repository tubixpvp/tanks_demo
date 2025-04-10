package alternativa.tanks.gui.lobby {
	import alternativa.gui.base.Dummy;
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.WindowAlign;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.widget.button.ButtonEvent;
	import alternativa.gui.widget.button.RadioButtonGroup;
	import alternativa.gui.window.WindowBase;
	import alternativa.gui.window.WindowEvent;
	import alternativa.init.IOInterfaces;
	import alternativa.init.Main;
	import alternativa.resource.A3DResource;
	import alternativa.resource.TextureResource;
	import alternativa.tanks.gui.loader.IndicatorWindow;
	import alternativa.tanks.gui.skin.LobbySkinManager;
	import alternativa.tanks.model.LobbyModel;
	import alternativa.tanks.model.TanksModels;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import alternativa.osgi.service.console.IConsoleService;
	
	import projects.tanks.models.lobby.struct.MapStruct;
	import projects.tanks.models.lobby.struct.TankStruct;
	import projects.tanks.models.lobby.struct.ArmyStruct;
	import projects.tanks.models.lobby.struct.TopRecord;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.materials.TextureMaterial;
	
	
	public class LobbyWindow extends WindowBase {
		
		[Embed(source="../../resources/lobby-window.png")] private static const backBitmap:Class;
		private static const backBd:BitmapData = new backBitmap().bitmapData;
	
		[Embed(source="../../resources/start-battle-button_n.png")] private static const startButtonNormalBitmap:Class;
		private static const startButtonNormalBd:BitmapData = new startButtonNormalBitmap().bitmapData;
		[Embed(source="../../resources/start-battle-button_p.png")] private static const startButtonPressBitmap:Class;
		private static const startButtonPressBd:BitmapData = new startButtonPressBitmap().bitmapData;
		
		[Embed(source="../../resources/lobby-reg-button_n.png")] private static const regButtonNormalBitmap:Class;
		private static const regButtonNormalBd:BitmapData = new regButtonNormalBitmap().bitmapData;
		[Embed(source="../../resources/lobby-reg-button_p.png")] private static const regButtonPressBitmap:Class;
		private static const regButtonPressBd:BitmapData = new regButtonPressBitmap().bitmapData;
		
		private var model:LobbyModel;
		
		private var back:Bitmap;
		
		private var leftContainer:Container;
		private var rightContainer:Container;
		
		private var tankContainer:Container;
		private var mapContainer:Container;
		private var infoContainer:Container;
		private var infoLabelContainer:Container;
		
		private var chooseTankContainer:Container;
		private var tankPreviewContainer:Container;
		private var chooseArmyContainer:Container;
		
		private var infoHeader:LobbyHeader;
		private var infoText:LobbyMapInfoLabel;
		
		private var top10List:Top10List;
		private var scoresLabel:ScoresLabel;
		
		public var startButton:LobbyImageButton;
		public var regButton:LobbyImageButton;
		
		private var startInt:int;
		private var updateInidicatorDelay:int = 100;
		private var startdelay:int = 3000;
		
		//private var tankModelButton:Array;
		//private var armyButton:Array;

		private var tankPreview:TankPreview;
		
		private var indicatorWindow:IndicatorWindow; 
		private var timeCounter:int;

		
		public function LobbyWindow(model:LobbyModel) {
			super(785, 434, false, false, "", false, false, false, WindowAlign.MIDDLE_CENTER);
			
			timeCounter = startdelay;
			
			this.model = model;
			//this.rootObject = this;
			
			skinManager = new LobbySkinManager();
			
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.TOP);
			
			//minSize.x = 785;
			//minSize.y = 434;
			
			back = new Bitmap(backBd);
			addChildAt(back, 0);
			back.x = -18;
			back.y = -116;
			
			leftContainer = new Container(0, 0, 11, 0);
			leftContainer.minSize.x = 595;
			leftContainer.stretchableV = true;
			leftContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.TOP, 8);
			addObject(leftContainer);
			
			rightContainer = new Container(12, 0, 0, 0);
			rightContainer.stretchableH = true;
			rightContainer.stretchableV = true;
			rightContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.TOP);
			addObject(rightContainer);
			
			
			tankContainer = new Container(0, 0, 0, 0);
			tankContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.MIDDLE);
			tankContainer.minSize.y = 192;
			tankContainer.stretchableH = true;
			leftContainer.addObject(tankContainer);
			
			mapContainer = new Container(0, 55, 0, 0);
			mapContainer.minSize.y = 141;
			mapContainer.stretchableH = true;
			mapContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.TOP, 20);
			leftContainer.addObject(mapContainer);
			
			infoContainer = new Container(38, 1, 8, 0);
			infoContainer.stretchableH = true;
			infoContainer.stretchableV = true;
			infoContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.TOP, 0);
			leftContainer.addObject(infoContainer);
			
			
			chooseTankContainer = new Container(0, 23, 0, 0);
			chooseTankContainer.stretchableV = true;
			chooseTankContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.TOP);
			tankContainer.addObject(chooseTankContainer);
			
			chooseTankContainer.addObject(new LobbyHeader("CHOOSE MODEL", Align.CENTER));
			chooseTankContainer.addObject(new Dummy(0, 12));
			
			tankPreviewContainer = new Container(0, 0, 0, 0);
			tankPreviewContainer.stretchableH = true;
			tankPreviewContainer.stretchableV = true;
			tankPreviewContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.CENTER, Align.MIDDLE);
			tankContainer.addObject(tankPreviewContainer);
			
			chooseArmyContainer = new Container(0, 23, 0, 0);
			chooseArmyContainer.stretchableV = true;
			chooseArmyContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.CENTER, Align.TOP);
			tankContainer.addObject(chooseArmyContainer);
			
			chooseArmyContainer.addObject(new LobbyHeader("CHOOSE ARMY", Align.CENTER));
			chooseArmyContainer.addObject(new Dummy(0, 12));
			
			infoLabelContainer = new Container(0, 15, 0, 0);
			infoLabelContainer.layoutManager = new CompletelyFillLayoutManager(Direction.VERTICAL, Align.LEFT, Align.TOP, 5);
			infoContainer.addObject(infoLabelContainer);
			
			infoHeader = new LobbyHeader("MAP NAME");
			infoText = new LobbyMapInfoLabel("MAP INFO");
			infoLabelContainer.addObject(infoHeader);
			infoLabelContainer.addObject(infoText);
			
			infoContainer.addObject(new Dummy(0, 0, true, true));
			
			startButton = new LobbyImageButton(startButtonNormalBd, startButtonNormalBd, startButtonPressBd, startButtonNormalBd);
			startButton.addEventListener(ButtonEvent.CLICK, onStartButtonClick);
			infoContainer.addObject(startButton);
			
			
			// SCORES
			top10List = new Top10List();
			rightContainer.addObject(top10List);
			
			rightContainer.addObject(new Dummy(0, 38));
			
			scoresLabel = new ScoresLabel("00000000000");
			rightContainer.addObject(scoresLabel);
			
			// REGISTRATION
			rightContainer.addObject(new Dummy(0, 24));
			
			regButton = new LobbyImageButton(regButtonNormalBd, regButtonNormalBd, regButtonPressBd, regButtonNormalBd);
			regButton.addEventListener(ButtonEvent.CLICK, onRegButtonPress);
			rightContainer.addObject(regButton);
			
			tabIndexes = new Array(startButton);
			
			draw(computeSize(computeMinSize()));
			
			// TANK PREVIEW
			tankPreview = new TankPreview();
			tankPreviewContainer.addChild(tankPreview);
			tankPreview.start();
		}
		
		public function setTankModels(tankModel:Array, selectedModelIndex:int):void {
			var chooseTankRadioGroup:RadioButtonGroup = new RadioButtonGroup();
			var indexes:Array = new Array();
			writeToConsole("LobbyWindow setTankModels", 0x0000ff);
			for (var i:int = 0; i < tankModel.length; i++) {
				writeToConsole("tankModel id: " + TankStruct(tankModel[i]).id, 0x0000ff);
				writeToConsole("tankModel name: " + TankStruct(tankModel[i]).name, 0x0000ff);
				var button:LobbyRadioButton = new LobbyRadioButton(TankStruct(tankModel[i]).name);
				chooseTankContainer.addObject(button);
				chooseTankRadioGroup.addButton(button);
				indexes.push(button);
				if (i == selectedModelIndex) {
					button.selected = true;
				}
				button.addEventListener(ButtonEvent.CLICK, onTankModelSelect);
			}
			tabIndexes = tabIndexes.splice(0, 0, indexes);
			
			repaintCurrentSize();
		}
		public function setArmies(army:Array, selectedArmyIndex:int):void {
			var chooseArmyRadioGroup:RadioButtonGroup = new RadioButtonGroup();
			var indexes:Array = new Array();
			writeToConsole("LobbyWindow setArmies", 0x0000ff);
			for (var i:int = 0; i < army.length; i++) {
				writeToConsole("army id: " + ArmyStruct(army[i]).armyId, 0x0000ff);
				writeToConsole("army name: " + ArmyStruct(army[i]).armyName, 0x0000ff);
				var button:LobbyRadioButton = new LobbyRadioButton(ArmyStruct(army[i]).armyName);
				chooseArmyContainer.addObject(button);
				chooseArmyRadioGroup.addButton(button);
				indexes.push(button);
				if (i == selectedArmyIndex) {
					button.selected = true;
				}
				button.addEventListener(ButtonEvent.CLICK, onArmySelect);
			}
			tabIndexes = tabIndexes.splice(chooseTankContainer.objects.length, 0, indexes);
			
			repaintCurrentSize();
		}
		public function setMaps(maps:Array, selectedMapIndex:int):void {
			writeToConsole("LobbyWindow setMaps", 0x0000ff);
			var chooseMapRadioGroup:RadioButtonGroup = new RadioButtonGroup();
			var indexes:Array = new Array();
			for (var i:int = 0; i < maps.length; i++) {
				writeToConsole("map id: " + MapStruct(maps[i]).id, 0x0000ff);
				writeToConsole("map name: " + MapStruct(maps[i]).name, 0x0000ff);
				var mapName:String = MapStruct(maps[i]).name;
				var mapDescription:String = MapStruct(maps[i]).description;
				var mapMaxPlayersNum:int = MapStruct(maps[i]).maxTanksOnline;
				var mapPreview:BitmapData = TextureResource(Main.resourceRegister.getResource(MapStruct(maps[i]).previewResourceId)).data.bitmapData;
				var button:LobbyMapIcon = new LobbyMapIcon(mapName, mapDescription, mapPreview, mapMaxPlayersNum);
				button.playersNum = MapStruct(maps[i]).tanksOnline;
				if (mapMaxPlayersNum == MapStruct(maps[i]).tanksOnline) {
					button.locked = true;
				}
				chooseMapRadioGroup.addButton(button);
				mapContainer.addObject(button);
				indexes.push(button);
				if (i == selectedMapIndex) {
					button.selected = true;
					infoHeader.text = mapName;
					infoText.text = mapDescription;
				}
				button.addEventListener(ButtonEvent.CLICK, onMapSelect);
			}
			tabIndexes = tabIndexes.splice(chooseTankContainer.objects.length + chooseArmyContainer.objects.length, 0, indexes);
			
			repaintCurrentSize();
			tankPreview.resize(tankPreviewContainer.currentSize.x, tankPreviewContainer.currentSize.y);
		}

		private function writeToConsole(message:String, color:uint) : void
		{
			(Main.osgi.getService(IConsoleService) as IConsoleService).writeToConsole(message);
		}
		
		public function showTank(modelResource:A3DResource, textureResource:TextureResource):void {
			var object:Object3D = modelResource.object;

			var material:TextureMaterial = new TextureMaterial(textureResource.data);

			object.forEach(function(child:Object3D):void{
				if(child is Mesh)
				{
					(child as Mesh).cloneMaterialToAllSurfaces(material);
				}
			});

			tankPreview.setModel(object);
		}
		
		public function updateMap(mapIndex:int, playersCount:int):void {
			var icon:LobbyMapIcon = LobbyMapIcon(mapContainer.objects[mapIndex]);
			icon.playersNum = playersCount;
			if (icon.maxPlayersNum == playersCount) {
				if (icon.selected) {
					icon.selected = false;
				}
				icon.locked = true;
				if (mapContainer.objects[mapIndex+1]!= null) {
					icon = LobbyMapIcon(mapContainer.objects[mapIndex+1]);
					icon.selected = true;
				} else if (mapContainer.objects[mapIndex-1]!= null) {
					icon = LobbyMapIcon(mapContainer.objects[mapIndex-1]);
					icon.selected = true;
				}
			} else {
				if (icon.locked) {
					icon.locked = false;
				}
			}
			icon.repaintCurrentSize();
		}
		
		public function setTop10List(top10:Array):void {
			if (top10List.objects.length > 0) {
				top10List.setItemsData(top10);
			} else {
				for (var i:int = 0; i < top10.length; i++) {
					top10List.addItem(TopRecord(top10[i]).name, TopRecord(top10[i]).score);
				}
			}
			rightContainer.repaintCurrentSize();
		}
		
		public function setSelfScores(scores:int):void {
			if (scores < 0) {
				scores = 0;
			}
			if (scores > 99999999999) {
				scores = 99999999999;
			}
			var s:String = scores.toString();
			while (s.length < 11) {
				s = "0" + s;
			}
			scoresLabel.text = s;
		}
		
		public function showRegisterButton():void {
			if (!rightContainer.contains(regButton)) {
				rightContainer.addObject(regButton);
				rightContainer.repaintCurrentSize();
			}
		}
		public function hideRegisterButton():void {
			if (rightContainer.contains(regButton)) {
				rightContainer.removeObject(regButton);
			}
		}
		
		private function onTankModelSelect(e:ButtonEvent):void {
			model.onTankModelSelect(chooseTankContainer.objects.indexOf(e.button)-2);
		}
		private function onArmySelect(e:ButtonEvent):void {
			model.onArmySelect(chooseArmyContainer.objects.indexOf(e.button)-2);
		}
		private function onMapSelect(e:ButtonEvent):void {
			model.onMapSelect(mapContainer.objects.indexOf(e.button));
			infoHeader.text = LobbyMapIcon(e.button).mapName;
			infoText.text = LobbyMapIcon(e.button).mapDescription;
		}
		private function onStartButtonClick(e:ButtonEvent):void {
			startButton.pressed = true;
			startButton.locked = true;
			
			indicatorWindow = new IndicatorWindow("03,0");
			TanksModels.systemWindowContainer.addWindow(indicatorWindow);
			indicatorWindow.dispatchEvent(new WindowEvent(WindowEvent.SELECT, indicatorWindow));
			indicatorWindow.x = Math.round((Main.stage.stageWidth - indicatorWindow.minSize.x)*0.5);
	    	indicatorWindow.y = Math.round((Main.stage.stageHeight - indicatorWindow.minSize.y)*0.5);
			
			IOInterfaces.mouseManager.updateCursor();
			
			startInt = setInterval(updateIndicator, updateInidicatorDelay);
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
				clearInterval(startInt);
				timeCounter = startdelay;
				TanksModels.systemWindowContainer.removeWindow(indicatorWindow);
				
				model.onStartButtonPressed();
			}
		}
		private function onRegButtonPress(e:ButtonEvent):void {
			model.onRegButtonPressed();
		}

	}
}