package alternativa.tanks.gfx {
	import alternativa.engine3d.core.Sprite3D;
	import alternativa.types.Texture;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class Title extends Sprite3D {
		
		public function Title(text:String) {
			super();
			
			var tf:TextField = new TextField();
			var format:TextFormat = new TextFormat("Sign", 10, 0);
			tf.embedFonts = true;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.sharpness = 50;
			tf.thickness = -50;
			tf.defaultTextFormat = format;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = text;
			
			var bmp:BitmapData = new BitmapData(tf.textWidth + 5, tf.textHeight + 5, true, 0);
			bmp.draw(tf, new Matrix(1, 0, 0, 1, 1, 1));
			format.color = 0xFFFFFF;
			tf.setTextFormat(format);
			bmp.draw(tf);
			
			material = new TitleMaterial(new Texture(bmp), 1, true);
		}
		
	}
}