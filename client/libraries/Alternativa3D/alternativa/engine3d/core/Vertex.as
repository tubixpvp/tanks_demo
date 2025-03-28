package alternativa.engine3d.core {

	import alternativa.engine3d.*;
	import alternativa.types.Point3D;
	import alternativa.types.Set;
	
	use namespace alternativa3d;
	
	/**
	 * Вершина полигона в трёхмерном пространстве. Вершина хранит свои координаты, а также ссылки на
	 * полигональный объект и грани этого объекта, которым она принадлежит. 
	 */
	final public class Vertex {
		// Операции
		/**
		 * @private
		 * Изменение локальных координат
		 */
		alternativa3d var changeCoordsOperation:Operation = new Operation("changeCoords", this);
		/**
		 * @private
		 * Расчёт глобальных координат
		 */
		alternativa3d var calculateCoordsOperation:Operation = new Operation("calculateCoords", this, calculateCoords, Operation.VERTEX_CALCULATE_COORDS);
		
		/**
		 * @private
		 * Меш
		 */
		alternativa3d var _mesh:Mesh;
		/**
		 * @private
		 * Координаты точки
		 */
		alternativa3d var _coords:Point3D;
		/**
		 * @private
		 * Грани
		 */
		alternativa3d var _faces:Set = new Set();
		/**
		 * @private
		 * Координаты в сцене
		 */
		alternativa3d var globalCoords:Point3D = new Point3D();
		
		/**
		 * Создание экземпляра вершины.
		 * 
		 * @param x координата вершины по оси X
		 * @param y координата вершины по оси Y
		 * @param z координата вершины по оси Z
		 */
		public function Vertex(x:Number = 0, y:Number = 0, z:Number = 0) {
			_coords = new Point3D(x, y, z);
			
			// Изменение координат инициирует пересчёт глобальных координат
			changeCoordsOperation.addSequel(calculateCoordsOperation);
		}
		
		/**
		 * Вызывается из операции calculateCoordsOperation для расчета глобальных координат вершины
		 */
		private function calculateCoords():void {
			globalCoords.copy(_coords);
			globalCoords.transform(_mesh._transformation);
		}
		
		/**
		 * @private
		 */
		public function set x(value:Number):void {
			if (_coords.x != value) {
				_coords.x = value;
				if (_mesh != null) {
					_mesh.addOperationToScene(changeCoordsOperation);
				}
			}
		}		

		/**
		 * @private
		 */
		public function set y(value:Number):void {
			if (_coords.y != value) {
				_coords.y = value;
				if (_mesh != null) {
					_mesh.addOperationToScene(changeCoordsOperation);
				}
			}
		}

		/**
		 * @private
		 */
		public function set z(value:Number):void {
			if (_coords.z != value) {
				_coords.z = value;
				if (_mesh != null) {
					_mesh.addOperationToScene(changeCoordsOperation);
				}
			}
		}
		
		/**
		 * @private
		 */
		public function set coords(value:Point3D):void {
			if (!_coords.equals(value)) {
				_coords.copy(value);
				if (_mesh != null) {
					_mesh.addOperationToScene(changeCoordsOperation);
				}
			}
		}

		/**
		 * координата вершины по оси X.
		 */
		public function get x():Number {
			return _coords.x;
		}		

		/**
		 * координата вершины по оси Y.
		 */
		public function get y():Number {
			return _coords.y;
		}		

		/**
		 * координата вершины по оси Z.
		 */
		public function get z():Number {
			return _coords.z;
		}
		
		/**
		 * Координаты вершины.
		 */
		public function get coords():Point3D {
			return _coords.clone();
		}
		
		/**
		 * Полигональный объект, которому принадлежит вершина.
		 */
		public function get mesh():Mesh {
			return _mesh;
		}

		/**
		 * Множество граней, которым принадлежит вершина. Каждый элемент множества является объектом класса
		 * <code>altertnativa.engine3d.core.Face</code>.
		 * 
		 * @see Face
		 */		
		public function get faces():Set {
			return _faces.clone();
		}
		
		/**
		 * Идентификатор вершины в полигональном объекте. Если вершина не принадлежит полигональному объекту, возвращается <code>null</code>.
		 */
		public function get id():Object {
			return (_mesh != null) ? _mesh.getVertexId(this) : null;
		}
		
		/**
		 * @private
		 * @param scene
		 */		
		alternativa3d function addToScene(scene:Scene3D):void {
			// При добавлении на сцену расчитать глобальные координаты
			scene.addOperation(calculateCoordsOperation);
		}

		/**
		 * @private
		 * @param scene
		 */		
		alternativa3d function removeFromScene(scene:Scene3D):void {
			// Удаляем все операции из очереди
			scene.removeOperation(calculateCoordsOperation);
			scene.removeOperation(changeCoordsOperation);
		}
		
		/**
		 * @private
		 * @param mesh
		 */
		alternativa3d function addToMesh(mesh:Mesh):void {
			// Подписка на операции меша
			mesh.changeCoordsOperation.addSequel(calculateCoordsOperation);
			mesh.changeRotationOrScaleOperation.addSequel(calculateCoordsOperation);
			// Сохранить меш
			_mesh = mesh;
		}
		
		/**
		 * @private
		 * @param mesh
		 */
		alternativa3d function removeFromMesh(mesh:Mesh):void {
			// Отписка от операций меша
			mesh.changeCoordsOperation.removeSequel(calculateCoordsOperation);
			mesh.changeRotationOrScaleOperation.removeSequel(calculateCoordsOperation);
			// Удалить зависимые грани
			for (var key:* in _faces) {
				var face:Face = key;
				mesh.removeFace(face);
			}
			// Удалить ссылку на меш
			_mesh = null;
		}
		
		/**
		 * @private
		 * @param face
		 */
		alternativa3d function addToFace(face:Face):void {
			// Подписка грани на операции
			changeCoordsOperation.addSequel(face.calculateUVOperation);
			changeCoordsOperation.addSequel(face.calculateNormalOperation);
			// Добавить грань в список
			_faces.add(face);
		}
		
		/**
		 * @private
		 * @param face
		 */
		alternativa3d function removeFromFace(face:Face):void {
			// Отписка грани от операций
			changeCoordsOperation.removeSequel(face.calculateUVOperation);
			changeCoordsOperation.removeSequel(face.calculateNormalOperation);
			// Удалить грань из списка
			_faces.remove(face);
		}
		
		/**
		 * Строковое представление объекта.
		 * 
		 * @return строковое представление объекта
		 */		
		public function toString():String {
			return "[Vertex ID:" + id + " " + _coords.x.toFixed(2) + ", " + _coords.y.toFixed(2) + ", " + _coords.z.toFixed(2) + "]";
		}

	}
}
