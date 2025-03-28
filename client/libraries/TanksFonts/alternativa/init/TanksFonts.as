package alternativa.init {
	import alternativa.osgi.bundle.IBundleActivator;
	//import alternativa.tanks.help.IHelpService;
	
	import flash.text.Font;
	import flash.text.TextFormat;
	
	public class TanksFonts implements IBundleActivator {

		[Embed(source="../tanks/font/MyriadPro-Regular6.ttf", fontName="MyriadPro", mimeType='application/x-font')]
		private static const MyriadPro:Class;
//		[Embed(source="../tanks/font/rouble.ttf", fontName="Rubl", mimeType='application/x-font')]
//		private static const Rubl:Class;

		
		public static function init():void {
			
			Font.registerFont(MyriadPro);
			
			
			
//			Font.registerFont(Rubl);
		}
		
		public function start(osgi:OSGi):void {
			Font.registerFont(MyriadPro);
			var format:TextFormat = new TextFormat("MyriadPro", 12);
			format.color = 0xFFFFFF;
			
			//(osgi.getService(IHelpService) as IHelpService).setHelperTextFormat(format);
//			Font.registerFont(Rubl);
		}
			
		public function stop(osgi:OSGi):void {
			
		}
	}
}