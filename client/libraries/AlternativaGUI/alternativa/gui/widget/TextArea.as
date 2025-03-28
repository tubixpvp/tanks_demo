package alternativa.gui.widget {
	import alternativa.gui.container.scrollBox.ScrollBox;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.enums.ScrollMode;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class TextArea extends ScrollBox {
		
		private var textObject:Text;
		
		public function TextArea(minWidth:int,
								 minHeight:int,
								 text:String,
								 align:uint = Align.LEFT,
								 wordWrap:Boolean = true,
								 editable:Boolean = true,
								 maxChars:uint=0,
								 scrollStep:int = 1,
								 scrollHorizontalMode:int = ScrollMode.AUTO,
								 scrollVerticalMode:int = ScrollMode.AUTO,
								 marginLeft:int = 0,
								 marginTop:int = 0,
								 marginRight:int = 0,
								 marginBottom:int = 0) {
			super(minWidth, minHeight, scrollHorizontalMode, scrollHorizontalMode, scrollStep, marginLeft, marginTop, marginRight, marginBottom);
			
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, Align.LEFT, Align.TOP);
			
			textObject = new Text(minWidth, text, align, wordWrap, editable, maxChars);			
			textObject.stretchableH = true;
			textObject.stretchableV = true;
			addObject(textObject);
			
			textObject.addEventListener(Event.CHANGE, onChange);
			textObject.tf.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		/*public function selectAll():void {			
			textObject.selectAll();	
		}*/
		
		override protected function focus():void {
			// если фокус на нас - то переадресуем его тексту
			stage.focus = textObject;						
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			// Перерисовка
			minSizeChanged = true;
			repaintCurrentSize();
			// Установка скроллера в нужную позицию
			var tf:TextField = textObject.tf;
			var index:int = tf.caretIndex;
			var bound:Rectangle = tf.getCharBoundaries(index);
			
		}	
		
		private function onChange(e:Event = null):void {
			// Рассылка события
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function set text(value:String):void {
			textObject.text = value;
		}

		public function get text():String {
			return textObject.text;
		}

		/*public function set htmlText(value:String):void {
			textObject.text = value;
		}

		public function get htmlText():String {
			return textObject.text;
		}*/
		
	}
}