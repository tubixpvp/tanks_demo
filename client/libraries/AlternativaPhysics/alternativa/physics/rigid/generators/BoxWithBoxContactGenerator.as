package alternativa.physics.rigid.generators {
	
	import alternativa.physics.altphysics;
	import alternativa.physics.collision.CollisionBox;
	import alternativa.physics.collision.CollisionData;
	import alternativa.physics.collision.CollisionDetector;
	import alternativa.physics.rigid.RigidBodyContact;
	import alternativa.physics.rigid.RigidBodyContactGenerator;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	
	use namespace altphysics;
	
	public class BoxWithBoxContactGenerator extends RigidBodyContactGenerator {
		
		private var boxes:RigidBox;
		private var collisionDetector:CollisionDetector;
		private var collisionData:RigidBoxCollisionData = RigidBoxCollisionData.create();
		private var restitution:Number;
		private var friction:Number;
		
		private var tolerance:Number = -0.01;
		
		public function BoxWithBoxContactGenerator(boxes:RigidBox, collisionDetector:CollisionDetector, restitution:Number, friction:Number) {
			super();
			this.boxes = boxes;
			this.collisionDetector = collisionDetector;
			this.restitution = restitution;
			this.friction = friction;
		}
		
		public function getBoxes():RigidBox {
			return boxes;
		}

		public function setBoxes(boxes:RigidBox):void {
			this.boxes = boxes;
		}
		
		public function getBoxesCount():int {
			var counter:int = 0;
			var box:RigidBox = boxes;
			while (box != null) {
				counter++;
				box = box.next;
			}
			return counter;
		}
		
		private function updateCillisionBoxes():void {
			var box:RigidBox = boxes;
			while (box != null) {
				box.collisionBox.updateTransform();
				box = box.next;
			}
		}

		override public function addContacts(contact:RigidBodyContact):RigidBodyContact {
			updateCillisionBoxes();

			var box:RigidBox = boxes;
			var otherBox:RigidBox;
			var key:*;
			var cachedCollisionData:RigidBoxCollisionData;
			while (box != null) {
				otherBox = box.next;
				while (otherBox != null) {
					var contactExists:Boolean = collisionDetector.boxToBoxCollision(box.collisionBox, otherBox.collisionBox, collisionData);
					collisionData.otherBox = otherBox;
					if (contactExists) {
						var cached:Boolean = false;
						// Поиск и обновление полученного контакта в кэше
						for (key in box.boxCollisionCache) {
							cachedCollisionData = key;
							if (!cachedCollisionData.fresh && cachedCollisionData.equals(collisionData)) {
								cached = true;
								cachedCollisionData.collisionNormal.copy(collisionData.collisionNormal);
								cachedCollisionData.collisionPoint.copy(collisionData.collisionPoint);
								cachedCollisionData.penetration = collisionData.penetration;
								break;
							}
						}
						if (!cached) {
							// В кэше не оказалось, добавляется новый контакт
							box.boxCollisionCache[collisionData] = true;
							collisionData = RigidBoxCollisionData.create();
						}
					}
					otherBox = otherBox.next as RigidBox;
				}
				
				// Создание контактов из кэша
				var counter:int;
				for (key in box.boxCollisionCache) {
					cachedCollisionData = key;
					if (cachedCollisionData.fresh) {
						cachedCollisionData.fresh = false;
					} else {
						// Проверка актуальности старых контактов
						var valid:Boolean = checkCachedContact(cachedCollisionData);
						if (!valid) {
							delete box.boxCollisionCache[key];
							RigidBoxCollisionData.destroy(cachedCollisionData);
							continue;
						}
						cachedCollisionData.timeStamp++;
					}
					// Создание контакта
					contact.timeStamp = cachedCollisionData.timeStamp;
					contact.body1 = box.body;
					contact.body2 = cachedCollisionData.otherBox.body;
					contact.contactNormal.copy(cachedCollisionData.collisionNormal);
					contact.contactPoint.copy(cachedCollisionData.collisionPoint);
					contact.penetration = cachedCollisionData.penetration;
					contact.friction = friction;
					contact.restitution = restitution;
					contact = contact.next;
					if (contact == null) {
						return null;
					}
				}
				
				box = box.next;
			}
			
			return contact;
		}
		
		private var _axis1:Point3D = new Point3D();
		private var _axis2:Point3D = new Point3D();
		private var _axis3:Point3D = new Point3D();
		private var _toFirst:Point3D = new Point3D();
		private var _point1:Point3D = new Point3D();
		private var _point2:Point3D = new Point3D();
		private var _collisionPoint:Point3D = new Point3D();
		/**
		 * 
		 * @param data
		 * @return 
		 */
		private function checkCachedContact(data:CollisionData):Boolean {
			var box1:CollisionBox = data.primitive1 as CollisionBox;
			var box2:CollisionBox = data.primitive2 as CollisionBox;
			var axisFlag1:int = data.pointAxisCode1 & 32;
			var axisFlag2:int = data.pointAxisCode2 & 32;
			var axisIndex1:int;
			var axisIndex2:int;
			var penetration:Number;
			_toFirst.difference(box1.position, box2.position);
			
			if (axisFlag1 == axisFlag2) {
				// Столкновение вдоль вторичной оси
				axisIndex1 = (data.pointAxisCode1 >> 3) & 3;
				box1.transform.getAxis(axisIndex1, _axis1);
				axisIndex2 = (data.pointAxisCode2 >> 3) & 3;
				box2.transform.getAxis(axisIndex2, _axis2);
				_axis3.cross2(_axis1, _axis2);
				_axis3.normalize();
				var overlap:Number = collisionDetector.overlapOnAxis(box1, box2, _axis3, _toFirst);
				if (overlap < 0) {
					return false;
				} else {
					penetration = getEdgesPenetrationAndCollisionPoint(box1, box2, _axis1, axisIndex1, data.pointAxisCode1 & 7, _axis2, axisIndex2, data.pointAxisCode2 & 7, _toFirst, _collisionPoint);
					if (penetration < tolerance) {
						return false;
					}
					// Обновляем контакт
					if (_toFirst.dot(_axis3) < 0) {
						_axis3.invert();
					}
					data.collisionNormal.copy(_axis3);
					data.collisionPoint.copy(_collisionPoint);
					data.penetration = penetration > 0 ? penetration : 0;
					return true;
				}
			} else {
				// Столкновение вдоль основной оси
				// TODO: Доделать проверку на попадание вершины внутрь бокса
				if (axisFlag1 != 0) {
					// Столкновение вершины второго бокса с гранью первого
					_toFirst.invert();
					axisIndex1 = (data.pointAxisCode1 >> 3) & 3;
					penetration = getPointBoxPenetrationAndCollisionPoint(box2, box1, data.pointAxisCode2 & 7, axisIndex1, _toFirst, _collisionPoint, _axis1);
					_axis1.invert();
				} else {
					// Столкновение вершины первого бокса с гранью второго
					axisIndex2 = (data.pointAxisCode2 >> 3) & 3;
					penetration = getPointBoxPenetrationAndCollisionPoint(box1, box2, data.pointAxisCode1 & 7, axisIndex2, _toFirst, _collisionPoint, _axis1);
				}
				if (penetration > tolerance) {
					data.collisionNormal.copy(_axis1);
					data.collisionPoint.copy(_collisionPoint);
					data.penetration = penetration > 0 ? penetration : 0;
				} else {
					return false;
				}
			}
			return true;
		}
		
		/**
		 * 
		 */
		private function getEdgesPenetrationAndCollisionPoint(box1:CollisionBox, box2:CollisionBox, axis1:Point3D, axisIndex1:int, pointIndex1:int, axis2:Point3D, axisIndex2:int, pointIndex2:int, toFirst:Point3D, collisionPoint:Point3D):Number {
			_point1.x = (pointIndex1 & 1) == 0 ? box1.halfSize.x : -box1.halfSize.x;
			_point1.y = (pointIndex1 & 2) == 0 ? box1.halfSize.y : -box1.halfSize.y;
			_point1.z = (pointIndex1 & 4) == 0 ? box1.halfSize.z : -box1.halfSize.z;
			_point1.transform(box1.transform);

			_point2.x = (pointIndex2 & 1) == 0 ? box2.halfSize.x : -box2.halfSize.x;
			_point2.y = (pointIndex2 & 2) == 0 ? box2.halfSize.y : -box2.halfSize.y;
			_point2.z = (pointIndex2 & 4) == 0 ? box2.halfSize.z : -box2.halfSize.z;
			_point2.transform(box2.transform);
			
			var k:Number = axis1.dot(axis2);
			var det:Number = k*k - 1;
			if (det > -0.0001 && det < 0.0001) {
				// Число по модулю должно быть быть больше, чем tolerance
				return -100;
			} else {
				collisionPoint.difference(_point2, _point1);
				var c1:Number = axis1.dot(collisionPoint);
				var c2:Number = axis2.dot(collisionPoint);
				var t1:Number = (c2*k - c1)/det;
				var size:Number = 2*(axisIndex1 == 0 ? box1.halfSize.x : (axisIndex1 == 1 ? box1.halfSize.y : box1.halfSize.z));
				if (t1 < 0 || t1 > size) {
					return -100;
				} else {
					var t2:Number = (c2 - c1*k)/det;
					size = 2*(axisIndex2 == 0 ? box2.halfSize.x : (axisIndex2 == 1 ? box2.halfSize.y : box2.halfSize.z));
					if (t2 < 0 || t2 > size) {
						return -100;
					} else {
						_point1.x += _axis1.x*t1;
						_point1.y += _axis1.y*t1;
						_point1.z += _axis1.z*t1;
						_point2.x += _axis2.x*t2;
						_point2.y += _axis2.y*t2;
						_point2.z += _axis2.z*t2;
						collisionPoint.x = 0.5*(_point1.x + _point2.x);
						collisionPoint.y = 0.5*(_point1.y + _point2.y);
						collisionPoint.z = 0.5*(_point1.z + _point2.z);
						_point1.subtract(_point2);
						return _point1.dot(toFirst) > 0 ? -_point1.length : _point1.length;
					}
				}
			}
			
			return -100;
		}
		
		/**
		 * 
		 * @param box1 бокс, вершина которого столкнулась с гранью второго бокса
		 * @param box2 бокс, грань которого столкнулась с вершиной второго бокса
		 * @param axisIndex1
		 * @param pointIndex2
		 * @param toCenter
		 * @param collisionPoint
		 * @return 
		 */
		private function getPointBoxPenetrationAndCollisionPoint(box1:CollisionBox, box2:CollisionBox, pointIndex1:int, axisIndex2:int, toFirst:Point3D, collisionPoint:Point3D, collisionNormal:Point3D):Number {
			// Локальные кординаты вершины
			_point1.x = (pointIndex1 & 1) == 0 ? box1.halfSize.x : -box1.halfSize.x;
			_point1.y = (pointIndex1 & 2) == 0 ? box1.halfSize.y : -box1.halfSize.y;
			_point1.z = (pointIndex1 & 4) == 0 ? box1.halfSize.z : -box1.halfSize.z;
			
			// размер второго бокса вдоль оси столкновения
			var size:Number;
			if (axisIndex2 == 0) {
				size = box2.halfSize.x;
			} else if (axisIndex2 == 1) {
				size = box2.halfSize.y;
			} else {
				size = box2.halfSize.z;
			}
			box2.transform.getAxis(axisIndex2, collisionNormal);
			var distance:Number = collisionNormal.dot(toFirst);
			if (distance < 0) {
				distance = -distance;
				collisionNormal.invert();
			}
			var m:Matrix3D = box1.transform;
			collisionPoint.x = m.a*_point1.x + m.b*_point1.y + m.c*_point1.z;
			collisionPoint.y = m.e*_point1.x + m.f*_point1.y + m.g*_point1.z;
			collisionPoint.z = m.i*_point1.x + m.j*_point1.y + m.k*_point1.z;
			var projection:Number = collisionNormal.dot(collisionPoint);
			var overlap:Number = size - projection - distance;
			if (overlap < tolerance) {
				return -100;
			}
			
			// Глобальные координаты вершины
			collisionPoint.x += m.d;
			collisionPoint.y += m.h;
			collisionPoint.z += m.l;
			
			// Координтаы вершины в системе второго бокса
			_point2.copy(collisionPoint);
			_point2.inverseTransform(box2.transform);
			// Проверка на принадлежность вершины боксу
			if (_point2.x < 0) {
				_point2.x = -_point2.x;
			}
			if (_point2.y < 0) {
				_point2.y = -_point2.y;
			}
			if (_point2.y < 0) {
				_point2.y = -_point2.y;
			}
			if ((_point2.x + tolerance > box2.halfSize.x) || (_point2.y + tolerance > box2.halfSize.y) || (_point2.z + tolerance > box2.halfSize.z)) {
				return -100;
			}

			return overlap;
		}

	}
}
