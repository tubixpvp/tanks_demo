package alternativa.model.general.layer {
	import alternativa.init.Main;
	import alternativa.object.ClientObject;
	import alternativa.model.general.IUIContainer;
	
	import flash.display.DisplayObjectContainer;
	
	import platform.models.core.layer.ILayerModelBase;
	import platform.models.core.layer.LayerModelBase;
	import platform.models.core.layer.LayerModelEnum;

	/**
	 * Модель обеспечивает доступ к слою объекта.
	 */
	public class LayerModel extends LayerModelBase implements ILayerModelBase, IUIContainer {

		public function LayerModel() {
			super();
		}
		
		public function initObject(clientObject:ClientObject, layer:LayerModelEnum):void {
			var layerSprite:DisplayObjectContainer;
			Main.writeToConsole("LayerModel initData: layer = " + layer.value);
			switch (layer) {
				case LayerModelEnum.CONTENT:
					layerSprite = Main.contentLayer;
					break;
				case LayerModelEnum.CONTENT_UI:
					layerSprite = Main.contentUILayer;
					break;
				case LayerModelEnum.CURSOR:
					layerSprite = Main.cursorLayer;
					break;
				case LayerModelEnum.DIALOGS:
					layerSprite = Main.dialogsLayer;
					break;
				case LayerModelEnum.NOTICES:
					layerSprite = Main.noticesLayer;
					break;
				case LayerModelEnum.SYSTEM:
					layerSprite = Main.systemLayer;
					break;
				case LayerModelEnum.SYSTEM_UI:
					layerSprite = Main.systemUILayer;
					break;
			}
			
			clientObject.putParams(LayerModelBase, layerSprite);
		}
		
		/**
		 * Возвращает контейнер объекта.
		 * 
		 * @param clientObject
		 * @return 
		 */
		public function getContainer(clientObject:ClientObject):DisplayObjectContainer {
			return clientObject.getParams(LayerModelBase) as DisplayObjectContainer;
		}
	}
}