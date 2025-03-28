package alternativa.gui.layout.snap {
	import alternativa.gui.base.IHelper;
	import alternativa.gui.base.MoveableBase;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	/**
	 * Базовый снапер. Установливается для компоновщиков объектов внутри контейнера.
	 */	
	public class SnapHelperBase implements IHelper, ISnapHelper {
		
		// Флаг общего включения/отключения прилипания
		private var _snapEnabled:Boolean;
		
		// Массив флагов снапинга объектов (для сохранения при отключении)
		private var objectsSnapEnabledFlags:Dictionary;
		
		// Расстояние срабатывания прилипания 
		private var _snapSensitivity:Number;
		
		// Расстояние между слипшимися объектами
		private var _snapSpace:Number;
		
		// Слипающиеся объекты
		private var objects:Array;
		
		// Габариты объектов
		private var objectSnapRect:Dictionary;
		
		// Габариты объектов
		private var objectPresaveSnapRect:Dictionary;
		
		// Область отрисовки инфографики
		private var _graphics:Graphics;
		
		
		
		public function SnapHelperBase(snapSensitivity:Number, snapSpace:Number) {
			_snapSensitivity = snapSensitivity;
			_snapSpace = snapSpace;
			_snapEnabled = true;
			objects = new Array();
			objectSnapRect = new Dictionary(false);
			objectPresaveSnapRect = new Dictionary(false);
		}
		
		/**
		 * Добавить объект на прилипание 
		 * @param object - объект, реализующий ISnapable
		 */		
		public function addObject(object:Object):void {
			if (object is ISnapable && objects.indexOf(object) == -1) {
				objects.push(object);
				var rect:Rectangle = (ISnapable(object).snapRect != null) ? ISnapable(object).snapRect : new Rectangle();
				// переводим в глобальные коордиинаты
				var globalCoord:Point = DisplayObject(object).localToGlobal(new Point(rect.x, rect.y));
				rect.x = globalCoord.x;
				rect.y = globalCoord.y;
				var snapRect:SnapRect = new SnapRect(rect.x, rect.y, rect.width, rect.height);
				objectSnapRect[object] = snapRect;
				// перерисовка
				redraw();
			}
		}
		
		/**
		 * Удалить объект из списка корректируемых объектов 
		 * @param object - объект
		 */		
		public function removeObject(object:Object):void {
			var index:int = objects.indexOf(object);
			if (index != -1) {
				objectSnapRect[object] = null;
				objects.splice(index, 1);
				// перерисовка
				redraw();
			}
		}
		
		/**
		 * Скорректировать воздействия для объектов
		 * @param objects - список объектов
		 * @param influences - список воздействий
		 * @return список скорректированных воздействий
		 */		
		public function correctInfluence(objects:Array, influences:Array):Array {
			//trace("SnapHelperBase correctInfluence");
			//trace("SnapHelperBase correctInfluence objects:" + objects);
			//trace("SnapHelperBase correctInfluence influences:" + influences);
			var resultInfluences:Array = new Array();
			
			for (var i:int = 0; i < objects.length; i++) {
				if (this.objects.indexOf(objects[i]) != -1) {
					var snapRect:SnapRect = SnapRect(objectSnapRect[objects[i]]);
					
					if (influences[i] is Point) {
						// MOVE
						var shift:Point = Point(influences[i]);
						var rect:Rectangle = new Rectangle(snapRect.x + shift.x, snapRect.y + shift.y, snapRect.width, snapRect.height);
						var newSnapRect:SnapRect = checkSnapRect(ISnapable(objects[i]), rect, Snap.NONE); 
						// предсохранение snapRect
						objectPresaveSnapRect[objects[i]] = newSnapRect;
						// Корректировка смещения
						shift = shift.add(new Point(newSnapRect.x - rect.x, newSnapRect.y - rect.y));
						// Сохранение данных о залипании в воздействие
						var snapShift:SnapPoint = new SnapPoint(shift.x, shift.y);
						snapShift.snapedSides = newSnapRect.snapedSides;
						for (var m:int = 0; m < 8; m++) {
							for (var n:int = 0; n < newSnapRect.snapedObjects[m].length; n++) {
								snapShift.snapedObjects[m][n] = newSnapRect.snapedObjects[m][n];
								snapShift.snapedObjectsSides[m][n] = newSnapRect.snapedObjectsSides[m][n];
							}
						}
						resultInfluences[i] = snapShift;
						
					} else if (influences[i] is Rectangle) {
						// RESIZE
						var sizeDelta:Rectangle = Rectangle(influences[i]);
						// Стороны, не участвующие в проверке на прилипание (в формате битовых констант Snap)
						var lockedSnapSides:int = Snap.NONE;
						if (sizeDelta.width == 0) {
							if (sizeDelta.y == 0)
								lockedSnapSides = Snap.TOP;
							else
								lockedSnapSides = Snap.BOTTOM;
						} else if (sizeDelta.height == 0) {
							if (sizeDelta.x == 0)
								lockedSnapSides = Snap.LEFT;
							else
								lockedSnapSides = Snap.RIGHT;
						}
						var rect:Rectangle = new Rectangle(snapRect.x + sizeDelta.x, snapRect.y + sizeDelta.y, snapRect.width + sizeDelta.width, snapRect.height + sizeDelta.height);
						var newSnapRect:SnapRect = checkSnapRect(ISnapable(objects[i]), rect, lockedSnapSides);
						
						var dx:int = newSnapRect.x - rect.x;
						var dy:int = newSnapRect.y - rect.y;
						/*if (dx != 0 || dy != 0) {
							trace("dx: " + dx);
							trace("dy: " + dy);
						}*/
						
						// Определяем смещения по координатам и размерам
						var delta:Rectangle = new Rectangle();
						if (newSnapRect.snapedSides & Snap.LEFT) {
							delta.x += dx;
							delta.width -= dx;
						}
						if (newSnapRect.snapedSides & Snap.TOP) {
							delta.y += dy;
							delta.height -= dy;
						}
						if (newSnapRect.snapedSides & Snap.RIGHT) {
							delta.width += dx;
						}
						if (newSnapRect.snapedSides & Snap.BOTTOM) {
							delta.height += dy;
						}
						// Корректировка воздействия
						sizeDelta.x += delta.x;
						sizeDelta.y += delta.y;
						sizeDelta.width += delta.width;
						sizeDelta.height += delta.height;
						
						// предсохранение snapRect
						newSnapRect.x = snapRect.x + sizeDelta.x;
						newSnapRect.y = snapRect.y + sizeDelta.y;
						newSnapRect.width = snapRect.width + sizeDelta.width;
						newSnapRect.height = snapRect.height + sizeDelta.height;
						objectPresaveSnapRect[objects[i]] = newSnapRect;
						
						// Сохранение данных о залипании в воздействие
						var snapSizeDelta:SnapRect = new SnapRect(sizeDelta.x, sizeDelta.y, sizeDelta.width, sizeDelta.height);
						snapSizeDelta.snapedSides = newSnapRect.snapedSides;
						snapSizeDelta.snapedSides = snapSizeDelta.snapedSides | (snapRect.snapedSides & lockedSnapSides);
						for (var m:int = 0; m < 8; m++) {
							for (var n:int = 0; n < newSnapRect.snapedObjects[m].length; n++) {
								snapSizeDelta.snapedObjects[m][n] = newSnapRect.snapedObjects[m][n];
								snapSizeDelta.snapedObjectsSides[m][n] = newSnapRect.snapedObjectsSides[m][n];
							}
						}
						resultInfluences[i] = snapSizeDelta;
					}
				} else {
					// не наш объект
					resultInfluences[i] = influences[i];
				}
			}
			return resultInfluences;
		}
		
		/**
		 * Сохранить воздействия для объектов
		 * @param objects - список объектов
		 * @param influences - список воздействий
		 */		
		public function saveInfluence(objects:Array, influences:Array):void {
			//trace("SnapHelperBase saveInfluence");
			//trace("SnapHelperBase saveInfluence objects: " + objects);
			//trace("SnapHelperBase saveInfluence influences: " + influences);
			for (var i:int = 0; i < objects.length; i++) {
				if (this.objects.indexOf(objects[i]) != -1) {
					var snapRect:SnapRect = SnapRect(objectSnapRect[objects[i]]);
					var preSnapRect:SnapRect = SnapRect(objectPresaveSnapRect[objects[i]]);
					
					if (influences[i] is Point) {
						// MOVE
						var shift:Point = Point(influences[i]);
						if (preSnapRect != null) {
							if ((snapRect.x + shift.x) == preSnapRect.x && (snapRect.y + shift.y) == preSnapRect.y) {
								changeSnapRect(ISnapable(objects[i]), preSnapRect);
							} else {
								snapRect.x += shift.x;
								snapRect.y += shift.y;
							}
						} else {
							snapRect.x += shift.x;
							snapRect.y += shift.y;
						}
					} else if (influences[i] is Rectangle) {
						// RESIZE
						var sizeDelta:Rectangle = Rectangle(influences[i]);
						if (preSnapRect != null) {
							if ((snapRect.x + sizeDelta.x) == preSnapRect.x
							 && (snapRect.y + sizeDelta.y) == preSnapRect.y
							 && (snapRect.width + sizeDelta.width) == preSnapRect.width
							 && (snapRect.height + sizeDelta.height) == preSnapRect.height) {
								changeSnapRect(ISnapable(objects[i]), preSnapRect);
							} else {
								snapRect.x += sizeDelta.x;
								snapRect.y += sizeDelta.y;
								snapRect.width += sizeDelta.width;
								snapRect.height += sizeDelta.height;
							}
						} else {
							snapRect.x += sizeDelta.x;
							snapRect.y += sizeDelta.y;
							snapRect.width += sizeDelta.width;
							snapRect.height += sizeDelta.height;
						}
						
					}
				}
			}
			// перерисовка
			redraw();
		}
		
		
		/**
		 * Проверить габаритный прямоугольник объекта на прилипание
		 * к габаритным прямоугольникам других объектов, добавленных на прилипание
		 * 
		 * @param object - ISnapable объект
		 * @param rect - габаритный прямоугольник на проверку (в глобальных координатах)
		 * @param lockedSides - стороны, не участвующие в проверке на прилипание (в формате битовых констант Snap)
		 * @return габаритный прямоугольник с учетом прилипания (в глобальных координатах)
		 * и с информацией о том, какие именно стороны залипли (в формате битовых констант Snap)
		 */		
		private function checkSnapRect(object:ISnapable, rect:Rectangle, lockedSides:int):SnapRect {
			var newSnapRect:SnapRect = new SnapRect(rect.x, rect.y, rect.width, rect.height);
			var objectSides:int = object.snapConfig & (~lockedSides);
			
			// проверка на пересечение прямоугольников
			for (var i:int = 0; i < objects.length; i++) {
				var testObject:ISnapable = ISnapable(objects[i]);
				if (testObject != object && testObject.snapEnabled && testObject.snapConfig != Snap.NONE) {
					// Изначально устанавливаем на проверку стороны снапинга проверяемого объекта,
					// затем условиями будем отсекать стороны, которые заведомо не стоит проверять
					var checkSides:int = testObject.snapConfig;
					
					// отсекаем стороны, исходя из относительного положения объектов
					var testObjectRect:Rectangle = Rectangle(objectSnapRect[testObject]).clone();
					
					var objX1:int = newSnapRect.x;
					var objX2:int = newSnapRect.x + newSnapRect.width;
					var testObjX1:int = testObjectRect.x;
					var testObjX2:int = testObjectRect.x + testObjectRect.width;
					
					var objY1:int = newSnapRect.y;
					var objY2:int = newSnapRect.y + newSnapRect.height;
					var testObjY1:int = testObjectRect.y;
					var testObjY2:int = testObjectRect.y + testObjectRect.height;
					
					// поиск пересечений полос объектов
					// Проверяем на пересечение по горизонтали 
					if (cross(objY1, objY2, testObjY1, testObjY2)) {
						//trace("cross Horizontal");
						if ((objX1 > testObjX2 + _snapSensitivity) || (testObjX1 > objX2 + _snapSensitivity)) {
							checkSides = checkSides & Snap.EXT_LEFT_RESET & Snap.EXT_RIGHT_RESET & Snap.INT_LEFT_RESET & Snap.INT_RIGHT_RESET;
						}
					} else {
						checkSides = checkSides & Snap.EXT_LEFT_RESET & Snap.EXT_RIGHT_RESET & Snap.INT_LEFT_RESET & Snap.INT_RIGHT_RESET;
					}
					// Проверяем на пересечение по вертикали
					if (cross(objX1, objX2, testObjX1, testObjX2)) {
						//trace("cross Vertical");
						if ((objY1 > testObjY2 + _snapSensitivity) || (testObjY1 > objY2 + _snapSensitivity)) {
							checkSides = checkSides & Snap.EXT_TOP_RESET & Snap.EXT_BOTTOM_RESET & Snap.INT_TOP_RESET & Snap.INT_BOTTOM_RESET;
						}
					} else {
						checkSides = checkSides & Snap.EXT_TOP_RESET & Snap.EXT_BOTTOM_RESET & Snap.INT_TOP_RESET & Snap.INT_BOTTOM_RESET;
					}
					
					// проверка по сторонам тестового объекта (указанным в checkSides)
					if (checkSides != 0) {
						//----- EXTERNAL
						if (int(checkSides & Snap.EXTERNAL) != 0) {
							// LEFT
							if (checkSides & Snap.EXT_LEFT) {
								if (objectSides & Snap.EXT_RIGHT) {
									if (near(testObjX1, objX2)) {
										newSnapRect.x = testObjectRect.x - _snapSpace - newSnapRect.width;
										newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.EXT_RIGHT;
										newSnapRect.snapedObjects[SnapRect.EXT_RIGHT_SIDE].push(testObject);
										newSnapRect.snapedObjectsSides[SnapRect.EXT_RIGHT_SIDE].push(SnapRect.EXT_LEFT_SIDE);
									}
								}
								if (objectSides & Snap.INT_LEFT) {
									if (near(testObjX1, objX1)) {
										newSnapRect.x = testObjectRect.x;
										newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.INT_LEFT;
										newSnapRect.snapedObjects[SnapRect.INT_LEFT_SIDE].push(testObject);
										newSnapRect.snapedObjectsSides[SnapRect.INT_LEFT_SIDE].push(SnapRect.EXT_LEFT_SIDE);
									}
								}
							}
							// TOP
							if (checkSides & Snap.EXT_TOP) {
								if (objectSides & Snap.EXT_BOTTOM) {
									if (near(testObjY1, objY2)) {
										newSnapRect.y = testObjectRect.y - _snapSpace - newSnapRect.height;
										newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.EXT_BOTTOM;
										newSnapRect.snapedObjects[SnapRect.EXT_BOTTOM_SIDE].push(testObject);
										newSnapRect.snapedObjectsSides[SnapRect.EXT_BOTTOM_SIDE].push(SnapRect.EXT_TOP_SIDE);
									}
								}
								if (objectSides & Snap.INT_TOP) {
									if (near(testObjY1, objY1)) {
										newSnapRect.y = testObjectRect.y;
										newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.INT_TOP;
										newSnapRect.snapedObjects[SnapRect.INT_TOP_SIDE].push(testObject);
										newSnapRect.snapedObjectsSides[SnapRect.INT_TOP_SIDE].push(SnapRect.EXT_TOP_SIDE);
									}
								}
							}
							// RIGHT
							if (checkSides & Snap.EXT_RIGHT) {
								if (objectSides & Snap.EXT_LEFT) {
									if (near(testObjX2, objX1)) {
										newSnapRect.x = testObjectRect.x + testObjectRect.width + _snapSpace;
										newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.EXT_LEFT;
										newSnapRect.snapedObjects[SnapRect.EXT_LEFT_SIDE].push(testObject);
										newSnapRect.snapedObjectsSides[SnapRect.EXT_LEFT_SIDE].push(SnapRect.EXT_RIGHT_SIDE);
									}
								}
								if (objectSides & Snap.INT_RIGHT) {
									if (near(testObjX2, objX2)) {
										newSnapRect.x = testObjectRect.x + testObjectRect.width - newSnapRect.width;
										newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.INT_RIGHT;
										newSnapRect.snapedObjects[SnapRect.INT_RIGHT_SIDE].push(testObject);
										newSnapRect.snapedObjectsSides[SnapRect.INT_RIGHT_SIDE].push(SnapRect.EXT_RIGHT_SIDE);
									}
								}
							}
							// BOTTOM
							if (checkSides & Snap.EXT_BOTTOM) {
								if (objectSides & Snap.EXT_TOP) {
									if (near(testObjY2, objY1)) {
										newSnapRect.y = testObjectRect.y + testObjectRect.height + _snapSpace;
										newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.EXT_TOP;
										newSnapRect.snapedObjects[SnapRect.EXT_TOP_SIDE].push(testObject);
										newSnapRect.snapedObjectsSides[SnapRect.EXT_TOP_SIDE].push(SnapRect.EXT_BOTTOM_SIDE);
									}
								}
								if (objectSides & Snap.INT_BOTTOM) {
									if (near(testObjY2, objY2)) {
										newSnapRect.y = testObjectRect.y + testObjectRect.height - newSnapRect.height;
										newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.INT_BOTTOM;
										newSnapRect.snapedObjects[SnapRect.INT_BOTTOM_SIDE].push(testObject);
										newSnapRect.snapedObjectsSides[SnapRect.INT_BOTTOM_SIDE].push(SnapRect.EXT_BOTTOM_SIDE);
									}
								}
							}
						}
						//----- INTERNAL
						if (int(checkSides & Snap.INTERNAL) != 0) {
							// LEFT
							if ((checkSides & Snap.INT_LEFT) && (objectSides & Snap.EXT_LEFT)) {
								if (near(testObjX1, objX1)) {
									newSnapRect.x = testObjectRect.x;
									newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.EXT_LEFT;
									newSnapRect.snapedObjects[SnapRect.EXT_LEFT_SIDE].push(testObject);
									newSnapRect.snapedObjectsSides[SnapRect.EXT_LEFT_SIDE].push(SnapRect.INT_LEFT_SIDE);
								}
							}
							// TOP
							if ((checkSides & Snap.INT_TOP) && (objectSides & Snap.EXT_TOP)) {
								if (near(testObjY1, objY1)) {
									newSnapRect.y = testObjectRect.y;
									newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.EXT_TOP;
									newSnapRect.snapedObjects[SnapRect.EXT_TOP_SIDE].push(testObject);
									newSnapRect.snapedObjectsSides[SnapRect.EXT_TOP_SIDE].push(SnapRect.INT_TOP_SIDE);
								}
							}
							// RIGHT
							if ((checkSides & Snap.INT_RIGHT) && (objectSides & Snap.EXT_RIGHT)) {
								if (near(testObjX2, objX2)) {
									newSnapRect.x = testObjectRect.x + testObjectRect.width - newSnapRect.width;
									newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.EXT_RIGHT;
									newSnapRect.snapedObjects[SnapRect.EXT_RIGHT_SIDE].push(testObject);
									newSnapRect.snapedObjectsSides[SnapRect.EXT_RIGHT_SIDE].push(SnapRect.INT_RIGHT_SIDE);
								}
							}
							// BOTTOM
							if ((checkSides & Snap.INT_BOTTOM) && (objectSides & Snap.EXT_BOTTOM)) {
								if (near(testObjY2, objY2)) {
									newSnapRect.y = testObjectRect.y + testObjectRect.height - newSnapRect.height;
									newSnapRect.snapedSides = newSnapRect.snapedSides | Snap.EXT_BOTTOM;
									newSnapRect.snapedObjects[SnapRect.EXT_BOTTOM_SIDE].push(testObject);
									newSnapRect.snapedObjectsSides[SnapRect.EXT_BOTTOM_SIDE].push(SnapRect.INT_BOTTOM_SIDE);
								}
							}
						}
					}
					
				}
			}
			return newSnapRect;
		}
		
		/**
		 * Сохранить новый габаритный прямоугольник
		 * @param object - объект, с измененным прямоугольником
		 * @param rect - новый габаритный прямоугольник (в глобальных координатах)
		 */
		private function changeSnapRect(object:ISnapable, rect:SnapRect):void {
			var oldRect:SnapRect = (objectSnapRect[object] != null) ? SnapRect(objectSnapRect[object]) : new SnapRect();
			// Анализ сторон, где изменилось залипание
			for (var i:int = 0; i < 8; i++) {
				if (rect.snapedObjects[i].length != oldRect.snapedObjects[i].length) {
					
					if (rect.snapedObjects[i].length < oldRect.snapedObjects[i].length) {
						// disconnect
						var disconnectedObjects:Array = new Array();
						for (var j:int = 0; j < oldRect.snapedObjects[i].length; j++) {
							if (rect.snapedObjects[i].indexOf(oldRect.snapedObjects[i][j]) == -1) {
								var disconnected:ISnapable = ISnapable(oldRect.snapedObjects[i][j]);
								var disconnectedSide:int = oldRect.snapedObjectsSides[i][j];
								var disconnectedSnapRect:SnapRect = SnapRect(objectSnapRect[disconnected]);
								
								var doNotDisconnectThisObject:Boolean = false;
								var resetBitMask:int = 1;
								for (var m:int = 0; m < 8; m++) {
									for (var n:int = 0; n < disconnectedSnapRect.snapedObjects[m].length; n++) {
										if (disconnectedSnapRect.snapedObjects[m][n] == object) {
											if (m == disconnectedSide) {
												disconnectedSnapRect.snapedObjects[m].splice(n, 1);
												disconnectedSnapRect.snapedObjectsSides[m].splice(n, 1);
												if (disconnectedSnapRect.snapedObjects[m].length == 0) {
													disconnectedSnapRect.snapedSides = disconnectedSnapRect.snapedSides & (resetBitMask ^ 255);
												}
											} else {
												doNotDisconnectThisObject = true;
											}
										}
									}
									resetBitMask = 2*resetBitMask;
								}
								if (!doNotDisconnectThisObject) {
									disconnectedObjects.push(disconnected);
								}
							}
						}
						
						// работа с группами
						/*if (_groupEnabled && object is ISnapGroupable) {
							if (ISnapGroupable(object).groupEnabled && ISnapGroupable(object).snapGroup != null) {
								for (var d:int = 0; d < disconnectedObjects.length; d++) {
									if (disconnectedObjects[d] is ISnapGroupable) {
										if (ISnapGroupable(disconnectedObjects[d]).snapGroup != null) {
											// Надо проверить, не осталось ли других соединений с отснапившимся объектом
											/*var doNotRemoveLinkToThisObject:Boolean = false;
											for (var m:int = 0; m < 8; m++) {
												for (var n:int = 0; n < ISnapable(disconnectedObjects[d]).snapRect.snapedObjects[m].length; n++) {
													if (ISnapable(disconnectedObjects[d]).snapRect.snapedObjects[m][n] == object) {
														doNotRemoveLinkToThisObject = true;
													}
												}
											}
											if (!doNotRemoveLinkToThisObject)*/
												/*ISnapGroupable(object).snapGroup.removeLink(ISnapGroupable(object), ISnapGroupable(disconnectedObjects[d]));
										}
									}
								}
								if (ISnapGroupable(object).snapGroup != null)
									trace("object snapGroup: " + ISnapGroupable(object).snapGroup.id);
								else
									trace("object snapGroup: NONE");
							}
						}*/
					} else {
						// connect
						var connectedObjects:Array = new Array();
						for (var j:int = 0; j < rect.snapedObjects[i].length; j++) {
							if (oldRect.snapedObjects[i].indexOf(rect.snapedObjects[i][j]) == -1) {
								var snapedObject:ISnapable = ISnapable(rect.snapedObjects[i][j]);
								connectedObjects.push(snapedObject);
								//trace("connect to object: " + snapedObject);
								var snapedObjectRect:SnapRect = SnapRect(objectSnapRect[snapedObject]);
								
								var objX1:int = rect.x;
								var objX2:int = rect.x + rect.width;
								var snapedObjX1:int = snapedObjectRect.x;
								var snapedObjX2:int = snapedObjectRect.x + snapedObjectRect.width;
								
								var objY1:int = rect.y;
								var objY2:int = rect.y + rect.height;
								var snapedObjY1:int = snapedObjectRect.y;
								var snapedObjY2:int = snapedObjectRect.y + snapedObjectRect.height;
								
								// сохраняем данные о коннекте
								switch (i) {
									// EXT_LEFT
									case 0:
										if (near(objX1, snapedObjX2)) {
											setConnect(object, snapedObject, Snap.EXT_RIGHT, SnapRect.EXT_RIGHT_SIDE);
											//saveConnectSide(object, i, j, SnapRect.EXT_RIGHT_SIDE);
										} else {
											setConnect(object, snapedObject, Snap.INT_LEFT, SnapRect.INT_LEFT_SIDE);
											//saveConnectSide(object, i, j, SnapRect.INT_LEFT_SIDE);
										}
										break;
									// EXT_TOP
									case 1:
										if (near(objY1, snapedObjY2)) {
											setConnect(object, snapedObject, Snap.EXT_BOTTOM, SnapRect.EXT_BOTTOM_SIDE);
											//saveConnectSide(object, i, j, SnapRect.EXT_BOTTOM_SIDE);
										} else {
											setConnect(object, snapedObject, Snap.INT_TOP, SnapRect.INT_TOP_SIDE);
											//saveConnectSide(object, i, j, SnapRect.INT_TOP_SIDE);
										}
										break;
									// EXT_RIGHT
									case 2:
										if (near(objX2, snapedObjX1)) {
											setConnect(object, snapedObject, Snap.EXT_LEFT, SnapRect.EXT_LEFT_SIDE);
											//saveConnectSide(object, i, j, SnapRect.EXT_LEFT_SIDE);
										} else {
											setConnect(object, snapedObject, Snap.INT_RIGHT, SnapRect.INT_RIGHT_SIDE);
											//saveConnectSide(object, i, j, SnapRect.INT_RIGHT_SIDE);
										}
										break;
									// EXT_BOTTOM
									case 3:
										if (near(objY2, snapedObjY1)) {
											setConnect(object, snapedObject, Snap.EXT_TOP, SnapRect.EXT_TOP_SIDE);
											//saveConnectSide(object, i, j, SnapRect.EXT_TOP_SIDE);
										} else {
											setConnect(object, snapedObject, Snap.INT_BOTTOM, SnapRect.INT_BOTTOM_SIDE);
											//saveConnectSide(object, i, j, SnapRect.INT_BOTTOM_SIDE);
										}
										break;
									// INT_LEFT
									case 4:
										setConnect(object, snapedObject, Snap.EXT_LEFT, SnapRect.EXT_LEFT_SIDE);
										//saveConnectSide(object, i, j, SnapRect.EXT_LEFT_SIDE);
										break;
									// INT_TOP
									case 5:
										setConnect(object, snapedObject, Snap.EXT_TOP, SnapRect.EXT_TOP_SIDE);
										//saveConnectSide(object, i, j, SnapRect.EXT_TOP_SIDE);
										break;
									// INT_RIGHT
									case 6:
										setConnect(object, snapedObject, Snap.EXT_RIGHT, SnapRect.EXT_RIGHT_SIDE);
										//saveConnectSide(object, i, j, SnapRect.EXT_RIGHT_SIDE);
										break;
									// INT_BOTTOM
									case 7:
										setConnect(object, snapedObject, Snap.EXT_BOTTOM, SnapRect.EXT_BOTTOM_SIDE);
										//saveConnectSide(object, i, j, SnapRect.EXT_BOTTOM_SIDE);
										break;
								}
							}
						}
						
						// работа с группами
						/*if (_groupEnabled && object is ISnapGroupable) {
							if (ISnapGroupable(object).groupEnabled) {
								if (ISnapGroupable(object).snapGroup != null) {
									for (var c:int = 0; c < connectedObjects.length; c++) {
										if (connectedObjects[c] is ISnapGroupable) {
											if (ISnapGroupable(connectedObjects[c]).groupEnabled) {
												if (ISnapGroupable(connectedObjects[c]).snapGroup == null) {
													ISnapGroupable(object).snapGroup.addObject(ISnapGroupable(connectedObjects[c]), new SnapGroupLink(ISnapGroupable(object), ISnapGroupable(connectedObjects[c])));
												} else {
													if (ISnapGroupable(connectedObjects[c]).snapGroup != ISnapGroupable(object).snapGroup)
														ISnapGroupable(object).snapGroup.mergeGroup(ISnapGroupable(connectedObjects[c]).snapGroup);
													ISnapGroupable(object).snapGroup.addLink(new SnapGroupLink(ISnapGroupable(object), ISnapGroupable(connectedObjects[c])));
												}
											}
										}
									}
								} else {
									var group:SnapGroup;
									if (connectedObjects.length == 1) {
										// Прилипли к одному объекту
										if (connectedObjects[0] is ISnapGroupable) {
											if (ISnapGroupable(connectedObjects[0]).groupEnabled) {
												if (ISnapGroupable(connectedObjects[0]).snapGroup != null) {
													ISnapGroupable(connectedObjects[0]).snapGroup.addObject(ISnapGroupable(object), new SnapGroupLink(ISnapGroupable(object), ISnapGroupable(connectedObjects[0])));
												} else {
													group = new SnapGroup();
													group.addObject(ISnapGroupable(object));
													group.addObject(ISnapGroupable(connectedObjects[0]), new SnapGroupLink(ISnapGroupable(object), ISnapGroupable(connectedObjects[0])));
												}												
											}
										}
									} else {
										// Прилипли к нескольким объектам
										var groups:Array = new Array();
										for (var i:int = 0; i < connectedObjects.length; i++) {
											if (connectedObjects[i] is ISnapGroupable) {
												if (ISnapGroupable(connectedObjects[i]).groupEnabled && ISnapGroupable(connectedObjects[i]).snapGroup != null && groups.indexOf(ISnapGroupable(connectedObjects[i]).snapGroup) == -1) {
													groups.push(ISnapGroupable(connectedObjects[i]).snapGroup);
												}
											}
										}
										if (groups.length == 0) {
											// Создание новой группы
											group = new SnapGroup();
											group.addObject(ISnapGroupable(object));
											for (var c:int = 0; c < connectedObjects.length; c++) {
												if (connectedObjects[c] is ISnapGroupable) {
													if (ISnapGroupable(connectedObjects[c]).groupEnabled) {
														group.addObject(ISnapGroupable(connectedObjects[c]), new SnapGroupLink(ISnapGroupable(object), ISnapGroupable(connectedObjects[c])));
													}
												}
											}
										} else if (groups.length == 1) {
											// Подключение к уже имеющейся группе
											var added:Boolean = false;
											for (var c:int = 0; c < connectedObjects.length; c++) {
												if (connectedObjects[c] is ISnapGroupable) {
													if (ISnapGroupable(connectedObjects[c]).groupEnabled) {
														if (ISnapGroupable(connectedObjects[c]).snapGroup != null) {
															if (!added) {
																SnapGroup(groups[0]).addObject(ISnapGroupable(object), new SnapGroupLink(ISnapGroupable(object), ISnapGroupable(connectedObjects[c])));
																added = true;
															} else {
																SnapGroup(groups[0]).addLink(new SnapGroupLink(ISnapGroupable(object), ISnapGroupable(connectedObjects[c])));
															}
														} else {
															SnapGroup(groups[0]).addObject(ISnapGroupable(connectedObjects[c]), new SnapGroupLink(ISnapGroupable(object), ISnapGroupable(connectedObjects[c])));
														}	
													}
												}
											}
										} else {
											// Объединение нескольких групп
											group = new SnapGroup();
											group.addObject(ISnapGroupable(object));
											for (var g:int = 0; g < groups.length; g++) {
												group.mergeGroup(SnapGroup(groups[g]));
											}
											for (var c:int = 0; c < connectedObjects.length; c++) {
												if (connectedObjects[c] is ISnapGroupable) {
													if (ISnapGroupable(connectedObjects[c]).groupEnabled) {
														if (ISnapGroupable(connectedObjects[c]).snapGroup == null) {
															group.addObject(ISnapGroupable(connectedObjects[c]), new SnapGroupLink(ISnapGroupable(object), ISnapGroupable(connectedObjects[c])));
														}
													}
												}
											}
										}
									}
								}
								if (ISnapGroupable(object).snapGroup != null)
									trace("object snapGroup: " + ISnapGroupable(object).snapGroup.id);
								else
									trace("object snapGroup: NONE");
							}
						}*/
						// autoTOP
						for (var c:int = 0; c < connectedObjects.length; c++) {
							if (connectedObjects[c] is MoveableBase && connectedObjects[c] is ISnapGroupable && object is ISnapGroupable) {
								if (MoveableBase(connectedObjects[c]).autoTopEnabled && ISnapGroupable(connectedObjects[c]).groupEnabled && ISnapGroupable(connectedObjects[c]).snapGroup == ISnapGroupable(object).snapGroup) {
									var connectedParent:DisplayObjectContainer = DisplayObject(connectedObjects[c]).parent;
									if (connectedParent.getChildIndex(DisplayObject(connectedObjects[c])) < connectedParent.numChildren - 2) {
										connectedParent.setChildIndex(DisplayObject(connectedObjects[c]), connectedParent.numChildren - 2);
									}
								}
							}
						}
					}
			
				}
			}
			// Сохранение
			objectSnapRect[object] = rect;
			// Перерисовка
			//redraw();
		}
		
		/**
		 * Установка snapedSides и snapedObjects в объекте, к которому прилипли
		 * @param object - объект, который прилип
		 * @param snapedObject - объект, к которому прилипли
		 * @param side - сторона, к которой прилипли (в константах Snap)
		 * @param rectSide - сторона, к которой прилипли (в константах SnapRect)
		 */		
		private function setConnect(object:ISnapable, snapedObject:ISnapable, side:int, rectSide:int):void {
			SnapRect(objectSnapRect[snapedObject]).snapedSides = SnapRect(objectSnapRect[snapedObject]).snapedSides | side;
			SnapRect(objectSnapRect[snapedObject]).snapedObjects[rectSide].push(object);
		}
		
		/**
		 * Сохранение стороны, к которой прилипли
		 * @param object - объект, который прилип
		 * @param sideIndex - сторона, которой прилипли (в константах SnapRect)
		 * @param objectIndex - объект, к которому прилипли
		 * @param snapedSide - сторона объекта, к которой прилипли (в константах SnapRect)
		 */		
		/*private function saveConnectSide(object:ISnapable, sideIndex:int, objectIndex:int, snapedSide:int):void {
			object.snapRect.snapedObjectsSides[sideIndex][objectIndex] = snapedSide;
			SnapRect(objectSnapRect[object]).snapedObjectsSides[sideIndex][objectIndex] = snapedSide;
		}*/
		
		// Проверка на наложение объектов a и b (по горизонтали или вертикали)
		private function cross(a1:int, a2:int, b1:int, b2:int):Boolean {
			return (a1 >= b1 && a1 <= b2) || (a2 >= b1 && a2 <= b2) || (a1 >= b1 && a2 <= b2) || (b1 >= a1 && b2 <= a2);
		}
		
		// Проверка на попадание в область чувствительности (по горизонтали или вертикали)
		private function near(a:int, b:int):Boolean {
			return Math.abs(a - b) <= _snapSensitivity;
		}
		
		// Каким объектам принадлежит точка (в абсолютных координатах)
		/*public function getObjectsUnderPoint(p:Point):Array {
			var underPointObjects:Array = new Array(); 
			
			for (var i:int = 0; i < objects.length; i++) {
				var object:ISnapable = ISnapable(objects[i]);
				var rect:Rectangle = Rectangle(objectSnapRect[object]);
				if (p.x > rect.x && p.x < (rect.x + rect.width) && p.y > rect.y && p.y < (rect.y + rect.height)) {
					underPointObjects.push(object);
				}
			}
			return underPointObjects;
		}*/
		
		// В прямоугольнике какого объекта лежит точка
		/*public function getPointParentObject(p:Point, objects:Array):ISnapable {
			var left:int = 10000;
			var top:int = 10000;
			var right:int = 10000;
			var bottom:int = 10000;
			
			var nearestObjects:Array = new Array();
			// 0 - left
			// 1 - top
			// 2 - right
			// 3 - bottom
			for (var i:int = 0; i < objects.length; i++) {
				var object:ISnapable = ISnapable(objects[i]);
				var rect:Rectangle = Rectangle(objectSnapRect[object]);
				// LEFT
				if ((p.x - rect.x) < left) {
					left = p.x - rect.x;
					nearestObjects[0] = object;
				}
				// TOP
				if ((p.y - rect.y) < top) {
					top = p.y - rect.y;
					nearestObjects[1] = object;
				}
				// RIGHT
				if ((rect.x + rect.width - p.x) < right) {
					right = rect.x + rect.width - p.x;
					nearestObjects[2] = object;
				}
				// BOTTOM
				if ((rect.y + rect.height - p.y) < bottom) { 
					bottom = rect.y + rect.height - p.y;
					nearestObjects[3] = object;
				}
			}
			// выбор объекта, ближайшего по сумме 4-х сторон
			var objectsNearestSidesNum:Array = new Array();
			// индекс выбранного объекта
			var maxNum:int = 0;
			var n:int;
			for (var i:int = 0; i < objects.length; i++) {
				object = ISnapable(objects[i]);
				objectsNearestSidesNum[i] = 0;
				if (nearestObjects[0] == object) objectsNearestSidesNum[i] += 1;
				if (nearestObjects[1] == object) objectsNearestSidesNum[i] += 1;
				if (nearestObjects[2] == object) objectsNearestSidesNum[i] += 1;
				if (nearestObjects[3] == object) objectsNearestSidesNum[i] += 1;
				
				if (objectsNearestSidesNum[i] > maxNum) {
					maxNum = objectsNearestSidesNum[i];
					n = i;
				}
				// !!! Есть проблема - баллов может оказаться одинаково у нескольких объектов
			}
			
			return objects[n];
		}*/	
		
		
		public function set snapEnabled(value:Boolean):void {
			_snapEnabled = value;
			if (_snapEnabled) {
				if (objectsSnapEnabledFlags != null) {
					for (var key:* in objectsSnapEnabledFlags) {
						var obj:ISnapable = key;
						obj.snapEnabled = objectsSnapEnabledFlags[key];
					}
					objectsSnapEnabledFlags = null;
				}
			} else {
				objectsSnapEnabledFlags = new Dictionary(false);
				for (var i:int = 0; i < objects.length; i++) {
					objectsSnapEnabledFlags[objects[i]] = ISnapable(objects[i]).snapEnabled;
					ISnapable(objects[i]).snapEnabled = false;
				}
			}
		}
		public function get snapEnabled():Boolean {
			return _snapEnabled;
		}
		
		/*public function set snapSpace(value:Number):void {
			_snapSpace = value;
			//update();
		}
		public function get snapSpace():Number {
			return _snapSpace;
		}
		
		public function set snapSensitivity(value:Number):void {
			_snapSensitivity = value;
			//update();
		}
		public function get snapSensitivity():Number {
			return _snapSensitivity;
		}*/
		
		/**
		 * Установить область отрисовки для отрисовки инфографики
		 * @param value область отрисовки
		 */		
		public function set graphics(value:Graphics):void {
			_graphics = value;
			redraw();
		}
		/**
		 * Получить область отрисовки
		 * @return область отрисовки
		 */		
		public function get graphics():Graphics {
			return _graphics;
		}
		
		// Перерисовка всех прямоугольников
		private function redraw():void {
			if (_graphics != null) {
				_graphics.clear();
				
				for (var i:int = 0; i < objects.length; i++) {
					var object:ISnapable = ISnapable(objects[i]);
					var snapRect:SnapRect = SnapRect(objectSnapRect[object]);
					if (object is MoveableBase) {
						_graphics.beginFill(0x990000, 0.4);
						/*_graphics.lineStyle(1, 0xcc0000, 1, false, LineScaleMode.NONE);
						_graphics.drawRect(snapRect.x, snapRect.y, snapRect.width, snapRect.height);*/
						
						//trace(object + " snapedSides: " + snapRect.snapedSides);
						
						// left
						if (snapRect.snapedSides & Snap.LEFT)
							_graphics.lineStyle(1, 0xffffff, 1, false, LineScaleMode.NORMAL);
						else 
							_graphics.lineStyle(1, 0xcc0000, 1, false, LineScaleMode.NORMAL);
						_graphics.moveTo(snapRect.x, snapRect.y + snapRect.height);
						_graphics.lineTo(snapRect.x, snapRect.y);
						// top
						if (snapRect.snapedSides & Snap.TOP)
							_graphics.lineStyle(1, 0xffffff, 1, false, LineScaleMode.NORMAL);
						else 
							_graphics.lineStyle(1, 0xcc0000, 1, false, LineScaleMode.NORMAL);
						_graphics.lineTo(snapRect.x + snapRect.width, snapRect.y);
						// right
						if (snapRect.snapedSides & Snap.RIGHT)
							_graphics.lineStyle(1, 0xffffff, 1, false, LineScaleMode.NORMAL);
						else 
							_graphics.lineStyle(1, 0xcc0000, 1, false, LineScaleMode.NORMAL);
						_graphics.lineTo(snapRect.x + snapRect.width, snapRect.y + snapRect.height);	
						// bottom
						if (snapRect.snapedSides & Snap.BOTTOM)
							_graphics.lineStyle(1, 0xffffff, 1, false, LineScaleMode.NORMAL);
						else 
							_graphics.lineStyle(1, 0xcc0000, 1, false, LineScaleMode.NORMAL);
						_graphics.lineTo(snapRect.x, snapRect.y + snapRect.height);	
					}
				}
			}
		}
		
		/*public function update():void {
			for (var i:int = 0; i < objects.length; i++) {
				if (objects[i] is WindowBase) {
					var rect:SnapRect = ISnapable(objects[i]).snapRect.duplicate();
					// переводим в глобальные коордиинаты
					var globalCoord:Point = DisplayObject(objects[i]).localToGlobal(new Point(rect.x, rect.y));
					rect.x = globalCoord.x;
					rect.y = globalCoord.y;
					var newRect:SnapRect = checkSnapRect(ISnapable(objects[i]), rect, Snap.NONE);;
					var newCoord:Point = DisplayObject(objects[i]).parent.globalToLocal(new Point(newRect.x, newRect.y));
					ISnapable(objects[i]).setNewX(newCoord.x - ISnapable(objects[i]).snapRect.x);
					ISnapable(objects[i]).setNewY(newCoord.y - ISnapable(objects[i]).snapRect.y);
				}
			}
			// Перерисовка
			redraw();
		}*/

	}
}