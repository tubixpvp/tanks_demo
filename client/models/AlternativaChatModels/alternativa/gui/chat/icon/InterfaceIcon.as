package alternativa.gui.chat.icon {
	import flash.display.BitmapData;
	
	public final  class InterfaceIcon {
		
		[Embed(source="resources/chat_volume1.png")] private static const bitmapChatVolume1:Class;
		[Embed(source="resources/chat_volume2.png")] private static const bitmapChatVolume2:Class;
		[Embed(source="resources/chat_volume3.png")] private static const bitmapChatVolume3:Class;
		
		public static var CHAT_VOLUME1:BitmapData = new bitmapChatVolume1().bitmapData;
		public static var CHAT_VOLUME2:BitmapData = new bitmapChatVolume2().bitmapData;
		public static var CHAT_VOLUME3:BitmapData = new bitmapChatVolume3().bitmapData;
		
	}
}