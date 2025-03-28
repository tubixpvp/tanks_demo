package alternativa.tanks.gui.lobby {
	import alternativa.gui.widget.button.RadioButton;
	
	import flash.geom.Point;
	
	
	public class LobbyRadioButton extends RadioButton {
		
		public function LobbyRadioButton(text:String = "") {
			super(text);
		}
		
		// Установка минимальных размеров
		override protected function setMinSize():void {
			_minSize.x = Math.max(_minSize.x, skin.unselected.width);
			_minSize.y = skin.unselected.height;
		}
		
		// Установка текстового поля
		override protected function setLabelPos():void {
			var textMinSize:Point = tf.computeMinSize()
			tf.x = Math.round((skin.unselected.width - textMinSize.x)*0.5);
			tf.y = Math.round((skin.unselected.height - textMinSize.y)*0.5);
		}
		
		override protected function fillSpace():void {}
		
		/**
		 * Вычислить минимальные размеры элемента
		 * @param size исходные размеры от менеджера компоновки
		 * @return минимальные размеры
		 * 
		 */	
		override public function computeMinSize():Point {
			_minSize.x = skin.unselected.width;
			_minSize.y = skin.unselected.height;
			
			minSizeChanged = false;
			return _minSize;
		}
		
		// Отрисовка
		override public function draw(size:Point):void {
			super.draw(size);
			if (tf.text != null && tf.text != "") {
				var tfSize:Point = new Point();
				tfSize.x = size.x - (skin.unselected.width + skin.space);
				tfSize.y = tf.minSize.y;
				
				tf.draw(tfSize);
				
				tf.y = Math.round((skin.unselected.height - tf.minSize.y)/2);
			} 
		}
		
		/**
		 * Смена визуального представления состояния 
		 * 
		 */
		override protected function switchState():void {
			if (_selected) {	
				if (_locked) {
					bitmap.bitmapData = skin.lockedSelected;
					tf.alpha = 1;
				} else {
					bitmap.bitmapData = skin.selected;
					tf.alpha = 1;
				}
			} else {
				if (_locked) {
					bitmap.bitmapData = skin.lockedUnselected;
					tf.alpha = 0.5;
				} else {
					bitmap.bitmapData = skin.unselected;
					tf.alpha = 0.5;
				}
			}
		}
		
		/**
		 * Фокусировка
		 */		
		override protected function focus():void {}
		/**
		 * Расфокусировка
		 */		
		override protected function unfocus():void {}

	}
}