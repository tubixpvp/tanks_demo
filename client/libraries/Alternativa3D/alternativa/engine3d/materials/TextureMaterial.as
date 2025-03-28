package alternativa.engine3d.materials {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.PolyPrimitive;
	import alternativa.engine3d.display.Skin;
	import alternativa.types.*;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.geom.Matrix;	

	use namespace alternativa3d;
	use namespace alternativatypes;

	/**
	 * Материал, заполняющий полигон текстурой. Помимо наложения текстуры, материал может рисовать границу полигона линией
	 * заданной толщины и цвета.
	 */
	public class TextureMaterial extends SurfaceMaterial {

		private static var stubBitmapData:BitmapData;
		private static var stubMatrix:Matrix;

		private var gfx:Graphics;
		private var textureMatrix:Matrix = new Matrix();
		private var focalLength:Number;
		private var distortion:Number;

		/**
		 * @private
		 * Текстура
		 */		
		alternativa3d var _texture:Texture;
		/**
		 * @private
		 * Повтор текстуры
		 */
		alternativa3d var _repeat:Boolean;
		/**
		 * @private
		 * Сглаженность текстуры
		 */
		alternativa3d var _smooth:Boolean;
		/**
		 * @private
		 * Точность перспективной коррекции
		 */
		alternativa3d var _precision:Number;

		/**
		 * @private
		 * Толщина линий обводки 
		 */
		alternativa3d var _wireThickness:Number;

		/**
		 * @private
		 * Цвет линий обводки 
		 */
		alternativa3d var _wireColor:uint;

		/**
		 * Создание экземпляра текстурного материала.
		 *
		 * @param texture текстура материала
		 * @param alpha коэффициент непрозрачности материала. Значение 1 соответствует полной непрозрачности, значение 0 соответствует полной прозрачности.
		 * @param repeat повтор текстуры при заполнении
		 * @param smooth сглаживание текстуры при увеличении масштаба
		 * @param blendMode режим наложения цвета
		 * @param wireThickness толщина линии обводки
		 * @param wireColor цвет линии обводки
		 * @param precision точность перспективной коррекции. Может быть задана одной из констант класса
		 *   <code>TextureMaterialPrecision</code> или числом типа Number. Во втором случае, чем ближе заданное значение к единице, тем более
		 *   качественная перспективная коррекция будет выполнена, и тем больше времени будет затрачено на расчёт кадра.
		 *
		 * @see TextureMaterialPrecision
		 */
		public function TextureMaterial(texture:Texture, alpha:Number = 1, repeat:Boolean = true, smooth:Boolean = false, blendMode:String = BlendMode.NORMAL, wireThickness:Number = -1, wireColor:uint = 0, precision:Number = TextureMaterialPrecision.MEDIUM) {
			super(alpha, blendMode);
			_texture = texture;
			_repeat = repeat;
			_smooth = smooth;
			_wireThickness = wireThickness;
			_wireColor = wireColor;
			_precision = precision;
			useUV = true;
		}

		/**
		 * @private
		 * @inheritDoc
		 */
		override alternativa3d function canDraw(primitive:PolyPrimitive):Boolean {
			return _texture != null;
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
			gfx = skin.gfx;

			// Проверка на нулевую UV-матрицу
			if (skin.primitive.face.uvMatrixBase == null) {
				if (stubBitmapData == null) {
					// Создание текстуры-заглушки
					stubBitmapData = new BitmapData(2, 2, false, 0);
					stubBitmapData.setPixel(0, 0, 0xFF00FF);
					stubBitmapData.setPixel(1, 1, 0xFF00FF);
					stubMatrix = new Matrix(10, 0, 0, 10, 0, 0);
				}
				gfx.beginBitmapFill(stubBitmapData, stubMatrix);
				if (camera._orthographic) {
					if (_wireThickness >= 0) {
						gfx.lineStyle(_wireThickness, _wireColor);
					}
					point = points[0];
					gfx.moveTo(point.x, point.y);
					for (i = 1; i < length; i++) {
						point = points[i];
						gfx.lineTo(point.x, point.y);
					}
					if (_wireThickness >= 0) {
						point = points[0];
						gfx.lineTo(point.x, point.y);
					}
				} else {
					if (_wireThickness >= 0) {
						gfx.lineStyle(_wireThickness, _wireColor);
					}
					point = points[0];
					var perspective:Number = camera._focalLength/point.z;
					gfx.moveTo(point.x*perspective, point.y*perspective);
					for (i = 1; i < length; i++) {
						point = points[i];
						perspective = camera._focalLength/point.z;
						gfx.lineTo(point.x*perspective, point.y*perspective);
					}
					if (_wireThickness >= 0) {
						point = points[0];
						perspective = camera._focalLength/point.z;
						gfx.lineTo(point.x*perspective, point.y*perspective);
					}
				}
				return;
			}

			if (camera._orthographic) {
				// Расчитываем матрицу наложения текстуры
				var face:Face = skin.primitive.face;
				// Если матрица не расчитана, считаем
				if (!camera.uvMatricesCalculated[face]) {
					camera.calculateUVMatrix(face, _texture._width, _texture._height);
				}
				gfx.beginBitmapFill(_texture._bitmapData, face.orthoTextureMatrix, _repeat, _smooth);
				if (_wireThickness >= 0) {
					gfx.lineStyle(_wireThickness, _wireColor);
				}
				point = points[0];
				gfx.moveTo(point.x, point.y);
				for (i = 1; i < length; i++) {
					point = points[i];
					gfx.lineTo(point.x, point.y);
				}
				if (_wireThickness >= 0) {
					point = points[0];
					gfx.lineTo(point.x, point.y);
				}
			} else {
				focalLength = camera._focalLength;
				distortion = camera.focalDistortion*_precision;

				// Отрисовка
				var front:uint = 0;
				var back:uint = length - 1;

				var newFront:uint = 1;
				var newBack:uint = (back > 0) ? (back - 1) : (length - 1);
				var direction:Boolean = true;

				var a:DrawPoint = points[back];
				var b:DrawPoint;
				var c:DrawPoint = points[front];

				var axp:Number;
				var ayp:Number;
				var bxp:Number;
				var byp:Number;
				var cxp:Number;
				var cyp:Number;

				if (_precision > 0) {
					// Адаптивная триангуляция

					axp = a.x/a.z;
					ayp = a.y/a.z;
					cxp = c.x/c.z;
					cyp = c.y/c.z;

					var dx:Number = (c.x + a.x)/(c.z + a.z) - 0.5*(cxp + axp);
					var dy:Number = (c.y + a.y)/(c.z + a.z) - 0.5*(cyp + ayp);

					var dab:Number;
					var dbc:Number;
					var dca:Number = dx*dx + dy*dy;

					while (front != newBack) {
						if (direction) {
							a = points[front];
							b = points[newFront];
							c = points[back];

							bxp = axp;
							byp = ayp;
							axp = cxp;
							ayp = cyp;
							cxp = bxp;
							cyp = byp;

							bxp = b.x/b.z;
							byp = b.y/b.z;

							dx = (b.x + c.x)/(b.z + c.z) - 0.5*(bxp + cxp);
							dy = (b.y + c.y)/(b.z + c.z) - 0.5*(byp + cyp);
							dbc = dx*dx + dy*dy;

							front = newFront;
							newFront = (front < length - 1) ? (front + 1) : 0;
						} else {
							a = points[newBack];
							b = points[back];
							c = points[front];

							axp = bxp;
							ayp = byp;
							bxp = cxp;
							byp = cyp;
							cxp = axp;
							cyp = ayp;

							axp = a.x/a.z;
							ayp = a.y/a.z;

							dx = (c.x + a.x)/(c.z + a.z) - 0.5*(cxp + axp);
							dy = (c.y + a.y)/(c.z + a.z) - 0.5*(cyp + ayp);
							dca = dx*dx + dy*dy;

							back = newBack;
							newBack = (back > 0) ? (back - 1) : (length - 1);
						}

						// Если треугольник больше пикселя
						if ((bxp - axp)*(cyp - ayp) - (byp - ayp)*(cxp - axp) < -camera.focalDistortion) {
							// Расчёт искажения для ребра AB
							dx = (a.x + b.x)/(a.z + b.z) - 0.5*(axp + bxp);
							dy = (a.y + b.y)/(a.z + b.z) - 0.5*(ayp + byp);
							dab = dx*dx + dy*dy;
							// Адаптивная триангуляция
							bisection(a.x, a.y, a.z, a.u, a.v, b.x, b.y, b.z, b.u, b.v, c.x, c.y, c.z, c.u, c.v, dab, dbc, dca);
						}

						direction = !direction;
					}
				} else {
					// Простая триангуляция
					axp = focalLength*a.x/a.z;
					ayp = focalLength*a.y/a.z;
					cxp = focalLength*c.x/c.z;
					cyp = focalLength*c.y/c.z;

					while (front != newBack) {
						if (direction) {
							a = points[front];
							b = points[newFront];
							c = points[back];

							bxp = axp;
							byp = ayp;
							axp = cxp;
							ayp = cyp;
							cxp = bxp;
							cyp = byp;

							bxp = focalLength*b.x/b.z;
							byp = focalLength*b.y/b.z;

							front = newFront;
							newFront = (front < length - 1) ? (front + 1) : 0;
						} else {
							a = points[newBack];
							b = points[back];
							c = points[front];

							axp = bxp;
							ayp = byp;
							bxp = cxp;
							byp = cyp;
							cxp = axp;
							cyp = ayp;

							axp = focalLength*a.x/a.z;
							ayp = focalLength*a.y/a.z;

							back = newBack;
							newBack = (back > 0) ? (back - 1) : (length - 1);
						}

						drawTriangle(axp, ayp, a.u, a.v, bxp, byp, b.u, b.v, cxp, cyp, c.u, c.v);

						direction = !direction;
					}						
				}
			}
		}

 		/**
		 * @private
 		 */
 		private function bisection(ax:Number, ay:Number, az:Number, au:Number, av:Number, bx:Number, by:Number, bz:Number, bu:Number, bv:Number, cx:Number, cy:Number, cz:Number, cu:Number, cv:Number, dab:Number, dbc:Number, dca:Number):void {
 			var dx:Number;
 			var dy:Number;
 			var dz:Number;
 			var du:Number;
 			var dv:Number;

 			var ddx:Number;
 			var ddy:Number;
 			var dad:Number;
 			var dbd:Number;
 			var dcd:Number;

 			if (dab > dbc) {
 				if (dab > dca) {
 					//ab
 					if (dab > distortion) {
 						dx = 0.5*(ax + bx);
 						dy = 0.5*(ay + by);
 						dz = 0.5*(az + bz);
 						du = 0.5*(au + bu);
 						dv = 0.5*(av + bv);

 						ddx = (ax + dx)/(az + dz) - 0.5*(ax/az + dx/dz);
						ddy = (ay + dy)/(az + dz) - 0.5*(ay/az + dy/dz);
 						dad = ddx*ddx + ddy*ddy;

 						ddx = (bx + dx)/(bz + dz) - 0.5*(bx/bz + dx/dz);
						ddy = (by + dy)/(bz + dz) - 0.5*(by/bz + dy/dz);
 						dbd = ddx*ddx + ddy*ddy;

 						ddx = (cx + dx)/(cz + dz) - 0.5*(cx/cz + dx/dz);
						ddy = (cy + dy)/(cz + dz) - 0.5*(cy/cz + dy/dz);
 						dcd = ddx*ddx + ddy*ddy;

		 				bisection(dx, dy, dz, du, dv, cx, cy, cz, cu, cv, ax, ay, az, au, av, dcd, dca, dad);
 						bisection(dx, dy, dz, du, dv, bx, by, bz, bu, bv, cx, cy, cz, cu, cv, dbd, dbc, dcd);
 						return;
 					}
 				} else {
 					//ca
 					if (dca > distortion) {
 						dx = 0.5*(cx + ax);
 						dy = 0.5*(cy + ay);
 						dz = 0.5*(cz + az);
 						du = 0.5*(cu + au);
 						dv = 0.5*(cv + av);

 						ddx = (ax + dx)/(az + dz) - 0.5*(ax/az + dx/dz);
						ddy = (ay + dy)/(az + dz) - 0.5*(ay/az + dy/dz);
 						dad = ddx*ddx + ddy*ddy;

 						ddx = (bx + dx)/(bz + dz) - 0.5*(bx/bz + dx/dz);
						ddy = (by + dy)/(bz + dz) - 0.5*(by/bz + dy/dz);
 						dbd = ddx*ddx + ddy*ddy;

 						ddx = (cx + dx)/(cz + dz) - 0.5*(cx/cz + dx/dz);
						ddy = (cy + dy)/(cz + dz) - 0.5*(cy/cz + dy/dz);
 						dcd = ddx*ddx + ddy*ddy;

		 				bisection(dx, dy, dz, du, dv, bx, by, bz, bu, bv, cx, cy, cz, cu, cv, dbd, dbc, dcd);
		 				bisection(dx, dy, dz, du, dv, ax, ay, az, au, av, bx, by, bz, bu, bv, dad, dab, dbd);
 						return;
		 			}
 				}
 			} else {
 				if (dbc > dca) {
 					//bc
 					if (dbc > distortion) {
 						dx = 0.5*(bx + cx);
 						dy = 0.5*(by + cy);
 						dz = 0.5*(bz + cz);
 						du = 0.5*(bu + cu);
 						dv = 0.5*(bv + cv);

 						ddx = (ax + dx)/(az + dz) - 0.5*(ax/az + dx/dz);
						ddy = (ay + dy)/(az + dz) - 0.5*(ay/az + dy/dz);
 						dad = ddx*ddx + ddy*ddy;

 						ddx = (bx + dx)/(bz + dz) - 0.5*(bx/bz + dx/dz);
						ddy = (by + dy)/(bz + dz) - 0.5*(by/bz + dy/dz);
 						dbd = ddx*ddx + ddy*ddy;

 						ddx = (cx + dx)/(cz + dz) - 0.5*(cx/cz + dx/dz);
						ddy = (cy + dy)/(cz + dz) - 0.5*(cy/cz + dy/dz);
 						dcd = ddx*ddx + ddy*ddy;

	 					bisection(dx, dy, dz, du, dv, ax, ay, az, au, av, bx, by, bz, bu, bv, dad, dab, dbd);
 						bisection(dx, dy, dz, du, dv, cx, cy, cz, cu, cv, ax, ay, az, au, av, dcd, dca, dad);
 						return;
 					}
 				} else {
 					//ca
 					if (dca > distortion) {
 						dx = 0.5*(cx + ax);
 						dy = 0.5*(cy + ay);
 						dz = 0.5*(cz + az);
 						du = 0.5*(cu + au);
 						dv = 0.5*(cv + av);

 						ddx = (ax + dx)/(az + dz) - 0.5*(ax/az + dx/dz);
						ddy = (ay + dy)/(az + dz) - 0.5*(ay/az + dy/dz);
 						dad = ddx*ddx + ddy*ddy;

 						ddx = (bx + dx)/(bz + dz) - 0.5*(bx/bz + dx/dz);
						ddy = (by + dy)/(bz + dz) - 0.5*(by/bz + dy/dz);
 						dbd = ddx*ddx + ddy*ddy;

 						ddx = (cx + dx)/(cz + dz) - 0.5*(cx/cz + dx/dz);
						ddy = (cy + dy)/(cz + dz) - 0.5*(cy/cz + dy/dz);
 						dcd = ddx*ddx + ddy*ddy;

		 				bisection(dx, dy, dz, du, dv, bx, by, bz, bu, bv, cx, cy, cz, cu, cv, dbd, dbc, dcd);
		 				bisection(dx, dy, dz, du, dv, ax, ay, az, au, av, bx, by, bz, bu, bv, dad, dab, dbd);
 						return;
		 			}
 				}
 			}
			var ap:Number = focalLength/az;
			var bp:Number = focalLength/bz;
			var cp:Number = focalLength/cz;
			drawTriangle(ax*ap, ay*ap, au, av, bx*bp, by*bp, bu, bv, cx*cp, cy*cp, cu, cv);
 		}

		/**
		 * @private
		 */
		private function drawTriangle(ax:Number, ay:Number, au:Number, av:Number, bx:Number, by:Number, bu:Number, bv:Number, cx:Number, cy:Number, cu:Number, cv:Number):void {

			var abx:Number = bx - ax;
			var aby:Number = by - ay;
			var acx:Number = cx - ax;
			var acy:Number = cy - ay;
			var abu:Number = bu - au;
			var abv:Number = bv - av;
			var acu:Number = cu - au;
			var acv:Number = cv - av;
			var det:Number = abu*acv - abv*acu;
			var w:Number = _texture._width;
			var h:Number = _texture._height;

			textureMatrix.a = (acv*abx - abv*acx)/det;
			textureMatrix.b = (acv*aby - abv*acy)/det;
			textureMatrix.c = (acu*abx - abu*acx)/det;
			textureMatrix.d = (acu*aby - abu*acy)/det;
			textureMatrix.tx = (av - 1)*textureMatrix.c - au*textureMatrix.a + ax;
			textureMatrix.ty = (av - 1)*textureMatrix.d - au*textureMatrix.b + ay;

			textureMatrix.a /= w;
			textureMatrix.b /= w;
			textureMatrix.c /= h;
			textureMatrix.d /= h;

			gfx.beginBitmapFill(_texture._bitmapData, textureMatrix, _repeat, _smooth);
			if (_wireThickness >= 0) {
				gfx.lineStyle(_wireThickness, _wireColor);
			}
			gfx.moveTo(ax, ay);
			gfx.lineTo(bx, by);
			gfx.lineTo(cx, cy);
			if (_wireThickness >= 0) {
				gfx.lineTo(ax, ay);
			}
		}

		/**
		 * Текстура материала. Материал не выполняет никаких действий по отрисовке, если не задана текстура.
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
		 * Повтор текстуры при заливке. Более подробную информацию можно найти в описании метода
		 * <code>flash.display.Graphics#beginBitmapFill()</code>.
		 */
		public function get repeat():Boolean {
			return _repeat;
		}

		/**
		 * @private
		 */
		public function set repeat(value:Boolean):void {
			if (_repeat != value) {
				_repeat = value;
				markToChange();
			}
		}

		/**
		 * Сглаживание текстуры при увеличении масштаба. Более подробную информацию можно найти в описании метода
		 * <code>flash.display.Graphics#beginBitmapFill()</code>.
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
				if (_surface != null) {
					_surface.addMaterialChangedOperationToScene();
				}
			}
		}

		/**
		 * Толщина линии обводки полигона. Если значение отрицательное, то обводка не рисуется.
		 */
		public function get wireThickness():Number {
			return _wireThickness;
		}

		/**
		 * @private
		 */		
		public function set wireThickness(value:Number):void {
			if (_wireThickness != value) {
				_wireThickness = value;
				markToChange();
			}
		}

		/**
		 * Цвет линии обводки полигона.
		 */
		public function get wireColor():uint {
			return _wireColor;
		}

		/**
		 * @private
		 */		
		public function set wireColor(value:uint):void {
			if (_wireColor != value) {
				_wireColor = value;
				markToChange();
			}
		}

		/**
		 * Точность перспективной коррекции.
		 */
		public function get precision():Number {
			return _precision;
		}

		/**
		 * @private
		 */		
		public function set precision(value:Number):void {
			if (_precision != value) {
				_precision = value;
				markToChange();
			}
		}

		/**
		 * @inheritDoc 
		 */
		override public function clone():Material {
			var res:TextureMaterial = new TextureMaterial(_texture, _alpha, _repeat, _smooth, _blendMode, _wireThickness, _wireColor, _precision);
			return res;
		}

	}
}
