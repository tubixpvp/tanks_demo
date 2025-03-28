package alternativa.engine3d.core {

	import alternativa.engine3d.*;
	import alternativa.engine3d.display.Skin;
	import alternativa.engine3d.display.View;
	import alternativa.engine3d.materials.DrawPoint;
	import alternativa.engine3d.materials.SpriteMaterial;
	import alternativa.engine3d.materials.SurfaceMaterial;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	import alternativa.types.Set;
	
	import flash.geom.Matrix;

	use namespace alternativa3d;

	/**
	 * Камера для отображения 3D-сцены на экране.
	 * 
	 * <p> Направление камеры совпадает с её локальной осью Z, поэтому только что созданная камера смотрит вверх в системе
	 * координат родителя.</p>
	 * 
	 * <p> Для отображения видимой через камеру части сцены на экран, к камере должен быть подключён вьюпорт &mdash;
	 * экземпляр класса <code>alternativa.engine3d.display.View</code>. </p>
	 * 
	 * @see alternativa.engine3d.display.View
	 */
	public class Camera3D extends Object3D {

		/**
		 * @private
		 * Расчёт матрицы пространства камеры
		 */
		alternativa3d var calculateMatrixOperation:Operation = new Operation("calculateMatrix", this, calculateMatrix, Operation.CAMERA_CALCULATE_MATRIX);
		/**
		 * @private
		 * Расчёт плоскостей отсечения
		 */		
		alternativa3d var calculatePlanesOperation:Operation = new Operation("calculatePlanes", this, calculatePlanes, Operation.CAMERA_CALCULATE_PLANES);
		/**
		 * @private
		 * Отрисовка
		 */
		alternativa3d var renderOperation:Operation = new Operation("render", this, render, Operation.CAMERA_RENDER);

		// Инкремент количества объектов
		private static var counter:uint = 0;

		/**
		 * @private
		 * Полупространство камеры при отрисовке
		 */
		alternativa3d var sector:Sector;

		/**
		 * @private
		 * Поле зрения
		 */
		alternativa3d var _fov:Number = Math.PI/2;
		/**
		 * @private
		 * Фокусное расстояние
		 */
		alternativa3d var _focalLength:Number;
		/**
		 * @private
		 * Перспективное искажение
		 */
		alternativa3d var focalDistortion:Number;

		/**
		 * @private
		 * Флаги рассчитанности UV-матриц
		 */
		alternativa3d var uvMatricesCalculated:Set = new Set(true);

		// Всмомогательные точки для расчёта UV-матриц
		private var textureA:Point3D = new Point3D();
		private var textureB:Point3D = new Point3D();
		private var textureC:Point3D = new Point3D();

		/**
		 * @private
		 * Вид из камеры
		 */
		alternativa3d var _view:View;

		/**
		 * @private
		 * Режим отрисовки
		 */
		alternativa3d var _orthographic:Boolean = false;
		private var fullDraw:Boolean;

		/**
		 * @private
		 * Масштаб
		 */
		alternativa3d var _zoom:Number = 1;

		// Синус половинчатого угла обзора камеры
		private var viewAngle:Number;

		/**
		 * @private
		 * Направление камеры
		 */
		private var direction:Point3D = new Point3D(0, 0, 1);

		/**
		 * @private
		 * Обратная трансформация камеры
		 */
		alternativa3d var cameraMatrix:Matrix3D = new Matrix3D();

		// Скины
		private var firstSkin:Skin;
		private var prevSkin:Skin;
		private var currentSkin:Skin;

		// Плоскости отсечения
		private var leftPlane:Point3D = new Point3D();
		private var rightPlane:Point3D = new Point3D();
		private var topPlane:Point3D = new Point3D();
		private var bottomPlane:Point3D = new Point3D();
		private var farPlane:Point3D = new Point3D();
		private var leftOffset:Number;
		private var rightOffset:Number;
		private var topOffset:Number;
		private var bottomOffset:Number;
		private var nearOffset:Number;
		private var farOffset:Number;

		// Вспомогательные массивы точек для отрисовки
		private var points1:Array = new Array();
		private var points2:Array = new Array();
		private var drawPoints:Array = new Array();
		private var spritePoint:Point3D = new Point3D();
		// Массив для сортировки спрайтов
		private var spritePrimitives:Array = new Array();

		/**
		 * @private
		 */
		alternativa3d var _nearClippingDistance:Number = 1;
		/**
		 * @private
		 */
		alternativa3d var _farClippingDistance:Number = 1;
		/**
		 * @private
		 */
		alternativa3d var _nearClipping:Boolean = false;
		/**
		 * @private
		 */
		alternativa3d var _farClipping:Boolean = false;
		/**
		 * @private
		 */
		alternativa3d var _viewClipping:Boolean = true;

		/**
		 * Создаёт новый экземпляр камеры.
		 * 
		 * @param name имя камеры
		 */
		public function Camera3D(name:String = null) {
			super(name);
		}

		/**
		 * @private
		 */
		private function calculateMatrix():void {
			// Расчёт матрицы пространства камеры
			cameraMatrix.copy(_transformation);
			cameraMatrix.invert();
			if (_orthographic) {
				cameraMatrix.scale(_zoom, _zoom, _zoom);
			}
			// Направление камеры
			direction.x = _transformation.c;
			direction.y = _transformation.g;
			direction.z = _transformation.k;
			direction.normalize();
		}

		/**
		 * @private
		 * Расчёт плоскостей отсечения
		 */
		private function calculatePlanes():void {
			var halfWidth:Number = _view._width*0.5;
			var halfHeight:Number = _view._height*0.5;

			var aw:Number = _transformation.a*halfWidth;
			var ew:Number = _transformation.e*halfWidth;
			var iw:Number = _transformation.i*halfWidth;
			var bh:Number = _transformation.b*halfHeight;
			var fh:Number = _transformation.f*halfHeight;
			var jh:Number = _transformation.j*halfHeight;
			if (_orthographic) {
				if (_viewClipping) {
					// Расчёт плоскостей отсечения в изометрии
					aw /= _zoom;
					ew /= _zoom;
					iw /= _zoom;
					bh /= _zoom;
					fh /= _zoom;
					jh /= _zoom;

					// Левая плоскость
					leftPlane.x = _transformation.f*_transformation.k - _transformation.j*_transformation.g;
					leftPlane.y = _transformation.j*_transformation.c - _transformation.b*_transformation.k;
					leftPlane.z = _transformation.b*_transformation.g - _transformation.f*_transformation.c;
					leftOffset = (_transformation.d - aw)*leftPlane.x + (_transformation.h - ew)*leftPlane.y + (_transformation.l - iw)*leftPlane.z;

					// Правая плоскость
					rightPlane.x = -leftPlane.x;
					rightPlane.y = -leftPlane.y;
					rightPlane.z = -leftPlane.z;
					rightOffset = (_transformation.d + aw)*rightPlane.x + (_transformation.h + ew)*rightPlane.y + (_transformation.l + iw)*rightPlane.z;

					// Верхняя плоскость
					topPlane.x = _transformation.g*_transformation.i - _transformation.k*_transformation.e;
					topPlane.y = _transformation.k*_transformation.a - _transformation.c*_transformation.i;
					topPlane.z = _transformation.c*_transformation.e - _transformation.g*_transformation.a;
					topOffset = (_transformation.d - bh)*topPlane.x + (_transformation.h - fh)*topPlane.y + (_transformation.l - jh)*topPlane.z;

					// Нижняя плоскость
					bottomPlane.x = -topPlane.x;
					bottomPlane.y = -topPlane.y;
					bottomPlane.z = -topPlane.z;
					bottomOffset = (_transformation.d + bh)*bottomPlane.x + (_transformation.h + fh)*bottomPlane.y + (_transformation.l + jh)*bottomPlane.z;
				}
			} else {
				// Вычисляем расстояние фокуса
				_focalLength = Math.sqrt(_view._width*_view._width + _view._height*_view._height)*0.5/Math.tan(0.5*_fov);
				// Вычисляем минимальное (однопиксельное) искажение перспективной коррекции
				focalDistortion = 1/(_focalLength*_focalLength);

				if (_viewClipping) {
					// Расчёт плоскостей отсечения в перспективе
					var cl:Number = _transformation.c*_focalLength;
					var gl:Number = _transformation.g*_focalLength;
					var kl:Number = _transformation.k*_focalLength;

					// Угловые вектора пирамиды видимости
					var leftTopX:Number = -aw - bh + cl;
					var leftTopY:Number = -ew - fh + gl;
					var leftTopZ:Number = -iw - jh + kl;
					var rightTopX:Number = aw - bh + cl;
					var rightTopY:Number = ew - fh + gl;
					var rightTopZ:Number = iw - jh + kl;
					var leftBottomX:Number = -aw + bh + cl;
					var leftBottomY:Number = -ew + fh + gl;
					var leftBottomZ:Number = -iw + jh + kl;
					var rightBottomX:Number = aw + bh + cl;
					var rightBottomY:Number = ew + fh + gl;
					var rightBottomZ:Number = iw + jh + kl;

					// Левая плоскость
					leftPlane.x = leftBottomY*leftTopZ - leftBottomZ*leftTopY;
					leftPlane.y = leftBottomZ*leftTopX - leftBottomX*leftTopZ;
					leftPlane.z = leftBottomX*leftTopY - leftBottomY*leftTopX;
					leftOffset = _transformation.d*leftPlane.x + _transformation.h*leftPlane.y + _transformation.l*leftPlane.z;

					// Правая плоскость
					rightPlane.x = rightTopY*rightBottomZ - rightTopZ*rightBottomY;
					rightPlane.y = rightTopZ*rightBottomX - rightTopX*rightBottomZ;
					rightPlane.z = rightTopX*rightBottomY - rightTopY*rightBottomX;
					rightOffset = _transformation.d*rightPlane.x + _transformation.h*rightPlane.y + _transformation.l*rightPlane.z;

					// Верхняя плоскость
					topPlane.x = leftTopY*rightTopZ - leftTopZ*rightTopY;
					topPlane.y = leftTopZ*rightTopX - leftTopX*rightTopZ;
					topPlane.z = leftTopX*rightTopY - leftTopY*rightTopX;
					topOffset = _transformation.d*topPlane.x + _transformation.h*topPlane.y + _transformation.l*topPlane.z;

					// Нижняя плоскость
					bottomPlane.x = rightBottomY*leftBottomZ - rightBottomZ*leftBottomY;
					bottomPlane.y = rightBottomZ*leftBottomX - rightBottomX*leftBottomZ;
					bottomPlane.z = rightBottomX*leftBottomY - rightBottomY*leftBottomX;
					bottomOffset = _transformation.d*bottomPlane.x + _transformation.h*bottomPlane.y + _transformation.l*bottomPlane.z;

					// Расчёт угла конуса
					var length:Number = Math.sqrt(leftTopX*leftTopX + leftTopY*leftTopY + leftTopZ*leftTopZ);
					leftTopX /= length;
					leftTopY /= length;
					leftTopZ /= length;
					length = Math.sqrt(rightTopX*rightTopX + rightTopY*rightTopY + rightTopZ*rightTopZ);
					rightTopX /= length;
					rightTopY /= length;
					rightTopZ /= length;
					length = Math.sqrt(leftBottomX*leftBottomX + leftBottomY*leftBottomY + leftBottomZ*leftBottomZ);
					leftBottomX /= length;
					leftBottomY /= length;
					leftBottomZ /= length;
					length = Math.sqrt(rightBottomX*rightBottomX + rightBottomY*rightBottomY + rightBottomZ*rightBottomZ);
					rightBottomX /= length;
					rightBottomY /= length;
					rightBottomZ /= length;

					viewAngle = leftTopX*direction.x + leftTopY*direction.y + leftTopZ*direction.z;
					var dot:Number = rightTopX*direction.x + rightTopY*direction.y + rightTopZ*direction.z;
					viewAngle = (dot < viewAngle) ? dot : viewAngle;
					dot = leftBottomX*direction.x + leftBottomY*direction.y + leftBottomZ*direction.z;
					viewAngle = (dot < viewAngle) ? dot : viewAngle;
					dot = rightBottomX*direction.x + rightBottomY*direction.y + rightBottomZ*direction.z;
					viewAngle = (dot < viewAngle) ? dot : viewAngle;

					viewAngle = Math.sin(Math.acos(viewAngle));
				} else {
					viewAngle = 1;
				}
			}

			var x:Number;
			var y:Number;
			var z:Number;
			var k:Number;

			if (_nearClipping) {
				if (_orthographic) {
					k = _nearClippingDistance/_zoom;
					x = _transformation.c*k + _transformation.d;
					y = _transformation.g*k + _transformation.h;
					z = _transformation.k*k + _transformation.l;
				} else {
					x = _transformation.c*_nearClippingDistance + _transformation.d;
					y = _transformation.g*_nearClippingDistance + _transformation.h;
					z = _transformation.k*_nearClippingDistance + _transformation.l;
				}
				nearOffset = direction.x*x + direction.y*y + direction.z*z;
			}

			if (_farClipping) {
				if (_orthographic) {
					k = _farClippingDistance/_zoom;
					x = _transformation.c*k + _transformation.d;
					y = _transformation.g*k + _transformation.h;
					z = _transformation.k*k + _transformation.l;					
				} else {
					x = _transformation.c*_farClippingDistance + _transformation.d;
					y = _transformation.g*_farClippingDistance + _transformation.h;
					z = _transformation.k*_farClippingDistance + _transformation.l;
				}

				farPlane.x = -direction.x;
				farPlane.y = -direction.y;
				farPlane.z = -direction.z;
				farOffset = farPlane.x*x + farPlane.y*y + farPlane.z*z;
			}
		}

		/**
		 * @private
		 */
		private function render():void {
			// Режим отрисовки
			fullDraw = (calculateMatrixOperation.queued || calculatePlanesOperation.queued);

			// Отрисовка
			prevSkin = null;
			currentSkin = firstSkin;

			sector = null;
			// Определяем текущее полупространство камеры
			findSector(_scene.bsp);
			// Отрисовка БСП дерева
			renderSplitterNode(_scene.bsp);

			// Очистка рассчитанных текстурных матриц
			uvMatricesCalculated.clear();

			// Удаление ненужных скинов
			while (currentSkin != null) {
 				removeCurrentSkin();
	 		}

	 		if (_view._interactive) {
	 			_view.checkMouseOverOut(true);
	 		}
		}

		/**
		 * Поиск сектора камеры.
		 */
		private function findSector(node:BSPNode):void {
			if (node != null && node.splitter != null) {
				var normal:Point3D = node.normal;
				if (globalCoords.x*normal.x + globalCoords.y*normal.y + globalCoords.z*normal.z - node.offset >= 0) {
					if (node.frontSector != null) {
						sector = node.frontSector;
					} else {
						findSector(node.front);
					}
				} else {
					if (node.backSector != null) {
						sector = node.backSector;
					} else {
						findSector(node.back);
					}
				}
			}
		}

		/**
		 * @private
		 */
		private function renderSplitterNode(node:BSPNode):void {
			if (node != null) {
				if (node.splitter != null) {
					var primitive:*;
					var normal:Point3D = node.normal;
					var cameraAngle:Number = direction.x*normal.x + direction.y*normal.y + direction.z*normal.z;
					var cameraOffset:Number;
					if (!_orthographic) {
						cameraOffset = globalCoords.x*normal.x + globalCoords.y*normal.y + globalCoords.z*normal.z - node.offset;
					}
					// В ноде только базовый примитив
					if (_orthographic ? (cameraAngle < 0) : (cameraOffset > 0)) {
						// Камера спереди ноды
						if ((_orthographic || cameraAngle < viewAngle) && (node.splitter._open && (node.backSector == null || sector == null || sector._visible[node.backSector]))) {
							// Полупространство видно в камере
							renderSplitterNode(node.back);
						}
						if (node.frontSector == null || sector == null || sector._visible[node.frontSector]) {
							renderSplitterNode(node.front);
						}
					} else {
						// Камера сзади ноды
						if ((_orthographic || cameraAngle > -viewAngle) && (node.splitter._open && (node.frontSector == null || sector == null || sector._visible[node.frontSector]))) {
							renderSplitterNode(node.front);
						}
						if (node.backSector == null || sector == null || sector._visible[node.backSector]) {
							renderSplitterNode(node.back);
						}
					}
				} else {
					// Обычная отрисовка
					renderBSPNode(node);
				}
			}
		}

		/**
		 * @private
		 */
		private function renderBSPNode(node:BSPNode):void {
			if (node != null) {
				if (node.isSprite) {
					// Спрайтовая нода
					if (node.primitive != null) {
						drawSpriteSkin(node.primitive as SpritePrimitive);
					} else {
						drawSpritePrimitives(node.frontPrimitives);
					}
				} else {
					var primitive:*;
					var normal:Point3D = node.normal;
					var cameraAngle:Number = direction.x*normal.x + direction.y*normal.y + direction.z*normal.z;
					var cameraOffset:Number;
					if (!_orthographic) {
						cameraOffset = globalCoords.x*normal.x + globalCoords.y*normal.y + globalCoords.z*normal.z - node.offset;
					}
					// В ноде только базовый примитив
					if (_orthographic ? (cameraAngle < 0) : (cameraOffset > 0)) {
						// Камера спереди ноды
						if (_orthographic || cameraAngle < viewAngle) {
							renderBSPNode(node.back);
							if (node.primitive != null) {
								drawSkin(node.primitive);
							} else {
								for (primitive in node.frontPrimitives) {
									drawSkin(primitive);
								}
							}
						}
						renderBSPNode(node.front);
					} else {
						// Камера сзади ноды
						if (_orthographic || cameraAngle > -viewAngle) {
							renderBSPNode(node.front);
							if (node.primitive == null) {
								for (primitive in node.backPrimitives) {
									drawSkin(primitive);
								}
							}
						}
						renderBSPNode(node.back);
					}
				}
			}
		}

		/**
		 * @private
		 * Функция сортирует список спрайтовых примитивов по удаленности и отправляет на отрисовку.
		 *  
		 * @param primitives список примитивов для отрисовки
		 */
		private function drawSpritePrimitives(primitives:Set):void {
			var primitive:SpritePrimitive;
			var counter:int = -1;
			for (var p:* in primitives) {
				primitive = p;
				var point:Point3D = primitive.sprite.globalCoords;
				var z:Number = cameraMatrix.i*point.x + cameraMatrix.j*point.y + cameraMatrix.k*point.z + cameraMatrix.l;
				primitive.screenDepth = z;
				spritePrimitives[++counter] = primitive;
			}
			if (counter > 0) {
				sortSpritePrimitives(0, counter);
			}
			for (var i:int = counter; i >= 0; i--) {
				drawSpriteSkin(spritePrimitives[i]);
			}
		}

		/**
		 * @private
		 * Сортировка примитивов по удаленности.
		 *
		 * @param l начальный индекс
		 * @param r конечный индекс
		 */
		private function sortSpritePrimitives(l:int, r:int):void {
			var i:int = l;
			var j:int = r;
			var left:SpritePrimitive;
			var mid:Number = spritePrimitives[(r + l) >> 1].screenDepth;
			var right:SpritePrimitive;
			do {
 				while ((left = spritePrimitives[i]).screenDepth < mid) {i++};
 				while (mid < (right = spritePrimitives[j]).screenDepth) {j--};
 				if (i <= j) {
					spritePrimitives[i++] = right;
					spritePrimitives[j--] = left;
 				}
			} while (i <= j)
			if (l < j) {
				sortSpritePrimitives(l, j);
			}
			if (i < r) {
				sortSpritePrimitives(i, r);
			}
		}

		/**
		 * @private
		 * Отрисовка скина спрайтового примитива.
		 *  
		 * @param primitive спрайтовый примитив
		 */
		private function drawSpriteSkin(primitive:SpritePrimitive):void {
 			if (!fullDraw && currentSkin != null && currentSkin.primitive == primitive && !_scene.changedPrimitives[primitive]) {
	 			// Пропуск скина
				prevSkin = currentSkin;
				currentSkin = currentSkin.nextSkin;
			} else {
				var sprite:Sprite3D = primitive.sprite;

	 			var material:SpriteMaterial = sprite._material;
	 			if (material == null) {
	 				return;
	 			}

 				if (!material.canDraw(this)) {
 					return;
 				}

 				if (fullDraw || _scene.changedPrimitives[primitive]) {

					// Если конец списка скинов
 					if (currentSkin == null) {
						// Добавляем скин в конец 
 						addCurrentSkin();
 					} else {
 						if (fullDraw || _scene.changedPrimitives[currentSkin.primitive]) {
							// Очистка скина
							currentSkin.material.clear(currentSkin);
	 					} else {
							// Вставка скина перед текущим
	 						insertCurrentSkin();
	 					}
 					}

					// Назначаем скину примитив и материал
					currentSkin.primitive = primitive;
					currentSkin.material = material;
					material.draw(this, currentSkin);
		 			prevSkin = currentSkin;
		 			currentSkin = currentSkin.nextSkin;
 				} else {
 					// Скин текущего примитива дальше по списку скинов

					// Удаление ненужных скинов
					while (currentSkin != null && _scene.changedPrimitives[currentSkin.primitive]) {
		 				removeCurrentSkin();
		 			}

		 			// Переключение на следующий скин
		 			if (currentSkin != null) {
			 			prevSkin = currentSkin;
		 				currentSkin = currentSkin.nextSkin;
		 			}

 				}
 			}
		}

		/**
		 * @private
		 * Отрисовка скина примитива
		 */
 		private function drawSkin(primitive:PolyPrimitive):void {
 			if (!fullDraw && currentSkin != null && currentSkin.primitive == primitive && !_scene.changedPrimitives[primitive]) {
	 			// Пропуск скина
				prevSkin = currentSkin;
				currentSkin = currentSkin.nextSkin;
			} else {
	 			// Проверка поверхности 
	 			var surface:Surface = primitive.face._surface;
	 			if (surface == null) {
	 				return;
	 			}
	 			// Проверка материала
	 			var material:SurfaceMaterial = surface._material;
 				if (material == null || !material.canDraw(primitive)) {
 					return;
 				}
 				// Отсечение выходящих за окно просмотра частей
 				var length:uint = primitive.num;
 				var tmp:Array;
 				var points:Array = primitive.points;
 				if (_farClipping && _nearClipping) {
 					// Отсечение по ближней плоскости
		 			if ((length = clip(length, points, points1, direction, nearOffset)) < 3) {
		 				return;
		 			}
 					// Отсечение по дальней плоскости
		 			if ((length = clip(length, points1, points2, farPlane, farOffset)) < 3) {
		 				return;
		 			}
		 			points = points2;
 				} else if (_nearClipping) {
 					// Отсечение по ближней плоскости
		 			if ((length = clip(length, points, points2, direction, nearOffset)) < 3) {
		 				return;
		 			}
		 			points = points2;
 				} else if (_farClipping) {
 					// Отсечение по дальней плоскости
		 			if ((length = clip(length, points, points2, farPlane, farOffset)) < 3) {
		 				return;
		 			}
		 			points = points2;
 				}

	 			if (_viewClipping) {
		 			// Отсечение по левой стороне
		 			if ((length = clip(length, points, points1, leftPlane, leftOffset)) < 3) {
		 				return;
		 			}
		 			// Отсечение по правой стороне
		 			if ((length = clip(length, points1, points2, rightPlane, rightOffset)) < 3) {
		 				return;
		 			}
		 			// Отсечение по верхней стороне
		 			if ((length = clip(length, points2, points1, topPlane, topOffset)) < 3) {
		 				return;
		 			}
		 			// Отсечение по нижней стороне
		 			if ((length = clip(length, points1, points2, bottomPlane, bottomOffset)) < 3) {
		 				return;
		 			}
		 			points = points2;
 				}

 				if (fullDraw || _scene.changedPrimitives[primitive]) {
	 				var i:uint;
	 				var point:Point3D;
	 				var drawPoint:DrawPoint;
 					var x:Number;
	 				var y:Number;
	 				var z:Number;
	 				var cz:Number;
	 				var uvMatrix:Matrix3D = primitive.face.uvMatrix;
 					// Переводим координаты в систему камеры
	 				if (!_orthographic && material.useUV && uvMatrix) {
	 					// Формируем список точек и UV-координат полигона
						for (i = 0; i < length; i++) {
							point = points[i];
	 						x = point.x;
	 						y = point.y;
	 						z = point.z;
	 						cz = cameraMatrix.i*x + cameraMatrix.j*y + cameraMatrix.k*z + cameraMatrix.l;
	 						if (cz < 0) {
	 							// Пропускаем полигон
	 							return;
	 						}
	 						// Расчет UV
			 				var u:Number = uvMatrix.a*x + uvMatrix.b*y + uvMatrix.c*z + uvMatrix.d;
			 				var v:Number = uvMatrix.e*x + uvMatrix.f*y + uvMatrix.g*z + uvMatrix.h;

							drawPoint = drawPoints[i];
							if (drawPoint == null) {
								drawPoints[i] = new DrawPoint(cameraMatrix.a*x + cameraMatrix.b*y + cameraMatrix.c*z + cameraMatrix.d, cameraMatrix.e*x + cameraMatrix.f*y + cameraMatrix.g*z + cameraMatrix.h, cz, u, v);
							} else {
								drawPoint.x = cameraMatrix.a*x + cameraMatrix.b*y + cameraMatrix.c*z + cameraMatrix.d;
								drawPoint.y = cameraMatrix.e*x + cameraMatrix.f*y + cameraMatrix.g*z + cameraMatrix.h;
								drawPoint.z = cz;
								drawPoint.u = u;
								drawPoint.v = v;
							}
		 				}
	 				} else {
		 				// Формируем список точек полигона
						for (i = 0; i < length; i++) {
							point = points[i];
	 						x = point.x;
	 						y = point.y;
	 						z = point.z;
	 						cz = cameraMatrix.i*x + cameraMatrix.j*y + cameraMatrix.k*z + cameraMatrix.l;
	 						if (cz < 0 && !_orthographic) {
	 							// Пропускаем полигон
	 							return;
	 						}
							drawPoint = drawPoints[i];
							if (drawPoint == null) {
								drawPoints[i] = new DrawPoint(cameraMatrix.a*x + cameraMatrix.b*y + cameraMatrix.c*z + cameraMatrix.d, cameraMatrix.e*x + cameraMatrix.f*y + cameraMatrix.g*z + cameraMatrix.h, cz);
							} else {
								drawPoint.x = cameraMatrix.a*x + cameraMatrix.b*y + cameraMatrix.c*z + cameraMatrix.d;
								drawPoint.y = cameraMatrix.e*x + cameraMatrix.f*y + cameraMatrix.g*z + cameraMatrix.h;
								drawPoint.z = cz;
							}
		 				}
		 			}

					// Если конец списка скинов
 					if (currentSkin == null) {
						// Добавляем скин в конец 
 						addCurrentSkin();
 					} else {
 						if (fullDraw || _scene.changedPrimitives[currentSkin.primitive]) {
							// Очистка скина
							currentSkin.material.clear(currentSkin);
	 					} else {
							// Вставка скина перед текущим
	 						insertCurrentSkin();
	 					}
 					}

					// Назначаем скину примитив и материал
					currentSkin.primitive = primitive;
					currentSkin.material = material;
					material.draw(this, currentSkin, length, drawPoints);

		 			// Переключаемся на следующий скин
		 			prevSkin = currentSkin;
		 			currentSkin = currentSkin.nextSkin;
 				} else {
 					// Скин текущего примитива дальше по списку скинов

					// Удаление ненужных скинов
					while (currentSkin != null && _scene.changedPrimitives[currentSkin.primitive]) {
		 				removeCurrentSkin();
		 			}

		 			// Переключение на следующий скин
		 			if (currentSkin != null) {
			 			prevSkin = currentSkin;
		 				currentSkin = currentSkin.nextSkin;
		 			}
 				}
 			}
 		}

		/**
		 * @private
		 * Отсечение полигона плоскостью.
		 * 
		 * @param length кол-во точек в полигоне
		 * @param points1 исходный полигон
		 * @param points2 отсеченный полигон
		 * @param plane нормаль плоскости отсечения
		 * @param offset оффсет плоскости отсечения
		 * 
		 * @return кол-во точек в отсеченном полигоне 
		 */
		private function clip(length:uint, points1:Array, points2:Array, plane:Point3D, offset:Number):uint {
			var i:uint;
			var k:Number;
			var index:uint = 0;
			var point:Point3D;
			var point1:Point3D;
			var point2:Point3D;
			var offset1:Number;
			var offset2:Number;

			point1 = points1[length - 1];
			offset1 = plane.x*point1.x + plane.y*point1.y + plane.z*point1.z - offset;

			for (i = 0; i < length; i++) {
				point2 = points1[i];
				offset2 = plane.x*point2.x + plane.y*point2.y + plane.z*point2.z - offset;

				if (offset2 > 0) {
					if (offset1 <= 0) {
						k = offset2/(offset2 - offset1);
						point = points2[index];
						if (point == null) {
							point = new Point3D(point2.x - (point2.x - point1.x)*k, point2.y - (point2.y - point1.y)*k, point2.z - (point2.z - point1.z)*k);
							points2[index] = point;
						} else {
							point.x = point2.x - (point2.x - point1.x)*k;
							point.y = point2.y - (point2.y - point1.y)*k;
							point.z = point2.z - (point2.z - point1.z)*k;
						}
						index++;
					}
					point = points2[index];
					if (point == null) {
						point = new Point3D(point2.x, point2.y, point2.z);
						points2[index] = point;
					} else {
						point.x = point2.x;
						point.y = point2.y;
						point.z = point2.z;
					}
					index++;
				} else {
					if (offset1 > 0) {
						k = offset2/(offset2 - offset1);
						point = points2[index];
						if (point == null) {
							point = new Point3D(point2.x - (point2.x - point1.x)*k, point2.y - (point2.y - point1.y)*k, point2.z - (point2.z - point1.z)*k);
							points2[index] = point;
						} else {
							point.x = point2.x - (point2.x - point1.x)*k;
							point.y = point2.y - (point2.y - point1.y)*k;
							point.z = point2.z - (point2.z - point1.z)*k;
						}
						index++;
					}
				}
				offset1 = offset2;
				point1 = point2;
			}
			return index;
		}

		/**
		 * @private
		 * Добавление текущего скина.
		 */
		private function addCurrentSkin():void {
 			currentSkin = Skin.createSkin();
 			_view.canvas.addChild(currentSkin);
 			if (prevSkin == null) {
 				firstSkin = currentSkin;
 			} else {
 				prevSkin.nextSkin = currentSkin;
 			}
		}

		/**
		 * @private
		 * Вставляем под текущий скин.
		 */
		private function insertCurrentSkin():void {
			var skin:Skin = Skin.createSkin();
 			_view.canvas.addChildAt(skin, _view.canvas.getChildIndex(currentSkin));
 			skin.nextSkin = currentSkin;
 			if (prevSkin == null) {
 				firstSkin = skin;
 			} else {
 				prevSkin.nextSkin = skin;
 			}
 			currentSkin = skin;
		}

		/**
		 * @private
		 * Удаляет текущий скин.
		 */
		private function removeCurrentSkin():void {
			// Сохраняем следующий
			var next:Skin = currentSkin.nextSkin;
			// Удаляем из канваса
			_view.canvas.removeChild(currentSkin);
			// Очистка скина
			if (currentSkin.material != null) {
				currentSkin.material.clear(currentSkin);
			}
			// Зачищаем ссылки
			currentSkin.nextSkin = null;
			currentSkin.primitive = null;
			currentSkin.material = null;
			// Удаляем
			Skin.destroySkin(currentSkin);
			// Следующий устанавливаем текущим
			currentSkin = next;
			// Устанавливаем связь от предыдущего скина
			if (prevSkin == null) {
		 		firstSkin = currentSkin;
		 	} else {
		 		prevSkin.nextSkin = currentSkin;
			}
		}

		/**
		 * @private
		 */		
		alternativa3d function calculateUVMatrix(face:Face, width:uint, height:uint):void {
			// Расчёт точек базового примитива в координатах камеры
			var point:Point3D = face.primitive.points[0];
			textureA.x = cameraMatrix.a*point.x + cameraMatrix.b*point.y + cameraMatrix.c*point.z;
			textureA.y = cameraMatrix.e*point.x + cameraMatrix.f*point.y + cameraMatrix.g*point.z;
			point = face.primitive.points[1];
			textureB.x = cameraMatrix.a*point.x + cameraMatrix.b*point.y + cameraMatrix.c*point.z;
			textureB.y = cameraMatrix.e*point.x + cameraMatrix.f*point.y + cameraMatrix.g*point.z;
			point = face.primitive.points[2];
			textureC.x = cameraMatrix.a*point.x + cameraMatrix.b*point.y + cameraMatrix.c*point.z;
			textureC.y = cameraMatrix.e*point.x + cameraMatrix.f*point.y + cameraMatrix.g*point.z;

			// Находим AB и AC
			var abx:Number = textureB.x - textureA.x;
			var aby:Number = textureB.y - textureA.y;
			var acx:Number = textureC.x - textureA.x;
			var acy:Number = textureC.y - textureA.y;

			// Расчёт текстурной матрицы
			var uvMatrixBase:Matrix = face.uvMatrixBase;
			var uvMatrix:Matrix = face.orthoTextureMatrix;
			uvMatrix.a = (uvMatrixBase.a*abx + uvMatrixBase.b*acx)/width;
			uvMatrix.b = (uvMatrixBase.a*aby + uvMatrixBase.b*acy)/width;
			uvMatrix.c = -(uvMatrixBase.c*abx + uvMatrixBase.d*acx)/height;
			uvMatrix.d = -(uvMatrixBase.c*aby + uvMatrixBase.d*acy)/height;
			uvMatrix.tx = (uvMatrixBase.tx + uvMatrixBase.c)*abx + (uvMatrixBase.ty + uvMatrixBase.d)*acx + textureA.x + cameraMatrix.d;
			uvMatrix.ty = (uvMatrixBase.tx + uvMatrixBase.c)*aby + (uvMatrixBase.ty + uvMatrixBase.d)*acy + textureA.y + cameraMatrix.h;

			// Помечаем, как рассчитанную
			uvMatricesCalculated[face] = true;
		}

		/**
		 * Вьюпорт, в который выводится изображение с камеры.
		 */
		public function get view():View {
			return _view;
		}

		/**
		 * @private
		 */
		public function set view(value:View):void {
			if (value != _view) {
				if (_view != null) {
					_view.camera = null;
				}
				if (value != null) {
					value.camera = this;
				}
			}
		}

		/**
		 * Флаг режима аксонометрической проекции.
		 * 
		 * @default false
		 */		
		public function get orthographic():Boolean {
			return _orthographic;
		}
		
		/**
		 * @private
		 */		
		public function set orthographic(value:Boolean):void {
			if (_orthographic != value) {
				// Отправляем сигнал об изменении типа камеры
				addOperationToScene(calculateMatrixOperation);
				// Сохраняем новое значение
				_orthographic = value;
			}
		}
		
		/**
		 * Угол поля зрения в радианах в режиме перспективной проекции. При изменении FOV изменяется фокусное расстояние
		 * камеры по формуле <code>f = d/tan(fov/2)</code>, где <code>d</code> является половиной диагонали вьюпорта.
		 * Угол зрения ограничен диапазоном 0-180 градусов.
		 * 
		 * @see focalLength
		 */
		public function get fov():Number {
			return _fov;
		}

		/**
		 * @private
		 */
		public function set fov(value:Number):void {
			value = (value < 0) ? 0 : ((value > (Math.PI - 0.0001)) ? (Math.PI - 0.0001) : value);
			if (_fov != value) {
				// Если перспектива
				if (!_orthographic) {
					// Отправляем сигнал об изменении плоскостей отсечения
					addOperationToScene(calculatePlanesOperation);
				}
				// Сохраняем новое значение
				_fov = value;
			}
		}

		/**
		 * Фокусное расстояние камеры.
		 * Вычисляется по формуле <code>f = d/tan(fov/2)</code>, где <code>d</code> является половиной диагонали вьюпорта.
		 * Если с камерой не связан вьюпорт, метод вернет NaN.
		 * 
		 * @see fov
		 */
		public function get focalLength():Number {
			if (_view == null) {
				return NaN;
			}
			if (orthographic || calculatePlanesOperation.queued || scene == null) {
				// Требуется пересчет
				return 0.5*Math.sqrt(_view._width*_view._width + _view._height*_view._height)/Math.tan(0.5*_fov);
			} else {
				return _focalLength;
			}
		}

		/**
		 * Коэффициент увеличения изображения в режиме аксонометрической проекции.
		 */
		public function get zoom():Number {
			return _zoom;
		}		

		/**
		 * @private
		 */
		public function set zoom(value:Number):void {
			value = (value < 0) ? 0 : value;
			if (_zoom != value) {
				// Если изометрия
				if (_orthographic) {
					// Отправляем сигнал об изменении zoom
					addOperationToScene(calculateMatrixOperation);
				}
				// Сохраняем новое значение
				_zoom = value;
			}
		}

		/**
		 * Сектор в котором находится камера.
		 * 
		 * <p>Для правильной работы метода, сцена должна быть построена вызовом метода 
		 * calculate после изменения следующих свойств сцены: splitters, sectors, planeOffsetThreshold.</p>
		 * 
		 * @see Scene3D#calculate()
		 */
		public function get currentSector():Sector {
			if (_scene == null) {
				return null;
			}
			sector = null;
			findSector(_scene.bsp);
			return sector;
		}

		/**
		 * @inheritDoc
		 */
		override protected function addToScene(scene:Scene3D):void {
			super.addToScene(scene);
			if (_view != null) {
				// Отправляем операцию расчёта плоскостей отсечения
				scene.addOperation(calculatePlanesOperation);
				// Подписываемся на сигналы сцены
				scene.changePrimitivesOperation.addSequel(renderOperation);
			}
		}

		/**
		 * @inheritDoc
		 */
		override protected function removeFromScene(scene:Scene3D):void {
			super.removeFromScene(scene);
			
			// Удаляем все операции из очереди
			scene.removeOperation(calculateMatrixOperation);
			scene.removeOperation(calculatePlanesOperation);
			scene.removeOperation(renderOperation);
			
			if (_view != null) {
				// Отписываемся от сигналов сцены
				scene.changePrimitivesOperation.removeSequel(renderOperation);
			}
		}

		/**
		 * @private
		 */
		alternativa3d function addToView(view:View):void {
			// Сохраняем первый скин
			firstSkin = (view.canvas.numChildren > 0) ? Skin(view.canvas.getChildAt(0)) : null;
			
			// Подписка на свои операции

			// При изменении камеры пересчёт матрицы
			calculateTransformationOperation.addSequel(calculateMatrixOperation);
			// При изменении матрицы или FOV пересчёт плоскостей отсечения
			calculateMatrixOperation.addSequel(calculatePlanesOperation);
			// При изменении плоскостей перерисовка
			calculatePlanesOperation.addSequel(renderOperation);

			if (_scene != null) {
				// Отправляем сигнал перерисовки
				_scene.addOperation(calculateMatrixOperation);
				// Подписываемся на сигналы сцены
				_scene.changePrimitivesOperation.addSequel(renderOperation);
			}
			
			// Сохраняем вид
			_view = view;
		}

		/**
		 * @private
		 */
		alternativa3d function removeFromView(view:View):void {
			// Сброс ссылки на первый скин
			firstSkin = null;
			
			// Отписка от своих операций

			// При изменении камеры пересчёт матрицы
			calculateTransformationOperation.removeSequel(calculateMatrixOperation);
			// При изменении матрицы или FOV пересчёт плоскостей отсечения
			calculateMatrixOperation.removeSequel(calculatePlanesOperation);
			// При изменении плоскостей перерисовка
			calculatePlanesOperation.removeSequel(renderOperation);
			
			if (_scene != null) {
				// Удаляем все операции из очереди
				_scene.removeOperation(calculateMatrixOperation);
				_scene.removeOperation(calculatePlanesOperation);
				_scene.removeOperation(renderOperation);
				// Отписываемся от сигналов сцены
				_scene.changePrimitivesOperation.removeSequel(renderOperation);
			}
			// Удаляем ссылку на вид
			_view = null;
		}

		/**
		 * @inheritDoc
		 */
		override protected function defaultName():String {
			return "camera" + ++counter;
		}

		/**
		 * @inheritDoc
		 */
		protected override function createEmptyObject():Object3D {
			return new Camera3D();
		}

		/**
		 * @inheritDoc
		 */
		protected override function clonePropertiesFrom(source:Object3D):void {
			super.clonePropertiesFrom(source);
			
			var src:Camera3D = Camera3D(source);
			orthographic = src._orthographic;
			zoom = src._zoom;
			fov = src._fov;
		}

		/**
		 * Включает отсечение по ближней плоскости. Если задано значение <code>true</code>, объекты или их части, имеющие в камере
		 * координату Z меньше заданного значения, не отрисовываются. Если задано значение <code>false</code>, отсечение не выполняется.
		 * 
		 * @see #farClipping
		 * @see #viewClipping
		 * @see #nearClippingDistance
		 * 
		 * @default false
		 */
		public function get nearClipping():Boolean {
			return _nearClipping;
		}

		/**
		 * @private
		 */
		public function set nearClipping(value:Boolean):void {
			if (_nearClipping != value) {
				_nearClipping = value;
				addOperationToScene(calculatePlanesOperation);
			}
		}

		/**
		 * Расстояние до ближней плоскости отсечения в системе координат камеры. Значение ограничено снизу нулём.
		 * 
		 * @see #nearClipping
		 * 
		 * @default 1
		 */
		public function get nearClippingDistance():Number {
			return _nearClippingDistance;
		}

		/**
		 * @private
		 */
		public function set nearClippingDistance(value:Number):void {
			if (value < 0) {
				value = 0;
			}
			if (_nearClippingDistance != value) {
				_nearClippingDistance = value;
				addOperationToScene(calculatePlanesOperation);
			}
		}

		/**
		 * Включает отсечение по дальней плоскости. Если задано значение <code>true</code>, объекты или их части, имеющие в камере
		 * координату Z больше заданного значения, не отрисовываются. Если задано значение <code>false</code>, отсечение не выполняется.
		 * 
		 * @see #nearClipping
		 * @see #viewClipping
		 * @see #farClippingDistance
		 * 
		 * @default false
		 */
		public function get farClipping():Boolean {
			return _farClipping;
		}

		/**
		 * @private
		 */
		public function set farClipping(value:Boolean):void {
			if (_farClipping != value) {
				_farClipping = value;
				addOperationToScene(calculatePlanesOperation);
			}
		}

		/**
		 * Расстояние до дальней плоскости отсечения в системе координат камеры. Значение ограничено снизу нулём.
		 * 
		 * @see #farClipping
		 * 
		 * @default 1
		 */
		public function get farClippingDistance():Number {
			return _farClippingDistance;
		}

		/**
		 * @private
		 */
		public function set farClippingDistance(value:Number):void {
			if (value < 0) {
				value = 0;
			}
			if (_farClippingDistance != value) {
				_farClippingDistance = value;
				addOperationToScene(calculatePlanesOperation);
			}
		}

		/**
		 * Включает отсечение по пирамиде видимости. Если задано значение <code>true</code>, выполняется отсечение объектов сцены по
		 * пирамиде видимости. Если задано значение <code>false</code>, отсечение не выполняется. Такой режим полезен, когда
		 * заранее известно, что вся сцена находится в пирамиде видимости. В этом случае отключение отсечения позволит ускорить отрисовку. Не следует отключать
		 * отсечение по пирамиде видимости одновременно с отсечением по ближней плоскости, если позади камеры находятся объекты или части объектов, т.к. это приведёт к
		 * артефактам отрисовки, а при использовании текстурных материалов и к зацикливанию адаптивной триангуляции.
		 * 
		 * @see #nearClipping
		 * @see #farClipping
		 * 
		 * @default true 
		 */
		public function get viewClipping():Boolean {
			return _viewClipping;
		}

		/**
		 * @private
		 */
		public function set viewClipping(value:Boolean):void {
			if (_viewClipping != value) {
				_viewClipping = value;
				addOperationToScene(calculatePlanesOperation);
			}
		}

	}
}
