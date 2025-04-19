package alternativa.gui.chat {
	import alternativa.gui.container.Container;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.widget.Image;
	import alternativa.gui.widget.Label;
	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import alternativa.types.Long;
	
	/**
	 * Графический элемент списка для чата
	 */
	public class ChatListItem extends Container {
		
		//public const CLICK_USER:String = 'CLICK_USER';
		
		private var icon:Image;
		private var userName:Label;
		private var message:ChatListItemMessage;
		
		private var contactId:Long;
		
		public function ChatListItem(iconBitmap:BitmapData, name:String, contactId:Long, text:String, textColor:uint) {
			super();
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.TOP, 10);
			
			//icon = new Image(iconBitmap);
			
			//var userNameContainer:Container = new Container();
			//userNameContainer.layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.RIGHT, Align.MIDDLE);
			//userNameContainer.minSize.x = 30;
			
			var userNameText:String;
			var exampleText:String = "Harley Davidson";
			
			if (name.length > exampleText.length) {
				userNameText = name.substring(0, exampleText.length-1) + "...";
			} else {
				userNameText = name;
			}
			
			userName = new Label(userNameText, Align.RIGHT, textColor);
			userName.minSize.x = 30;
			//userNameContainer.addObject(userName);
			
			//message = new Label(text, Align.LEFT, textColor);
			message = new ChatListItemMessage(text, textColor);
			message.stretchableH = true;
			
			//addObject(icon);
			//addObject(userNameContainer);
			addObject(userName);
			addObject(message);
			
			// ловим события click
			userName.mouseEnabled = true;
			userName.addEventListener(MouseEvent.CLICK, onUserNameClick);
			
			cacheAsBitmap = true;
		}
		
		
		/**
		 * Выбран пользователя
		 */
		public function onUserNameClick(event:MouseEvent):void {
			
		}
		
	}
}