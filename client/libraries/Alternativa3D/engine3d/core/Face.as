package alternativa.engine3d.core {

	import alternativa.engine3d.*;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	import alternativa.types.Set;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;

	use namespace alternativa3d;

	/**
	 * Событие рассылается когда пользователь последовательно нажимает и отпускает левую кнопку мыши над одной и той же гранью.
	 * Между нажатием и отпусканием кнопки могут происходить любые другие события.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.CLICK
	 */
	[Event(name="click", type = "alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь нажимает левую кнопку мыши над гранью.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_DOWN
	 */
	[Event(name="mouseDown", type = "alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь отпускает левую кнопку мыши над гранью.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_UP
	 */
	[Event(name="mouseUp", type = "alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь наводит курсор мыши на грань.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_OVER
	 */
	[Event(name="mouseOver", type = "alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь уводит курсор мыши с грани.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_OUT
	 */
	[Event(name="mouseOut", type = "alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь перемещает курсор мыши над гранью.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_MOVE
	 */
	[Event(name="mouseMove", type = "alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Событие рассылается когда пользователь вращает колесо мыши над гранью.
	 *
	 * @eventType alternativa.engine3d.events.MouseEvent3D.MOUSE_WHEEL
	 */
	[Event(name="mouseWheel", type = "alternativa.engine3d.events.MouseEvent3D")]
	/**
	 * Грань, образованная тремя или более вершинами. Грани являются составными частями полигональных объектов. Каждая грань
	 * содержит информацию об объекте и поверхности, которым она принадлежит. Для обеспечения возможности наложения
	 * текстуры на грань, первым трём её вершинам могут быть заданы UV-координаты, на основании которых расчитывается
	 * матрица трансформации текстуры.
	 *
	 * <p> Класс реализует интерфейс <code>flash.events.IEventDispatcher</code> и может рассылать мышиные события, содержащие информацию
	 * о точке в трёхмерном пространстве, в которой произошло событие.</p>
	 */
	final public class Face implements IEventDispatcher {
		// Погрешность определения вырожденной UV матрицы
		private static const uvThreshold:Number = 1.0 / 2880;
		// Операции
		/**
		 * @private
		 * Расчёт глобальной нормали плоскости грани.
		 */
		alternativa3d var calculateNormalOperation:Operation = new Operation("calculateNormal", this, calculateNormal, Operation.FACE_CALCULATE_NORMAL);
		/**
		 * @private
		 * Расчёт базовой UV матрицы, используется для расчета UV матрицы.
		 */
		alternativa3d var calculateBaseUVOperation:Operation = new Operation("calculateBaseUV", this, calculateBaseUV, Operation.FACE_CALCULATE_BASE_UV);
		/**
		 * @private
		 * Расчёт UV матрицы.
		 */
		alternativa3d var calculateUVOperation:Operation = new Operation("calculateUV", this, calculateUV, Operation.FACE_CALCULATE_UV);
		/**
		 * @private
		 * Обновление примитива в сцене.
		 */
		alternativa3d var updatePrimitiveOperation:Operation = new Operation("updatePrimitive", this, updatePrimitive, Operation.FACE_UPDATE_PRIMITIVE);
		/**
		 * @private
		 * Обновление материала.
		 */
		alternativa3d var updateMaterialOperation:Operation = new Operation("updateMaterial", this, updateMaterial, Operation.FACE_UPDATE_MATERIAL);

		/**
		 * @private
		 * Меш
		 */
		alternativa3d var _mesh:Mesh;
		/**
		 * @private
		 * Поверхность
		 */
		alternativa3d var _surface:Surface;
		/**
		 * @private
		 * Вершины грани
		 */
		alternativa3d var _vertices:Array;
		/**
		 * @private
		 * Количество вершин
		 */
		alternativa3d var _verticesCount:uint;
		/**
		 * @private
		 * Примитив
		 */
		alternativa3d var primitive:PolyPrimitive;

		// UV-координаты
		/**
		 * @private
		 */
		alternativa3d var _aUV:Point;
		/**
		 * @private
		 */
		alternativa3d var _bUV:Point;
		/**
		 * @private
		 */
		alternativa3d var _cUV:Point;

		/**
		 * @private
		 * базовая UV матрица
		 */
		alternativa3d var uvMatrixBase:Matrix;
		/**
		 * @private
		 * UV матрица 
		 */
		alternativa3d var uvMatrix:Matrix3D;
		/**
		 * @private
		 * UV Матрица перевода текстурных координат в изометрическую камеру.
		 */
		alternativa3d var orthoTextureMatrix:Matrix;

		/**
		 * @private
		 * Нормаль плоскости
		 */
		alternativa3d var globalNormal:Point3D = new Point3D();
		/**
		 * @private
		 * Смещение плоскости
		 */
		alternativa3d var globalOffset:Number;

		/**
		 * Флаг указывает, будет ли объект принимать мышиные события.
		 */
		public var mouseEnabled:Boolean = true;
		/**
		 * Диспетчер событий.
		 */
		private var dispatcher:EventDispatcher;

		/**
		 * Создание экземпляра грани.
		 *
		 * @param vertices массив объектов типа <code>alternativa.engine3d.core.Vertex</code>, задающий вершины грани в
		 * порядке обхода лицевой стороны грани против часовой стрелки.
		 *
		 * @see Vertex
		 */
		public function Face(vertices:Array) {
			// Сохраняем вершины
			_vertices = vertices;
			_verticesCount = vertices.length;

			// Создаём оригинальный примитив
			primitive = PolyPrimitive.create();
			primitive.face = this;
			primitive.num = _verticesCount;

			// Обрабатываем вершины
			for (var i:uint = 0; i < _verticesCount; i++) {
				var vertex:Vertex = vertices[i];
				// Добавляем координаты вершины в примитив
				primitive.points.push(vertex.globalCoords);
				// Добавляем вершину в грань
				vertex.addToFace(this);
			}

			// Расчёт нормали
			calculateNormalOperation.addSequel(updatePrimitiveOperation);

			// Расчет нормали заставляет пересчитаться UV матрицу
			calculateNormalOperation.addSequel(calculateUVOperation);
			// Расчет базововй UV матрицы инициирует расчет UV матрицы грани 
			calculateBaseUVOperation.addSequel(calculateUVOperation);
			// Расчёт UV матрицы грани инициирует перерисовку
			calculateUVOperation.addSequel(updateMaterialOperation);
		}

		/**
		 * @private
		 * Расчёт нормали в глобальных координатах
		 */
		private function calculateNormal():void {
			// Вектор AB
			var vertex:Vertex = _vertices[0];
			var av:Point3D = vertex.globalCoords;
			vertex = _vertices[1];
			var bv:Point3D = vertex.globalCoords;
			var abx:Number = bv.x - av.x;
			var aby:Number = bv.y - av.y;
			var abz:Number = bv.z - av.z;
			// Вектор AC
			vertex = _vertices[2];
			var cv:Point3D = vertex.globalCoords;
			var acx:Number = cv.x - av.x;
			var acy:Number = cv.y - av.y;
			var acz:Number = cv.z - av.z;
			// Перпендикуляр к плоскости
			globalNormal.x = acz*aby - acy*abz;
			globalNormal.y = acx*abz - acz*abx;
			globalNormal.z = acy*abx - acx*aby;
			// Нормализация перпендикуляра
			globalNormal.normalize();
		}

		/**
		 * @private
		 * Расчитывает глобальное смещение плоскости грани.
		 * Помечает конечные примитивы на удаление, а базовый на добавление в сцене.
		 */
		private function updatePrimitive():void {
			// Расчёт смещения
			var vertex:Vertex = _vertices[0];
			globalOffset = vertex.globalCoords.x*globalNormal.x + vertex.globalCoords.y*globalNormal.y + vertex.globalCoords.z*globalNormal.z;

			removePrimitive(primitive);
			primitive.mobility = _mesh.inheritedMobility;
			_mesh._scene.addPrimitives.push(primitive);
		}

		/**
		 * @private
		 * Рекурсивно проходит по фрагментам примитива и отправляет конечные фрагменты на удаление из сцены
		 */
		private function removePrimitive(primitive:PolyPrimitive):void {
			if (primitive.backFragment != null) {
				removePrimitive(primitive.backFragment);
				removePrimitive(primitive.frontFragment);
				primitive.backFragment = null;
				primitive.frontFragment = null;
				if (primitive != this.primitive) {
					primitive.parent = null;
					primitive.sibling = null;
					PolyPrimitive.destroy(primitive);
				}
			} else {
				// Если примитив в BSP-дереве
				if (primitive.node != null) {
					// Удаление примитива
					_mesh._scene.removeBSPPrimitive(primitive);
				}
			}
		}

		/**
		 * @private
		 * Пометка на перерисовку фрагментов грани.
		 */
		private function updateMaterial():void {
			if (!updatePrimitiveOperation.queued) {
				changePrimitive(primitive);
			}
		}

		/**
		 * @private
		 * Рекурсивно проходит по фрагментам примитива и отправляет конечные фрагменты на перерисовку
		 */
		private function changePrimitive(primitive:PolyPrimitive):void {
			if (primitive.backFragment != null) {
				changePrimitive(primitive.backFragment);
				changePrimitive(primitive.frontFragment);
			} else {
				_mesh._scene.changedPrimitives[primitive] = true;
			}
		}

		/**
		 * @private
		 * Расчёт UV-матрицы на основании первых трёх UV-координат.
		 */
		private function calculateBaseUV():void {
			// Расчёт UV-матрицы
			if (_aUV != null && _bUV != null && _cUV != null) {
				var abu:Number = _bUV.x - _aUV.x;
				var abv:Number = _bUV.y - _aUV.y;
				var acu:Number = _cUV.x - _aUV.x;
				var acv:Number = _cUV.y - _aUV.y;
				var det:Number = abu*acv - abv*acu;

				// Проверка на нулевой определитель
				if (det < uvThreshold && det > -uvThreshold) {
					var len:Number;
					if (abu < uvThreshold && abu > -uvThreshold && abv < uvThreshold && abv > -uvThreshold) {
						if (acu < uvThreshold && acu > -uvThreshold && acv < uvThreshold && acv > -uvThreshold) {
							// Оба вырождены
							abu = uvThreshold;
							acv = uvThreshold;
						} else {
							// Вырожден AB
							len = Math.sqrt(acu*acu + acv*acv);
							abu = uvThreshold*acv/len;
							abv = -uvThreshold*acu/len;
						}
					} else {
						if (acu < uvThreshold && acu > -uvThreshold && acv < uvThreshold && acv > -uvThreshold) {
							//Вырожден AC
							len = Math.sqrt(abu*abu + abv*abv);
							acu = -uvThreshold*abv/len;
							acv = uvThreshold*abu/len;
						} else {
							// Сонаправлены
							len = Math.sqrt(abu*abu + abv*abv);
							acu += uvThreshold*abv/len;
							acv -= uvThreshold*abu/len;
						}
					}
					// Пересчитываем определитель
					det = abu*acv - abv*acu;
				}
				// Создаём матрицу
				if (uvMatrixBase == null) {
					uvMatrixBase = new Matrix();
					orthoTextureMatrix = new Matrix();
				}
				uvMatrixBase.a = acv / det;
				uvMatrixBase.b = -abv / det;
				uvMatrixBase.c = -acu / det;
				uvMatrixBase.d = abu / det;
				uvMatrixBase.tx = -(uvMatrixBase.a * _aUV.x + uvMatrixBase.c * _aUV.y);
				uvMatrixBase.ty = -(uvMatrixBase.b * _aUV.x + uvMatrixBase.d * _aUV.y);
			} else {
				// Удаляем UV-матрицу
				uvMatrixBase = null;
				orthoTextureMatrix = null;
			}
		}

		/**
		 * @private
		 * Расчет UV матрицы грани. 
		 */
		private function calculateUV():void {
			if (uvMatrixBase != null) {
				if (uvMatrix == null) {
					uvMatrix = new Matrix3D();
				}
				var a:Point3D = _vertices[0].globalCoords;
				var b:Point3D = _vertices[1].globalCoords;
				var c:Point3D = _vertices[2].globalCoords;
				var abx:Number = b.x - a.x;
				var aby:Number = b.y - a.y;
				var abz:Number = b.z - a.z;
				var acx:Number = c.x - a.x;
				var acy:Number = c.y - a.y;
				var acz:Number = c.z - a.z;

				uvMatrix.a = abx*uvMatrixBase.a + acx*uvMatrixBase.b;
				uvMatrix.b = abx*uvMatrixBase.c + acx*uvMatrixBase.d;
				uvMatrix.c = globalNormal.x;
				uvMatrix.d = abx*uvMatrixBase.tx + acx*uvMatrixBase.ty + a.x;
				uvMatrix.e = aby*uvMatrixBase.a + acy*uvMatrixBase.b;
				uvMatrix.f = aby*uvMatrixBase.c + acy*uvMatrixBase.d;
				uvMatrix.g = globalNormal.y;
				uvMatrix.h = aby*uvMatrixBase.tx + acy*uvMatrixBase.ty + a.y;
				uvMatrix.i = abz*uvMatrixBase.a + acz*uvMatrixBase.b;
				uvMatrix.j = abz*uvMatrixBase.c + acz*uvMatrixBase.d;
				uvMatrix.k = globalNormal.z;
				uvMatrix.l = abz*uvMatrixBase.tx + acz*uvMatrixBase.ty + a.z;

				// Считаем invert
				var _a:Number = uvMatrix.a;
				var _b:Number = uvMatrix.b;
				var _c:Number = uvMatrix.c;
				var _d:Number = uvMatrix.d;
				var _e:Number = uvMatrix.e;
				var _f:Number = uvMatrix.f;
				var _g:Number = uvMatrix.g;
				var _h:Number = uvMatrix.h;
				var _i:Number = uvMatrix.i;
				var _j:Number = uvMatrix.j;
				var _k:Number = uvMatrix.k;
				var _l:Number = uvMatrix.l;

				var det:Number = -_c*_f*_i + _b*_g*_i + _c*_e*_j - _a*_g*_j - _b*_e*_k + _a*_f*_k;
				if (det != 0) {
					uvMatrix.a = (-_g*_j + _f*_k)/det;
					uvMatrix.b = (_c*_j - _b*_k)/det;
					uvMatrix.c = (-_c*_f + _b*_g)/det;
					uvMatrix.d = (_d*_g*_j - _c*_h*_j - _d*_f*_k + _b*_h*_k + _c*_f*_l - _b*_g*_l)/det;
					uvMatrix.e = (_g*_i - _e*_k)/det;
					uvMatrix.f = (-_c*_i + _a*_k)/det;
					uvMatrix.g = (_c*_e - _a*_g)/det;
					uvMatrix.h = (_c*_h*_i - _d*_g*_i + _d*_e*_k - _a*_h*_k - _c*_e*_l + _a*_g*_l)/det;
					uvMatrix.i = (-_f*_i + _e*_j)/det;
					uvMatrix.j = (_b*_i - _a*_j)/det;
					uvMatrix.k = (-_b*_e + _a*_f)/det;
					uvMatrix.l = (_d*_f*_i - _b*_h*_i - _d*_e*_j + _a*_h*_j + _b*_e*_l - _a*_f*_l)/det;
				} else {
					uvMatrix = null;
				}
			} else {
				uvMatrix = null;
			}
		}

		/**
		 * Массив вершин грани, представленных объектами класса <code>alternativa.engine3d.core.Vertex</code>.
		 *
		 * @see Vertex
		 */
		public function get vertices():Array {
			return new Array().concat(_vertices);
		}

		/**
		 * Количество вершин грани.
		 */
		public function get verticesCount():uint {
			return _verticesCount;
		}

		/**
		 * Полигональный объект, которому принадлежит грань.
		 */
		public function get mesh():Mesh {
			return _mesh;
		}

		/**
		 * Поверхность, которой принадлежит грань.
		 */
		public function get surface():Surface {
			return _surface;
		}

		/**
		 * Идентификатор грани в полигональном объекте. В случае, если грань не принадлежит ни одному объекту, идентификатор
		 * имеет значение <code>null</code>.
		 */
		public function get id():Object {
			return (_mesh != null) ? _mesh.getFaceId(this) : null;
		}

		/**
		 * UV-координаты, соответствующие первой вершине грани.
		 */
		public function get aUV():Point {
			return (_aUV != null) ? _aUV.clone() : null;
		}

		/**
		 * UV-координаты, соответствующие второй вершине грани.
		 */
		public function get bUV():Point {
			return (_bUV != null) ? _bUV.clone() : null;
		}

		/**
		 * UV-координаты, соответствующие третьей вершине грани.
		 */
		public function get cUV():Point {
			return (_cUV != null) ? _cUV.clone() : null;
		}

		/**
		 * @private
		 */
		public function set aUV(value:Point):void {
			if (_aUV != null) {
				if (value != null) {
					if (!_aUV.equals(value)) {
						_aUV.x = value.x;
						_aUV.y = value.y;
						if (_mesh != null) {
							_mesh.addOperationToScene(calculateBaseUVOperation);
						}
					}
				} else {
					_aUV = null;
					if (_mesh != null) {
						_mesh.addOperationToScene(calculateBaseUVOperation);
					}
				}
			} else {
				if (value != null) {
					_aUV = value.clone();
					if (_mesh != null) {
						_mesh.addOperationToScene(calculateBaseUVOperation);
					}
				}
			}
		}

		/**
		 * @private
		 */
		public function set bUV(value:Point):void {
			if (_bUV != null) {
				if (value != null) {
					if (!_bUV.equals(value)) {
						_bUV.x = value.x;
						_bUV.y = value.y;
						if (_mesh != null) {
							_mesh.addOperationToScene(calculateBaseUVOperation);
						}
					}
				} else {
					_bUV = null;
					if (_mesh != null) {
						_mesh.addOperationToScene(calculateBaseUVOperation);
					}
				}
			} else {
				if (value != null) {
					_bUV = value.clone();
					if (_mesh != null) {
						_mesh.addOperationToScene(calculateBaseUVOperation);
					}
				}
			}
		}

		/**
		 * @private
		 */
		public function set cUV(value:Point):void {
			if (_cUV != null) {
				if (value != null) {
					if (!_cUV.equals(value)) {
						_cUV.x = value.x;
						_cUV.y = value.y;
						if (_mesh != null) {
							_mesh.addOperationToScene(calculateBaseUVOperation);
						}
					}
				} else {
					_cUV = null;
					if (_mesh != null) {
						_mesh.addOperationToScene(calculateBaseUVOperation);
					}
				}
			} else {
				if (value != null) {
					_cUV = value.clone();
					if (_mesh != null) {
						_mesh.addOperationToScene(calculateBaseUVOperation);
					}
				}
			}
		}

		/**
		 * Нормаль в локальной системе координат.
		 */
		public function get normal():Point3D {
			var res:Point3D = new Point3D();
			var vertex:Vertex = _vertices[0];
			var av:Point3D = vertex.coords;
			vertex = _vertices[1];
			var bv:Point3D = vertex.coords;
			var abx:Number = bv.x - av.x;
			var aby:Number = bv.y - av.y;
			var abz:Number = bv.z - av.z;
			vertex = _vertices[2];
			var cv:Point3D = vertex.coords;
			var acx:Number = cv.x - av.x;
			var acy:Number = cv.y - av.y;
			var acz:Number = cv.z - av.z;
			res.x = acz*aby - acy*abz;
			res.y = acx*abz - acz*abx;
			res.z = acy*abx - acx*aby;
			if (res.x != 0 || res.y != 0 || res.z != 0) {
				var k:Number = Math.sqrt(res.x*res.x + res.y*res.y + res.z*res.z);
				res.x /= k;
				res.y /= k;
				res.z /= k;
			}
			return res;
		}

		/**
		 * Расчёт UV-координат для произвольной точки в системе координат объекта, которому принадлежит грань.
		 *
		 * @param point точка в плоскости грани, для которой производится расчёт UV-координат
		 * @return UV-координаты заданной точки
		 */
		public function getUV(point:Point3D):Point {
			return getUVFast(point, normal);
		}

		/**
		 * @private
		 * Расчёт UV-координат для произвольной точки в локальной системе координат без расчёта
		 * локальной нормали грани. Используется для оптимизации.
		 *
		 * @param point точка в плоскости грани, для которой производится расчёт UV-координат
		 * @param normal нормаль плоскости грани в локальной системе координат
		 * @return UV-координаты заданной точки
		 */
		alternativa3d function getUVFast(point:Point3D, normal:Point3D):Point {
			if (_aUV == null || _bUV == null || _cUV == null) {
				return null;
			}

			// Выбор наиболее длинной оси нормали
			var dir:uint;
			if (((normal.x < 0) ? -normal.x : normal.x) > ((normal.y < 0) ? -normal.y : normal.y)) {
				if (((normal.x < 0) ? -normal.x : normal.x) > ((normal.z < 0) ? -normal.z : normal.z)) {
					dir = 0;
				} else {
					dir = 2;
				}
			} else {
				if (((normal.y < 0) ? -normal.y : normal.y) > ((normal.z < 0) ? -normal.z : normal.z)) {
					dir = 1;
				} else {
					dir = 2;
				}
			}

			// Расчёт соотношения по векторам AB и AC
			var v:Vertex = _vertices[0];
			var a:Point3D = v._coords;
			v = _vertices[1];
			var b:Point3D = v._coords;
			v = _vertices[2];
			var c:Point3D = v._coords;

			var ab1:Number = (dir == 0) ? (b.y - a.y) : (b.x - a.x);
			var ab2:Number = (dir == 2) ? (b.y - a.y) : (b.z - a.z);
			var ac1:Number = (dir == 0) ? (c.y - a.y) : (c.x - a.x);
			var ac2:Number = (dir == 2) ? (c.y - a.y) : (c.z - a.z);
			var det:Number = ab1*ac2 - ac1*ab2;
				
			var ad1:Number = (dir == 0) ? (point.y - a.y) : (point.x - a.x);
			var ad2:Number = (dir == 2) ? (point.y - a.y) : (point.z - a.z);
			var abk:Number = (ad1*ac2 - ac1*ad2)/det;
			var ack:Number = (ab1*ad2 - ad1*ab2)/det;
			
			// Интерполяция по UV первых точек
			var abu:Number = _bUV.x - _aUV.x;
			var abv:Number = _bUV.y - _aUV.y;
			var acu:Number = _cUV.x - _aUV.x;
			var acv:Number = _cUV.y - _aUV.y;
							
			return new Point(_aUV.x + abu*abk + acu*ack, _aUV.y + abv*abk + acv*ack);
		}

		/**
		 * Множество граней, имеющих общие рёбра с текущей гранью.
		 */
		public function get edgeJoinedFaces():Set {
			var res:Set = new Set(true);
			// Перебираем точки грани
			for (var i:uint = 0; i < _verticesCount; i++) {
				var a:Vertex = _vertices[i];
				var b:Vertex = _vertices[(i < _verticesCount - 1) ? (i + 1) : 0];

				// Перебираем грани текущей точки
				for (var key:* in a._faces) {
					var face:Face = key;
					// Если это другая грань и у неё также есть следующая точка
					if (face != this && face._vertices.indexOf(b) >= 0) {
						// Значит у граней общее ребро
						res[face] = true;
					}
				}
			}
			return res;
		}

		/**
		 * @private
		 * Удаление всех вершин из грани.
		 * Очистка базового примитива.
		 */
		alternativa3d function removeVertices():void {
			// Удалить вершины
			for (var i:uint = 0; i < _verticesCount; i++) {
				// Удаляем из списка
				var vertex:Vertex = _vertices.pop();
				// Удаляем вершину из грани
				vertex.removeFromFace(this);
			}
			// Очищаем вершины в примитиве
			primitive.points.length = 0;
			// Обнуляем количество вершин
			_verticesCount = 0;
		}

		/**
		 * @private
		 * Добавление грани на сцену
		 * @param scene
		 */
		alternativa3d function addToScene(scene:Scene3D):void {
			// При добавлении на сцену рассчитываем плоскость и UV
			scene.addOperation(calculateNormalOperation);
			scene.addOperation(calculateBaseUVOperation);

			// Подписываем сцену на операции
			updatePrimitiveOperation.addSequel(scene.calculateBSPOperation);
			updateMaterialOperation.addSequel(scene.changePrimitivesOperation);
		}

		/**
		 * @private
		 * Удаление грани из сцены
		 * @param scene
		 */
		alternativa3d function removeFromScene(scene:Scene3D):void {
			// Удаляем все операции из очереди
			scene.removeOperation(calculateBaseUVOperation);
			scene.removeOperation(calculateNormalOperation);
			scene.removeOperation(updatePrimitiveOperation);
			scene.removeOperation(updateMaterialOperation);

			// Удаляем примитивы из сцены
			removePrimitive(primitive);

			// Посылаем операцию сцены на расчёт BSP
			scene.addOperation(scene.calculateBSPOperation);

			// Отписываем сцену от операций
			updatePrimitiveOperation.removeSequel(scene.calculateBSPOperation);
			updateMaterialOperation.removeSequel(scene.changePrimitivesOperation);
		}

		/**
		 * @private
		 * Добавление грани в меш
		 * @param mesh
		 */
		alternativa3d function addToMesh(mesh:Mesh):void {
			// Подписка на операции меша
			mesh.changeCoordsOperation.addSequel(updatePrimitiveOperation);
			// При перемещении меша, пересчитать UV. При вращении вызовется calculateNormal и UV пересчитаются.
			mesh.changeCoordsOperation.addSequel(calculateUVOperation);
			mesh.changeRotationOrScaleOperation.addSequel(calculateNormalOperation);
			mesh.calculateMobilityOperation.addSequel(updatePrimitiveOperation);
			// Сохранить меш
			_mesh = mesh;
		}

		/**
		 * @private
		 * Удаление грани из меша
		 * @param mesh
		 */
		alternativa3d function removeFromMesh(mesh:Mesh):void {
			// Отписка от операций меша
			mesh.changeCoordsOperation.removeSequel(updatePrimitiveOperation);
			mesh.changeCoordsOperation.removeSequel(calculateUVOperation);
			mesh.changeRotationOrScaleOperation.removeSequel(calculateNormalOperation);
			mesh.calculateMobilityOperation.removeSequel(updatePrimitiveOperation);
			// Удалить ссылку на меш
			_mesh = null;
		}

		/**
		 * @private
		 * Добавление к поверхности
		 *
		 * @param surface
		 */
		alternativa3d function addToSurface(surface:Surface):void {
			// Подписка поверхности на операции
			surface.changeMaterialOperation.addSequel(updateMaterialOperation);
			// Если при смене поверхности изменился материал
			if (_mesh != null && (_surface != null && _surface._material != surface._material || _surface == null && surface._material != null)) {
				// Отправляем сигнал смены материала
				_mesh.addOperationToScene(updateMaterialOperation);
			}
			// Сохранить поверхность
			_surface = surface;
		}

		/**
		 * @private
		 * Удаление из поверхности
		 *
		 * @param surface
		 */
		alternativa3d function removeFromSurface(surface:Surface):void {
			// Отписка поверхности от операций
			surface.changeMaterialOperation.removeSequel(updateMaterialOperation);
			// Если был материал
			if (surface._material != null) {
				// Отправляем сигнал смены материала
				_mesh.addOperationToScene(updateMaterialOperation);
			}
			// Удалить ссылку на поверхность
			_surface = null;
		}

		/**
		 * Строковое представление объекта.
		 *
		 * @return строковое представление объекта
		 */
		public function toString():String {
			var res:String = "[Face ID:" + id + ((_verticesCount > 0) ? " vertices:" : "");
			for (var i:uint = 0; i < _verticesCount; i++) {
				var vertex:Vertex = _vertices[i];
				res += vertex.id + ((i < _verticesCount - 1) ? ", " : "");
			}
			res += "]";
			return res;
		}

		/**
		 * Добавление обработчика события.
		 *
		 * @param type тип события
		 * @param listener обработчик события
		 * @param useCapture не используется,
		 * @param priority приоритет обработчика. Обработчики с большим приоритетом выполняются раньше. Обработчики с одинаковым приоритетом
		 *   выполняются в порядке их добавления.
		 * @param useWeakReference флаг использования слабой ссылки для обработчика
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			if (dispatcher == null) {
				dispatcher = new EventDispatcher(this);
			}
			useCapture = false;
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		/**
		 * Рассылка события.
		 *
		 * @param event посылаемое событие
		 * @return false
		 */
		public function dispatchEvent(event:Event):Boolean {
			if (dispatcher != null) {
				dispatcher.dispatchEvent(event);
			}
			return false;
		}

		/**
		 * Проверка наличия зарегистрированных обработчиков события указанного типа.
		 *
		 * @param type тип события
		 * @return <code>true</code> если есть обработчики события указанного типа, иначе <code>false</code>
		 */
		public function hasEventListener(type:String):Boolean {
			if (dispatcher != null) {
				return dispatcher.hasEventListener(type);
			}
			return false;
		}

		/**
		 * Удаление обработчика события.
		 *
		 * @param type тип события
		 * @param listener обработчик события
		 * @param useCapture не используется
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			if (dispatcher != null) {
				useCapture = false;
				dispatcher.removeEventListener(type, listener, useCapture);
			}
		}

		/**
		 *
		 */
		public function willTrigger(type:String):Boolean {
			if (dispatcher != null) {
				return dispatcher.willTrigger(type);
			}
			return false;
		}

	}
}
