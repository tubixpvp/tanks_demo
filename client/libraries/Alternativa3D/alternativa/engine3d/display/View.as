package alternativa.engine3d.display {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Sprite3D;
	import alternativa.engine3d.core.SpritePrimitive;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.events.MouseEvent3D;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	use namespace alternativa3d;
	
	/**
	 * Вьюпорт для вывода изображения с камеры.
	 */
	public class View extends Sprite {
		
		/**
		 * @private
		 * Область отрисовки спрайтов
		 */		
		alternativa3d var canvas:Sprite;
		
		private var _camera:Camera3D;
		
		/**
		 * @private
		 * Ширина области вывода
		 */		
		alternativa3d var _width:Number;
		/**
		 * @private
		 * Высота области вывода
		 */		
		alternativa3d var _height:Number;
		
		/**
		 * @private
		 * Флаг интерактивности вьюпорта. В интерактивном режиме вьюпорт принимает события мыши и транслирует их
		 * в подсистему трёхмерных событий, которая, в свою очередь, преобразует двумерный клик в трёхмерный и рассылает
		 * события всем подписчикам.
		 */
		alternativa3d var _interactive:Boolean;

		// Грань под курсором
		private var faceUnderPoint:Face;
		private var objectUnderPoint:Object3D;

		private var lastMouseEvent:MouseEvent;
		private var stagePoint:Point = new Point();

		// Текущая грань
		private var currentFace:Face;
		// Текущая поверхность
		private var currentSurface:Surface;
		// Текущий объект
		private var currentObject:Object3D;
		// Грань, на которой было событие MOUSE_DOWN
		private var pressedFace:Face;
		// Поверхность, на которой было событие MOUSE_DOWN
		private var pressedSurface:Surface;
		// Объект, на котором было событие MOUSE_DOWN
		private var pressedObject:Object3D;

		// Направляющий вектор проецирующей прямой в камере 
		private var lineVector:Point3D = new Point3D();
		// Вспомогательная переменная для хранения точки проецирующей прямой в ортографической камере 
		private var linePoint:Point3D = new Point3D();
		// Точка на объекте под курсором в глобальной системе координат. 
		private var globalCursor3DCoords:Point3D = new Point3D();
		// Координаты курсора в системе координат объекта
		private var localCursor3DCoords:Point3D = new Point3D();
		// UV-координаты в грани под курсором
		private var uvPoint:Point = new Point();
		// Вспомогательная матрица
		private var inverseMatrix:Matrix3D = new Matrix3D();
		
		/**
		 * Создаёт новый экземпляр вьюпорта.
		 * 
		 * @param camera камера, связанная с вьюпортом 
		 * @param width ширина вьюпорта
		 * @param height высота вьюпорта
		 */
		public function View(camera:Camera3D = null, width:Number = 0, height:Number = 0) {
			canvas = new Sprite();
			canvas.mouseEnabled = false;
			canvas.mouseChildren = false;
			canvas.tabEnabled = false;
			canvas.tabChildren = false;
			addChild(canvas);
			
			this.camera = camera;
			this.width = width;
			this.height = height;
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}

		/**
		 * Камера, с которой выводится изображение. 
		 */
		public function get camera():Camera3D {
			return _camera;
		}

		/**
		 * @private
		 */
		public function set camera(value:Camera3D):void {
			if (_camera != value) {
				// Если была камера
				if (_camera != null) {
					// Удалить камеру
					_camera.removeFromView(this);
				}
				// Если новая камера
				if (value != null) {
					// Если камера была в другом вьюпорте
					if (value._view != null) {
						// Удалить её оттуда
						value._view.camera = null;
					}
					// Добавить камеру
					value.addToView(this);
				} else {
					// Зачистка скинов
					if (canvas.numChildren > 0) {
						var skin:Skin = Skin(canvas.getChildAt(0));
						while (skin != null) {
							// Сохраняем следующий
							var next:Skin = skin.nextSkin;
							// Удаляем из канваса
							canvas.removeChild(skin);
							// Очистка скина
							if (skin.material != null) {
								skin.material.clear(skin);
							}
							// Зачищаем ссылки
							skin.nextSkin = null;
							skin.primitive = null;
							skin.material = null;
							// Удаляем
							Skin.destroySkin(skin);
							// Следующий устанавливаем текущим
							skin = next;
						}
					}
				}
				// Сохраняем камеру
				_camera = value;
			}
		}
		
		/**
		 * Ширина вьюпорта в пикселях.
		 */
		override public function get width():Number {
			return _width;
		}

		/**
		 * @private
		 */
		override public function set width(value:Number):void {
			if (_width != value) {
				_width = value;
				canvas.x = _width*0.5;
				if (_camera != null) {
					camera.addOperationToScene(camera.calculatePlanesOperation);
				}
			}
		}

		/**
		 * Высота вьюпорта в пикселях.
		 */
		override public function get height():Number {
			return _height;
		}

		/**
		 * @private
		 */
		override public function set height(value:Number):void {
			if (_height != value) {
				_height = value;
				canvas.y = _height*0.5;
				if (_camera != null) {
					camera.addOperationToScene(camera.calculatePlanesOperation);
				}
			}
		}
		
		/**
		 * Возвращает объект, находящийся под указанной точкой вьюпорта.
		 * 
		 * @param viewPoint координаты точки относительно вьюпорта. Верхнему левому углу соотвествуют координаты (0, 0).
		 * 
		 * @return ближайший к камере объект под заданной точкой вьюпорта, либо <code>null</code>,
		 *  если под указанной точкой нет объектов или вьюпорт не помещён на Stage.
		 * Объект может быть гранью (Face) или спрайтом (Sprite3D).
		 */
		public function getObjectUnderPoint(viewPoint:Point):Object {
			if (stage == null) {
				return null;
			}
			var stagePoint:Point = localToGlobal(viewPoint);
			var objects:Array = stage.getObjectsUnderPoint(stagePoint);
			var skin:Skin;
			for (var i:int = objects.length - 1; i >= 0; i--) {
				skin = objects[i] as Skin;
				if (skin != null && skin.parent.parent == this) {
					return skin.primitive.face != null ? skin.primitive.face : (skin.primitive as SpritePrimitive).sprite;
				}
			}
			return null;
		}

		/**
		 * Возвращает объекты, находящиеся под указанной точкой вьюпорта.
		 * 
		 * @param viewPoint координаты точки относительно вьюпорта. Верхнему левому углу соотвествуют координаты (0, 0).
		 * 
		 * @return массив объектов, расположенных под заданной точкой вьюпорта. Первым элементом массива является самый дальний объект.
		 *   Объектами могут быть грани (Face) или спрайты (Sprite3D). Если под указанной точкой нет ни одного объекта, массив будет пустым. 
		 *   Если вьюпорт не помещен на Stage, возвращается <code>null</code>. 
		 */
		override public function getObjectsUnderPoint(viewPoint:Point):Array {
			if (stage == null) {
				return null;
			}
			var stagePoint:Point = localToGlobal(viewPoint);
			var objects:Array = stage.getObjectsUnderPoint(stagePoint);
			var res:Array = new Array();
			var length:uint = objects.length;
			for (var i:uint = 0; i < length; i++) {
				var skin:Skin = objects[i] as Skin;
				if (skin != null && skin.parent.parent == this) {
					if (skin.primitive.face != null) {
						res.push(skin.primitive.face);
					} else {
						res.push((skin.primitive as SpritePrimitive).sprite);
					}
				}
			}
			return res;
		}

		/**
		 * Проецирует заданную глобальными координатами точку на плоскость вьюпорта.
		 * 
		 * @param point глобальные координаты проецируемой точки
		 * 
		 * @return объект <code>Point3D</code>, содержащий координаты проекции точки относительно левого верхнего угла вьюпорта и z-координату
		 *   точки в системе координат камеры. Если вьюпорту не назначена камера или камера не находится в сцене, возвращается <code>null</code>.
		 */
		public function projectPoint(point:Point3D):Point3D {
			if (_camera == null || _camera._scene == null) {
				return null;
			}

			var cameraMatrix:Matrix3D = Object3D.matrix2;
			var focalLength:Number = _camera._focalLength;;
			var zoom:Number;

			// Вычисление матрицы трансформации камеры
			if (_camera.getTransformation(cameraMatrix)) {
				// Матрица была пересчитана заново
				cameraMatrix.invert();
				if (_camera._orthographic) {
					// Учёт масштабирования в ортографической камере
					zoom = _camera.zoom;
					cameraMatrix.scale(zoom, zoom, zoom);
				}
			} else {
				// Пересчёта не потребовалось, проверяем изменение зума
				if (_camera._orthographic && _camera.calculateMatrixOperation.queued) {
					cameraMatrix.invert();
					zoom = _camera.zoom;
					cameraMatrix.scale(zoom, zoom, zoom);
				} else {
					// Зум не менялся или перспективный режим, просто копируем обратную матрицу
					cameraMatrix = _camera.cameraMatrix;
				}
			}
			// Расчёт фокусного расстояния
			if (!_camera._orthographic && _camera.calculatePlanesOperation.queued) {
				focalLength = 0.5 * Math.sqrt(_height * _height + _width * _width) / Math.tan(0.5 * _camera._fov);
			}
			// Координаты точки в системе координат камеры
			var x:Number = cameraMatrix.a * point.x + cameraMatrix.b * point.y + cameraMatrix.c * point.z + cameraMatrix.d;
			var y:Number = cameraMatrix.e * point.x + cameraMatrix.f * point.y + cameraMatrix.g * point.z + cameraMatrix.h;
			var z:Number = cameraMatrix.i * point.x + cameraMatrix.j * point.y + cameraMatrix.k * point.z + cameraMatrix.l;
			// Проекция точки на вьюпорт
			if (_camera._orthographic) {
				return new Point3D(x + (_width >> 1), y + (_height >> 1), z);
			} else {
				return new Point3D(x * focalLength / z + (_width >> 1), y * focalLength / z + (_height >> 1), z);
			}
		}

		/**
		 * Интерактивность области вьюпорта. При включённой интерактивности возможно использование системы мышиных событий.
		 * 
		 * @default false
		 */		
		public function get interactive():Boolean {
			return _interactive;
		}
		
		/**
		 * @private
		 */
		public function set interactive(value:Boolean):void {
			if (_interactive == value) {
				return;
			}
			_interactive = value;
			
			if (_interactive) {
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
				addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
				addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent);
				addEventListener(MouseEvent.MOUSE_WHEEL, onMouseEvent);
				addEventListener(MouseEvent.MOUSE_OUT, onMouseEvent);
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
				removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
				removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent);
				removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseEvent);
				removeEventListener(MouseEvent.MOUSE_OUT, onMouseEvent);
				if (stage != null) {
					stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
				}
				pressedFace = currentFace = null;
				pressedSurface = currentSurface = null;
				pressedObject = currentObject = null;
			}
		}

		/**
		 * Проецирует двумерную точку во вьюпорте на заданную плоскость в трёхмерном пространстве.
		 * 
		 * @param viewPoint координаты точки во вьюпорте. Верхнему левому углу соответствуют координаты (0, 0).
		 * @param planeNormal нормаль плоскости в глобальной системе координат, на которую проецируется точка
		 * @param planeOffset смещение плоскости в глобальной системе координат, на которую проецируется точка
		 * @param result результат проецирования будет записан в этот параметр. Если в качестве значения будет указано <code>null</code>, метод
		 *   создаст новый экземпляр <code>Point3D</code> и вернёт результат в нём.
		 * @return переданный в параметре result экземпляр <code>Point3D</code> или новый экземпляр, если значение result равно <code>null</code>. Если возможно бесконечное
		 *   количество решений (линия зрения параллельна заданной плоскости), то результат содержит значения NaN.
		 * Если вьюпорту не назначена камера или камера не находится в сцене, возвращается <code>null</code>. 
		 */
		public function projectViewPointToPlane(viewPoint:Point, planeNormal:Point3D, planeOffset:Number, result:Point3D = null):Point3D {
			if (_camera == null || _camera._scene == null) {
				return null;
			}
			if (result == null) {
				result = new Point3D();
			}
			calculateRayOriginAndVector(viewPoint.x - (_width >> 1), viewPoint.y - (_height >> 1), linePoint, lineVector, true);
			if (!calculateLineAndPlaneIntersection(linePoint, lineVector, planeNormal, planeOffset, result)) {
				result.reset(NaN, NaN, NaN);
			}
			return result;
		}

		/**
		 * Вычисляет координаты точки в системе координат камеры, связанной с вьюпортом. Если камера в режиме перспективной
		 * проекции, то метод вычислит координаты точки, лежащей на прямой, проходящей через начало координат камеры и указанную точку
		 * вьюпорта. Если камера в режиме ортографической проекции, то метод вычислит координаты точки, лежащей на прямой,
		 * перпендикулярной фокальной плоскости камеры и проходящей через указанную точку вьюпорта.
		 * 
		 * @param viewPoint координаты точки во вьюпорте. Верхнему левому углу соответствуют координаты (0, 0).
		 * @param depth глубина точки в камере &mdash; координата Z в системе координат камеры
		 * @param result результат будет записан в этот параметр. Если в качестве значения будет указано <code>null</code>, метод
		 *   создаст новый экземпляр <code>Point3D</code> и вернёт результат в нём.
		 * @return координаты точки в системе координат камеры или <code>null</code>, если с вьюпортом не связана камера
		 */
		public function get3DCoords(viewPoint:Point, depth:Number, result:Point3D = null):Point3D {
			if (_camera == null) {
				return null;
			}
			if (result == null) {
				result = new Point3D();
			}
			if (_camera._orthographic) {
				result.x = (viewPoint.x - (_width >> 1))/camera._zoom;
				result.y = (viewPoint.y - (_height >> 1))/camera._zoom;
			} else {
				var k:Number = depth/_camera.focalLength;
				result.x = (viewPoint.x - (_width >> 1))*k;
				result.y = (viewPoint.y - (_height >> 1))*k;
			}
			result.z = depth;
			return result;
		}
		
		/**
		 * 
		 */
		private function onRemovedFromStage(e:Event):void {
			interactive = false;
		}

		/**
		 * Сброс нажатых объектов при отпускании кнопки мыши вне вьюпорта. 
		 */
		private function stageMouseUp(e:MouseEvent):void {
			if (stage == null) {
				return;
			}
			pressedFace = null;
			pressedSurface = null;
			pressedObject = null;
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
		}

		/**
		 * Метод находит интерактивный объект (Object3D) и интерактивную грань, если возможно, находящиеся под указанной точкой в области вывода.
		 * 
		 * @param pointX X-координата точки относительно области вывода
		 * @param pointY Y-координата точки относительно области вывода
		 */
		private function getInteractiveObjectUnderPoint(pointX:Number, pointY:Number):void {
			if (stage == null) {
				return;
			}
			faceUnderPoint = null;
			objectUnderPoint = null;
			stagePoint.x = pointX;
			stagePoint.y = pointY;
			var objects:Array = stage.getObjectsUnderPoint(stagePoint);
			var skin:Skin;
			for (var i:int = objects.length - 1; i >= 0; i--) {
				skin = objects[i] as Skin;
				if (skin != null && skin.parent.parent == this) {
					if (skin.primitive.face != null) {
						// Скин, содержащий PolyPrimitive
						if (skin.primitive.face._mesh.mouseEnabled) {
							faceUnderPoint = skin.primitive.face;
							objectUnderPoint = faceUnderPoint._mesh;
							return;
						}
					} else {
						// Скин, содержащий SpritePrimitive
						var sprite:Sprite3D = (skin.primitive as SpritePrimitive).sprite;
						if (sprite.mouseEnabled) {
							objectUnderPoint = sprite;
							return;
						}
					}
				}
			}
		}
		
		/**
		 * Вычисление свойств точки объекта, находящегося под указанной точкой фокусной плоскости камеры. Метод расчитывает глобальные и локальные
		 * 3D-координаты точки, а также её UV-координаты.
		 * 
		 * @param canvasX
		 * @param canvasY
		 */
		private function getInteractiveObjectPointProperties(canvasX:Number, canvasY:Number):void {
			if (objectUnderPoint == null) {
				return;
			}
			calculateRayOriginAndVector(canvasX, canvasY, linePoint, lineVector);
			// Вычисление глобальных координат точки пересечения проецирующей прямой и плоскости объекта
			var normal:Point3D;
			var offset:Number;
			if (faceUnderPoint != null) {
				// Работаем с гранью
				normal = faceUnderPoint.globalNormal;
				offset = faceUnderPoint.globalOffset;
			} else {
				// Работаем со спрайтом
				normal = lineVector.clone();
				normal.invert();
				globalCursor3DCoords.copy(objectUnderPoint._coords);
				globalCursor3DCoords.transform(objectUnderPoint._transformation);
				offset = globalCursor3DCoords.dot(normal); 
			}
			calculateLineAndPlaneIntersection(linePoint, lineVector, normal, offset, globalCursor3DCoords);
			// Вычисление локальных координат точки пересечения
			inverseMatrix.copy((faceUnderPoint != null ? faceUnderPoint._mesh : objectUnderPoint)._transformation);
			inverseMatrix.invert();
			localCursor3DCoords.copy(globalCursor3DCoords);
			localCursor3DCoords.transform(inverseMatrix);
			// Вычисление UV-координат
			if (faceUnderPoint != null) {
				var uv:Point = faceUnderPoint.getUV(localCursor3DCoords);
				if (uv != null) {
					uvPoint.x = uv.x;
					uvPoint.y = uv.y;
				} else {
					uvPoint.x = NaN;
					uvPoint.y = NaN;
				}
			}
		}

		/**
		 * 
		 */
		private function createSimpleMouseEvent3D(type:String, object:Object3D, surface:Surface, face:Face):MouseEvent3D {
			var altKey:Boolean = lastMouseEvent == null ? false : lastMouseEvent.altKey;
			var ctrlKey:Boolean = lastMouseEvent == null ? false : lastMouseEvent.ctrlKey;
			var shiftKey:Boolean = lastMouseEvent == null ? false : lastMouseEvent.shiftKey;
			var delta:int = lastMouseEvent == null ? 0 : lastMouseEvent.delta;
			return new MouseEvent3D(type, this, object, surface, face,
				NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN,
				altKey, ctrlKey, shiftKey, delta);
		}

		/**
		 * 
		 */
		private function createFullMouseEvent3D(type:String, object:Object3D, surface:Surface, face:Face):MouseEvent3D {
			var altKey:Boolean = lastMouseEvent == null ? false : lastMouseEvent.altKey;
			var ctrlKey:Boolean = lastMouseEvent == null ? false : lastMouseEvent.ctrlKey;
			var shiftKey:Boolean = lastMouseEvent == null ? false : lastMouseEvent.shiftKey;
			var delta:int = lastMouseEvent == null ? 0 : lastMouseEvent.delta;
			return new MouseEvent3D(type, this, object, surface, face,
				globalCursor3DCoords.x, globalCursor3DCoords.y, globalCursor3DCoords.z, localCursor3DCoords.x, localCursor3DCoords.y, localCursor3DCoords.z, uvPoint.x, uvPoint.y,
				altKey, ctrlKey, shiftKey, delta);
		}
		
		/**
		 * Обработка мышиного события на вьюпорте и передача его в систему трёхмерных событий.
		 */
		private function onMouseEvent(e:MouseEvent):void {
			if (stage == null) {
				return;
			}
			// Сохранение события для использования в функциях создания MouseEvent3D
			lastMouseEvent = e;
			// Получение объекта под курсором и свойств точки на этом объекте
			getInteractiveObjectUnderPoint(stage.mouseX, stage.mouseY);
			getInteractiveObjectPointProperties(mouseX - (_width >> 1), mouseY - (_height >> 1));
			// Обработка события
			switch (e.type) {
				case MouseEvent.MOUSE_MOVE:
					processMouseMove();
					break;
				case MouseEvent.MOUSE_OUT:
					stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
					checkMouseOverOut();
					break;
				case MouseEvent.MOUSE_DOWN:
					processMouseDown();
					break;
				case MouseEvent.MOUSE_UP:
					processMouseUp();
					break;
				case MouseEvent.MOUSE_WHEEL:
					processMouseWheel();
					break;
			}
			lastMouseEvent = null;
		}
		
		/**
		 * Обработка нажатия кнопки мыши во вьюпорте. Генерируются события: MouseEvent3D.MOUSE_DOWN.
		 */
		private function processMouseDown():void {
			if (objectUnderPoint == null) {
				return;
			}
			if (faceUnderPoint != null) {
				currentFace = faceUnderPoint;
				currentSurface = faceUnderPoint._surface;
			} else {
				currentFace = null;
				currentSurface = null;
			}
			currentObject = pressedObject = objectUnderPoint;
			
			var evt:MouseEvent3D;
			if (currentFace != null && currentFace.mouseEnabled) {
				pressedFace = currentFace;
				evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_DOWN, currentObject, currentSurface, currentFace);
				currentFace.dispatchEvent(evt);
			}
			
			if (currentSurface != null && currentSurface.mouseEnabled) {
				pressedSurface = currentSurface;
				evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_DOWN, currentObject, currentSurface, currentFace);
				currentSurface.dispatchEvent(evt);
			}
			
			evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_DOWN, currentObject, currentSurface, currentFace);
			currentObject.dispatchEvent(evt);
		}

		/**
		 * Обработка отжатия кнопки мыши во вьюпорте. Генерируются события: MouseEvent3D.MOUSE_UP, MouseEvent3D.CLICK.
		 */
		private function processMouseUp():void {
			if (objectUnderPoint == null) {
				pressedFace = null;
				pressedSurface = null;
				pressedObject = null;
				return;
			}
			
			if (faceUnderPoint != null) {
				currentFace = faceUnderPoint;
				currentSurface = faceUnderPoint._surface;
			} else {
				currentFace = null;
				currentSurface = null;
			}
			currentObject = objectUnderPoint;
			
			var evt:MouseEvent3D;
			// MouseEvent3D.MOUSE_UP
			if (currentFace != null && currentFace.mouseEnabled) {
				evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_UP, currentObject, currentSurface, currentFace);
				currentFace.dispatchEvent(evt);
			}
			
			if (currentSurface != null && currentSurface.mouseEnabled) {
				evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_UP, currentObject, currentSurface, currentFace);
				currentSurface.dispatchEvent(evt);
			}

			evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_UP, currentObject, currentSurface, currentFace);
			currentObject.dispatchEvent(evt);

			// MouseEvent3D.CLICK
			if (currentFace != null && currentFace == pressedFace && currentFace.mouseEnabled) {
				evt = createFullMouseEvent3D(MouseEvent3D.CLICK, currentObject, currentSurface, currentFace);
				currentFace.dispatchEvent(evt);
			}

			if (currentSurface != null && currentSurface == pressedSurface && currentSurface.mouseEnabled) {
				evt = createFullMouseEvent3D(MouseEvent3D.CLICK, currentObject, currentSurface, currentFace);
				currentSurface.dispatchEvent(evt);
			}
			
			if (currentObject == pressedObject) {
				evt = createFullMouseEvent3D(MouseEvent3D.CLICK, currentObject, currentSurface, currentFace);
				currentObject.dispatchEvent(evt);
			}
			
			pressedFace = null;
			pressedSurface = null;
			pressedObject = null;
		}
		
		/**
		 * Обработка вращения колеса мыши во вьюпорте. Генерируются события: MouseEvent3D.MOUSE_WHEEL.
		 */
		private function processMouseWheel():void {
			if (objectUnderPoint == null) {
				return;
			}
			
			var evt:MouseEvent3D;
			if (faceUnderPoint != null) {
				currentFace = faceUnderPoint;
				currentSurface = faceUnderPoint._surface;

				if (currentFace.mouseEnabled) {
					evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_WHEEL, currentObject, currentSurface, currentFace);
					currentFace.dispatchEvent(evt);
				}
				
				if (currentSurface.mouseEnabled) {
					evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_WHEEL, currentObject, currentSurface, currentFace);
					currentSurface.dispatchEvent(evt);
				}
			} else {
				currentFace = null;
				currentSurface = null;
			}
			currentObject = objectUnderPoint;
			evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_WHEEL, currentObject, currentSurface, currentFace);
			currentObject.dispatchEvent(evt);
		}
		
		/**
		 * @private
		 * Метод проверяет наличиче событий MOUSE_OVER, MOUSE_OUT для объектов сцены, их поверхностей и граней.
		 * 
		 * @param checkObject флаг необходимости предварительно получить объект под курсором. Используется при вызове метода из функции отрисовки камеры.
		 */
		alternativa3d function checkMouseOverOut(checkObject:Boolean = false):void {
			if (stage == null) {
				return;
			}
			if (checkObject) {
				getInteractiveObjectUnderPoint(stage.mouseX, stage.mouseY);
				getInteractiveObjectPointProperties(mouseX - (_width >> 1), mouseY - (_height >> 1));
			}
			var evt:MouseEvent3D;
			if (objectUnderPoint == null) {
				// Мышь ушла с объекта, генерируются события MOUSE_OUT
				if (currentFace != null) {
					// MOUSE_OUT для грани
					if (currentFace.mouseEnabled) {
						evt = createSimpleMouseEvent3D(MouseEvent3D.MOUSE_OUT, currentObject, currentSurface, currentFace);
						currentFace.dispatchEvent(evt);
					}
					// MOUSE_OUT для поверхности
					if (currentSurface.mouseEnabled) {
						evt = createSimpleMouseEvent3D(MouseEvent3D.MOUSE_OUT, currentObject, currentSurface, currentFace);
						currentSurface.dispatchEvent(evt);
					}
				}

				if (currentObject != null) {
					// MOUSE_OUT для объекта
					evt = createSimpleMouseEvent3D(MouseEvent3D.MOUSE_OUT, currentObject, currentSurface, currentFace);
					currentObject.dispatchEvent(evt);
				}

				currentFace = null;
				currentSurface = null;
				currentObject = null;
			} else {
				// Мышь на каком-то объекте
				var surface:Surface;
				var faceChanged:Boolean;
				var surfaceChanged:Boolean;
				var objectChanged:Boolean;

				if (faceUnderPoint != null) {
					surface = faceUnderPoint._surface;
				}
				// 
				if (faceUnderPoint != currentFace) {
					// MOUSE_OUT для грани
					if (currentFace != null && currentFace.mouseEnabled) {
						evt = createSimpleMouseEvent3D(MouseEvent3D.MOUSE_OUT, currentObject, currentSurface, currentFace);
						currentFace.dispatchEvent(evt);
					}
					faceChanged = true;
					// MOUSE_OUT для поверхности
					if (surface != currentSurface) {
						if (currentSurface != null && currentSurface.mouseEnabled) {
							evt = createSimpleMouseEvent3D(MouseEvent3D.MOUSE_OUT, currentObject, currentSurface, currentFace);
							currentSurface.dispatchEvent(evt);
						}
						surfaceChanged = true;
					}
				}
				// MOUSE_OUT для объекта
				if (objectUnderPoint != currentObject) {
					if (currentObject != null) {
						evt = createSimpleMouseEvent3D(MouseEvent3D.MOUSE_OUT, currentObject, currentSurface, currentFace);
						currentObject.dispatchEvent(evt);
					}
					objectChanged = true;
				}
				
				currentFace = faceUnderPoint;
				currentSurface = surface;
				currentObject = objectUnderPoint;
				if (currentFace != null) {
					// MOUSE_OVER для грани
					if (faceChanged && currentFace.mouseEnabled) {
						evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_OVER, currentObject, currentSurface, currentFace);
						currentFace.dispatchEvent(evt);
					}
					// MOUSE_OVER для поверхности
					if (surfaceChanged && currentSurface.mouseEnabled) {
						evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_OVER, currentObject, currentSurface, currentFace);
						currentSurface.dispatchEvent(evt);
					}
				}
				// MOUSE_OVER для объекта
				if (objectChanged) {
					evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_OVER, currentObject, currentSurface, currentFace);
					currentObject.dispatchEvent(evt);
				}
			}
		}

		/**
		 * Обработчик движения мыши.
		 */
		private function processMouseMove():void {
			// Запуск проверки на наличие событий MOUSE_OVER и MOUSE_OUT
			checkMouseOverOut();
			// Генерация событий MOUSE_MOVE
			var evt:MouseEvent3D;
			if (currentFace != null) {
				// Мышь на каком-то объекте
				if (currentFace.mouseEnabled) {
					evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_MOVE, currentObject, currentSurface, currentFace);
					currentFace.dispatchEvent(evt);
				}

				if (currentSurface.mouseEnabled) {
					evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_MOVE, currentObject, currentSurface, currentFace);
					currentSurface.dispatchEvent(evt);
				}
			}
			
			if (currentObject != null) {
				evt = createFullMouseEvent3D(MouseEvent3D.MOUSE_MOVE, currentObject, currentSurface, currentFace);
				currentObject.dispatchEvent(evt);
			}
		}

		/**
		 * @private
		 * Вычисляет точку пересечения прямой и плоскости.
		 * 
		 * @param linePoint точка, лежащая на прямой
		 * @param lineVector направляющий вектор прямой
		 * @param planeNormal нормаль плоскости
		 * @param planeOffset смещение плоскости
		 * @param result переменная для сохранения координат точки пересечения
		 * 
		 * @return <code>true</code> если прямая и плоскость пересекаются, иначе <code>false</code>
		 */		
		private function calculateLineAndPlaneIntersection(linePoint:Point3D, lineVector:Point3D, planeNormal:Point3D, planeOffset:Number, result:Point3D):Boolean {
			var dot:Number = planeNormal.x*lineVector.x + planeNormal.y*lineVector.y + planeNormal.z*lineVector.z;
			if (dot < 1E-8 && dot > -1E-8) {
				// Прямая и плосоксть параллельны
				return false;
			}
			var k:Number = (planeOffset - linePoint.x*planeNormal.x - linePoint.y*planeNormal.y - linePoint.z*planeNormal.z)/dot;
			result.x = linePoint.x + k*lineVector.x;
			result.y = linePoint.y + k*lineVector.y;
			result.z = linePoint.z + k*lineVector.z;
			return true;
		}

		/**
		 * Вычисляет точку и направляющий вектор для луча зрения, проходящего через заданную точку вьюпорта.
		 * 
		 * @param rayOrigin сюда будут записаны глобальные координаты начальной точки луча
		 * @param rayVector сюда будут записаны глобальные координаты направляющего вектора
		 * @param calculate определяет необходимо ли вычислять актуальные значения объекта при вызове метода
		 */
		private function calculateRayOriginAndVector(canvasX:Number, canvasY:Number, rayOrigin:Point3D, rayVector:Point3D, calculate:Boolean = false):void {
			var x:Number;
			var y:Number;
			var z:Number;
			// Вычисление направляющего вектора и точки проецирующей прямой в глобальном пространстве
			// Вычисление матрицы трансформации камеры
			var m:Matrix3D;
			if (calculate) {
				m = Object3D.matrix2;
				_camera.getTransformation(m);
			} else {
				m = _camera._transformation;
			}
			if (_camera._orthographic) {
				// Координаты точки на луче
				x = canvasX/_camera.zoom;
				y = canvasY/_camera.zoom;
				rayOrigin.x = m.a*x + m.b*y + m.d;
				rayOrigin.y = m.e*x + m.f*y + m.h;
				rayOrigin.z = m.i*x + m.j*y + m.l;
				// Координаты локального направляющего вектора 
				x = y = 0;
				z = 1;
			} else {
				// Координаты точки на луче
				rayOrigin.x = m.d;
				rayOrigin.y = m.h;
				rayOrigin.z = m.l;
				// Координаты локального направляющего вектора 
				x = canvasX;
				y = canvasY;
				if (calculate) {
					z = _camera.focalLength;
				} else {
					z = _camera._focalLength;
				}
			}
			// Направляющий вектор в глобальном пространстве
			lineVector.x = x*m.a + y*m.b + z*m.c;
			lineVector.y = x*m.e + y*m.f + z*m.g;
			lineVector.z = x*m.i + y*m.j + z*m.k;
		}

	}
}
