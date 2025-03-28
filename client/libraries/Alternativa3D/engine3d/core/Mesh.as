package alternativa.engine3d.core {

	import alternativa.engine3d.*;
	import alternativa.engine3d.errors.FaceExistsError;
	import alternativa.engine3d.errors.FaceNeedMoreVerticesError;
	import alternativa.engine3d.errors.FaceNotFoundError;
	import alternativa.engine3d.errors.InvalidIDError;
	import alternativa.engine3d.errors.SurfaceExistsError;
	import alternativa.engine3d.errors.SurfaceNotFoundError;
	import alternativa.engine3d.errors.VertexExistsError;
	import alternativa.engine3d.errors.VertexNotFoundError;
	import alternativa.engine3d.materials.SurfaceMaterial;
	import alternativa.types.Map;
	import alternativa.utils.ObjectUtils;
	
	import flash.geom.Point;

	use namespace alternativa3d;

	/**
	 * Полигональный объект &mdash; базовый класс для трёхмерных объектов, состоящих из граней-полигонов. Объект
	 * содержит в себе наборы вершин, граней и поверхностей.
	 */
	public class Mesh extends Object3D {

		// Инкремент количества объектов
		private static var counter:uint = 0;

		// Инкременты для идентификаторов вершин, граней и поверхностей
		private var vertexIDCounter:uint = 0;
		private var faceIDCounter:uint = 0;
		private var surfaceIDCounter:uint = 0;

		/**
		 * @private
		 * Список вершин
		 */
		alternativa3d var _vertices:Map = new Map();
		/**
		 * @private
		 * Список граней
		 */
		alternativa3d var _faces:Map = new Map();
		/**
		 * @private
		 * Список поверхностей
		 */
		alternativa3d var _surfaces:Map = new Map();
		
		/**
		 * Создание экземпляра полигонального объекта.
		 * 
		 * @param name имя экземпляра
		 */
		public function Mesh(name:String = null) {
			super(name);
		}

		/**
		 * Добавление новой вершины к объекту.
		 *  
		 * @param x координата X в локальной системе координат объекта  
		 * @param y координата Y в локальной системе координат объекта
		 * @param z координата Z в локальной системе координат объекта
		 * @param id идентификатор вершины. Если указано значение <code>null</code>, идентификатор будет
		 * сформирован автоматически.
		 * 
		 * @return экземпляр добавленной вершины
		 * 
		 * @throws alternativa.engine3d.errors.VertexExistsError объект уже содержит вершину с указанным идентификатором
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 */
		public function createVertex(x:Number = 0, y:Number = 0, z:Number = 0, id:Object = null):Vertex {
			// Проверяем ID
			if (id != null) {
				// Если уже есть вершина с таким ID
				if (_vertices[id] != undefined) {
					if (_vertices[id] is Vertex) {
						throw new VertexExistsError(id, this);
					} else {
						throw new InvalidIDError(id, this);
					}
				}
			} else {
				// Ищем первый свободный
				while (_vertices[vertexIDCounter] != undefined) {
					vertexIDCounter++;
				}
				id = vertexIDCounter;
			}
			
			// Создаём вершину
			var v:Vertex = new Vertex(x, y, z);
			
			// Добавляем вершину на сцену
			if (_scene != null) {
				v.addToScene(_scene);
			}
			
			// Добавляем вершину в меш
			v.addToMesh(this);
			_vertices[id] = v;
			
			return v;
		}

		/**
		 * Удаление вершины из объекта. При удалении вершины из объекта также удаляются все грани, которым принадлежит данная вершина.
		 *  
		 * @param vertex экземпляр класса <code>alternativa.engine3d.core.Vertex</code> или идентификатор удаляемой вершины
		 *  
		 * @return экземпляр удалённой вершины
		 * 
		 * @throws alternativa.engine3d.errors.VertexNotFoundError объект не содержит указанную вершину
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 */
		public function removeVertex(vertex:Object):Vertex {
			var byLink:Boolean = vertex is Vertex;

			// Проверяем на null
			if (vertex == null) {
				throw new VertexNotFoundError(null, this);
			}
			
			// Проверяем наличие вершины в меше
			if (byLink) {
				// Если удаляем по ссылке
				if (Vertex(vertex)._mesh != this) {
					// Если вершина не в меше
					throw new VertexNotFoundError(vertex, this);
				}
			} else {
				// Если удаляем по ID
				if (_vertices[vertex] == undefined) {
					// Если нет вершины с таким ID
					throw new VertexNotFoundError(vertex, this);
				} else if (!(_vertices[vertex] is Vertex)) {
					// По этому id не вершина
					throw new InvalidIDError(vertex, this);
				}
			}
			
			// Находим вершину и её ID
			var v:Vertex = byLink ? Vertex(vertex) : _vertices[vertex];
			var id:Object = byLink ? getVertexId(Vertex(vertex)) : vertex;
			
			// Удаляем вершину из сцены
			if (_scene != null) {
				v.removeFromScene(_scene);
			}
			
			// Удаляем вершину из меша
			v.removeFromMesh(this);
			delete _vertices[id];
			
			return v;
		}

		/**
		 * Добавление грани к объекту. В результате выполнения метода в объекте появляется новая грань, не привязанная
		 * ни к одной поверхности.
		 *   
		 * @param vertices массив вершин грани, указанных в порядке обхода лицевой стороны грани против часовой
		 * стрелки. Каждый элемент массива может быть либо экземпляром класса <code>alternativa.engine3d.core.Vertex</code>,
		 * либо идентификатором в наборе вершин объекта. В обоих случаях объект должен содержать указанную вершину.
		 * @param id идентификатор грани. Если указано значение <code>null</code>, идентификатор будет
		 * сформирован автоматически.
		 * 
		 * @return экземпляр добавленной грани 
		 * 
		 * @throws alternativa.engine3d.errors.FaceNeedMoreVerticesError в качестве массива вершин был передан
		 * <code>null</code>, либо количество вершин в массиве меньше трёх
		 * @throws alternativa.engine3d.errors.FaceExistsError объект уже содержит грань с заданным идентификатором
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 * @throws alternativa.engine3d.errors.VertexNotFoundError объект не содержит какую-либо вершину из входного массива
		 * 
		 * @see Vertex
		 */ 
		public function createFace(vertices:Array, id:Object = null):Face {
			// Проверяем на null
			if (vertices == null) {
				throw new FaceNeedMoreVerticesError(this);
			} 

			// Проверяем ID
			if (id != null) {
				// Если уже есть грань с таким ID
				if (_faces[id] != undefined) {
					if (_faces[id] is Face) {
						throw new FaceExistsError(id, this);
					} else {
						throw new InvalidIDError(id, this);
					}
				}
			} else {
				// Ищем первый свободный ID
				while (_faces[faceIDCounter] != undefined) {
					faceIDCounter++;
				}
				id = faceIDCounter;
			}
			
			// Проверяем количество точек
			var length:uint = vertices.length;
			if (length < 3) {
				throw new FaceNeedMoreVerticesError(this, length);
			}

			// Проверяем и формируем список вершин
			var v:Array = new Array();
			var vertex:Vertex;
			for (var i:uint = 0; i < length; i++) {
				if (vertices[i] is Vertex) {
					// Если работаем со ссылками
					vertex = vertices[i];
					if (vertex._mesh != this) {
						// Если вершина не в меше
						throw new VertexNotFoundError(vertices[i], this);
					}
				} else {
					// Если работаем с ID
					if (_vertices[vertices[i]] == null) {
						// Если нет вершины с таким ID
						throw new VertexNotFoundError(vertices[i], this);
					} else if (!(_vertices[vertices[i]] is Vertex)) {
						// Если id зарезервировано
						throw new InvalidIDError(vertices[i],this);
					}
					vertex = _vertices[vertices[i]];
				}
				v.push(vertex);
			}

			// Создаём грань
			var f:Face = new Face(v);

			// Добавляем грань на сцену
			if (_scene != null) {
				f.addToScene(_scene);
			}

			// Добавляем грань в меш
			f.addToMesh(this);
			_faces[id] = f;
			
			return f;
		}

		/**
		 * Удаление грани из объекта. Грань также удаляется из поверхности объекта, которой она принадлежит.
		 *  
		 * @param экземпляр класса <code>alternativa.engine3d.core.Face</code> или идентификатор удаляемой грани
		 * 
		 * @return экземпляр удалённой грани
		 *  
		 * @throws alternativa.engine3d.errors.FaceNotFoundError объект не содержит указанную грань
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 */
		public function removeFace(face:Object):Face {
			var byLink:Boolean = face is Face;

			// Проверяем на null
			if (face == null) {
				throw new FaceNotFoundError(null, this);
			}

			// Проверяем наличие грани в меше
			if (byLink) {
				// Если удаляем по ссылке
				if (Face(face)._mesh != this) {
					// Если грань не в меше
					throw new FaceNotFoundError(face, this);
				}
			} else {
				// Если удаляем по ID
				if (_faces[face] == undefined) {
					// Если нет грани с таким ID
					throw new FaceNotFoundError(face, this);
				} else if (!(_faces[face] is Face)) {
					throw new InvalidIDError(face, this);
				}
			}

			// Находим грань и её ID
			var f:Face = byLink ? Face(face) : _faces[face] ;
			var id:Object = byLink ? getFaceId(Face(face)) : face;

			// Удаляем вершины из грани
			f.removeVertices();

			// Удаляем грань из поверхности
			if (f._surface != null) {
				f._surface._faces.remove(f);
				f.removeFromSurface(f._surface);
			}

			// Удаляем грань из сцены
			if (_scene != null) {
				f.removeFromScene(_scene);
			}

			// Удаляем грань из меша
			f.removeFromMesh(this);

			delete _faces[id];

			return f;
		}

		/**
		 * Добавление новой поверхности к объекту.
		 *    
		 * @param faces набор граней, составляющих поверхность. Каждый элемент массива должен быть либо экземпляром класса
		 * <code>alternativa.engine3d.core.Face</code>, либо идентификатором грани. В обоих случаях объект должен содержать
		 * указанную грань. Если значение параметра равно <code>null</code>, то будет создана пустая поверхность. Если
		 * какая-либо грань содержится в другой поверхности, она будет перенесена в новую поверхность. 
		 * @param id идентификатор новой поверхности. Если указано значение <code>null</code>, идентификатор будет
		 * сформирован автоматически.
		 * 
		 * @return экземпляр добавленной поверхности
		 *   
		 * @throws alternativa.engine3d.errors.SurfaceExistsError объект уже содержит поверхность с заданным идентификатором
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 * 
		 * @see Face
		 */
		public function createSurface(faces:Array = null, id:Object = null):Surface {
			// Проверяем ID
			if (id != null) {
				// Если уже есть поверхность с таким ID
				if (_surfaces[id] != undefined) {
					if (_surfaces[id] is Surface) {
						throw new SurfaceExistsError(id, this);
					} else {
						throw new InvalidIDError(id, this);
					}
				}
			} else {
				// Ищем первый свободный ID
				while (_surfaces[surfaceIDCounter] != undefined) {
					surfaceIDCounter++;
				}
				id = surfaceIDCounter;
			}
			
			// Создаём поверхность
			var s:Surface = new Surface();
			
			// Добавляем поверхность на сцену
			if (_scene != null) {
				s.addToScene(_scene);
			}
			
			// Добавляем поверхность в меш
			s.addToMesh(this);
			_surfaces[id] = s;

			// Добавляем грани, если есть
			if (faces != null) {
				var length:uint = faces.length;
				for (var i:uint = 0; i < length; i++) {
					s.addFace(faces[i]);
				}
			}
			return s;
		}

		/**
		 * Удаление поверхности объекта. Из удаляемой поверхности также удаляются все содержащиеся в ней грани.
		 *  
		 * @param surface экземпляр класса <code>alternativa.engine3d.core.Face</code> или идентификатор удаляемой поверхности
		 *  
		 * @return экземпляр удалённой поверхности
		 *  
		 * @throws alternativa.engine3d.errors.SurfaceNotFoundError объект не содержит указанную поверхность 
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора 
		 */
		public function removeSurface(surface:Object):Surface {
			var byLink:Boolean = surface is Surface;

			// Проверяем на null
			if (surface == null) {
				throw new SurfaceNotFoundError(null, this);
			}

			// Проверяем наличие поверхности в меше
			if (byLink) {
				// Если удаляем по ссылке
				if (Surface(surface)._mesh != this) {
					// Если поверхность не в меше
					throw new SurfaceNotFoundError(surface, this);
				}
			} else {
				// Если удаляем по ID
				if (_surfaces[surface] == undefined) {
					// Если нет поверхности с таким ID
					throw new SurfaceNotFoundError(surface, this);
				} else if (!(_surfaces[surface] is Surface)) {
						throw new InvalidIDError(surface, this);
				}
			}

			// Находим поверхность и её ID
			var s:Surface = byLink ? Surface(surface) : _surfaces[surface];
			var id:Object = byLink ? getSurfaceId(Surface(surface)) : surface;

			// Удаляем поверхность из сцены
			if (_scene != null) {
				s.removeFromScene(_scene);
			}

			// Удаляем грани из поверхности
			s.removeFaces();

			// Удаляем поверхность из меша
			s.removeFromMesh(this);
			delete _surfaces[id];

			return s;
		}

		/**
		 * Добавление всех граней объекта в указанную поверхность.
		 *
		 * @param surface экземпляр класса <code>alternativa.engine3d.core.Surface</code> или идентификатор поверхности, в
		 * которую добавляются грани. Если задан идентификатор, и объект не содержит поверхность с таким идентификатором,
		 * будет создана новая поверхность.
		 * 
		 * @param removeSurfaces удалять или нет пустые поверхности после переноса граней 
		 * 
		 * @return экземпляр поверхности, в которую перенесены грани
		 *  
		 * @throws alternativa.engine3d.errors.SurfaceNotFoundError объект не содержит указанный экземпляр поверхности
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 */
		public function moveAllFacesToSurface(surface:Object = null, removeSurfaces:Boolean = false):Surface {
			var returnSurface:Surface;
			var returnSurfaceId:Object;
			if (surface is Surface) {
				// Работаем с экземпляром Surface
				if (surface._mesh == this) {
					returnSurface = Surface(surface);
				} else {
					throw new SurfaceNotFoundError(surface, this);
				}
			} else {
				// Работаем с идентификатором
				if (_surfaces[surface] == undefined) {
					// Поверхности еще нет
					returnSurface = createSurface(null, surface);
					returnSurfaceId = surface;
				} else {
					if (_surfaces[surface] is Surface) {
						returnSurface = _surfaces[surface];
					} else { 
						// _surfaces[surface] по идентификатору возвращает не Surface
						throw new InvalidIDError(surface, this);
					}
				}
			}
			// Перемещаем все грани
			for each (var face:Face in _faces) {
				if (face._surface != returnSurface) {
					returnSurface.addFace(face);
				}
			}
			if (removeSurfaces) {
				// Удаляем старые, теперь вручную - меньше проверок, но рискованно
 				if (returnSurfaceId == null) {
 					returnSurfaceId = getSurfaceId(returnSurface);
 				}
 				var newSurfaces:Map = new Map();
 				newSurfaces[returnSurfaceId] = returnSurface;
 				delete _surfaces[returnSurfaceId];
 				// Удаляем оставшиеся
 				for (var currentSurfaceId:* in _surfaces) {
					 // Удаляем поверхность из сцены
					 var currentSurface:Surface = _surfaces[currentSurfaceId];
					 if (_scene != null) {
						currentSurface.removeFromScene(_scene);
					}
					// Удаляем поверхность из меша
					currentSurface.removeFromMesh(this);
					delete _surfaces[currentSurfaceId];
				}
				// Новый список граней
				_surfaces = newSurfaces;
			}
			return returnSurface;
		}

		/**
		 * Установка материала для указанной поверхности.
		 *  
		 * @param material материал, назначаемый поверхности. Один экземпляр SurfaceMaterial можно назначить только одной поверхности.
		 * @param surface экземпляр класса <code>alternativa.engine3d.core.Surface</code> или идентификатор поверхности
		 * 
		 * @throws alternativa.engine3d.errors.SurfaceNotFoundError объект не содержит указанную поверхность 
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 * 
		 * @see Surface 
		 */
		public function setMaterialToSurface(material:SurfaceMaterial, surface:Object):void {
			var byLink:Boolean = surface is Surface;

			// Проверяем на null
			if (surface == null) {
				throw new SurfaceNotFoundError(null, this);
			}

			// Проверяем наличие поверхности в меше
			if (byLink) {
				// Если назначаем по ссылке
				if (Surface(surface)._mesh != this) {
					// Если поверхность не в меше
					throw new SurfaceNotFoundError(surface, this);
				}
			} else {
				// Если назначаем по ID
				if (_surfaces[surface] == undefined) {
					// Если нет поверхности с таким ID
					throw new SurfaceNotFoundError(surface, this);
				} else if (!(_surfaces[surface] is Surface)) {
					throw new InvalidIDError(surface, this);
				}
			}

			// Находим поверхность
			var s:Surface = byLink ? Surface(surface) : _surfaces[surface];

			// Назначаем материал
			s.material = material;
		}

		/**
		 * Установка материала для всех поверхностей объекта. Для каждой поверхности устанавливается копия материала.
		 * При передаче <code>null</code> в качестве параметра происходит сброс материалов у всех поверхностей.
		 * 
		 * @param material устанавливаемый материал
		 */		
		public function cloneMaterialToAllSurfaces(material:SurfaceMaterial):void {
			for each (var surface:Surface in _surfaces) {
				surface.material = (material != null) ? SurfaceMaterial(material.clone()) : null;
			}
		}

		/**
		 * Установка UV-координат для указанной грани объекта. Матрица преобразования UV-координат расчитывается по
		 * UV-координатам первых трёх вершин грани, поэтому для корректного текстурирования эти вершины должны образовывать
		 * невырожденный треугольник в UV-пространстве.
		 *
		 * @param aUV UV-координаты, соответствующие первой вершине грани
		 * @param bUV UV-координаты, соответствующие второй вершине грани
		 * @param cUV UV-координаты, соответствующие третьей вершине грани
		 * @param face экземпляр класса <code>alternativa.engine3d.core.Face</code> или идентификатор грани
		 *  
		 * @throws alternativa.engine3d.errors.FaceNotFoundError объект не содержит указанную грань
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 * 
		 * @see Face
		 */
		public function setUVsToFace(aUV:Point, bUV:Point, cUV:Point, face:Object):void {
			var byLink:Boolean = face is Face;

			// Проверяем на null
			if (face == null) {
				throw new FaceNotFoundError(null, this);
			}
			
			// Проверяем наличие грани в меше
			if (byLink) {
				// Если назначаем по ссылке
				if (Face(face)._mesh != this) {
					// Если грань не в меше
					throw new FaceNotFoundError(face, this);
				}
			} else {
				// Если назначаем по ID
				if (_faces[face] == undefined) {
					// Если нет грани с таким ID
					throw new FaceNotFoundError(face, this);
				} else if (!(_faces[face] is Face)) {
					throw new InvalidIDError(face, this);
				}
			}
			
			// Находим грань
			var f:Face = byLink ? Face(face) : _faces[face];
			
			// Назначаем UV-координаты
			f.aUV = aUV;
			f.bUV = bUV;
			f.cUV = cUV;
		}  

		/**
		 * Набор вершин объекта. Ключами ассоциативного массива являются идентификаторы вершин, значениями - экземпляры вершин.
		 */
		public function get vertices():Map {
			return _vertices.clone();
		}

		/**
		 * Набор граней объекта. Ключами ассоциативного массива являются идентификаторы граней, значениями - экземпляры граней.
		 */
		public function get faces():Map {
			return _faces.clone();
		}

		/**
		 * Набор поверхностей объекта. Ключами ассоциативного массива являются идентификаторы поверхностей, значениями - экземпляры поверхностей.
		 */		
		public function get surfaces():Map {
			return _surfaces.clone();
		}

		/**
		 * Получение вершины объекта по её идентификатору.
		 *  
		 * @param id идентификатор вершины
		 * 
		 * @return экземпляр вершины с указанным идентификатором
		 * 
		 * @throws alternativa.engine3d.errors.VertexNotFoundError объект не содержит вершину с указанным идентификатором
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 */
		public function getVertexById(id:Object):Vertex {
			if (id == null) {
				throw new VertexNotFoundError(null, this);
			}
			if (_vertices[id] == undefined) {
				// Если нет вершины с таким ID
				throw new VertexNotFoundError(id, this);
			} else {
				if (_vertices[id] is Vertex) {
					return _vertices[id];
				} else {
					throw new InvalidIDError(id, this);
				}
			}
		}

		/**
		 * Получение идентификатора вершины объекта. 
		 *
		 * @param экземпляр вершины
		 *
		 * @return идентификатор указанной вершины
		 * 
		 * @throws alternativa.engine3d.errors.VertexNotFoundError объект не содержит указанную вершину
		 */
		public function getVertexId(vertex:Vertex):Object {
			if (vertex == null) {
				throw new VertexNotFoundError(null, this);
			}
			if (vertex._mesh != this) {
				// Если вершина не в меше
				throw new VertexNotFoundError(vertex, this);
			}
			for (var i:Object in _vertices) {
				if (_vertices[i] == vertex) {
					return i;
				}
			}
			throw new VertexNotFoundError(vertex, this);
		}

		/**
		 * Проверка наличия вершины в объекте.
		 * 
		 * @param vertex экземпляр класса <code>alternativa.engine3d.core.Vertex</code> или идентификатор вершины
		 * 
		 * @return <code>true</code>, если объект содержит указанную вершину, иначе <code>false</code>  
		 * 
		 * @throws alternativa.engine3d.errors.VertexNotFoundError в качестве vertex был передан null
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 * 
		 * @see Vertex
		 */
		public function hasVertex(vertex:Object):Boolean {
			if (vertex == null) {
				throw new VertexNotFoundError(null, this);
			}
			if (vertex is Vertex) {
				// Проверка вершины
				return vertex._mesh == this;
			} else {
				// Проверка ID вершины
				if (_vertices[vertex] != undefined) {
					// По этому ID есть объект
					if (_vertices[vertex] is Vertex) {
						// Объект является вершиной
						return true;
					} else {
						// ID некорректный
						throw new InvalidIDError(vertex, this);
					}
				} else {
					return false;
				}
			}
		}

		/**
		 * Получение грани объекта по ее идентификатору.
		 *  
		 * @param id идентификатор грани
		 * 
		 * @return экземпляр грани с указанным идентификатором
		 *
		 * @throws alternativa.engine3d.errors.FaceNotFoundError объект не содержит грань с указанным идентификатором
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 */
		public function getFaceById(id:Object):Face {
			if (id == null) {
				throw new FaceNotFoundError(null, this);
			}
			if (_faces[id] == undefined) {
				// Если нет грани с таким ID
				throw new FaceNotFoundError(id, this);
			} else {
				if (_faces[id] is Face) {
					return _faces[id];
				} else { 
					throw new InvalidIDError(id, this);
				}
			}
		}

		/**
		 * Получение идентификатора грани объекта.
		 *  
		 * @param face экземпляр грани
		 * 
		 * @return идентификатор указанной грани 
		 * 
		 * @throws alternativa.engine3d.errors.FaceNotFoundError объект не содержит указанную грань
		 */
		public function getFaceId(face:Face):Object {
			if (face == null) {
				throw new FaceNotFoundError(null, this);
			}
			if (face._mesh != this) {
				// Если грань не в меше
				throw new FaceNotFoundError(face, this);
			}
			for (var i:Object in _faces) {
				if (_faces[i] == face) {
					return i;
				}
			}
			throw new FaceNotFoundError(face, this);
		}

		/**
		 * Проверка наличия грани в объекте.
		 * 
		 * @param face экземпляр класса <code>Face</code> или идентификатор грани
		 * 
		 * @return <code>true</code>, если объект содержит указанную грань, иначе <code>false</code> 
		 * 
		 * @throws alternativa.engine3d.errors.FaceNotFoundError в качестве face был указан null
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора
		 */
		public function hasFace(face:Object):Boolean {
			if (face == null) {
				throw new FaceNotFoundError(null, this);
			}
			if (face is Face) {
				// Проверка грани
				return face._mesh == this;
			} else {
				// Проверка ID грани
				if (_faces[face] != undefined) {
					// По этому ID есть объект
					if (_faces[face] is Face) {
						// Объект является гранью
						return true;
					} else {
						// ID некорректный
						throw new InvalidIDError(face, this);
					}
				} else {
					return false;
				}
			}
		}

		/**
		 * Получение поверхности объекта по ее идентификатору
		 *  
		 * @param id идентификатор поверхности
		 * 
		 * @return экземпляр поверхности с указанным идентификатором
		 * 
		 * @throws alternativa.engine3d.errors.SurfaceNotFoundError объект не содержит поверхность с указанным идентификатором
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора 
		 */
		public function getSurfaceById(id:Object):Surface {
			if (id == null) {
				throw new SurfaceNotFoundError(null, this);
			}
			if (_surfaces[id] == undefined) {
				// Если нет поверхности с таким ID
				throw new SurfaceNotFoundError(id, this);
			} else {
				if (_surfaces[id] is Surface) {
					return _surfaces[id];
				} else {
					throw new InvalidIDError(id, this);
				}
			}
		}

		/**
		 * Получение идентификатора поверхности объекта.
		 *  
		 * @param surface экземпляр поверхности
		 * 
		 * @return идентификатор указанной поверхности
		 * 
		 * @throws alternativa.engine3d.errors.SurfaceNotFoundError объект не содержит указанную поверхность 
		 */
		public function getSurfaceId(surface:Surface):Object {
			if (surface == null) {
				throw new SurfaceNotFoundError(null, this);
			}
			if (surface._mesh != this) {
				// Если поверхность не в меше
				throw new SurfaceNotFoundError(surface, this);
			}
			for (var i:Object in _surfaces) {
				if (_surfaces[i] == surface) {
					return i;
				}
			}
			return null;
		}
		
		/**
		 * Проверка наличия поверхности в объекте.
		 *  
		 * @param surface экземпляр класса <code>Surface</code> или идентификатор поверхности
		 *  
		 * @return <code>true</true>, если объект содержит указанную поверхность, иначе <code>false</code>
		 *  
		 * @throws alternativa.engine3d.errors.SurfaceNotFoundError в качестве surface был передан null 
		 * @throws alternativa.engine3d.errors.InvalidIDError указано недопустимое значение идентификатора 
 		 */
		public function hasSurface(surface:Object):Boolean {
			if (surface == null) {
				throw new SurfaceNotFoundError(null, this);
			}
			if (surface is Surface) {
				// Проверка поверхности
				return surface._mesh == this;
			} else {
				// Проверка ID поверхности
				if (_surfaces[surface] != undefined) {
					// По этому ID есть объект
					if (_surfaces[surface] is Surface) {
						// Объект является поверхностью
						return true;
					} else {
						// ID некорректный
						throw new InvalidIDError(surface, this);
					}
				} else {
					return false;
				}
			}
		}

		/**
		 * @private
		 * @inheritDoc
		 */		
		override alternativa3d function setScene(value:Scene3D):void {
			if (_scene != value) {
				var vertex:Vertex;
				var face:Face;
				var surface:Surface;
				if (value != null) {
					// Добавить вершины на сцену
					for each (vertex in _vertices) {
						vertex.addToScene(value);
					}
					// Добавить грани на сцену
					for each (face in _faces) {
						face.addToScene(value);
					}
					// Добавить поверхности на сцену
					for each (surface in _surfaces) {
						surface.addToScene(value);
					}
				} else {
					// Удалить вершины из сцены
					for each (vertex in _vertices) {
						vertex.removeFromScene(_scene);
					}
					// Удалить грани из сцены
					for each (face in _faces) {
						face.removeFromScene(_scene);
					}
					// Удалить поверхности из сцены
					for each (surface in _surfaces) {
						surface.removeFromScene(_scene);
					}
				}
			}
			super.setScene(value);
		}

		/**
		 * @inheritDoc
		 */
		override protected function defaultName():String {
			return "mesh" + ++counter;
		}

		/**
		 * @inheritDoc
		 */
		override public function toString():String {
			return "[" + ObjectUtils.getClassName(this) + " " + _name + " vertices: " + _vertices.length + " faces: " + _faces.length + "]";
		}

		/**
		 * @inheritDoc
		 */		
		override protected function createEmptyObject():Object3D {
			return new Mesh();
		}

		/**
		 * @inheritDoc
		 */
		override protected function clonePropertiesFrom(source:Object3D):void {
			super.clonePropertiesFrom(source);

			var src:Mesh = Mesh(source);

			var id:*;
			var len:int;
			var i:int;
			// Копирование вершин
			var vertexMap:Map = new Map(true);
			for (id in src._vertices) {
				var sourceVertex:Vertex = src._vertices[id];
				vertexMap[sourceVertex] = createVertex(sourceVertex.x, sourceVertex.y, sourceVertex.z, id);
			}

			// Копирование граней
			var faceMap:Map = new Map(true);
			for (id in src._faces) {
				var sourceFace:Face = src._faces[id];
				len = sourceFace._vertices.length;
				var faceVertices:Array = new Array(len);
				for (i = 0; i < len; i++) {
					faceVertices[i] = vertexMap[sourceFace._vertices[i]];
				}
				var newFace:Face = createFace(faceVertices, id);
				newFace.aUV = sourceFace._aUV;
				newFace.bUV = sourceFace._bUV;
				newFace.cUV = sourceFace._cUV;
				faceMap[sourceFace] = newFace;
			}

			// Копирование поверхностей
			for (id in src._surfaces) {
				var sourceSurface:Surface = src._surfaces[id];
				var surfaceFaces:Array = sourceSurface._faces.toArray();
				len = surfaceFaces.length;
				for (i = 0; i < len; i++) {
					surfaceFaces[i] = faceMap[surfaceFaces[i]];
				}
				var surface:Surface = createSurface(surfaceFaces, id);
				var sourceMaterial:SurfaceMaterial = sourceSurface.material;
				if (sourceMaterial != null) {
					surface.material = SurfaceMaterial(sourceMaterial.clone());
				}
			}
		}

	}
}
