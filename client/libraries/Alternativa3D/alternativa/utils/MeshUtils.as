package alternativa.utils {
	
	import alternativa.engine3d.*;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.core.Vertex;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.SurfaceMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.TextureMaterialPrecision;
	import alternativa.engine3d.materials.WireMaterial;
	import alternativa.types.*;
	
	import flash.display.BlendMode;
	import flash.geom.Point;
	
	use namespace alternativa3d;
	use namespace alternativatypes;
	
	/**
	 * Утилиты для работы с Mesh-объектами.
	 */	
	public class MeshUtils {

		static private var verticesSort:Array = ["x", "y", "z"];
		static private var verticesSortOptions:Array = [Array.NUMERIC, Array.NUMERIC, Array.NUMERIC];
		
		/**
		 * Объединение нескольких Mesh-объектов. Объекты, переданные как аргументы метода, не изменяются.
		 * 
		 * @param meshes объединяемые объекты класса <code>alternativa.engine3d.core.Mesh</code>
		 * 
		 * @return новый Mesh-объект, содержащий результат объединения переданных Mesh-объектов
		 */
		static public function uniteMeshes(... meshes):Mesh {
			var res:Mesh = new Mesh();
			
			var length:uint = meshes.length;
			var key:*;
			var vertex:Vertex;
			var face:Face;
			var j:uint;
			for (var i:uint = 0; i < length; i++) {
				var mesh:Mesh = meshes[i];
				var vertices:Map = mesh._vertices.clone();
				for (key in vertices) {
					vertex = vertices[key];
					vertices[key] = res.createVertex(vertex.x, vertex.y, vertex.z);
				}
				var faces:Map = mesh._faces.clone();
				for (key in faces) {
					face = faces[key];
					var faceVertices:Array = new Array().concat(face._vertices);
					for (j = 0; j < face._verticesCount; j++) {
						vertex = faceVertices[j];
						faceVertices[j] = vertices[vertex.id];
					}
					faces[key] = res.createFace(faceVertices);
					res.setUVsToFace(face._aUV, face._bUV, face._cUV, faces[key]);
				}
				for (key in mesh._surfaces) {
					var surface:Surface = mesh._surfaces[key];
					var surfaceFaces:Array = surface._faces.toArray();
					var numFaces:uint = surfaceFaces.length;
					for (j = 0; j < numFaces; j++) {
						face = surfaceFaces[j];
						surfaceFaces[j] = faces[face.id];
					}
					var newSurface:Surface = res.createSurface(surfaceFaces);
					newSurface.material = SurfaceMaterial(surface.material.clone()); 
				}
			}
			return res;
		}
		
		/**
		 * Слияние вершин Mesh-объекта с одинаковыми координатами. Равенство координат проверяется с учётом погрешности.
		 * 
		 * @param mesh объект, вершины которого объединяются
		 * @param threshold погрешность измерения расстояний
		 */		
		static public function autoWeldVertices(mesh:Mesh, threshold:Number = 0):void {
			// Получаем список вершин меша и сортируем по координатам
			var vertices:Array = mesh._vertices.toArray(true);
			vertices.sortOn(verticesSort, verticesSortOptions);

			// Поиск вершин с одинаковыми координатами
			var weld:Map = new Map(true);
			var vertex:Vertex;
			var currentVertex:Vertex = vertices[0];
			var length:uint = vertices.length;
			var i:uint;
			for (i = 1; i < length; i++) {
				vertex = vertices[i];
				if ((currentVertex.x - vertex.x <= threshold) && (currentVertex.x - vertex.x >= -threshold) && (currentVertex.y - vertex.y <= threshold) && (currentVertex.y - vertex.y >= -threshold) && (currentVertex.z - vertex.z <= threshold) && (currentVertex.z - vertex.z >= -threshold)) {
					weld[vertex] = currentVertex;
				} else {
					currentVertex = vertex;
				}
			}
			
			// Собираем грани объединяемых вершин
			var faces:Set = new Set(true);
			var keyVertex:*;
			var keyFace:*;
			for (keyVertex in weld) {
				vertex = keyVertex;
				for (keyFace in vertex._faces) {
					faces[keyFace] = true;
				}
			}

			// Заменяем грани
			for (keyFace in faces) {
				var face:Face = keyFace;
				var id:Object = mesh.getFaceId(face);
				var surface:Surface = face._surface;
				var aUV:Point = face._aUV;
				var bUV:Point = face._bUV;
				var cUV:Point = face._cUV;
				vertices = new Array().concat(face._vertices);
				length = vertices.length;
				for (i = 0; i < length; i++) {
					vertex = weld[vertices[i]];
					if (vertex != null) {
						vertices[i] = vertex;
					}
				}
				mesh.removeFace(face);
				face = mesh.createFace(vertices, id);
				if (surface != null) {
					surface.addFace(face);
				}
				face.aUV = aUV;
				face.bUV = bUV;
				face.cUV = cUV;
			}
			
			// Удаляем вершины
			for (keyVertex in weld) {
				mesh.removeVertex(keyVertex);
			}
		}
		
		/**
		 * Объединение соседних граней, образующих плоский выпуклый многоугольник.
		 * 
		 * @param mesh объект, грани которого объединяются
		 * @param angleThreshold погрешность измерения углов
		 * @param uvThreshold погрешность измерения UV-координат
		 * @param ignoreLineJoints значение <code>true</code> запрещает объединения, в результате которых два соседних ребра оказываются на одной линии.
		 * Например, если флаг включен, два прямоугольника с общим ребром не объединятся.
		 */		 
		static public function autoWeldFaces(mesh:Mesh, angleThreshold:Number = 0, uvThreshold:Number = 0, ignoreLineJoints:Boolean = false):void {
			angleThreshold = Math.cos(angleThreshold);
			var digitThreshold:Number = 0.001;
			
			var vertex:Vertex;
			var face:Face;
			var sibling:Face;
			var key:*;
			var i:uint;
			var normal:Point3D;

			// Формируем списки граней
			var faces1:Set = new Set(true);
			var faces2:Set = new Set(true);

			// Формируем список нормалей
			var normals:Map = new Map(true);
			for each (face in mesh._faces.clone()) {
				normal = new Point3D();
				vertex = face._vertices[0];
				var av:Point3D = vertex._coords;
				vertex = face._vertices[1];
				var abx:Number = vertex._coords.x - av.x;
				var aby:Number = vertex._coords.y - av.y;
				var abz:Number = vertex._coords.z - av.z;
				vertex = face._vertices[2];
				var acx:Number = vertex._coords.x - av.x;
				var acy:Number = vertex._coords.y - av.y;
				var acz:Number = vertex._coords.z - av.z;
				normal.x = acz*aby - acy*abz;
				normal.y = acx*abz - acz*abx;
				normal.z = acy*abx - acx*aby;
				var normalLength:Number = Math.sqrt(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z);
				if (normalLength > digitThreshold) {
					normal.x /= normalLength;
					normal.y /= normalLength;
					normal.z /= normalLength;
					faces1[face] = true;
					normals[face] = normal;
				} else {
					mesh.removeFace(face);
				}
			}

			// Объединение
			do {
				// Флаг объединения
				var weld:Boolean = false;
				// Объединяем грани
				while ((face = faces1.take()) != null) {
					//var num:uint = face.num;
					//var vertices:Array = face.vertices;
					var currentWeld:Boolean = false;
					
					// Проверка общих граней по точкам
					
					
					// Проверка общих граней по рёбрам

					// Перебираем точки грани
					for (i = 0; (i < face._verticesCount) && !currentWeld; i++) {
						var faceIndex1:uint = i;
						var faceIndex2:uint;
						var siblingIndex1:int;
						var siblingIndex2:uint;
						
						// Перебираем грани текущей точки
						vertex = face._vertices[faceIndex1];
						var vertexFaces:Set = vertex.faces;
						for (key in vertexFaces) {
							sibling = key;
							// Если грань в списке на объединение и в одной поверхности
							if (faces1[sibling] && face._surface == sibling._surface) {
								faceIndex2 = (faceIndex1 < face._verticesCount - 1) ? (faceIndex1 + 1) : 0;
								siblingIndex1 = sibling._vertices.indexOf(face._vertices[faceIndex2]);
								// Если общее ребро
								if (siblingIndex1 >= 0) {
									// Если грани сонаправлены
									normal = normals[face]; 
									if (Point3D.dot(normal, normals[sibling]) >= angleThreshold) {
										// Если в точках объединения нет перегибов
										siblingIndex2 = (siblingIndex1 < sibling._verticesCount - 1) ? (siblingIndex1 + 1) : 0;

										// Расширяем грани объединения
										var i1:uint;
										var i2:uint;
										while (true) {
											i1 = (faceIndex1 > 0) ? (faceIndex1 - 1) : (face._verticesCount - 1);
											i2 = (siblingIndex2 < sibling._verticesCount - 1) ? (siblingIndex2 + 1) : 0;
											if (face._vertices[i1] == sibling._vertices[i2]) {
												faceIndex1 = i1;
												siblingIndex2 = i2;
											} else {
												break;
											}
										}

										while (true) {
											i1 = (faceIndex2 < face._verticesCount - 1) ? (faceIndex2 + 1) : 0;
											i2 = (siblingIndex1 > 0) ? (siblingIndex1 - 1) : (sibling._verticesCount - 1);
											if (face._vertices[i1] == sibling._vertices[i2]) {
												faceIndex2 = i1;
												siblingIndex1 = i2;
											} else {
												break;
											}
										}

										vertex = face._vertices[faceIndex1];
										var a:Point3D = vertex.coords;
										vertex = face._vertices[faceIndex2];
										var b:Point3D = vertex.coords;

										// Считаем первый перегиб
										vertex = sibling._vertices[(siblingIndex2 < sibling._verticesCount - 1) ? (siblingIndex2 + 1) : 0];
										var c:Point3D = vertex.coords;
										vertex = face._vertices[(faceIndex1 > 0) ? (faceIndex1 - 1) : (face._verticesCount - 1)];
										var d:Point3D = vertex.coords;

										var cx:Number = c.x - a.x;
										var cy:Number = c.y - a.y;
										var cz:Number = c.z - a.z;
										var dx:Number = d.x - a.x;
										var dy:Number = d.y - a.y;
										var dz:Number = d.z - a.z;
										
										var crossX:Number = cy*dz - cz*dy;
										var crossY:Number = cz*dx - cx*dz;
										var crossZ:Number = cx*dy - cy*dx;
										var zeroCross:Boolean = crossX < digitThreshold && crossX > -digitThreshold && crossY < digitThreshold && crossY > -digitThreshold && crossZ < digitThreshold && crossZ > -digitThreshold;
										if (zeroCross && (cx*dx + cy*dy + cz*dz > 0 || ignoreLineJoints) || !zeroCross && crossX*normal.x + crossY*normal.y + crossZ*normal.z < 0) {
											break;
										}
									
										// Считаем второй перегиб
										vertex = face._vertices[(faceIndex2 < face._verticesCount - 1) ? (faceIndex2 + 1) : 0];
										c = vertex.coords;
										vertex = sibling._vertices[(siblingIndex1 > 0) ? (siblingIndex1 - 1) : (sibling._verticesCount - 1)];
										d = vertex.coords;

										cx = c.x - b.x;
										cy = c.y - b.y;
										cz = c.z - b.z;
										dx = d.x - b.x;
										dy = d.y - b.y;
										dz = d.z - b.z;
										
										crossX = cy*dz - cz*dy;
										crossY = cz*dx - cx*dz;
										crossZ = cx*dy - cy*dx;
										zeroCross = crossX < digitThreshold && crossX > -digitThreshold && crossY < digitThreshold && crossY > -digitThreshold && crossZ < digitThreshold && crossZ > -digitThreshold;
										if (zeroCross && (cx*dx + cy*dy + cz*dz > 0 || ignoreLineJoints) || !zeroCross && crossX*normal.x + crossY*normal.y + crossZ*normal.z < 0) {
											break;
										}
											
										// Флаг наличия UV у обеих граней
										var hasUV:Boolean = (face._aUV != null && face._bUV != null && face._cUV != null && sibling._aUV != null && sibling._bUV != null && sibling._cUV != null);
										
										if (hasUV || (face._aUV == null && face._bUV == null && face._cUV == null && sibling._aUV == null && sibling._bUV == null && sibling._cUV == null)) {
											
											// Если грани имеют UV, проверяем совместимость
											if (hasUV) {
												vertex = sibling._vertices[0];
												var uv:Point = face.getUVFast(vertex.coords, normal);
												if ((uv.x - sibling._aUV.x > uvThreshold) || (uv.x - sibling._aUV.x < -uvThreshold) || (uv.y - sibling._aUV.y > uvThreshold) || (uv.y - sibling._aUV.y < -uvThreshold)) {
													break;
												}
												
												vertex = sibling._vertices[1];
												uv = face.getUVFast(vertex.coords, normal);
												if ((uv.x - sibling._bUV.x > uvThreshold) || (uv.x - sibling._bUV.x < -uvThreshold) || (uv.y - sibling._bUV.y > uvThreshold) || (uv.y - sibling._bUV.y < -uvThreshold)) {
													break;
												}
												
												vertex = sibling._vertices[2];
												uv = face.getUVFast(vertex.coords, normal);
												if ((uv.x - sibling._cUV.x > uvThreshold) || (uv.x - sibling._cUV.x < -uvThreshold) || (uv.y - sibling._cUV.y > uvThreshold) || (uv.y - sibling._cUV.y < -uvThreshold)) {
													break;
												}
											}
										
											// Формируем новую грань
											var newVertices:Array = new Array();
											var n:uint = faceIndex2;
											do {
												newVertices.push(face._vertices[n]);
												n = (n < face._verticesCount - 1) ? (n + 1) : 0;
											} while (n != faceIndex1); 
											n = siblingIndex2;
											do {
												newVertices.push(sibling._vertices[n]);
												n = (n < sibling._verticesCount - 1) ? (n + 1) : 0;
											} while (n != siblingIndex1); 
											
											// Выбираем начальную точку
											n = getBestBeginVertexIndex(newVertices);
											for (var m:uint = 0; m < n; m++) {
												newVertices.push(newVertices.shift());
											}
											
											// Заменяем грани новой
											var surface:Surface = face._surface;
											var newFace:Face = mesh.createFace(newVertices);
											if (hasUV) {
												newFace.aUV = face.getUVFast(newVertices[0].coords, normal);
												newFace.bUV = face.getUVFast(newVertices[1].coords, normal);
												newFace.cUV = face.getUVFast(newVertices[2].coords, normal);
											}
											if (surface != null) {
												surface.addFace(newFace);
											}
											mesh.removeFace(face);
											mesh.removeFace(sibling);
											
											// Обновляем список нормалей
											delete normals[sibling];
											delete normals[face];
											normals[newFace] = newFace.normal;

											// Обновляем списки расчётов
											delete faces1[sibling];
											faces2[newFace] = true;

											// Помечаем объединение
											weld = true;
											currentWeld = true;
											break;
										}
									} 
								}								
							}
						}
					}
					
					// Если не удалось объединить, переносим грань
					faces2[face] = true;
				}
				
				// Меняем списки
				var fs:Set = faces1;
				faces1 = faces2;
				faces2 = fs;
			} while (weld);
			
			removeIsolatedVertices(mesh);
			removeUselessVertices(mesh);
		}
		
		/**
		 * Удаление вершин объекта, не принадлежащим ни одной грани.
		 * 
		 * @param mesh объект, вершины которого удаляются
		 */		
		static public function removeIsolatedVertices(mesh:Mesh):void {
			for each (var vertex:Vertex in mesh._vertices.clone()) {
				if (vertex._faces.isEmpty()) {
					mesh.removeVertex(vertex);
				}
			}
		}
		
		/**
		 * Удаление вершин объекта, которые во всех своих гранях лежат на отрезке между предыдущей и следующей вершиной.
		 * 
		 * @param mesh объект, вершины которого удаляются
		 */		
		static public function removeUselessVertices(mesh:Mesh):void {
			var digitThreshold:Number = 0.001;
			var v:Vertex;
			var key:*;
			var face:Face;
			var index:uint;
			var length:uint;
			for each (var vertex:Vertex in mesh._vertices.clone()) {
				var useless:Boolean = true;
				var indexes:Map = new Map(true);
				for (key in vertex._faces) {
					face = key;
					length = face._vertices.length;
					index = face._vertices.indexOf(vertex);
					v = face._vertices[index];
					var a:Point3D = v.coords;
					v = face._vertices[(index < length - 1) ? (index + 1) : 0];
					var b:Point3D = v.coords;
					v = face._vertices[(index > 0) ? (index - 1) : (length - 1)];
					var c:Point3D = v.coords;
					var abx:Number = b.x - a.x;
					var aby:Number = b.y - a.y;
					var abz:Number = b.z - a.z;
					var acx:Number = c.x - a.x;
					var acy:Number = c.y - a.y;
					var acz:Number = c.z - a.z;
					var crossX:Number = aby*acz - abz*acy;
					var crossY:Number = abz*acx - abx*acz;
					var crossZ:Number = abx*acy - aby*acx;
					if (crossX < digitThreshold && crossX > -digitThreshold && crossY < digitThreshold && crossY > -digitThreshold && crossZ < digitThreshold && crossZ > -digitThreshold) {
						indexes[face] = index;
					} else {
						useless = false;
						break;
					}
				}
				if (useless && !indexes.isEmpty()) {
					// Удаляем
					for (key in indexes) {
						var i:uint;
						face = key;
						index = indexes[face];
						length = face._vertices.length;
						var newVertices:Array = new Array();
						for (i = 0; i < length; i++) {
							if (i != index) {
								newVertices.push(face._vertices[i]);
							}
						}
						var n:uint = getBestBeginVertexIndex(newVertices);
						for (i = 0; i < n; i++) {
							newVertices.push(newVertices.shift());
						}
						var surface:Surface = face._surface;
						var newFace:Face = mesh.createFace(newVertices);
						if (face._aUV != null && face._bUV != null && face._cUV != null) {
							var normal:Point3D = face.normal;
							newFace.aUV = face.getUVFast(newVertices[0].coords, normal);
							newFace.bUV = face.getUVFast(newVertices[1].coords, normal);
							newFace.cUV = face.getUVFast(newVertices[2].coords, normal);
						}
						if (surface != null) {
							surface.addFace(newFace);
						}
						mesh.removeFace(face);
					}
					mesh.removeVertex(vertex);
				}
			}
		}
		
		/**
		 * Удаление вырожденных граней.
		 * 
		 * @param mesh объект, грани которого удаляются
		 */
		static public function removeSingularFaces(mesh:Mesh):void {
			for each (var face:Face in mesh._faces.clone()) {
				var normal:Point3D = face.normal;
				if (normal.x == 0 && normal.y == 0 && normal.z == 0) {
					mesh.removeFace(face);
				}
			}
		}
		
		/**
		 * @private
		 * Находит наиболее подходящую первую точку.
		 * @param vertices
		 * @return 
		 */		
		static public function getBestBeginVertexIndex(vertices:Array):uint {
			var bestIndex:uint = 0;
			var num:uint = vertices.length;
			if (num > 3) {
				var maxCrossLength:Number = 0;
				var v:Vertex = vertices[num - 1];
				var c1:Point3D = v.coords;
				v = vertices[0];
				var c2:Point3D = v.coords;
	
				var prevX:Number = c2.x - c1.x;
				var prevY:Number = c2.y - c1.y;
				var prevZ:Number = c2.z - c1.z;
				
				for (var i:uint = 0; i < num; i++) {
					c1 = c2;
					v = vertices[(i < num - 1) ? (i + 1) : 0];
					c2 = v.coords;
	
					var nextX:Number = c2.x - c1.x;
					var nextY:Number = c2.y - c1.y;
					var nextZ:Number = c2.z - c1.z;
	
					var crossX:Number = prevY*nextZ - prevZ*nextY; 
					var crossY:Number = prevZ*nextX - prevX*nextZ; 
					var crossZ:Number = prevX*nextY - prevY*nextX;
					
					
					var crossLength:Number = crossX*crossX + crossY*crossY + crossZ*crossZ;
					if (crossLength > maxCrossLength) {
						maxCrossLength = crossLength;
						bestIndex = i;
					}
					
					prevX = nextX;
					prevY = nextY;
					prevZ = nextZ;
				}
				// Берём предыдущий
				bestIndex = (bestIndex > 0) ? (bestIndex - 1) : (num - 1);
			}
			
			return bestIndex;
		}
		
		/**
		 * Генерация AS-класса.
		 *   
		 * @param mesh объект, на базе которого генерируется класс
		 * @param packageName имя пакета для генерируемого класса
		 * @return AS-класс в текстовом виде
		 */
		static public function generateClass(mesh:Mesh, packageName:String = ""):String {
			
			var className:String = mesh._name.charAt(0).toUpperCase() + mesh._name.substr(1);
			
			var header:String = "package" + ((packageName != "") ? (" " + packageName + " ") : " ") + "{\r\r";
			
			var importSet:Object = new Object();
			importSet["alternativa.engine3d.core.Mesh"] = true;

			var materialSet:Map = new Map(true);
			var materialName:String;			
			var materialNum:uint = 1;
			
			var footer:String = "\t\t}\r\t}\r}";
			
			var classHeader:String = "\tpublic class "+ className + " extends Mesh {\r\r";
			
			var constructor:String = "\t\tpublic function " + className + "() {\r";
			constructor += "\t\t\tsuper(\"" + mesh._name +"\");\r\r";
			
			
			var newLine:Boolean = false;
			if (mesh.mobility != 0) {
				constructor += "\t\t\tmobility = " + mesh.mobility +";\r";
				newLine = true;
			} 

			if (mesh.x != 0 && mesh.y != 0 && mesh.z != 0) {
				importSet["alternativa.types.Point3D"] = true;
				constructor += "\t\t\tcoords = new Point3D(" + mesh.x + ", " + mesh.y + ", " + mesh.z +");\r";
				newLine = true;
			} else {
				if (mesh.x != 0) {
					constructor += "\t\t\tx = " + mesh.x + ";\r";
					newLine = true;
				}
				if (mesh.y != 0) {
					constructor += "\t\t\ty = " + mesh.y + ";\r";
					newLine = true;
				}
				if (mesh.z != 0) {
					constructor += "\t\t\tz = " + mesh.z + ";\r";
					newLine = true;
				}
			}
			if (mesh.rotationX != 0) {
				constructor += "\t\t\trotationX = " + mesh.rotationX + ";\r";
				newLine = true;
			}
			if (mesh.rotationY != 0) {
				constructor += "\t\t\trotationY = " + mesh.rotationY + ";\r";
				newLine = true;
			}
			if (mesh.rotationZ != 0) {
				constructor += "\t\t\trotationZ = " + mesh.rotationZ + ";\r";
				newLine = true;
			}
			if (mesh.scaleX != 1) {
				constructor += "\t\t\tscaleX = " + mesh.scaleX + ";\r";
				newLine = true;
			}
			if (mesh.scaleY != 1) {
				constructor += "\t\t\tscaleY = " + mesh.scaleY + ";\r";
				newLine = true;
			}
			if (mesh.scaleZ != 1) {
				constructor += "\t\t\tscaleZ = " + mesh.scaleZ + ";\r";
				newLine = true;
			}

			constructor += newLine ? "\r" : "";
			
			function idToString(value:*):String {
				return isNaN(value) ? ("\"" + value + "\"") : value;
			}
			
			function blendModeToString(value:String):String {
				switch (value) {
					case BlendMode.ADD: return "BlendMode.ADD";
					case BlendMode.ALPHA: return "BlendMode.ALPHA";
					case BlendMode.DARKEN: return "BlendMode.DARKEN";
					case BlendMode.DIFFERENCE: return "BlendMode.DIFFERENCE";
					case BlendMode.ERASE: return "BlendMode.ERASE";
					case BlendMode.HARDLIGHT: return "BlendMode.HARDLIGHT";
					case BlendMode.INVERT: return "BlendMode.INVERT";
					case BlendMode.LAYER: return "BlendMode.LAYER";
					case BlendMode.LIGHTEN: return "BlendMode.LIGHTEN";
					case BlendMode.MULTIPLY: return "BlendMode.MULTIPLY";
					case BlendMode.NORMAL: return "BlendMode.NORMAL";
					case BlendMode.OVERLAY: return "BlendMode.OVERLAY";
					case BlendMode.SCREEN: return "BlendMode.SCREEN";
					case BlendMode.SUBTRACT: return "BlendMode.SUBTRACT";
					default: return "BlendMode.NORMAL";
				}
			}
			
			function colorToString(value:uint):String {
				var hex:String = value.toString(16).toUpperCase();
				var res:String = "0x";
				var len:uint = 6 - hex.length;
				for (var j:uint = 0; j < len; j++) {
					res += "0";
				}
				res += hex;
				return res;
			}
			
			var i:uint;
			var length:uint;
			var key:*;
			var id:String;
			var face:Face;
			var surface:Surface;
			
			newLine = false;
			for (id in mesh._vertices) {
				var vertex:Vertex = mesh._vertices[id];
				var coords:Point3D = vertex.coords;
				constructor += "\t\t\tcreateVertex(" + coords.x + ", " + coords.y + ", " + coords.z + ", " + idToString(id) + ");\r";
				newLine = true;
			}

			constructor += newLine ? "\r" : "";

			newLine = false;
			for (id in mesh._faces) {
				face = mesh._faces[id];
				length = face._verticesCount;
				constructor += "\t\t\tcreateFace(["
				for (i = 0; i < length - 1; i++) {
					constructor += idToString(mesh.getVertexId(face._vertices[i])) + ", ";
				}
				constructor += idToString(mesh.getVertexId(face._vertices[i])) + "], " + idToString(id) + ");\r";
				
				if (face._aUV != null || face._bUV != null || face._cUV != null) {
					importSet["flash.geom.Point"] = true;
					constructor += "\t\t\tsetUVsToFace(new Point(" + face._aUV.x + ", " + face._aUV.y + "), new Point(" + face._bUV.x + ", " + face._bUV.y + "), new Point(" + face._cUV.x + ", " + face._cUV.y + "), " + idToString(id) + ");\r";
				}
				newLine = true;
			}
			
			constructor += newLine ? "\r" : "";
			
			for (id in mesh._surfaces) {
				surface = mesh._surfaces[id];
				var facesStr:String = "";
				for (key in surface._faces) {
					facesStr += idToString(mesh.getFaceId(key)) + ", ";
				}
				constructor += "\t\t\tcreateSurface([" + facesStr.substr(0, facesStr.length - 2) + "], " + idToString(id) + ");\r";

				if (surface.material != null) {
					var material:String;
					var defaultAlpha:Boolean = surface.material.alpha == 1;
					var defaultBlendMode:Boolean = surface.material.blendMode == BlendMode.NORMAL;
					if (surface.material is WireMaterial) {
						importSet["alternativa.engine3d.materials.WireMaterial"] = true;
						var defaultThickness:Boolean = WireMaterial(surface.material).thickness == 0;
						var defaultColor:Boolean = WireMaterial(surface.material).color == 0;
						material = "new WireMaterial(";
						if (!defaultThickness || !defaultColor || !defaultAlpha || !defaultBlendMode) {
							material += WireMaterial(surface.material).thickness;
							if (!defaultColor || !defaultAlpha || !defaultBlendMode) {
								material += ", " + colorToString(WireMaterial(surface.material).color);
								if (!defaultAlpha || !defaultBlendMode) {
									material += ", " + surface.material.alpha ;
									if (!defaultBlendMode) {
										importSet["flash.display.BlendMode"] = true;
										material += ", " + blendModeToString(surface.material.blendMode);
									}
								}
							}
						}
					}
					var defaultWireThickness:Boolean;
					var defaultWireColor:Boolean;
					if (surface.material is FillMaterial) {
						importSet["alternativa.engine3d.materials.FillMaterial"] = true;
						defaultWireThickness = FillMaterial(surface.material).wireThickness < 0;
						defaultWireColor = FillMaterial(surface.material).wireColor == 0;
						material = "new FillMaterial(" + colorToString(FillMaterial(surface.material).color);
						if (!defaultAlpha || !defaultBlendMode || !defaultWireThickness || !defaultWireColor) {
							material += ", " + surface.material.alpha;
							if (!defaultBlendMode || !defaultWireThickness || !defaultWireColor) {
								importSet["flash.display.BlendMode"] = true;
								material += ", " + blendModeToString(surface.material.blendMode);
								if (!defaultWireThickness || !defaultWireColor) {
									material += ", " + FillMaterial(surface.material).wireThickness;
									if (!defaultWireColor) {
										material += ", " + colorToString(FillMaterial(surface.material).wireColor);
									}
								}
							}
						}
					}
					if (surface.material is TextureMaterial) {
						importSet["alternativa.engine3d.materials.TextureMaterial"] = true;
						var defaultRepeat:Boolean = TextureMaterial(surface.material).repeat;
						var defaultSmooth:Boolean = !TextureMaterial(surface.material).smooth;
						defaultWireThickness = TextureMaterial(surface.material).wireThickness < 0;
						defaultWireColor = TextureMaterial(surface.material).wireColor == 0;
						var defaultPrecision:Boolean = TextureMaterial(surface.material).precision == TextureMaterialPrecision.MEDIUM;
						
						if (TextureMaterial(surface.material).texture == null) {
							materialName = "null";
						} else {
							importSet["alternativa.types.Texture"] = true;
							if (materialSet[TextureMaterial(surface.material).texture] == undefined) {
								materialName = (TextureMaterial(surface.material).texture._name != null) ? TextureMaterial(surface.material).texture._name : "texture" + materialNum++;
								materialSet[TextureMaterial(surface.material).texture] = materialName; 
							} else {
								materialName = materialSet[TextureMaterial(surface.material).texture];
							}
							materialName = materialName.split(".")[0];
						}
						material = "new TextureMaterial(" + materialName;
						if (!defaultAlpha || !defaultRepeat || !defaultSmooth || !defaultBlendMode || !defaultWireThickness || !defaultWireColor || !defaultPrecision) {
							material += ", " + TextureMaterial(surface.material).alpha;
							if (!defaultRepeat || !defaultSmooth || !defaultBlendMode || !defaultWireThickness || !defaultWireColor || !defaultPrecision) {
								material += ", " + TextureMaterial(surface.material).repeat;
								if (!defaultSmooth || !defaultBlendMode || !defaultWireThickness || !defaultWireColor || !defaultPrecision) {
									material += ", " + TextureMaterial(surface.material).smooth;
									if (!defaultBlendMode || !defaultWireThickness || !defaultWireColor || !defaultPrecision) {
										importSet["flash.display.BlendMode"] = true;
										material += ", " + blendModeToString(surface.material.blendMode);
										if (!defaultWireThickness || !defaultWireColor || !defaultPrecision) {
											material += ", " + TextureMaterial(surface.material).wireThickness;
											if (!defaultWireColor || !defaultPrecision) {
												material += ", " + colorToString(TextureMaterial(surface.material).wireColor);
												if (!defaultPrecision) {
													material += ", " + TextureMaterial(surface.material).precision;
												}
											}
										}
									}
								}
							}
						}
					}
					
					constructor += "\t\t\tsetMaterialToSurface(" + material + "), " + idToString(id) + ");\r";
				}
			}
			
			var imports:String = "";
			newLine = false;
			
			var importArray:Array = new Array();
			for (key in importSet) {
				importArray.push(key);
			}
			importArray.sort();
			
			length = importArray.length;
			for (i = 0; i < length; i++) {
				var pack:String = importArray[i];
				var current:String = pack.substr(0, pack.indexOf("."));
				imports += (current != prev && prev != null) ? "\r" : "";
				imports += "\timport " + pack + ";\r";
				var prev:String = current;
				newLine = true;
			}
			imports += newLine ? "\r" : "";
			
			var embeds:String = "";
			newLine = false;
			for each (materialName in materialSet) {
				var materialClassName:String = materialName.split(".")[0];
				var materialBmpName:String = materialClassName.charAt(0).toUpperCase() + materialClassName.substr(1);
				embeds += "\t\t[Embed(source=\"" + materialName + "\")] private static const bmp" + materialBmpName + ":Class;\r";
				embeds += "\t\tprivate static const " + materialClassName + ":Texture = new Texture(new bmp" + materialBmpName + "().bitmapData, \"" + materialName + "\");\r";
				newLine = true;
			}
			embeds += newLine ? "\r" : "";

			return header + imports + classHeader + embeds + constructor + footer;
		}

	}
}
