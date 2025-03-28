package alternativa.init {
	import flash.text.Font;
	
	public class AlternativaFont {
		
		[Embed(source="../font/AlternativaNormal.ttf", fontName="Alternativa", mimeType='application/x-font')]
		private static const ttfNormal:Class;

		[Embed(source="../font/AlternativaBold.ttf", fontName="Alternativa", mimeType='application/x-font', fontWeight="bold")]
		private static const ttfBold:Class;
		
		public static function init():void {
			Font.registerFont(ttfNormal);
			Font.registerFont(ttfBold);
			
			//params["console"].write("Шрифт Alternativa инициализирован.", 0x0000cc);
		}
	}
}