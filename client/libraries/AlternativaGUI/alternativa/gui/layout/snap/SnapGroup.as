package alternativa.gui.layout.snap {
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * Группа объектов <code>ISnapGroupable</code>
	 * (для совместного перетаскивания, например)
	 */
	public class SnapGroup {
		
		/**
		 * Список объектов
		 */		
		private var _objects:Array;
		/**
		 * Связи между объектами (в формате <code>SnapGroupLink</code>)
		 */		
		private var _links:Array;
		/**
		 * Идентификатор группы
		 */		
		private var _id:int;
		
		
		public function SnapGroup() {
			// Инициализация
			_objects = new Array();
			_links = new Array();
			
			var time:Date = new Date();
			time.getTime();
			_id = time.minutes*60 + time.seconds;
		}
		
		/**
		 * Добавление объекта в группу
		 * @param object
		 * @param link
		 */		
		public function addObject(object:ISnapGroupable, link:SnapGroupLink = null):void {
			// Сохранение объекта
			_objects.push(object);
			object.snapGroup = this;
			// Сохранение связи (null - для 1-го объекта, т.к. у него нет связи ни с кем)
			if (link != null) {
				_links.push(link);
			}
		}
		
		/**
		 * Добавление связи (если такой ещё не было)
		 * @param link связь
		 */		
		public function addLink(link:SnapGroupLink):void {
			var doNotAddThisLinkBecauseItsAlreadyAdded:Boolean = false;
			for (var i:int = 0; i < _links.length; i++) {
				var l:SnapGroupLink = SnapGroupLink(_links[i]);
				if ((l.obj1 == link.obj1 && l.obj2 == link.obj2) || (l.obj1 == link.obj2 && l.obj2 == link.obj1))
					doNotAddThisLinkBecauseItsAlreadyAdded = true;
			}
			if (!doNotAddThisLinkBecauseItsAlreadyAdded)
				_links.push(link);
		}
		
		/**
		 * Удаление связи между объектами
		 * @param obj1 объект 1
		 * @param obj2 объект 2
		 */		
		public function removeLink(obj1:ISnapGroupable, obj2:ISnapGroupable):void {
			var newGroupsObjects:Array = new Array();
			var newGroupsLinks:Array = new Array();
			
			for (var i:int = 0; i < _links.length; i++) {
				if ((SnapGroupLink(_links[i]).obj1 == obj1 && SnapGroupLink(_links[i]).obj2 == obj2) || (SnapGroupLink(_links[i]).obj1 == obj2 && SnapGroupLink(_links[i]).obj2 == obj1)) {
					_links.splice(i, 1);
				}
			}
			if (_links.length > 1) {
				var groupIndex:int = 0;
				
				while (_links.length > 0) {
					newGroupsObjects[groupIndex] = new Array();
					newGroupsLinks[groupIndex] = new Array();
					var checkMask:Array = new Array(SnapGroupLink(_links[0]).obj1, SnapGroupLink(_links[0]).obj2);
					newGroupsLinks[groupIndex].push(_links[0]);
					_links.splice(0, 1)
					
					var splicedLinksNum:int = 1; 
					while(splicedLinksNum != 0) {
						splicedLinksNum = 0;
						i = 0;
						while (i < _links.length) {
							var l:SnapGroupLink = SnapGroupLink(_links[i]);
							// проход по объектам в маске
							var m:int = 0;
							var maskLength:int = checkMask.length;
							var checked:Boolean = false;
							while (m < maskLength && !checked) {
								if (l.obj1 == ISnapGroupable(checkMask[m]) || l.obj2 == ISnapGroupable(checkMask[m])) {
									if (l.obj1 == ISnapGroupable(checkMask[m])) {
										checkMask.push(l.obj2);
									} else {
										checkMask.push(l.obj1);
									}									
									newGroupsLinks[groupIndex].push(_links[i]);
									_links.splice(i, 1);
									checked = true;
									splicedLinksNum += 1;
								}
								m++;
							}
							if (!checked) i++;						
						}
					}
					for (var objIndex:int = 0; objIndex < checkMask.length; objIndex++) {
						newGroupsObjects[groupIndex].push(checkMask[objIndex]);
					}
					groupIndex += 1;
				}
				// Раскладывание объектов по группам
				if (newGroupsObjects.length == 1) {
					// Группа осталась целой
					_links = new Array();
					_objects = new Array();
					for (i = 0; i < newGroupsLinks[0].length; i++) {
						_links[i] = SnapGroupLink(newGroupsLinks[0][i]);
					}
					for (i = 0; i < newGroupsObjects[0].length; i++) {
						_objects[i] = ISnapGroupable(newGroupsObjects[0][i]);
					}
				} else {
					var group:SnapGroup;
					// Разбиваем на группы
					for (var g:int = 0; g < newGroupsObjects.length; g++) {
						group = new SnapGroup();
						if (newGroupsLinks[g].length > 0) {
							for (i = 0; i < newGroupsObjects[g].length; i++) {
								group.addObject(ISnapGroupable(newGroupsObjects[g][i]));
							}
							for (i = 0; i < newGroupsLinks[g].length; i++) {
								group.addLink(SnapGroupLink(newGroupsLinks[g][i]));
							}
						} else {
							for (i = 0; i < newGroupsObjects[g].length; i++) {
								ISnapGroupable(newGroupsObjects[g][i]).snapGroup = null;
							}
						}
					}
				}
			} else {
				if (_links.length == 1) {
					for (i = 0; i < _objects.length; i++) {
						if (ISnapGroupable(_objects[i]) != SnapGroupLink(_links[0]).obj1 && ISnapGroupable(_objects[i]) != SnapGroupLink(_links[0]).obj2) {
							ISnapGroupable(_objects[i]).snapGroup = null;
							_objects.splice(i, 1);
						}
					}
				} else {
					// Самоуничтожение
					for (i = 0; i < _objects.length; i++) {
						ISnapGroupable(_objects[i]).snapGroup = null;
					}
					_objects = new Array();
				}
			}
		}
		
		/**
		 * Удаление объекта из группы
		 * @param object объект
		 */		
		public function removeObject(object:ISnapGroupable):void {
			_objects.splice(_objects.indexOf(object), 1);
			object.snapGroup = null;
			
			if (_objects.length == 1) {
				ISnapGroupable(_objects[0]).snapGroup = null;
				_objects = new Array();
			}
		}
		
		/**
		 * Поглотить группу со всеми объектами и связми между ними
		 * @param group группа слипшихся объектов
		 */		
		public function mergeGroup(group:SnapGroup):void {
			if (group != this) {
				var groupObjects:Array = group.objects;
				var groupLinks:Array = group.links;
				// Передача объектов
				for (var i:int = 0; i < groupObjects.length; i++) {
					_objects.push(ISnapGroupable(groupObjects[i]));
					ISnapGroupable(groupObjects[i]).snapGroup = this;
				}
				// Передача связей
				for (i = 0; i < groupLinks.length; i++) {
					_links.push(SnapGroupLink(groupLinks[i]));
				}
				// Затирание группы
				groupObjects = new Array();
				groupLinks = new Array();
			}
		}
		
		/*public function move(offsetX:int, offsetY:int):void {
			trace("snapGroup move offset: " + offsetX + ", " + offsetY);
			var snapHelper:ISnapHelper = ISnapable(_objects[0]).snapHelper;
			
			// Отключение снапа для объектов внутри группы
			var objectsSnapEnabledFlags:Array = new Array();
			for (var i:int = 0; i < _objects.length; i++) {
				var object:ISnapable = ISnapable(_objects[i]);
				objectsSnapEnabledFlags[i] = object.snapEnabled;
				object.snapEnabled = false;
			}
			
			// Массив смещений в результате снапа (элементы Point)
			var snapList:Array = new Array();
			var snapRectList:Array = new Array();
			// Проверка на прилипание
			for (i = 0; i < _objects.length; i++) {
				object = ISnapable(_objects[i]);
				var objectSnapRect:SnapRect = object.snapRect;
				
				var globalCoord:Point = DisplayObject(object).localToGlobal(new Point(offsetX + objectSnapRect.x, offsetY + objectSnapRect.y));
				var globalSnapRect:SnapRect = snapHelper.checkSnapRect(object, new Rectangle(globalCoord.x, globalCoord.y, objectSnapRect.width, objectSnapRect.height), Snap.NONE);
				
				var snapX:int = globalSnapRect.x - globalCoord.x;
				var snapY:int = globalSnapRect.y - globalCoord.y;
				
				if (snapX != 0 || snapY != 0) {
					snapList[i] = new Point(snapX, snapY);
					snapRectList[i] = globalSnapRect;
				}
			}
			var n:int = -1;
			if (snapList.length != 0) {
				var snapOffset:Point;
				var R:Number = 1000000;
				for (var l:int = 0; l < snapList.length; l++) {
					if (snapList[l] != null && (Point(snapList[l]).x != 0 || Point(snapList[l]).y != 0)) {
						snapOffset = Point(snapList[l]);
						var newR = snapOffset.x*snapOffset.x + snapOffset.y*snapOffset.y;
						if (newR < R) {
							n = l;
						}
					}
				}
				snapOffset = Point(snapList[n]);
				offsetX += snapOffset.x;
				offsetY += snapOffset.y;
			}
			
			// Включение снапа для объектов внутри группы
			for (i = 0; i < _objects.length; i++) {
				ISnapable(_objects[i]).snapEnabled = objectsSnapEnabledFlags[i];
			}
			
			// Отключение группировки
			var objectsGroupEnabledFlags:Array = new Array();
			for (var i:int = 0; i < _objects.length; i++) {
				objectsGroupEnabledFlags[i] = ISnapGroupable(_objects[i]).groupEnabled;
				ISnapGroupable(_objects[i]).groupEnabled = false;
			}
			
			// Сохранение новых габаритных контейнеров
			var length:int = _objects.length;
			for (i = 0; i < length; i++) {
				object = ISnapable(_objects[i]);
				objectSnapRect = object.snapRect;
				object.x += offsetX;
				object.y += offsetY;
				if (i != n) {
					var globalCoord:Point = DisplayObject(object).localToGlobal(new Point(objectSnapRect.x, objectSnapRect.y));
					var rect:SnapRect = objectSnapRect.duplicate();
					rect.x = globalCoord.x;
					rect.y = globalCoord.y;
					snapHelper.changeSnapRect(object, rect);
				}
			}
			if (n != -1) {
				object = ISnapable(_objects[n]);
				objectSnapRect = object.snapRect;
				globalCoord = DisplayObject(object).localToGlobal(new Point(objectSnapRect.x, objectSnapRect.y));
				rect = objectSnapRect.duplicate();
				rect.x = globalCoord.x;
				rect.y = globalCoord.y;
				for (var j:int = 0; j < 8; j++) {
					for (var k:int = objectSnapRect.snapedObjects[j].length; k < SnapRect(snapRectList[n]).snapedObjects[j].length; k++) {
						rect.snapedObjects[j][k] = SnapRect(snapRectList[n]).snapedObjects[j][k];
						rect.snapedObjectsSides[j][k] = SnapRect(snapRectList[n]).snapedObjectsSides[j][k];
						objectSnapRect.snapedObjects[j][k] = rect.snapedObjects[j][k];
						objectSnapRect.snapedObjectsSides[j][k] = rect.snapedObjectsSides[j][k];
					}
				}				
				snapHelper.changeSnapRect(object, rect);
			}
			
			// Включение группировки
			for (var i:int = 0; i < _objects.length; i++) {
				ISnapGroupable(_objects[i]).groupEnabled = objectsGroupEnabledFlags[i];
			}
		}*/
		
		/**
		 * Количество объектов в группе
		 */		
		public function get objectsNum():int {
			return _objects.length;
		}
		
		/**
		 * Сгруппированные объекты
		 */		
		public function get objects():Array {
			return _objects;
		}
		
		/**
		 * Связи внутри группы
		 */		
		public function get links():Array {
			return _links;
		}
		
		/**
		 * Идентификатор группы
		 */		
		public function get id():int {
			return _id;
		}

	}
}