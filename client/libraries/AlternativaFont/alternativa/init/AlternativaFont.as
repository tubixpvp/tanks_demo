package alternativa.init {
	import flash.text.Font;
	import alternativa.osgi.bundle.IBundleActivator;
	
	public class AlternativaFont implements IBundleActivator {
		
		[Embed(source="../font/AlternativaNormal.ttf", fontName="Alternativa", mimeType='application/x-font', embedAsCFF="false")]
		private static const ttfNormal:Class;

		[Embed(source="../font/AlternativaBold.ttf", fontName="Alternativa", mimeType='application/x-font', fontWeight="bold", embedAsCFF="false")]
		private static const ttfBold:Class;


		public function start(osgi:OSGi) : void
		{
			Font.registerFont(ttfNormal);
			Font.registerFont(ttfBold);
		}

		public function stop(osgi:OSGi) : void
		{
		}
	}
}