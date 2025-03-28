package alternativa.engine3d.materials {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.display.Skin;
	import alternativa.types.*;
	
	import flash.display.BlendMode;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	use namespace alternativa3d;
	use namespace alternativatypes;

	/**
	 * Материал, отображающий заданную текстуру в точке нахождения спрайта. Текстура отображается так, как если бы она находилась в плоскости,
	 * параллельной плоскости области вывода камеры, а верхний край текстуры был параллелен верхнему краю области вывода. При отрисовке изображения
	 * начало координат текстуры в области вывода совпадает с проекцией точки спрайта. По умолчанию начало координат текстуры перенесено в её центр.
	 */
	public class SpriteTextureMaterial extends SpriteMaterial {

		/**
		 * @private
		 * Вспомогательный прямоугольник, используется при отрисовке для хранения параметров отрисовки. 
		 */
		private static var drawRect:Rectangle = new Rectangle();

		/**
		 * @private
		 * Матрица, используемая для отрисовки текстуры спрайта
		 */
		private static var textureMatrix:Matrix = new Matrix();

		/**
		 * @private
		 * Текстура
		 */
		alternativa3d var _texture:Texture;

		/**
		 * @private
		 * Сглаженность текстуры
		 */
		alternativa3d var _smooth:Boolean;

		/**
		 * @private
		 * Смещение начала координат по оси X
		 */
		alternativa3d var _originX:Number;

		/**
		 * @private
		 * Смещение начала координат по оси Y
		 */
		alternativa3d var _originY:Number;

		/**
		 * Создание экземпляра класса.
		 *
		 * @param texture текстура для отображения
		 * @param alpha коэффициент непрозрачности материала. Значение 1 соответствует полной непрозрачности, значение 0 соответствует полной прозрачности.
		 * @param smooth сглаживание текстуры
		 * @param blendMode режим наложения цвета
		 * @param originX относительное смещение начала координат в текстуре по оси X
		 * @param originY относительное смещение начала координат в текстуре по оси Y
		 */
		public function SpriteTextureMaterial(texture:Texture, alpha:Number = 1, smooth:Boolean = false, blendMode:String = BlendMode.NORMAL, originX:Number = 0.5, originY:Number = 0.5) {
			super(alpha, blendMode);
			_texture = texture;
			_smooth = smooth;
			_originX = originX;
			_originY = originY;
		}

		/**
		 * @private
		 * @inheritDoc
		 */
		override alternativa3d function canDraw(camera:Camera3D):Boolean {
			if (_texture == null) {
				return false;
			}

 			// Переводим координаты в систему камеры
			var cameraMatrix:Matrix3D = camera.cameraMatrix;

 			var x:Number = _sprite.globalCoords.x;
 			var y:Number = _sprite.globalCoords.y;
 			var z:Number = _sprite.globalCoords.z;
 			var pointX:Number = cameraMatrix.a*x + cameraMatrix.b*y + cameraMatrix.c*z + cameraMatrix.d;
			var pointY:Number = cameraMatrix.e*x + cameraMatrix.f*y + cameraMatrix.g*z + cameraMatrix.h;
			var pointZ:Number = cameraMatrix.i*x + cameraMatrix.j*y + cameraMatrix.k*z + cameraMatrix.l;

			var w:Number;
			var h:Number;

			if (camera._orthographic) {
				if ((camera._nearClipping && pointZ < camera._nearClippingDistance) || (camera._farClipping && pointZ > camera._farClippingDistance)) {
					return false;
				}
				w = _texture._width*camera._zoom*_sprite._materialScale;
				h = _texture._height*camera._zoom*_sprite._materialScale;
				x = pointX - w*_originX;
				y = pointY - h*_originY;
			} else {
				if ((pointZ <= 0) || (camera._nearClipping && pointZ < camera._nearClippingDistance) ||	(camera._farClipping && pointZ > camera._farClippingDistance)) {
					return false;
				}
				var perspective:Number = camera._focalLength/pointZ;
				w = _texture._width*perspective*_sprite._materialScale;
				h = _texture._height*perspective*_sprite._materialScale;
				x = pointX*perspective - w*_originX;
				y = pointY*perspective - h*_originY;
			}
			var halfW:Number = camera._view._width*0.5;
			var halfH:Number = camera._view._height*0.5;

			if (camera._viewClipping && (x >= halfW || y >= halfH || x + w <= -halfW || y + h <= -halfH)) {
				return false;
			}

			textureMatrix.a = w/_texture._width;
			textureMatrix.d = h/_texture._height;
			textureMatrix.tx = x;
			textureMatrix.ty = y;

			if (camera._viewClipping) {
				if (x < -halfW) {
					w -= -halfW - x;
					x = -halfW;
				}
				if (x + w > halfW) {
					w = halfW - x;
				}
				if (y < -halfH) {
					h -= -halfH - y;
					y = -halfH;
				}
				if (y + h > halfH) {
					h = halfH - y;
				}
			}
			drawRect.x = x;
			drawRect.y = y;
			drawRect.width = w;
			drawRect.height = h;

			return true;
		}

		/**
		 * @private
		 * @inheritDoc
		 */
		override alternativa3d function draw(camera:Camera3D, skin:Skin):void {
			skin.alpha = _alpha;
			skin.blendMode = _blendMode;
			skin.gfx.beginBitmapFill(_texture._bitmapData, textureMatrix, false, _smooth);
			skin.gfx.drawRect(drawRect.x, drawRect.y, drawRect.width, drawRect.height);
		}

		/**
		 * Текстура.
		 */
		public function get texture():Texture {
			return _texture;
		}

		/**
		 * @private
		 */
		public function set texture(value:Texture):void {
			if (_texture != value) {
				_texture = value;
				markToChange();
			}
		}

		/**
		 * Сглаживание текстуры.
		 */
		public function get smooth():Boolean {
			return _smooth;
		}

		/**
		 * @private
		 */
		public function set smooth(value:Boolean):void {
			if (_smooth != value) {
				_smooth = value;
				markToChange();
			}
		}

		/**
		 * Относительное смещение начала координат в текстуре по оси X.
		 * 
		 * @default 0.5
		 */
		public function get originX():Number {
			return _originX;
		}

		/**
		 * @private
		 */
		public function set originX(value:Number):void {
			if (_originX != value) {
				_originX = value;
				markToChange();
			}
		}

		/**
		 * Относительное смещение начала координат в текстуре по оси Y.
		 * 
		 * @default 0.5
		 */
		public function get originY():Number {
			return _originY;
		}

		/**
		 * @private
		 */
		public function set originY(value:Number):void {
			if (_originY != value) {
				_originY = value;
				markToChange();
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function clone():Material {
			return new SpriteTextureMaterial(_texture, _alpha, _smooth, _blendMode, _originX, _originY);
		}

	}
}
