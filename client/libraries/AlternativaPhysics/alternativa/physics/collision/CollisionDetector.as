package alternativa.physics.collision {
	import alternativa.physics.altphysics;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	
	use namespace altphysics;
	
	public class CollisionDetector {
		
		private var epsilon:Number;
		
		private var bestAxisIndex:int;
		private var minOverlap:Number;
		
		private var vectorToBox1:Point3D = new Point3D();
		private var axis:Point3D = new Point3D();
		private var axis10:Point3D = new Point3D();
		private var axis11:Point3D = new Point3D();
		private var axis12:Point3D = new Point3D();
		private var axis20:Point3D = new Point3D();
		private var axis21:Point3D = new Point3D();
		private var axis22:Point3D = new Point3D();
		private var collisionAxis:Point3D = new Point3D();
		private var tmpAxis:Point3D = new Point3D();
		private var point1:Point3D = new Point3D();
		private var point2:Point3D = new Point3D();
		private var vector:Point3D = new Point3D();

		public function CollisionDetector(epsilon:Number = 0.01) {
			this.epsilon = epsilon;
		}
		
		/**
		 * Проверяет столкновение двух боксов, используя теорему о разделяющих плоскостях.
		 * 
		 * @param box1
		 * @param box2
		 * @param collisionData
		 * 
		 * @return 
		 */
		public function boxToBoxCollision(box1:CollisionBox, box2:CollisionBox, collisionData:CollisionData):Boolean {
			if (box1.body.inverseMass == 0 && box2.body.inverseMass == 0) {
				// Нет необходимости проверять столкновения между неподвижными объектами
				return false;
			}
			minOverlap = Number.MAX_VALUE;
			// Вектор из центра второго бокса в центр первого
			vectorToBox1.difference(box1.position, box2.position);
			
			// Проверка пересечения по основным осям
			box1.transform.getAxis(0, axis10);
			if (!testAxis(box1, box2, axis10, 0, vectorToBox1)) return false;
			box1.transform.getAxis(1, axis11);
			if (!testAxis(box1, box2, axis11, 1, vectorToBox1)) return false;
			box1.transform.getAxis(2, axis12);
			if (!testAxis(box1, box2, axis12, 2, vectorToBox1)) return false;
			
			box2.transform.getAxis(0, axis20);
			if (!testAxis(box1, box2, axis20, 3, vectorToBox1)) return false;
			box2.transform.getAxis(1, axis21);
			if (!testAxis(box1, box2, axis21, 4, vectorToBox1)) return false;
			box2.transform.getAxis(2, axis22);
			if (!testAxis(box1, box2, axis22, 5, vectorToBox1)) return false;
			
			// Сохраняем ось с наименьшим перекрытием на случай обнаружения контакта ребро-грань
			var bestMainAxis:int = bestAxisIndex;
			
			// Проверка производных осей
			axis.cross2(axis10, axis20);
			if (!testAxis(box1, box2, axis, 6, vectorToBox1)) return false;
			axis.cross2(axis10, axis21);
			if (!testAxis(box1, box2, axis, 7, vectorToBox1)) return false;
			axis.cross2(axis10, axis22);
			if (!testAxis(box1, box2, axis, 8, vectorToBox1)) return false;
			
			axis.cross2(axis11, axis20);
			if (!testAxis(box1, box2, axis, 9, vectorToBox1)) return false;
			axis.cross2(axis11, axis21);
			if (!testAxis(box1, box2, axis, 10, vectorToBox1)) return false;
			axis.cross2(axis11, axis22);
			if (!testAxis(box1, box2, axis, 11, vectorToBox1)) return false;

			axis.cross2(axis12, axis20);
			if (!testAxis(box1, box2, axis, 12, vectorToBox1)) return false;
			axis.cross2(axis12, axis21);
			if (!testAxis(box1, box2, axis, 13, vectorToBox1)) return false;
			axis.cross2(axis12, axis22);
			if (!testAxis(box1, box2, axis, 14, vectorToBox1)) return false;
			
			if (bestAxisIndex < 3) {
				// Пересечение вершины второго бокса с гранью первого
				fillPointBoxPenetrationData(box1, box2, vectorToBox1, bestAxisIndex, minOverlap, collisionData);
				collisionData.primitive1 = box1;
				collisionData.primitive2 = box2;
				return true;
			} else if (bestAxisIndex < 6) {
				// Пересечение вершины первого бокса с гранью второго
				vectorToBox1.invert();
				fillPointBoxPenetrationData(box2, box1, vectorToBox1, bestAxisIndex - 3, minOverlap, collisionData);
				collisionData.primitive1 = box1;
				collisionData.primitive2 = box2;
				collisionData.collisionNormal.invert();
				var tmp:Number = collisionData.pointAxisCode1;
				collisionData.pointAxisCode1 = collisionData.pointAxisCode2;
				collisionData.pointAxisCode2 = tmp;
				return true;
			} else {
				// Пересечение рёбер
				bestAxisIndex -= 6;
				var axisIndex1:int = int(bestAxisIndex/3);
				var axisIndex2:int = bestAxisIndex%3;
				
				box1.transform.getAxis(axisIndex1, axis10);
				box2.transform.getAxis(axisIndex2, axis20);
				collisionAxis.cross2(axis10, axis20);
				collisionAxis.normalize();
				// Разворот оси в сторону первого бокса
				if (collisionAxis.dot(vectorToBox1) < 0) {
					collisionAxis.invert();
				}
				
				var edgeHalfLength1:Number;
				var edgeHalfLength2:Number;
				var pointEdgeCode1:int;
				var pointEdgeCode2:int;
				
				point1.copy(box1.halfSize);
				point2.copy(box2.halfSize);
				// x
				if (axisIndex1 == 0) {
					point1.x = 0;
					edgeHalfLength1 = box1.halfSize.x;
					pointEdgeCode1 |= 1;
				} else {
					box1.transform.getAxis(0, tmpAxis);
					if (tmpAxis.dot(collisionAxis) > 0) {
						point1.x = -point1.x;
						pointEdgeCode1 |= 1;
					}
				}
				if (axisIndex2 == 0) {
					point2.x = 0;
					edgeHalfLength2 = box2.halfSize.x;
					pointEdgeCode2 |= 1;
				} else {
					box2.transform.getAxis(0, tmpAxis);
					if (tmpAxis.dot(collisionAxis) < 0) {
						point2.x = -point2.x;
						pointEdgeCode2 |= 1;
					}
				}
				// y
				if (axisIndex1 == 1) {
					point1.y = 0;
					edgeHalfLength1 = box1.halfSize.y;
					pointEdgeCode1 |= 2;
				} else {
					box1.transform.getAxis(1, tmpAxis);
					if (tmpAxis.dot(collisionAxis) > 0) {
						point1.y = -point1.y;
						pointEdgeCode1 |= 2;
					}
				}
				if (axisIndex2 == 1) {
					point2.y = 0;
					edgeHalfLength2 = box2.halfSize.y;
					pointEdgeCode2 |= 2;
				} else {
					box2.transform.getAxis(1, tmpAxis);
					if (tmpAxis.dot(collisionAxis) < 0) {
						point2.y = -point2.y;
						pointEdgeCode2 |= 2;
					}
				}
				// z
				if (axisIndex1 == 2) {
					point1.z = 0;
					edgeHalfLength1 = box1.halfSize.z;
					pointEdgeCode1 |= 4;
				} else {
					box1.transform.getAxis(2, tmpAxis);
					if (tmpAxis.dot(collisionAxis) > 0) {
						point1.z = -point1.z;
						pointEdgeCode1 |= 4;
					}
				}
				if (axisIndex2 == 2) {
					point2.z = 0;
					edgeHalfLength2 = box2.halfSize.z;
					pointEdgeCode2 |= 4;
				} else {
					box2.transform.getAxis(2, tmpAxis);
					if (tmpAxis.dot(collisionAxis) < 0) {
						point2.z = -point2.z;
						pointEdgeCode2 |= 4;
					}
				}
				
				point1.transform(box1.transform);
				point2.transform(box2.transform);
				
				// Находим точку пересечения рёбер
				var k:Number = axis10.dot(axis20);
				var det:Number = k*k - 1;
				if (det > -0.0001 && det < 0.0001) {
					vector.copy(bestMainAxis > 2 ? point1 : point2);
				} else {
					vector.difference(point2, point1);
					var c1:Number = axis10.dot(vector);
					var c2:Number = axis20.dot(vector);
					var t1:Number = (c2*k - c1)/det;
					if (t1 < -edgeHalfLength1 || t1 > edgeHalfLength1) {
						vector.copy(bestMainAxis > 2 ? point1 : point2);
					} else {
						var t2:Number = (c2 - c1*k)/det;
						if (t2 < -edgeHalfLength2 || t2 > edgeHalfLength2) {
							vector.copy(bestMainAxis > 2 ? point1 : point2);
						} else {
							vector.x = 0.5*(point1.x + point2.x + axis10.x*t1 + axis20.x*t2);
							vector.y = 0.5*(point1.y + point2.y + axis10.y*t1 + axis20.y*t2);
							vector.z = 0.5*(point1.z + point2.z + axis10.z*t1 + axis20.z*t2);
						}
					}
				}
				collisionData.primitive1 = box1;
				collisionData.primitive2 = box2;
				collisionData.penetration = minOverlap;
				collisionData.collisionPoint.copy(vector);
				collisionData.collisionNormal.copy(collisionAxis);
				collisionData.pointAxisCode1 = pointEdgeCode1 | (axisIndex1 << 3) | 32;
				collisionData.pointAxisCode2 = pointEdgeCode2 | (axisIndex2 << 3) | 32;
			}
			return true;
		}
		
		/**
		 * 
		 * @param box1
		 * @param box2
		 * @param axis
		 * @param axisIndex
		 * @param vectorToBox1
		 * @param bestAxis
		 * @return 
		 * 
		 */
		private function testAxis(box1:CollisionBox, box2:CollisionBox, axis:Point3D, axisIndex:int, vectorToBox1:Point3D):Boolean {
			if (axis.lengthSqr < 0.0001) {
				return true;
			}
			axis.normalize();
			
			var overlap:Number = overlapOnAxis(box1, box2, axis, vectorToBox1);
			if (overlap <= 0) {
				return false;
			}
			if (overlap < minOverlap) {
				minOverlap = overlap;
				bestAxisIndex = axisIndex;
			}
			return true;
		}
		
		/**
		 * 
		 * @param box1
		 * @param box2
		 * @param axis
		 * @param vectorToBox1
		 * @return 
		 * 
		 */
		public function overlapOnAxis(box1:CollisionBox, box2:CollisionBox, axis:Point3D, vectorToBox1:Point3D):Number {
			var m:Matrix3D = box1.transform;
			var d:Number = (m.a*axis.x + m.e*axis.y + m.i*axis.z)*box1.halfSize.x;
			var projection:Number = d < 0 ? -d : d;
			d = (m.b*axis.x + m.f*axis.y + m.j*axis.z)*box1.halfSize.y;
			projection += d < 0 ? -d : d;
			d = (m.c*axis.x + m.g*axis.y + m.k*axis.z)*box1.halfSize.z;
			projection += d < 0 ? -d : d;

			m = box2.transform;
			d = (m.a*axis.x + m.e*axis.y + m.i*axis.z)*box2.halfSize.x;
			projection += d < 0 ? -d : d;
			d = (m.b*axis.x + m.f*axis.y + m.j*axis.z)*box2.halfSize.y;
			projection += d < 0 ? -d : d;
			d = (m.c*axis.x + m.g*axis.y + m.k*axis.z)*box2.halfSize.z;
			projection += d < 0 ? -d : d;
			
			d = vectorToBox1.x*axis.x + vectorToBox1.y*axis.y + vectorToBox1.z*axis.z;
			if (d < 0) {
				d = -d;
			}
			
			return projection - d;
		}
		
		/**
		 * Заполняет данные о контакте грани первого бокса с вершиной второго. 
		 *  
		 * @param box1
		 * @param box2
		 * @param vectorToBox1
		 * @param axisIndex
		 * @param overlap
		 * @param collisionData
		 * @param swapBoxes поменять примитивы местами при записи данных
		 */
		private function fillPointBoxPenetrationData(box1:CollisionBox, box2:CollisionBox, vectorToBox1:Point3D,  axisIndex:int, overlap:Number, collisionData:CollisionData):void {
			box1.transform.getAxis(axisIndex, collisionData.collisionNormal);
			if (collisionData.collisionNormal.dot(vectorToBox1) < 0) {
				collisionData.collisionNormal.invert();
			}
			
			var pointCode:int;
			axis10.copy(box2.halfSize);
			box2.transform.getAxis(0, axis20);
			if (axis20.dot(collisionData.collisionNormal) < 0) {
				axis10.x = -axis10.x;
				pointCode |= 1;
			}
			box2.transform.getAxis(1, axis20);
			if (axis20.dot(collisionData.collisionNormal) < 0) {
				axis10.y = -axis10.y;
				pointCode |= 2;
			}
			box2.transform.getAxis(2, axis20);
			if (axis20.dot(collisionData.collisionNormal) < 0) {
				axis10.z = -axis10.z;
				pointCode |= 4;
			}
			axis10.transform(box2.transform);
			
			collisionData.collisionPoint.copy(axis10);
			collisionData.penetration = overlap;
			collisionData.pointAxisCode1 = (axisIndex << 3) | 32;
			collisionData.pointAxisCode2 = pointCode;
		}

	}
}