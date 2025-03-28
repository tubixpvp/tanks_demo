package alternativa.model.general.quadro {
	import alternativa.init.Main;
	import alternativa.object.ClientObject;
	import alternativa.model.IObjectLoadListener;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import platform.models.core.quadro.IQuadroModelBase;
	import platform.models.core.quadro.QuadroModelBase;
	
	
	public class QuadroModel extends QuadroModelBase implements IQuadroModelBase, IObjectLoadListener {
		
		private var clientObject:ClientObject;
		private var quadro:Sprite;
		private var textField:TextField;
		
		public function QuadroModel() {
			quadro = new Sprite();
			quadro.graphics.beginFill(0xff0000, 1);
			quadro.graphics.drawRect(0, 0, 100, 100);
			textField = new TextField();
			quadro.addChild(textField);
		}
		
		public function initObject(clientObject:ClientObject, x:int, y:int):void {
			Main.hideConsole();
			Main.writeToConsole("QuadroModelImp initData " + clientObject.id);
			this.clientObject = clientObject;
			
			Main.mainContainer.addChild(quadro);
			
			Main.stage.addEventListener(MouseEvent.CLICK, onClick);
			
			quadro.x = x;
			quadro.y = y;
		}
		
		public function setClientPosition(clientObject:ClientObject, x:int, y:int):void {
			//Main.writeToConsole("QuadroModelImp setClientPosition " + NumberUtils.LongToString(clientObject.id));
			quadro.x = x;
			quadro.y = y;
		}
		
		private function onClick(e:MouseEvent):void {
			//Main.writeToConsole("QuadroModelImp setPosition", 0x0000ff);
			setPosition(clientObject, Main.stage.mouseX, Main.stage.mouseY);
		}
		
		public function objectLoaded(object:ClientObject):void {
			Main.writeToConsole("QuadroModelImp object loaded", 0xff0000);
		}
			
		public function objectUnloaded(object:ClientObject):void {
			Main.writeToConsole("QuadroModelImp object unloaded", 0xff0000);
			Main.stage.removeEventListener(MouseEvent.CLICK, onClick);
			Main.mainContainer.removeChild(quadro);
			clientObject = null;
		}

		public function ping(clientObject:ClientObject):void {
			pong(clientObject);
		}
 	 	
		public function displayResult(clientObject:ClientObject, result:String):void {
			Main.showConsole();
			Main.writeToConsole("QuadroModel displayResult " + result);
			textField.text = result;
		}
		
	}
}