package alternativa.engine3d.materials {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.PolyPrimitive;
	import alternativa.engine3d.display.Skin;
	
	import flash.display.BlendMode;
	import flash.display.Graphics;

	use namespace alternativa3d;

	/**
	 * Материал для рисования рёбер полигонов.
	 */	
	public class WireMaterial extends SurfaceMaterial {

		/**
		 * @private
		 * Цвет
		 */
		alternativa3d var _color:uint;
		/**
		 * @private
		 * Толщина линий
		 */
		alternativa3d var _thickness:Number;

		/**
		 * Создание экземпляра класса.
		 * 
		 * @param thickness толщина линий
		 * @param color цвет линий
		 * @param alpha коэффициент непрозрачности линий. Значение 1 соответствует полной непрозрачности, значение 0 соответствует полной прозрачности.
		 * @param blendMode режим наложения цвета
		 */
		public function WireMaterial(thickness:Number = 0, color:uint = 0, alpha:Number = 1, blendMode:String = BlendMode.NORMAL) {
			super(alpha, blendMode);
			_color = color;
			_thickness = thickness;
		}

		/**
		 * @private
		 * @inheritDoc
		 */
		override alternativa3d function canDraw(primitive:PolyPrimitive):Boolean {
			return _thickness >= 0;
		}

		/**
		 * @private
		 * @inheritDoc
		 */
		override alternativa3d function draw(camera:Camera3D, skin:Skin, length:uint, points:Array):void {
			skin.alpha = _alpha;
			skin.blendMode = _blendMode;

			var i:uint;
			var point:DrawPoint;
			var gfx:Graphics = skin.gfx;

			if (camera._orthographic) {
				gfx.lineStyle(_thickness, _color);
				point = points[length - 1];
				gfx.moveTo(point.x, point.y);
				for (i = 0; i < length; i++) {
					point = points[i];
					gfx.lineTo(point.x, point.y);
				}
			} else {
				// Отрисовка
				gfx.lineStyle(_thickness, _color);
				point = points[length - 1];
				var perspective:Number = camera._focalLength/point.z;
				gfx.moveTo(point.x*perspective, point.y*perspective);
				for (i = 0; i < length; i++) {
					point = points[i];
					perspective = camera._focalLength/point.z;
					gfx.lineTo(point.x*perspective, point.y*perspective);
				}
			}			
		}

		/**
		 * Цвет линий.
		 */
		public function get color():uint {
			return _color;
		}

		/**
		 * @private
		 */
		public function set color(value:uint):void {
			if (_color != value) {
				_color = value;
				markToChange();
			}
		}

		/**
		 * Толщина линий. Если толщина отрицательная, то отрисовка не выполняется.
		 */
		public function get thickness():Number {
			return _thickness;
		}

		/**
		 * @private
		 */
		public function set thickness(value:Number):void {
			if (_thickness != value) {
				_thickness = value;
				markToChange();
			}
		}

		/**
		 * @inheritDoc 
		 */		
		override public function clone():Material {
			return new WireMaterial(_thickness, _color, _alpha, _blendMode);
		}

	}
}
