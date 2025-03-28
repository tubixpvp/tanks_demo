package alternativa.gui.widget.progressBar {
	import alternativa.gui.base.GUIObject;
	import alternativa.gui.skin.widget.progressBar.ProgressBarSkin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	
	public class ProgressBar extends GUIObject {
		
		/**
		 * Скин 
		 */		
		protected var skin:ProgressBarSkin;
		/**
		 * Графика пустой полосы
		 */		
		protected var gfx:Sprite;
		/**
		 * Левая часть поля 
		 */		
		protected var left:Bitmap;
		/**
		 * Центральная часть поля 
		 */
		protected var center:Bitmap;
		/**
		 * Правая часть поля 
		 */
		protected var right:Bitmap;
		/**
		 * Заливка 
		 */		
		protected var fill:Shape;
		/**
		 * Прогресс (0..1) 
		 */		
		protected var _value:Number;
		
		
		
		
		public function ProgressBar() {
			super();
			
			gfx = new Sprite();
			gfx.mouseEnabled = false;		
			gfx.mouseChildren = false;		
			gfx.tabEnabled = false;
			gfx.tabChildren = false;		
			addChildAt(gfx, 0);
			
			// Создаём части графики
			left = new Bitmap();
			center = new Bitmap();
			right = new Bitmap();
			gfx.addChild(left);
			gfx.addChild(center);
			gfx.addChild(right);
			
			fill = new Shape();
			addChild(fill);
			
			_value = 0.3;
		}
		
		/**
		 * Обновить скин 
		 */
		override public function updateSkin():void {
			skin = ProgressBarSkin(skinManager.getSkin(ProgressBar));
			super.updateSkin();
			
			state(skin.left, skin.center, skin.right);
			
			fill.x = skin.borderThickness;
			fill.y = skin.borderThickness;
			
			_minSize.x = skin.left.width + skin.center.width + skin.right.width;
			_minSize.y = skin.center.height;
		}
		
		/**
		 * Перегрузка графики пустой полосы
		 */
		private function state(_left:BitmapData,_center:BitmapData,_right:BitmapData):void {
			left.bitmapData = _left;
			center.bitmapData = _center;
			right.bitmapData = _right;
		}
		
		/**
		 * Отрисовка в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */		
		override public function draw(size:Point):void {
			super.draw(size);
			
			center.x = left.width;
			center.width = currentSize.x - left.width - right.width;
			right.x = currentSize.x - right.width;
			
			value = _value;
		}
		
		public function set value(n:Number):void {
			if (n > 1) {
				n = 1;
			} else if (n < 0) {
				n = 0;
			} else {
				_value = n;
			}
			if (isSkined) {
				fill.graphics.clear();
				fill.graphics.beginBitmapFill(skin.fill, new Matrix(), true);
				fill.graphics.drawRect(0, 0, (currentSize.x - 2*skin.borderThickness)*n, currentSize.y - 2*skin.borderThickness);
			}
		}
		public function get value():Number {
			return _value;
		}

	}
}