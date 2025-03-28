package alternativa.engine3d.physics {

	import alternativa.engine3d.*;
	import alternativa.engine3d.core.BSPNode;
	import alternativa.engine3d.core.PolyPrimitive;
	import alternativa.engine3d.core.Scene3D;
	import alternativa.engine3d.core.SplitterPrimitive;
	import alternativa.types.Point3D;
	import alternativa.types.Set;
	import alternativa.utils.ObjectUtils;
	
	use namespace alternativa3d;
	
	/**
	 * Класс реализует алгоритм непрерывного определения столкновений эллипсоида с плоскими выпуклыми многоугольниками.
	 */
	public class EllipsoidCollider {
		
		// Максимальное количество попыток найти свободное от столкновения со сценой направление   
		private static const MAX_COLLISIONS:uint = 50;
		// Радиус наибольшей сферы
		private var _radius:Number = 100;
		private var _radius2:Number = _radius * _radius;
		private var _radiusX:Number = _radius;
		private var _radiusY:Number = _radius;
		private var _radiusZ:Number = _radius;
		private var _radiusX2:Number = _radiusX * _radiusX;
		private var _radiusY2:Number = _radiusY * _radiusY;
		private var _radiusZ2:Number = _radiusZ * _radiusZ;
		// Коэффициенты масштабирования осей
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _scaleZ:Number = 1;
		// Квадраты коэффициентов масштабирования осей
		private var _scaleX2:Number = 1;
		private var _scaleY2:Number = 1;
		private var _scaleZ2:Number = 1;

		private var collisionSource:Point3D;
		private var currentDisplacement:Point3D = new Point3D();
		private var collisionDestination:Point3D = new Point3D();
		
		private var collisionPlanes:Array = new Array();
		private var collisionPrimitive:PolyPrimitive;
		private var collisionPrimitiveNearest:PolyPrimitive;
		private var collisionPlanePoint:Point3D = new Point3D();
		private var collisionPrimitiveNearestLengthSqr:Number;
		private var collisionPrimitivePoint:Point3D = new Point3D();
		
		private var collisionNormal:Point3D = new Point3D();
		private var collisionPoint:Point3D = new Point3D();
		private var collisionOffset:Number;

		private var currentCoords:Point3D = new Point3D();
		private var collision:Collision = new Collision();
		private var collisionRadius:Number;
		private var radiusVector:Point3D = new Point3D();
		private var p1:Point3D = new Point3D();
		private var p2:Point3D = new Point3D();;
		private var localCollisionPlanePoint:Point3D = new Point3D();

		// Флаг использования упорщённого алгоритма. Включается когда эллипсоид представляет собой сферу.
		private var useSimpleAlgorithm:Boolean = true;

		/**
		 * Сцена, в которой определяются столкновения. 
		 */
		public var scene:Scene3D;
		/**
		 * Погрешность определения расстояний и координат. Две точки совпадают, если модуль разности любых соответствующих
		 * координат меньше указанной погрешности.
		 */
		public var offsetThreshold:Number = 0.0001;
		/**
		 * Множество объектов, учитываемых в процессе определения столкновений. В качестве объектов могут выступать экземпляры
		 * классов <code>Mesh</code> и <code>Surface</code>. Каким образом учитываются перечисленные в множестве объекты зависит
		 * от значения поля <code>collisionSetMode</code>. Значение <code>null</code> эквивалентно заданию пустого множества.
		 * 
		 * @see #collisionSetMode
		 * @see alternativa.engine3d.core.Mesh
		 * @see alternativa.engine3d.core.Surface
		 */
		public var collisionSet:Set;
		/**
		 * Параметр определяет, каким образом учитываются объекты, перечисленные в множестве <code>collisionSet</code>. Если
		 * значение параметра равно <code>true</code>, то грани объектов из множества игнорируются при определении столкновений.
		 * При значении параметра <code>false</code> учитываются только столкновения с гранями, принадлежащим перечисленным
		 * в множестве объектам.
		 * 
		 * @default true
		 * @see #collisionSet
		 */
		private var _collisionSetMode:int = CollisionSetMode.EXCLUDE;

		/**
		 * Создаёт новый экземпляр класса.
		 * 
		 * @param scene сцена, в которой определяются столкновения
		 * @param scaleX радиус эллипсоида по оси X
		 * @param scaleY радиус эллипсоида по оси Y
		 * @param scaleZ радиус эллипсоида по оси Z
		 */
		public function EllipsoidCollider(scene:Scene3D = null, radiusX:Number = 100, radiusY:Number = 100, radiusZ:Number = 100) {
			this.scene = scene;
			this.radiusX = radiusX;
			this.radiusY = radiusY;
			this.radiusZ = radiusZ;
		}

		/**
		 * Параметр определяет, каким образом учитываются объекты, перечисленные в множестве <code>collisionSet</code>.
		 * 
		 * @default CollisionSetMode.EXCLUDE
		 * @see #collisionSet
		 * @see CollisionSetMode
		 * 
		 * @throws ArgumentError было указано значение не являющееся константой CollisionSetMode
		 */
		public function get collisionSetMode():int {
			return _collisionSetMode;
		}

		/**
		 * @private
		 */
		public function set collisionSetMode(value:int):void {
			if (value != CollisionSetMode.EXCLUDE && value != CollisionSetMode.INCLUDE) {
				throw ArgumentError(ObjectUtils.getClassName(this) + ".collisionSetMode invalid value");
			}	
			_collisionSetMode = value;
		}
		
		/**
		 * Величина радиуса (полуоси) эллипсоида по оси X. При установке отрицательного значения берётся модуль.
		 * 
		 * @default 100 
		 */
		public function get radiusX():Number {
			return _radiusX;
		}

		/**
		 * @private
		 */
		public function set radiusX(value:Number):void {
			_radiusX = value >= 0 ? value : -value;
			_radiusX2 = _radiusX * _radiusX;
			calculateScales();
		}

		/**
		 * Величина радиуса (полуоси) эллипсоида по оси Y. При установке отрицательного значения берётся модуль.
		 * 
		 * @default 100 
		 */
		public function get radiusY():Number {
			return _radiusY;
		}

		/**
		 * @private
		 */
		public function set radiusY(value:Number):void {
			_radiusY = value >= 0 ? value : -value;
			_radiusY2 = _radiusY * _radiusY;
			calculateScales();
		}

		/**
		 * Величина радиуса (полуоси) эллипсоида по оси Z. При установке отрицательного значения берётся модуль.
		 * 
		 * @default 100 
		 */
		public function get radiusZ():Number {
			return _radiusZ;
		}

		/**
		 * @private
		 */
		public function set radiusZ(value:Number):void {
			_radiusZ = value >= 0 ? value : -value;
			_radiusZ2 = _radiusZ * _radiusZ;
			calculateScales();
		}

		/**
		 * Расчёт коэффициентов масштабирования осей.
		 */
		private function calculateScales():void {
			_radius = _radiusX;
			if (_radiusY > _radius) {
				_radius = _radiusY;
			}
			if (_radiusZ > _radius) {
				_radius = _radiusZ;
			}
			_radius2 = _radius * _radius;
			_scaleX = _radiusX / _radius;
			_scaleY = _radiusY / _radius;
			_scaleZ = _radiusZ / _radius;
			_scaleX2 = _scaleX * _scaleX;
			_scaleY2 = _scaleY * _scaleY;
			_scaleZ2 = _scaleZ * _scaleZ;
			
			useSimpleAlgorithm = (_radiusX == _radiusY) && (_radiusX == _radiusZ);
		}

		/**
		 * Расчёт конечного положения эллипсоида по заданному начальному положению и вектору смещения. Если задано значение
		 * поля <code>scene</code>, то при вычислении конечного положения учитываются столкновения с объектами сцены,
		 * принимая во внимание множество <code>collisionSet</code> и режим работы <code>collisionSetMode</code>. Если
		 * значение поля <code>scene</code> равно <code>null</code>, то результат работы метода будет простой суммой двух
		 * входных векторов.
		 * 
		 * @param sourcePoint начальное положение центра эллипсоида в системе координат корневого объекта сцены
		 * @param displacementVector вектор перемещения эллипсоида в системе координат корневого объекта сцены. Если модуль
		 *   каждого компонента вектора не превышает значения <code>offsetThreshold</code>, эллипсоид остаётся в начальной точке.
		 * @param destinationPoint в эту переменную записывается расчётное положение центра эллипсоида в системе координат
		 *   корневого объекта сцены
		 * 
		 * @see #scene
		 * @see #collisionSet
		 * @see #collisionSetMode
		 * @see #offsetThreshold
		 */
		public function calculateDestination(sourcePoint:Point3D, displacementVector:Point3D, destinationPoint:Point3D):void {
			// Расчеты не производятся, если перемещение мало
			if (displacementVector.x < offsetThreshold && displacementVector.x > -offsetThreshold &&
					displacementVector.y < offsetThreshold && displacementVector.y > -offsetThreshold &&
					displacementVector.z < offsetThreshold && displacementVector.z > -offsetThreshold) {
				destinationPoint.x = sourcePoint.x;
				destinationPoint.y = sourcePoint.y;
				destinationPoint.z = sourcePoint.z;
				return;
			}
			
			// Начальные координаты
			currentCoords.x = sourcePoint.x;
			currentCoords.y = sourcePoint.y;
			currentCoords.z = sourcePoint.z;
			// Начальный вектор перемещения
			currentDisplacement.x = displacementVector.x;
			currentDisplacement.y = displacementVector.y;
			currentDisplacement.z = displacementVector.z;
			// Начальная точка назначения
			destinationPoint.x = sourcePoint.x + currentDisplacement.x;
			destinationPoint.y = sourcePoint.y + currentDisplacement.y;
			destinationPoint.z = sourcePoint.z + currentDisplacement.z;

			if (useSimpleAlgorithm) {
				calculateDestinationS(sourcePoint, destinationPoint);
			} else {
				calculateDestinationE(sourcePoint, destinationPoint);				
			}
		}

		/**
		 * Вычисление точки назначения для сферы.
		 * @param sourcePoint
		 * @param destinationPoint
		 */
		private function calculateDestinationS(sourcePoint:Point3D, destinationPoint:Point3D):void {
			var collisionCount:uint = 0;
			var hasCollision:Boolean;
			do {
				hasCollision = getCollision(currentCoords, currentDisplacement, collision);
				if (hasCollision ) {
					// Вынос точки назначения из-за плоскости столкновения на высоту радиуса сферы над плоскостью по направлению нормали
					var offset:Number = _radius + offsetThreshold + collision.offset - destinationPoint.x*collision.normal.x - destinationPoint.y*collision.normal.y - destinationPoint.z*collision.normal.z;
					destinationPoint.x += collision.normal.x * offset;
					destinationPoint.y += collision.normal.y * offset;
					destinationPoint.z += collision.normal.z * offset;
					// Коррекция текущих кординат центра сферы для следующей итерации 
					currentCoords.x = collision.point.x + collision.normal.x * (_radius + offsetThreshold);
					currentCoords.y = collision.point.y + collision.normal.y * (_radius + offsetThreshold);
					currentCoords.z = collision.point.z + collision.normal.z * (_radius + offsetThreshold);
					// Коррекция вектора скорости. Результирующий вектор направлен вдоль плоскости столкновения.
					currentDisplacement.x = destinationPoint.x - currentCoords.x;
					currentDisplacement.y = destinationPoint.y - currentCoords.y;
					currentDisplacement.z = destinationPoint.z - currentCoords.z;
					
					// Если смещение слишком мало, останавливаемся
					if (currentDisplacement.x < offsetThreshold && currentDisplacement.x > -offsetThreshold &&
							currentDisplacement.y < offsetThreshold && currentDisplacement.y > -offsetThreshold &&
							currentDisplacement.z < offsetThreshold && currentDisplacement.z > -offsetThreshold) {
						break;
					}
				}
			} while (hasCollision && (++collisionCount < MAX_COLLISIONS));
			// Если количество итераций достигло максимально возможного значения, то остаемся на старом месте
			if (collisionCount == MAX_COLLISIONS) {
				destinationPoint.x = sourcePoint.x;
				destinationPoint.y = sourcePoint.y;
				destinationPoint.z = sourcePoint.z;
			}
		}

		/**
		 * Вычисление точки назначения для эллипсоида.
		 * @param destinationPoint
		 * @return 
		 */
		private function calculateDestinationE(sourcePoint:Point3D, destinationPoint:Point3D):void {
			var collisionCount:uint = 0;
			var hasCollision:Boolean;
			// Цикл выполняется до тех пор, пока не будет найдено ни одного столкновения на очередной итерации или пока не
			// будет достигнуто максимально допустимое количество столкновений, что означает зацикливание алгоритма и
			// необходимость принудительного выхода.
			do {
				hasCollision = getCollision(currentCoords, currentDisplacement, collision);
				if (hasCollision) {
					// Вынос точки назначения из-за плоскости столкновения на высоту эффективного радиуса эллипсоида над плоскостью по направлению нормали
					var offset:Number = collisionRadius + offsetThreshold + collision.offset - destinationPoint.x * collision.normal.x - destinationPoint.y * collision.normal.y - destinationPoint.z * collision.normal.z;
					destinationPoint.x += collision.normal.x * offset;
					destinationPoint.y += collision.normal.y * offset;
					destinationPoint.z += collision.normal.z * offset;
					// Коррекция текущих кординат центра эллипсоида для следующей итерации
					collisionRadius = (collisionRadius + offsetThreshold) / collisionRadius;
					currentCoords.x = collision.point.x - collisionRadius * radiusVector.x;
					currentCoords.y = collision.point.y - collisionRadius * radiusVector.y;
					currentCoords.z = collision.point.z - collisionRadius * radiusVector.z;
					// Коррекция вектора смещения. Результирующий вектор направлен параллельно плоскости столкновения.
					currentDisplacement.x = destinationPoint.x - currentCoords.x;
					currentDisplacement.y = destinationPoint.y - currentCoords.y;
					currentDisplacement.z = destinationPoint.z - currentCoords.z;
					// Если смещение слишком мало, останавливаемся
					if (currentDisplacement.x < offsetThreshold && currentDisplacement.x > -offsetThreshold &&
							currentDisplacement.y < offsetThreshold && currentDisplacement.y > -offsetThreshold &&
							currentDisplacement.z < offsetThreshold && currentDisplacement.z > -offsetThreshold) {
						destinationPoint.x = currentCoords.x;
						destinationPoint.y = currentCoords.y;
						destinationPoint.z = currentCoords.z;
						break;
					}
				}
			} while (hasCollision && (++collisionCount < MAX_COLLISIONS));
			// Если количество итераций достигло максимально возможного значения, то остаемся на старом месте
			if (collisionCount == MAX_COLLISIONS) {
				destinationPoint.x = sourcePoint.x;
				destinationPoint.y = sourcePoint.y;
				destinationPoint.z = sourcePoint.z;
			}
		}
		
		/**
		 * Метод определяет наличие столкновения при смещении эллипсоида из заданной точки на величину указанного вектора
		 * перемещения, принимая во внимание множество <code>collisionSet</code> и режим работы <code>collisionSetMode</code>.
		 *  
		 * @param sourcePoint начальное положение центра эллипсоида в системе координат корневого объекта сцены
		 * @param displacementVector вектор перемещения эллипсоида в системе координат корневого объекта сцены
		 * @param collision в эту переменную будут записаны данные о плоскости и точке столкновения в системе координат
		 *   корневого объекта сцены
		 * 
		 * @return <code>true</code>, если эллипсоид при заданном перемещении столкнётся с каким-либо полигоном сцены,
		 * <code>false</code> если столкновений нет или не задано значение поля <code>scene</code>.
		 * 
		 * @see #scene
		 * @see #collisionSet
		 * @see #collisionSetMode
		 */
		public function getCollision(sourcePoint:Point3D, displacementVector:Point3D, collision:Collision):Boolean {
			if (scene == null) {
				return false;
			}

			collisionSource = sourcePoint;
			
			currentDisplacement.x = displacementVector.x;
			currentDisplacement.y = displacementVector.y;
			currentDisplacement.z = displacementVector.z;
			
			collisionDestination.x = collisionSource.x + currentDisplacement.x;
			collisionDestination.y = collisionSource.y + currentDisplacement.y;
			collisionDestination.z = collisionSource.z + currentDisplacement.z;
			
			collectPotentialCollisionPlanes(scene.bsp);
			collisionPlanes.sortOn("sourceOffset", Array.NUMERIC | Array.DESCENDING);
			
			var plane:CollisionPlane;
			// Пока не найдём столкновение с примитивом или плоскости не кончатся
			if (useSimpleAlgorithm) {
				while ((plane = collisionPlanes.pop()) != null) {
					if (collisionPrimitive == null) {
						calculateCollisionWithPlaneS(plane);
					}
					CollisionPlane.destroyCollisionPlane(plane);
				}
			} else {
				while ((plane = collisionPlanes.pop()) != null) {
					if (collisionPrimitive == null) {
						calculateCollisionWithPlaneE(plane);
					}
					CollisionPlane.destroyCollisionPlane(plane);
				}				
			}
			
			var collisionFound:Boolean = collisionPrimitive != null;
			if (collisionFound) {
				collision.face = collisionPrimitive.face;
				collision.normal = collisionNormal;
				collision.offset = collisionOffset;
				collision.point = collisionPoint;
			}
			
			collisionPrimitive = null;
			collisionSource = null;

			return collisionFound;
		}

		/**
		 * Сбор потенциальных плоскостей столкновения.
		 *
		 * @param node текущий узел BSP-дерева
		 */
		private function collectPotentialCollisionPlanes(node:BSPNode):void {
			if (node == null) {
				return;
			}

			var sourceOffset:Number = collisionSource.x * node.normal.x + collisionSource.y * node.normal.y + collisionSource.z * node.normal.z - node.offset;
			var destinationOffset:Number = collisionDestination.x * node.normal.x + collisionDestination.y * node.normal.y + collisionDestination.z * node.normal.z - node.offset;
			var plane:CollisionPlane;

			if (sourceOffset >= 0) {
				// Исходное положение центра перед плоскостью ноды
				// Проверяем передние ноды
				collectPotentialCollisionPlanes(node.front);
				// Грубая оценка пересечения с плоскостью по радиусу ограничивающей сферы эллипсоида
				// Или мы наткнулись на спрайтовую ноду
				if (destinationOffset < _radius && !node.isSprite) {
					// Добавляем плоскость если это не сплитеровая нода
					if (node.splitter == null) {
						// Нашли потенциальное пересечение с плоскостью
						plane = CollisionPlane.createCollisionPlane(node, true, sourceOffset, destinationOffset);
						collisionPlanes.push(plane);
					}
					// Проверяем задние ноды
					collectPotentialCollisionPlanes(node.back);
				}
			} else {
				// Исходное положение центра за плоскостью ноды
				// Проверяем задние ноды
				collectPotentialCollisionPlanes(node.back);
				// Грубая оценка пересечения с плоскостью по радиусу ограничивающей сферы эллипсоида
				if (destinationOffset > -_radius) {
					// Столкновение возможно только в случае если в ноде есть примитивы, направленные назад
					if (node.backPrimitives != null) {
						// Нашли потенциальное пересечение с плоскостью
						plane = CollisionPlane.createCollisionPlane(node, false, -sourceOffset, -destinationOffset);
						collisionPlanes.push(plane);
					}
					// Проверяем передние ноды
					collectPotentialCollisionPlanes(node.front);
				}
			}
		}
		
		/**
		 * @private
		 * Определение пересечения сферы с примитивами, лежащими в заданной плоскости. 
		 * 
		 * @param plane плоскость, содержащая примитивы для проверки 
		 */
		private function calculateCollisionWithPlaneS(plane:CollisionPlane):void {
			collisionPlanePoint.copy(collisionSource);

			var normal:Point3D = plane.node.normal;
			// Если сфера врезана в плоскость
			if (plane.sourceOffset <= _radius) {
				if (plane.infront) {
					collisionPlanePoint.x -= normal.x * plane.sourceOffset;
					collisionPlanePoint.y -= normal.y * plane.sourceOffset;
					collisionPlanePoint.z -= normal.z * plane.sourceOffset;
				} else {
					collisionPlanePoint.x += normal.x * plane.sourceOffset;
					collisionPlanePoint.y += normal.y * plane.sourceOffset;
					collisionPlanePoint.z += normal.z * plane.sourceOffset;
				}
			} else {
				// Находим центр сферы во время столкновения с плоскостью
				var time:Number = (plane.sourceOffset - _radius) / (plane.sourceOffset - plane.destinationOffset);
				collisionPlanePoint.x = collisionSource.x + currentDisplacement.x * time;
				collisionPlanePoint.y = collisionSource.y + currentDisplacement.y * time;
				collisionPlanePoint.z = collisionSource.z + currentDisplacement.z * time;

				// Устанавливаем точку пересечения cферы с плоскостью
				if (plane.infront) {
					collisionPlanePoint.x -= normal.x * _radius;
					collisionPlanePoint.y -= normal.y * _radius;
					collisionPlanePoint.z -= normal.z * _radius;
				} else {
					collisionPlanePoint.x += normal.x * _radius;
					collisionPlanePoint.y += normal.y * _radius;
					collisionPlanePoint.z += normal.z * _radius;
				}
			}

			// Проверяем примитивы плоскости
			var primitive:*;
			collisionPrimitiveNearestLengthSqr = Number.MAX_VALUE;
			collisionPrimitiveNearest = null;
			if (plane.infront) {
				if ((primitive = plane.node.primitive) != null) {
					if (((_collisionSetMode == CollisionSetMode.EXCLUDE) && (collisionSet == null || !(collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) ||
					 		((_collisionSetMode == CollisionSetMode.INCLUDE) && (collisionSet != null) && (collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) {
						calculateCollisionWithPrimitiveS(plane.node.primitive);
					}
				} else {
					for (primitive in plane.node.frontPrimitives) {
						if (((_collisionSetMode == CollisionSetMode.EXCLUDE) && (collisionSet == null || !(collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) ||
						 		((_collisionSetMode == CollisionSetMode.INCLUDE) && (collisionSet != null) && (collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) {
							calculateCollisionWithPrimitiveS(primitive);
							if (collisionPrimitive != null) break;
						}
					}
				}
			} else {
				for (primitive in plane.node.backPrimitives) {
					if (((_collisionSetMode == CollisionSetMode.EXCLUDE) && (collisionSet == null || !(collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) ||
					 		((_collisionSetMode == CollisionSetMode.INCLUDE) && (collisionSet != null) && (collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) {
						calculateCollisionWithPrimitiveS(primitive);
						if (collisionPrimitive != null) break;
					}
				}
			}

			if (collisionPrimitive != null) {
				// Если точка пересечения попала в примитив

				// Нормаль плоскости при столкновении - нормаль плоскости
				if (plane.infront) {
					collisionNormal.x = normal.x;
					collisionNormal.y = normal.y;
					collisionNormal.z = normal.z;
					collisionOffset = plane.node.offset;
				} else {
					collisionNormal.x = -normal.x;
					collisionNormal.y = -normal.y;
					collisionNormal.z = -normal.z;
					collisionOffset = -plane.node.offset;
				}

				// Точка столкновения в точке столкновения с плоскостью
				collisionPoint.x = collisionPlanePoint.x;
				collisionPoint.y = collisionPlanePoint.y;
				collisionPoint.z = collisionPlanePoint.z;

			} else {
				// Если точка пересечения не попала ни в один примитив, проверяем столкновение с ближайшей

				// Вектор из ближайшей точки в центр сферы
				var nearestPointToSourceX:Number = collisionSource.x - collisionPrimitivePoint.x;
				var nearestPointToSourceY:Number = collisionSource.y - collisionPrimitivePoint.y; 
				var nearestPointToSourceZ:Number = collisionSource.z - collisionPrimitivePoint.z;

				// Если движение в сторону точки
				if (nearestPointToSourceX * currentDisplacement.x + nearestPointToSourceY * currentDisplacement.y + nearestPointToSourceZ * currentDisplacement.z <= 0) {

					// Ищем нормализованный вектор обратного направления
					var vectorLength:Number = Math.sqrt(currentDisplacement.x * currentDisplacement.x + currentDisplacement.y * currentDisplacement.y + currentDisplacement.z * currentDisplacement.z);
					var vectorX:Number = -currentDisplacement.x / vectorLength;
					var vectorY:Number = -currentDisplacement.y / vectorLength;
					var vectorZ:Number = -currentDisplacement.z / vectorLength;

					// Длина вектора из ближайшей точки в центр сферы
					var nearestPointToSourceLengthSqr:Number = nearestPointToSourceX * nearestPointToSourceX + nearestPointToSourceY * nearestPointToSourceY + nearestPointToSourceZ * nearestPointToSourceZ;

					// Проекция вектора из ближайшей точки в центр сферы на нормализованный вектор обратного направления
					var projectionLength:Number = nearestPointToSourceX * vectorX + nearestPointToSourceY * vectorY + nearestPointToSourceZ * vectorZ;

					var projectionInsideSphereLengthSqr:Number = _radius2 - nearestPointToSourceLengthSqr + projectionLength * projectionLength;

					if (projectionInsideSphereLengthSqr > 0) {
						// Находим расстояние из ближайшей точки до сферы
						var distance:Number = projectionLength - Math.sqrt(projectionInsideSphereLengthSqr);

						if (distance < vectorLength) {
							// Столкновение сферы с ближайшей точкой произошло

							// Точка столкновения в ближайшей точке
							collisionPoint.x = collisionPrimitivePoint.x;
							collisionPoint.y = collisionPrimitivePoint.y;
							collisionPoint.z = collisionPrimitivePoint.z;

							// Находим нормаль плоскости столкновения
							var nearestPointToSourceLength:Number = Math.sqrt(nearestPointToSourceLengthSqr);
							collisionNormal.x = nearestPointToSourceX / nearestPointToSourceLength;
							collisionNormal.y = nearestPointToSourceY / nearestPointToSourceLength;
							collisionNormal.z = nearestPointToSourceZ / nearestPointToSourceLength;

							// Смещение плоскости столкновения
							collisionOffset = collisionPoint.x * collisionNormal.x + collisionPoint.y * collisionNormal.y + collisionPoint.z * collisionNormal.z; 
							collisionPrimitive = collisionPrimitiveNearest;
						}
					}
				}
			}
		}
		
		/**
		 * @private
		 * Определение столкновения сферы с примитивом.
		 * 
		 * @param primitive примитив, столкновение с которым проверяется
		 */
		private function calculateCollisionWithPrimitiveS(primitive:PolyPrimitive):void {

			var length:uint = primitive.num;
			var points:Array = primitive.points;
			var normal:Point3D = primitive.face.globalNormal;
			var inside:Boolean = true;

			for (var i:uint = 0; i < length; i++) {

				var p1:Point3D = points[i];
				var p2:Point3D = points[(i < length - 1) ? (i + 1) : 0];

				var edgeX:Number = p2.x - p1.x;
				var edgeY:Number = p2.y - p1.y;
				var edgeZ:Number = p2.z - p1.z;

				var vectorX:Number = collisionPlanePoint.x - p1.x;
				var vectorY:Number = collisionPlanePoint.y - p1.y;
				var vectorZ:Number = collisionPlanePoint.z - p1.z;

				var crossX:Number = vectorY * edgeZ - vectorZ * edgeY;
				var crossY:Number = vectorZ * edgeX - vectorX * edgeZ;
				var crossZ:Number = vectorX * edgeY - vectorY * edgeX;

				if (crossX * normal.x + crossY * normal.y + crossZ * normal.z > 0) {
					// Точка за пределами полигона
					inside = false;

					var edgeLengthSqr:Number = edgeX * edgeX + edgeY * edgeY + edgeZ * edgeZ;
					var edgeDistanceSqr:Number = (crossX * crossX + crossY * crossY + crossZ * crossZ) / edgeLengthSqr;

					// Если расстояние до прямой меньше текущего ближайшего
					if (edgeDistanceSqr < collisionPrimitiveNearestLengthSqr) {

						// Ищем нормализованный вектор ребра
						var edgeLength:Number = Math.sqrt(edgeLengthSqr);
						var edgeNormX:Number = edgeX / edgeLength;
						var edgeNormY:Number = edgeY / edgeLength;
						var edgeNormZ:Number = edgeZ / edgeLength;

						// Находим расстояние до точки перпендикуляра вдоль ребра
						var t:Number = edgeNormX * vectorX + edgeNormY * vectorY + edgeNormZ * vectorZ;

						var vectorLengthSqr:Number;
						if (t < 0) {
							// Ближайшая точка - первая
							vectorLengthSqr = vectorX * vectorX + vectorY * vectorY + vectorZ * vectorZ;
							if (vectorLengthSqr < collisionPrimitiveNearestLengthSqr) {
								collisionPrimitiveNearestLengthSqr = vectorLengthSqr;
								collisionPrimitivePoint.x = p1.x;
								collisionPrimitivePoint.y = p1.y;
								collisionPrimitivePoint.z = p1.z;
								collisionPrimitiveNearest = primitive;
							}
						} else {
							if (t > edgeLength) {
								// Ближайшая точка - вторая
								vectorX = collisionPlanePoint.x - p2.x;
								vectorY = collisionPlanePoint.y - p2.y;
								vectorZ = collisionPlanePoint.z - p2.z;
								vectorLengthSqr = vectorX * vectorX + vectorY * vectorY + vectorZ * vectorZ;
								if (vectorLengthSqr < collisionPrimitiveNearestLengthSqr) {
									collisionPrimitiveNearestLengthSqr = vectorLengthSqr;
									collisionPrimitivePoint.x = p2.x;
									collisionPrimitivePoint.y = p2.y;
									collisionPrimitivePoint.z = p2.z;
									collisionPrimitiveNearest = primitive;
								}
							} else {
								// Ближайшая точка на ребре
								collisionPrimitiveNearestLengthSqr = edgeDistanceSqr;
								collisionPrimitivePoint.x = p1.x + edgeNormX * t;
								collisionPrimitivePoint.y = p1.y + edgeNormY * t;
								collisionPrimitivePoint.z = p1.z + edgeNormZ * t;
								collisionPrimitiveNearest = primitive;
							}
						}
					}
				}
			}

			// Если попали в примитив
			if (inside) {
				collisionPrimitive = primitive;
			}
		}
		
		/**
		 * Проверка на действительное столкновение эллипсоида с плоскостью.
		 */
		private function calculateCollisionWithPlaneE(plane:CollisionPlane):void {
			var normalX:Number = plane.node.normal.x;
			var normalY:Number = plane.node.normal.y;
			var normalZ:Number = plane.node.normal.z;
			// Смещение по направлению к плоскости вдоль нормали. Положительное смещение означает приближение к плоскости, отрицательное -- удаление
			// от плоскости, в этом случае столкновения не происходит.
			var displacementAlongNormal:Number = currentDisplacement.x * normalX + currentDisplacement.y * normalY + currentDisplacement.z * normalZ;
			if (plane.infront) {
				displacementAlongNormal = -displacementAlongNormal;
			}
			// Выходим из функции в случае удаления от плоскости
			if (displacementAlongNormal < 0) {
				return;
			}
			// Определение ближайшей к плоскости точки эллипсоида
			var k:Number = _radius / Math.sqrt(normalX * normalX * _scaleX2 + normalY * normalY * _scaleY2 + normalZ * normalZ * _scaleZ2);
			// Положение точки в локальной системе координат эллипсоида
			var localClosestX:Number = k * normalX * _scaleX2;
			var localClosestY:Number = k * normalY * _scaleY2;
			var localClosestZ:Number = k * normalZ * _scaleZ2;
			// Глобальные координаты точки
			var px:Number = collisionSource.x + localClosestX;
			var py:Number = collisionSource.y + localClosestY;
			var pz:Number = collisionSource.z + localClosestZ;
			// Растояние от найденной точки эллипсоида до плоскости
			var closestPointDistance:Number = px * normalX + py * normalY + pz * normalZ - plane.node.offset;
			if (!plane.infront) {
				closestPointDistance = -closestPointDistance;
			}
			if (closestPointDistance > plane.sourceOffset) {
				// Найдена наиболее удалённая точка, расчитываем вторую
				px = collisionSource.x - localClosestX;
				py = collisionSource.y - localClosestY;
				pz = collisionSource.z - localClosestZ;
				closestPointDistance = px * normalX + py * normalY + pz * normalZ - plane.node.offset;
				if (!plane.infront) {
					closestPointDistance = -closestPointDistance;
				}
			}
			// Если расстояние от ближайшей точки эллипсоида до плоскости больше, чем смещение эллипсоида вдоль нормали плоскости,
			// то столкновения не произошло и нужно завершить выполнение функции 
			if (closestPointDistance > displacementAlongNormal) {
				return;
			}
			// Если добрались до этого места, значит произошло столкновение с плоскостью. Требуется определить точку столкновения
			// с ближайшим полигоном, лежащим в этой плоскости
			if (closestPointDistance <= 0 ) {
				// Эллипсоид пересекается с плоскостью, ищем проекцию ближайшей точки эллипсоида на плоскость
				if (plane.infront) {
					collisionPlanePoint.x = px - normalX * closestPointDistance;
					collisionPlanePoint.y = py - normalY * closestPointDistance;
					collisionPlanePoint.z = pz - normalZ * closestPointDistance;
				} else {
					collisionPlanePoint.x = px + normalX * closestPointDistance;
					collisionPlanePoint.y = py + normalY * closestPointDistance;
					collisionPlanePoint.z = pz + normalZ * closestPointDistance;
				}
			} else {
				// Эллипсоид не пересекается с плоскостью, ищем точку контакта
				var t:Number = closestPointDistance / displacementAlongNormal;
				collisionPlanePoint.x = px + currentDisplacement.x * t;
				collisionPlanePoint.y = py + currentDisplacement.y * t;
				collisionPlanePoint.z = pz + currentDisplacement.z * t;
			}
			// Проверяем примитивы плоскости
			var primitive:*;
			collisionPrimitiveNearestLengthSqr = Number.MAX_VALUE;
			collisionPrimitiveNearest = null;
			if (plane.infront) {
				if ((primitive = plane.node.primitive) != null) {
					if (((_collisionSetMode == CollisionSetMode.EXCLUDE) && (collisionSet == null || !(collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) ||
					 		((_collisionSetMode == CollisionSetMode.INCLUDE) && (collisionSet != null) && (collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) {
						calculateCollisionWithPrimitiveE(primitive);
					}
				} else {
					for (primitive in plane.node.frontPrimitives) {
						if (((_collisionSetMode == CollisionSetMode.EXCLUDE) && (collisionSet == null || !(collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) ||
						 		((_collisionSetMode == CollisionSetMode.INCLUDE) && (collisionSet != null) && (collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) {
							calculateCollisionWithPrimitiveE(primitive);
							if (collisionPrimitive != null) {
								break;
							}
						}
					}
				}
			} else {
				for (primitive in plane.node.backPrimitives) {
					if (((_collisionSetMode == CollisionSetMode.EXCLUDE) && (collisionSet == null || !(collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) ||
					 		((_collisionSetMode == CollisionSetMode.INCLUDE) && (collisionSet != null) && (collisionSet[primitive.face._mesh] || collisionSet[primitive.face._surface]))) {
						calculateCollisionWithPrimitiveE(primitive);
						if (collisionPrimitive != null) {
							break;
						}
					}
				}
			}

			if (collisionPrimitive != null) {
				// Если точка пересечения попала в примитив
				// Нормаль плоскости при столкновении - нормаль плоскости примитива
				if (plane.infront) {
					collisionNormal.x = normalX;
					collisionNormal.y = normalY;
					collisionNormal.z = normalZ;
					collisionOffset = plane.node.offset;
				} else {
					collisionNormal.x = -normalX;
					collisionNormal.y = -normalY;
					collisionNormal.z = -normalZ;
					collisionOffset = -plane.node.offset;
				}
				// Радиус эллипсоида в точке столкновения
				collisionRadius = localClosestX * collisionNormal.x + localClosestY * collisionNormal.y + localClosestZ * collisionNormal.z;
				if (collisionRadius < 0) {
					collisionRadius = -collisionRadius;
				}
				radiusVector.x = px - collisionSource.x;
				radiusVector.y = py - collisionSource.y;
				radiusVector.z = pz - collisionSource.z;
				// Точка столкновения совпадает с точкой столкновения с плоскостью примитива
				collisionPoint.x = collisionPlanePoint.x;
				collisionPoint.y = collisionPlanePoint.y;
				collisionPoint.z = collisionPlanePoint.z;
			} else {
				// Если точка пересечения не попала внутрь примитива, находим пересечение с ближайшей точкой ближайшего примитива
				// Трансформированная в пространство эллипсоида ближайшая точка на примитиве
				px = collisionPrimitivePoint.x;
				py = collisionPrimitivePoint.y;
				pz = collisionPrimitivePoint.z;
				
				var collisionExists:Boolean;
				// Квадрат расстояния из центра эллипсоида до точки примитива 
				var r2:Number = px*px + py*py + pz*pz;
				if (r2 < _radius2) {
					// Точка оказалась внутри эллипсоида, находим точку на поверхности эллипсоида, лежащую на том же радиусе
					k = _radius / Math.sqrt(r2);
					px *= k * _scaleX;
					py *= k * _scaleY;
					pz *= k * _scaleZ;
					
					collisionExists = true;
				} else {
					// Точка вне эллипсоида, находим пересечение луча, направленного противоположно скорости эллипсоида из точки
					// примитива, с поверхностью эллипсоида
					// Трансформированный в пространство эллипсоида противоположный вектор скорости
					var vx:Number = - currentDisplacement.x / _scaleX;
					var vy:Number = - currentDisplacement.y / _scaleY;
					var vz:Number = - currentDisplacement.z / _scaleZ;
					// Нахождение точки пересечения сферы и луча, направленного вдоль вектора скорости
					var a:Number = vx*vx + vy*vy + vz*vz;
					var b:Number = 2 * (px*vx + py*vy + pz*vz);
					var c:Number = r2 - _radius2;
					var d:Number = b*b - 4*a*c;
					// Решение есть только при действительном дискриминанте квадратного уравнения
					if (d >=0) {
						// Выбирается минимальное время, т.к. нужна первая точка пересечения
						t = -0.5 * (b + Math.sqrt(d)) / a;
						// Точка лежит на луче только если время положительное
						if (t >= 0 && t <= 1) {
							// Координаты точки пересечения луча с эллипсоидом, переведённые обратно в нормальное пространство
							px = (px + t * vx) * _scaleX;
							py = (py + t * vy) * _scaleY;
							pz = (pz + t * vz) * _scaleZ;

							collisionExists = true;
						}
					}
				}
				if (collisionExists) {
					// Противоположная нормаль к эллипсоиду в точке пересечения
					collisionNormal.x = - px / _scaleX2;
					collisionNormal.y = - py / _scaleY2;
					collisionNormal.z = - pz / _scaleZ2;
					collisionNormal.normalize();
					// Радиус эллипсоида в точке столкновения
					collisionRadius = px * collisionNormal.x + py * collisionNormal.y + pz * collisionNormal.z;
					if (collisionRadius < 0) {
						collisionRadius = -collisionRadius;
					}
					radiusVector.x = px;
					radiusVector.y = py;
					radiusVector.z = pz;
					// Точка столкновения в ближайшей точке
					collisionPoint.x = collisionPrimitivePoint.x * _scaleX + currentCoords.x;
					collisionPoint.y = collisionPrimitivePoint.y * _scaleY + currentCoords.y;
					collisionPoint.z = collisionPrimitivePoint.z * _scaleZ + currentCoords.z;
					// Смещение плоскости столкновения
					collisionOffset = collisionPoint.x * collisionNormal.x + collisionPoint.y * collisionNormal.y + collisionPoint.z * collisionNormal.z; 
					collisionPrimitive = collisionPrimitiveNearest;
				}
			}
		}

		/**
		 * @private
		 * Определение наличия столкновения эллипсоида с примитивом. Все расчёты выполняются в пространстве эллипсоида, где он выглядит
		 * как сфера. По окончании работы может быть установлена переменная collisionPrimitive в случае попадания точки
		 * столкновения внутрь примитива или collisionPrimitiveNearest в случае столкновения с ребром примитива через
		 * минимальное время.
		 * 
		 * @param primitive примитив, столкновение с которым проверяется
		 */
		private function calculateCollisionWithPrimitiveE(primitive:PolyPrimitive):void {
			var length:uint = primitive.num;
			var points:Array = primitive.points;
			var normal:Point3D = primitive.face.globalNormal;
			var inside:Boolean = true;

			var point1:Point3D;
			var point2:Point3D = points[length - 1];
			p2.x = (point2.x - currentCoords.x) / _scaleX;
			p2.y = (point2.y - currentCoords.y) / _scaleY;
			p2.z = (point2.z - currentCoords.z) / _scaleZ;
			
			localCollisionPlanePoint.x = (collisionPlanePoint.x - currentCoords.x) / _scaleX;
			localCollisionPlanePoint.y = (collisionPlanePoint.y - currentCoords.y) / _scaleY;
			localCollisionPlanePoint.z = (collisionPlanePoint.z - currentCoords.z) / _scaleZ;
			// Обход всех рёбер примитива
			for (var i:uint = 0; i < length; i++) {
				point1 = point2;
				point2 = points[i];
				
				p1.x = p2.x;
				p1.y = p2.y;
				p1.z = p2.z;

				p2.x = (point2.x - currentCoords.x) / _scaleX;
				p2.y = (point2.y - currentCoords.y) / _scaleY;
				p2.z = (point2.z - currentCoords.z) / _scaleZ;

				// Расчёт векторного произведения вектора ребра на радиус-вектор точки столкновения относительно начала ребра
				// с целью определения положения точки столкновения относительно полигона
				var edgeX:Number = p2.x - p1.x;
				var edgeY:Number = p2.y - p1.y;
				var edgeZ:Number = p2.z - p1.z;

				var vectorX:Number = localCollisionPlanePoint.x - p1.x;
				var vectorY:Number = localCollisionPlanePoint.y - p1.y;
				var vectorZ:Number = localCollisionPlanePoint.z - p1.z;

				var crossX:Number = vectorY * edgeZ - vectorZ * edgeY;
				var crossY:Number = vectorZ * edgeX - vectorX * edgeZ;
				var crossZ:Number = vectorX * edgeY - vectorY * edgeX;

				if (crossX * normal.x + crossY * normal.y + crossZ * normal.z > 0) {
					// Точка за пределами полигона
					inside = false;

					var edgeLengthSqr:Number = edgeX * edgeX + edgeY * edgeY + edgeZ * edgeZ;
					var edgeDistanceSqr:Number = (crossX * crossX + crossY * crossY + crossZ * crossZ) / edgeLengthSqr;

					// Если расстояние до прямой меньше текущего ближайшего
					if (edgeDistanceSqr < collisionPrimitiveNearestLengthSqr) {
						// Ищем нормализованный вектор ребра
						var edgeLength:Number = Math.sqrt(edgeLengthSqr);
						var edgeNormX:Number = edgeX / edgeLength;
						var edgeNormY:Number = edgeY / edgeLength;
						var edgeNormZ:Number = edgeZ / edgeLength;
						// Находим расстояние до точки перпендикуляра вдоль ребра
						var t:Number = edgeNormX * vectorX + edgeNormY * vectorY + edgeNormZ * vectorZ;
						var vectorLengthSqr:Number;
						if (t < 0) {
							// Ближайшая точка - первая
							vectorLengthSqr = vectorX * vectorX + vectorY * vectorY + vectorZ * vectorZ;
							if (vectorLengthSqr < collisionPrimitiveNearestLengthSqr) {
								collisionPrimitiveNearestLengthSqr = vectorLengthSqr;
								collisionPrimitivePoint.x = p1.x;
								collisionPrimitivePoint.y = p1.y;
								collisionPrimitivePoint.z = p1.z;
								collisionPrimitiveNearest = primitive;
							}
						} else {
							if (t > edgeLength) {
								// Ближайшая точка - вторая
								vectorX = localCollisionPlanePoint.x - p2.x;
								vectorY = localCollisionPlanePoint.y - p2.y;
								vectorZ = localCollisionPlanePoint.z - p2.z;
								vectorLengthSqr = vectorX * vectorX + vectorY * vectorY + vectorZ * vectorZ;
								if (vectorLengthSqr < collisionPrimitiveNearestLengthSqr) {
									collisionPrimitiveNearestLengthSqr = vectorLengthSqr;
									collisionPrimitivePoint.x = p2.x;
									collisionPrimitivePoint.y = p2.y;
									collisionPrimitivePoint.z = p2.z;
									collisionPrimitiveNearest = primitive;
								}
							} else {
								// Ближайшая точка на ребре
								collisionPrimitiveNearestLengthSqr = edgeDistanceSqr;
								collisionPrimitivePoint.x = p1.x + edgeNormX * t;
								collisionPrimitivePoint.y = p1.y + edgeNormY * t;
								collisionPrimitivePoint.z = p1.z + edgeNormZ * t;
								collisionPrimitiveNearest = primitive;
							}
						}
					}
				}
			}

			// Если попали в примитив
			if (inside) {
				collisionPrimitive = primitive;
			}
		}

	}
}
