package alternativa.gui.layout.impl {
	import alternativa.gui.base.IGUIObject;
	import alternativa.gui.base.IHelper;
	import alternativa.gui.container.IContainer;
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.layout.enums.Direction;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Компоновщик, заполняющий размер без остатка (появляющегося при округлении)
	 * @autor Брагин А.В.
	 */	
	public class CompletelyFillLayoutManager extends LayoutManagerBase {
		
		/**
		 * Направление
		 */		
		private var _direction:Boolean;
		/**
		 * Выравнивание по горизонтали
		 */		
		private var hAlign:uint;
		/**
		 * Выравнивание по вертикали
		 */		
		private var vAlign:uint;
		/**
		 * Контейнер, с которым работаем
		 */		
		//private var _container:IContainer;
		/**
		 * Размещаемые объекты
		 */		
		//private var objects:Array;
		/**
		 * Количество объектов
		 */		
		//private var objectsNum:uint;
		/**
		 * Счетчик нерезиновых объектов 
		 */		
		private var countNotStretch:int;
		/**
		 * Счетчик резиновых объектов
		 */		
		private var countStretch:int;
		/**
		 * Совокупный размер нерезиновых объектов
		 */		
		private	var notStretchSize:int;
		/**
		 * Совокупный размер резиновых объектов
		 */		
		private	var stretchSize:int;
		/**
		 * Посчитанные размеры объектов
		 */		
		//private var objectsSize:Array;
		/**
		 * Минимальный суммарный размер всех объектов (без промежутков между ними)
		 */		
		private var allObjectsMinSize:Point;
		/**
		 * Посчитанные минимальные размеры объектов
		 */		
		//private var objectsMinSize:Array;
		/**
		 * Посчитанные минимальные размеры контейнера
		 */		
		//private var _minSize:Point;
		/**
		 * Общий размер объектов с учетом space
		 */		
		private var areaSize:Point;
		/**
		 * Пробел между объектами
		 */		
		private var _space:int;
		/**
		 * Суммарное расстояние между объектами
		 */		
		private var spaceSize:int;
		/**
		 * Нулевой размер для определения минимального
		 */		
		//private const nullSize:Point = new Point();
		
		
		public function CompletelyFillLayoutManager(direction:Boolean = Direction.HORIZONTAL,
													hAlign:uint = Align.CENTER,
													vAlign:uint = Align.MIDDLE,
													space:int = 0) {
			// Сохранение параметров
			_direction = direction;
			this.hAlign = hAlign;
			this.vAlign = vAlign;
			_space = space;
			
			this.objectsSize = new Array();
			this.objectsMinSize = new Array();
		}
		
		/**
		 * Вычислить минимальные размеры контента контейнера
		 * @return минимальные размеры
		 */		 		
		override public function computeMinSize():Point {
			//trace("CompletelyFillLayoutManager computeMinSize container: " + container);
			
			objects = _container.objects;		
			objectsNum = objects.length;
			// Минимальный размер контента
			_minSize = new Point();
			
			// Если есть объекты
			if (objectsNum > 0) {
				var influences:Array = new Array();
				
				// Счетчик нерезиновых объектов
				countNotStretch = 0;
				// Счетчик резиновых объектов
				countStretch = 0;
				// Размер нерезиновых объектов
				notStretchSize = 0;
				// Размер резиновых объектов
				stretchSize = 0;
				// Суммарное расстояние между объектами
				spaceSize = _space*(objectsNum - 1);
				
				for (var i:int = 0; i < objectsNum; i++) {
					var object:IGUIObject = IGUIObject(objects[i]);
					
					// Рассчет минимального размера объекта
					if (object.minSizeChanged) {
						objectsMinSize[i] = object.computeMinSize();
						//object.minSizeChanged = false;
					} else {
						if (objectsMinSize[i] == null) {
							objectsMinSize[i] = object.computeMinSize();
						}
					}
					// Сохранение воздействия для хелперов
					var p:Point;
					if (object.currentSize.x == 0 && object.currentSize.y == 0) {
						p = objectsMinSize[i];
					} else {
						p = new Point();
					}
					influences.push(new Rectangle(0, 0, p.x, p.y));
					
					// Подсчет объектов
					if (!object.isStretchable(_direction)) {
						// Объект нерезиновый
						notStretchSize += directionSize(objectsMinSize[i]);
						countNotStretch++;
					} else {
						// Объект резиновый
						stretchSize += directionSize(objectsMinSize[i]);
					}
					// Суммирование мин.размеров всех объектов
					addObjectSize(_minSize, objectsMinSize[i]);
				}
				// Количество резиновых объектов
				countStretch = objectsNum - countNotStretch;
				
				// Временно сохраняем размеры объектов без промежутков между ними 
				allObjectsMinSize = _minSize.clone();
				
				// Раccтояние между элементами
				if (_direction == Direction.HORIZONTAL) {
					_minSize.x += spaceSize;
				} else {
					_minSize.y += spaceSize;
				}
				// Сохранение воздействий в хэлперы
				for (var n:int = 0; n < _helperList.length; n++) {
					var helper:IHelper = IHelper(_helperList[n]);
					helper.saveInfluence(objects, influences);
						
					var c:Array = new Array();
					c.push(_container);
					var s:Array = new Array();
					s.push(new Point(_minSize.x, _minSize.y));
					helper.saveInfluence(c, s);
				}				
			} else {
				allObjectsMinSize = new Point();
			}
			return _minSize;
		}
		
		/**
		 * Подсчитать размер контента контейнера
		 * @param container - контейнер
		 * @param size - заданный размер
		 * @return - рассчитанный размер
		 */		
		override public function computeSize(_size:Point):Point {
			//trace("CompletelyFillLayoutManager computeSize container: " + container);
			//trace("CompletelyFillLayoutManager computeSize size: " + _size);
			
			if (_size == null) 
				var size:Point = new Point();
			else 
				size = _size.clone();
				
			objects = _container.objects;			
			objectsNum = objects.length;
			// Итоговый размер контейнера
			var newSize:Point = allObjectsMinSize.clone();
			
			// Если есть объекты
			if (objectsNum > 0) {
				var influences:Array = new Array();
				
				// Суммарный размер объектов
				if (_direction == Direction.HORIZONTAL)
					size.x-=spaceSize;
				else
					size.y-=spaceSize;
				
				// Остаток, который необходимо разделить между резиновыми объектами
				var remainder:int = directionSize(size) - stretchSize - notStretchSize;
				
				// Растягиваем по неглавной стороне до заданного размера
				// или максимального размера объекта по нерезиновой стороне
				for (var i:int = 0; i < objectsNum; i++) {
					var object:IGUIObject = IGUIObject(objects[i]);
					// Пересчет минимальных размеров, если необходимо
					if (object.minSizeChanged) {
						objectsMinSize[i] = object.computeMinSize();
					}
					objectsSize[i] = Point(objectsMinSize[i]).clone();
					
					if (object.isStretchable(!_direction)) {
						objectsSize[i] = _direction == Direction.HORIZONTAL ? new Point(objectsSize[i].x, Math.max(newSize.y, size.y)) : new Point(Math.max(newSize.x, size.x), objectsSize[i].y);
					}
					if (object.sidesCorrelated) {
						if (objectsSize[i] != null) {
							objectsSize[i] = object.computeSize(Point(objectsSize[i]));
						} else {
							objectsSize[i] = object.computeSize(new Point());
						}
					}
				}
				// Если по сумме минимальных размеров укладываемся в заданный
				if (directionSize(newSize) <= directionSize(size) && (countStretch != 0)) {
					// Средний размер, до которого нужно растянуть резиновые объекты
					var stretchAverageSize:int = Math.round((directionSize(size) - notStretchSize)/countStretch);
					
					for (i = 0; i < objectsNum; i++) {
						object = IGUIObject(objects[i]);
						var lastStretchObjectNum:int;
						// Только для резиновых объектов
						if (object.isStretchable(_direction)) {
							// Запоминаем последний резиновый объект
							lastStretchObjectNum = i;
							// Растягиваем по главной стороне
							if (directionSize(objectsSize[i]) < stretchAverageSize) {
								var delta:int = stretchAverageSize - directionSize(objectsSize[i]);
								if (remainder >= delta) {
									if ( _direction == Direction.HORIZONTAL) {
										objectsSize[i] = new Point(Point(objectsSize[i]).x+delta, Point(objectsSize[i]).y);
										// Добавление в суммарный размер добавленного размера
										addObjectSize(newSize, new Point(delta,0));
									} else {
										objectsSize[i] = new Point(Point(objectsSize[i]).x, Point(objectsSize[i]).y+delta);
										// Добавление в суммарный размер добавленного размера
										addObjectSize(newSize, new Point(0,delta));
									}
									remainder -= delta;
								} else {
									if ( _direction == Direction.HORIZONTAL) {
										objectsSize[i] = new Point(Point(objectsSize[i]).x+remainder, Point(objectsSize[i]).y);
										// Добавление в суммарный размер добавленного размера
										addObjectSize(newSize, new Point(remainder,0));
									} else {
										objectsSize[i] = new Point(Point(objectsSize[i]).x, Point(objectsSize[i]).y+remainder);
										// Добавление в суммарный размер добавленного размера
										addObjectSize(newSize, new Point(0,remainder));
									}									
									remainder = 0;
								}
							}						
						}
					}
					if (remainder > 0) {
						if ( _direction == Direction.HORIZONTAL) {
							objectsSize[lastStretchObjectNum] = new Point(Point(objectsSize[lastStretchObjectNum]).x+remainder, Point(objectsSize[lastStretchObjectNum]).y);
							addObjectSize(newSize, new Point(remainder,0));
						} else {
							objectsSize[lastStretchObjectNum] = new Point(Point(objectsSize[lastStretchObjectNum]).x, Point(objectsSize[lastStretchObjectNum]).y+remainder);
							addObjectSize(newSize, new Point(0,remainder));
						}
						remainder = 0;
					}
					
					if (object.sidesCorrelated) {
						if (objectsSize[i] != null) {
							objectsSize[i] = object.computeSize(Point(objectsSize[i]));
						} else {
							objectsSize[i] = object.computeSize(new Point());
						}
					}
				}
				
				// Пересчет контейнеров
				for (i = 0; i < objectsNum; i++) {
					object = IGUIObject(objects[i]);
					//if (object is IContainer && Point(objectsSize[i]) != Point(objectsMinSize[i])) {
					if (object is IContainer) {
						object.computeSize(Point(objectsSize[i]));
					}
				}
				// Раccтояние между элементами
				if (_direction == Direction.HORIZONTAL)
					newSize.x+=spaceSize;
				else
					newSize.y+=spaceSize;
			}
			
			// Сохранение воздействия для хелперов
			for (i = 0; i < objectsNum; i++) {
					object = IGUIObject(objects[i]);
				var p:Point = new Point();
				if (Point(objectsSize[i]).x != object.currentSize.x || Point(objectsSize[i]).y != object.currentSize.y) {
					if (object.currentSize.x == 0 && object.currentSize.y == 0) {
						p = Point(objectsSize[i]).subtract(objectsMinSize[i]);
					} else {
						p = Point(objectsSize[i]).subtract(object.currentSize);
					}
				}
				influences.push(new Rectangle(0, 0, p.x, p.y));
			}
			// Сохранение воздействий в хэлперы
			for (var n:int = 0; n < _helperList.length; n++) {
				var helper:IHelper = IHelper(_helperList[n]);
				helper.saveInfluence(objects, influences);
				
				var c:Array = new Array();
				c.push(_container);
				var s:Array = new Array();
				s.push(new Point(newSize.x - _minSize.x, newSize.y - _minSize.y));
				helper.saveInfluence(c, s);
			}
				
			// Сохраняем 
			areaSize = newSize;
			
			return newSize;
		}
		
		/**
		 * Добавляет размер объекта по направлению менеджера к общему размеру
		 * и выбирает максимальный размер по другой стороне для всех объектов
		 * @param newSize суммарный размер объектов
		 * @param objectSize размер объекта
		 */		
		private function addObjectSize(newSize:Point, objectSize:Point):void {
			if (_direction == Direction.HORIZONTAL) {
				newSize.x += objectSize.x;
				newSize.y = Math.max(newSize.y,objectSize.y);							
			} else {
				newSize.y += objectSize.y;
				newSize.x = Math.max(newSize.x,objectSize.x);
			}		
		}
		
		/**
		 * Отдает ширину или высоту размера point в зависимости от направления менеджера
		 * @param point размеры
		 * @return ширина или высота
		 */		
		private function directionSize(point:Point):int {			
			return _direction == Direction.HORIZONTAL ? point.x : point.y;
		} 
		
		/**
		 * Отрисовать и расположить объекты контейнера
		 * @param container - контейнер
		 * @param size - заданный размер
		 * @return размер отрисовки
		 */		
		override public function draw(size:Point):Point {
			// Текущая координата объекта по резиновой стороне			
			var currentCoord:int = 0;
			
			if (objectsNum > 0) {
				var influences:Array = new Array();
				
				// Выравнивание по резиновой стороне
				if (_direction == Direction.HORIZONTAL) {
					switch(hAlign) {
						case Align.LEFT:
						// Ничего не делаем
						break;
						case Align.CENTER:
							currentCoord = int((size.x - areaSize.x)*0.5+0.5);	
						break;				
						case Align.RIGHT:
							currentCoord = size.x - areaSize.x;
						break;					
					}
				} else {				
					switch(vAlign) {
						case Align.TOP:
						// Ничего не делаем
						break;
						case Align.MIDDLE:
							currentCoord = int((size.y - areaSize.y)*0.5+0.5);	
						break;				
						case Align.BOTTOM:
							currentCoord = size.y - areaSize.y;
						break;					
					}			
				}
				
				for (var i:int = 0; i < objectsNum; i++) {
					var object:IGUIObject = IGUIObject(objects[i]);
					var objectSize:Point = Point(objectsSize[i]);
					var offset:Point = new Point();
					// Отрисовка
					if (objectSize.x != object.currentSize.x || objectSize.y != object.currentSize.y || object is IContainer) {
						object.draw(objectSize);
					}
					
					if (_direction == Direction.HORIZONTAL) {					
						offset.x = currentCoord - object.x;
						
						object.x += offset.x;
						currentCoord += objectSize.x + _space;
						
						// Выравнивание по нерезиновой стороне
						switch(vAlign) {
							case Align.TOP:
								offset.y = 0 - object.y;
								break;
							case Align.MIDDLE:
								offset.y = int((size.y - objectSize.y)*0.5+0.5) - object.y;
								break;				
							case Align.BOTTOM:
								offset.y = (size.y - objectSize.y) - object.y;
								break;					
						}	
						object.y += offset.y;
					} else {
						offset.y = currentCoord - object.y;
						
						object.y += offset.y;
						currentCoord += objectSize.y + _space;
						
						switch(hAlign) {
							case Align.LEFT:
								offset.x = 0 - object.x;
								break;
							case Align.CENTER:
								offset.x = int((size.x - objectSize.x)*0.5+0.5) - object.x;
								break;				
							case Align.RIGHT:
								offset.x = (size.x - objectSize.x) - object.x;
								break;					
						}
						object.x += offset.x;
					}
					influences.push(offset);
					
					// Отметка нулевой точки объекта
					/*if (object is Sprite)
					with (Sprite(object).graphics) {
						//clear();
						lineStyle(1, 0x0000ff, 1);
						moveTo(-5,0);
						lineTo(5,0);
						moveTo(0,-5);
						lineTo(0,5);
					}*/
				}
				
				// Сохранение воздействий в хэлперы
				for (var n:int = 0; n < _helperList.length; n++) {
					var helper:IHelper = IHelper(_helperList[n]);
					helper.saveInfluence(objects, influences);
				}
			}				
			return size;
		}
		
		
		/**
		 * Контейнер, с которым работаем 
		 */		
		/*public function set container(c:IContainer):void {
			_container = c;
		}*/
		
		/**
		 * Минимальный размер контента контейнера (без пересчета)
		 */		
		/*public function get minSize():Point {
			return _minSize;
		}*/
		
		/**
		 * Пробел между объектами
		 */
		public function get space():int {
			return _space;
		}
		public function set space(value:int):void {
			_space = value;
		}
		
		/**
		 * Направление
		 */
		public function get direction():Boolean {
			return _direction;
		}
		public function set direction(value:Boolean):void {
			if (_direction != value) {
				_direction = value;
				
				var newAlignH:uint;
				var newAlignV:uint;
				if (vAlign == Align.TOP) {
					newAlignH = Align.LEFT;
				} else if (vAlign == Align.MIDDLE) {
					newAlignH = Align.CENTER;
				} else {
					newAlignH = Align.RIGHT;
				}
				if (hAlign == Align.LEFT) {
					newAlignV = Align.TOP;
				} else if (hAlign == Align.CENTER) {
					newAlignV = Align.MIDDLE;
				} else {
					newAlignV = Align.BOTTOM;
				}
				hAlign = newAlignH;
				vAlign = newAlignV;
			}
		}
				
	}
}