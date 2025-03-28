package alternativa.gui.skin.window {
	import alternativa.gui.skin.widget.LabelSkin;
	import alternativa.skin.ISkin;
	
	import flash.text.TextFormat;
	
	public class WindowTitleLabelSkin extends LabelSkin implements ISkin {
		
		public var tfOver:TextFormat;
		public var tfPress:TextFormat;
		public var tfActiveNormal:TextFormat;
		public var tfActiveOver:TextFormat;
		public var tfActivePress:TextFormat;
		
		public function WindowTitleLabelSkin(tfNormal:TextFormat,
											 tfOver:TextFormat,
											 tfPress:TextFormat,
											 tfActiveNormal:TextFormat,
											 tfActiveOver:TextFormat,
											 tfActivePress:TextFormat,
											 tfLocked:TextFormat,
											 thickness:Number,
											 sharpness:Number) {
											 	
			super(tfNormal, tfLocked, new Array(), new Array(), thickness, sharpness);
			
			this.tfOver = tfOver;
			this.tfPress = tfPress;
			this.tfActiveNormal = tfActiveNormal;
			this.tfActiveOver = tfActiveOver;
			this.tfActivePress = tfActivePress;
		}

	}
}