package alternativa.tanks.model {
	import alternativa.gui.window.WindowEvent;
	import alternativa.init.IOInterfaces;
	import alternativa.init.Main;
	import alternativa.model.IObjectLoadListener;
	import alternativa.object.ClientObject;
	import alternativa.resource.A3DResource;
	import alternativa.tanks.gui.lobby.LobbyWindow;
	
	import flash.events.Event;
	import projects.tanks.models.lobby.struct.TankStruct;
	import projects.tanks.models.lobby.struct.ArmyStruct;
	import projects.tanks.models.lobby.struct.MapStruct;
	import projects.tanks.models.lobby.struct.TopRecord;
	import alternativa.types.Long;
	
	import projects.tanks.models.lobby.LobbyModelBase;
	import projects.tanks.models.lobby.ILobbyModelBase;
	import alternativa.resource.TextureResource;
	
	
	public class LobbyModel extends LobbyModelBase implements ILobbyModelBase, IObjectLoadListener {
		
		public var clientObject:ClientObject;
		
		public var lobbyWindow:LobbyWindow;
		
		public var selectedTankModel:TankStruct;
		public var selectedArmy:ArmyStruct;
		public var selectedMap:MapStruct;
		
		
		public function LobbyModel() {}
		
		public function initObject(clientObject:ClientObject,
								 armies:Array,
								 defaultArmy:Long,
								 defaultMap:Long,
								 defaultTank:Long,
								 maps:Array,
								 selfScore:int,
								 showRegButton:Boolean,
								 tanks:Array,
								 top10:Array):void {
								 	
			Main.console.writeToConsole("LobbyModel initData");
			//Main.console.write("clientObjectId: " + clientObject.id, 0x666666);
			
			this.clientObject = clientObject;
			clientObject.putParams(LobbyModel, new Array(tanks, armies, maps));
			
			lobbyWindow = new LobbyWindow(this);
			
			if (showRegButton) {
				lobbyWindow.showRegisterButton();
			} else {
				lobbyWindow.hideRegisterButton();
			}
			
			var selectedModelIndex:int = -1;
			var selectedArmyIndex:int = -1;
			var selectedMapIndex:int = -1;
			for (var i:int = 0; i < tanks.length; i++) {
				if (TankStruct(tanks[i]).id == defaultTank) {
					selectedTankModel = tanks[i];
					selectedModelIndex = i;
				}
			}
			for (i = 0; i < armies.length; i++) {
				if (ArmyStruct(armies[i]).armyId == defaultArmy) {
					selectedArmy = armies[i];
					selectedArmyIndex = i;
				}
			}
			for (i = 0; i < maps.length; i++) {
				if (MapStruct(maps[i]).id == defaultMap) {
					selectedMap = maps[i];
					selectedMapIndex = i;
				}
			}
			if (selectedTankModel == null) {
				selectedTankModel = tanks[0];
			}
			if (selectedArmy == null) {
				selectedArmy = armies[0];
			}
			if (selectedMap == null) {
				selectedMap = maps[0];
			}
			//Main.console.write("selectedTankModelId: " + selectedTankModel.id, 0x666666);
			//Main.console.write("selectedArmyId: " + selectedArmy.armyId, 0x666666);
			//Main.console.write("selectedMapId: " + selectedMap.id, 0x666666);
			
			TanksModels.windowContainer.addWindow(lobbyWindow);
			lobbyWindow.dispatchEvent(new WindowEvent(WindowEvent.SELECT, lobbyWindow));
			
			lobbyWindow.setTankModels(tanks, selectedModelIndex);
			lobbyWindow.setArmies(armies, selectedArmyIndex);
			lobbyWindow.setMaps(maps, selectedMapIndex);
			lobbyWindow.setSelfScores(selfScore);
			lobbyWindow.setTop10List(top10);
			
			for (i = 0; i < top10.length; i++) {
	    		Main.console.writeToConsole("name: " + TopRecord(top10[i]).name, 0x666666);
	    		Main.console.writeToConsole("score: " + TopRecord(top10[i]).score, 0x666666);
	    		Main.console.writeToConsole(" ");
	    	}
			
			selectTank(clientObject, selectedTankModel.id, selectedArmy.armyId);
			
			onStageResize();
			Main.stage.addEventListener(Event.RESIZE, onStageResize);
		}
		
		public function objectLoaded(object:ClientObject):void {
			Main.loadingProgress.closeLoadingWindow();
		}
		public function objectUnloaded(object:ClientObject):void {
			Main.stage.removeEventListener(Event.RESIZE, onStageResize);
			if (TanksModels.windowContainer.contains(lobbyWindow)) {
				TanksModels.windowContainer.removeWindow(lobbyWindow);
				lobbyWindow.dispatchEvent(new WindowEvent(WindowEvent.UNSELECT, lobbyWindow));
				
				IOInterfaces.mouseManager.updateCursor();
			}
			clientObject = null;
			lobbyWindow = null;
			
			Main.stage.removeEventListener(Event.RESIZE, onStageResize);
		}
		
			
		public function hideRegisterButton(clientObject:ClientObject = null):void {
			lobbyWindow.hideRegisterButton();
		}
		
		 /**
	     * Показать танк
	     * @param modelId id ресурса танка
		 * @param textureId id ресурса текстуры
	     */
	    public function showTank(clientObject:ClientObject, modelId:Long, textureId:Long):void {
	    	var modelResource:A3DResource = Main.resourceRegister.getResource(modelId) as A3DResource;
			var textureResource:TextureResource = Main.resourceRegister.getResource(textureId) as TextureResource;

	    	if (modelResource != null && textureResource != null) {
	    		lobbyWindow.showTank(modelResource, textureResource);
	    	}
	    }
	    
	    /**
	     * Обновить данные о карте
	     * @param mapId id карты
	     * @param playersCount количество игроков на карте
	     */
	    public function updateMap(clientObject:ClientObject, mapId:Long, playersCount:int):void {
	    	var maps:Array = clientObject.getParams(LobbyModel)[2];
	    	for (var i:int = 0; i < maps.length; i++) {
	    		if (MapStruct(maps[i]).id == mapId) {
	    			lobbyWindow.updateMap(i, playersCount);
	    		}
	    	}
	    }
	    
	    /**
	     * Обновить топ игроков
	     * @param personId id игрока
	     * @param score текущие очки
	     */
	    public function updateTop(clientObject:ClientObject, top10:Array):void {
	    	Main.console.writeToConsole("updateTop");
	    	lobbyWindow.setTop10List(top10);
	    	for (var i:int = 0; i < top10.length; i++) {
	    		Main.console.writeToConsole("name: " + TopRecord(top10[i]).name, 0x666666);
	    		Main.console.writeToConsole("score: " + TopRecord(top10[i]).score, 0x666666);
	    		Main.console.writeToConsole(" ");
	    	}
	    }
	    
	    private function onStageResize(e:Event = null):void {
	    	lobbyWindow.x = Math.round((Main.stage.stageWidth - lobbyWindow.minSize.x)*0.5);
	    	lobbyWindow.y = Math.round((Main.stage.stageHeight - (lobbyWindow.minSize.y))*0.5)+50;
	    }
	    
	    public function onTankModelSelect(modelIndex:int):void {
	    	var tanks:Array = clientObject.getParams(LobbyModel)[0];
	    	selectedTankModel = TankStruct(tanks[modelIndex]);
	    	// Сообщение на сервер
	    	Main.console.writeToConsole("selectTankModel");
	    	Main.console.writeToConsole("tanks: " + tanks);
	    	Main.console.writeToConsole("selectedTankModel: " + selectedTankModel);
	    	Main.console.writeToConsole("modelIndex: " + modelIndex);
	    	Main.console.writeToConsole("clientObject: " + clientObject, 0x666666);
	    	Main.console.writeToConsole("modelId: " + selectedTankModel.id, 0x666666);
	    	Main.console.writeToConsole("armyId: " + selectedArmy.armyId, 0x666666);
	    	selectTank(clientObject, selectedTankModel.id, selectedArmy.armyId);
	    }
	    
	    public function onArmySelect(armyIndex:int):void {
	    	var armies:Array = clientObject.getParams(LobbyModel)[1];
	    	selectedArmy = ArmyStruct(armies[armyIndex]);
	    	// Сообщение на сервер
	    	Main.console.writeToConsole("selectTankArmy");
	    	Main.console.writeToConsole("armies: " + armies);
	    	Main.console.writeToConsole("selectedArmy: " + selectedArmy);
	    	Main.console.writeToConsole("armyIndex: " + armyIndex);
	    	Main.console.writeToConsole("clientObject: " + clientObject, 0x666666);
	    	Main.console.writeToConsole("modelId: " + selectedTankModel.id, 0x666666);
	    	Main.console.writeToConsole("armyId: " + selectedArmy.armyId, 0x666666);
	    	selectTank(clientObject, selectedTankModel.id, selectedArmy.armyId);
	    }
	    
	    public function onMapSelect(mapIndex:int):void {
	    	var maps:Array = clientObject.getParams(LobbyModel)[2];
	    	selectedMap = MapStruct(maps[mapIndex]);
	    	// Сообщение на сервер
	    	Main.console.writeToConsole("selectMap");
	    	Main.console.writeToConsole("mapIndex: " + mapIndex);
	    	Main.console.writeToConsole("clientObject: " + clientObject, 0x666666);
	    	Main.console.writeToConsole("mapId: " + selectedMap.id, 0x666666);
	    	selectMap(clientObject, selectedMap.id);
	    }
	    
	    public function onStartButtonPressed():void {
	    	Main.console.writeToConsole("startBattle");
			startBattle(clientObject);
		}
	    public function onRegButtonPressed():void {
	    	register(clientObject);
	    }


	}
}