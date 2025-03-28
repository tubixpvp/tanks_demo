package alternativa.model.general.world3d {
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.init.Main;
	import alternativa.resource.TextureResource;
	
	import flash.geom.Point;

	import platform.models.general.world3d.a3d.A3D;
	import platform.models.general.world3d.a3d.engine3d.materials.A3DFillMaterial;
	import platform.models.general.world3d.a3d.engine3d.materials.A3DTextureMaterial;
	import platform.models.general.world3d.a3d.engine3d.core.A3DMesh;
	import platform.models.general.world3d.a3d.A3DVector3D;
	import platform.models.general.world3d.a3d.engine3d.core.A3DFace;
	import platform.models.general.world3d.a3d.A3DVector2D;
	import platform.models.general.world3d.a3d.engine3d.core.A3DSurface;
	import platform.models.general.world3d.a3d.engine3d.materials.A3DMaterialType;
	import platform.models.general.world3d.a3d.engine3d.core.A3DObject3D;
	
	public class A3DParser {
		
		private var data:A3D;
		private var fillMaterials:Array;
		private var textureMaterials:Array;
		
		public function A3DParser(data:A3D) {
			this.data = data;
		}
		
		/**
		 * Метод преобразует серверную 3д-модель в клиентский вариант.
		 * 
		 * @param data модель в серверном формате
		 * @return контейнер, содержащий модель в клиентском формате
		 */
		public function parse():Object3D {
			var i:int;
			var len:int;
			// Разбираем заливочные материалы
			len = data.fillMaterials.length;
			fillMaterials = new Array(len);
			for (i = 0; i < len; i++) {
				var a3dFillMaterial:A3DFillMaterial = data.fillMaterials[i];
				var fillMaterial:FillMaterial = new FillMaterial(0);
				fillMaterial.color = a3dFillMaterial.color;
				fillMaterial.alpha = a3dFillMaterial.alpha;
				fillMaterials[i] = fillMaterial;
			}
			// Разбираем текстурные материалы
			len = data.textureMaterials.length;
			textureMaterials = new Array(len);
			for (i = 0; i < len; i++) {
				var a3dTextureMaterial:A3DTextureMaterial = data.textureMaterials[i];
				var textureMaterial:TextureMaterial = new TextureMaterial(null);
				textureMaterials[i] = textureMaterial;
				var textureResource:TextureResource = Main.resourceRegister.getResource(a3dTextureMaterial.texture.id) as TextureResource;
				textureMaterial.texture = textureResource.data;
				textureMaterial.alpha = a3dTextureMaterial.alpha;
			}
			// Конвертируем дерево серверных объектов в дерево клиентских
			return parseObject3D(data.rootObject);
		}
		
		/**
		 * Рекурсивно разбирает объект в формате A3D.
		 * 
		 * @param a3dObject
		 * @param fillMaterials
		 * @param textureMaterials
		 * @return объект в формате 3д-движка
		 */
		private function parseMesh(a3dMesh:A3DMesh):Object3D {
			var mesh:Mesh = new Mesh(a3dMesh.name);

			mesh.x = a3dMesh.coords.x;
			mesh.y = a3dMesh.coords.y;
			mesh.z = a3dMesh.coords.z;
			
			mesh.rotationX = a3dMesh.rotation.x;
			mesh.rotationY = a3dMesh.rotation.y;
			mesh.rotationZ = a3dMesh.rotation.z;
			
			mesh.scaleX = a3dMesh.scale.x;
			mesh.scaleY = a3dMesh.scale.y;
			mesh.scaleZ = a3dMesh.scale.z;
			
			mesh.mobility = a3dMesh.mobility;
			
			var i:int;
			var len:int;

			// Разбор вершин
			len = a3dMesh.vertices.length;
			for (i = 0; i < len; i++) {
				var vector3d:A3DVector3D = a3dMesh.vertices[i];
				mesh.createVertex(vector3d.x, vector3d.y, vector3d.z, i);
			}

			// Разбор граней
			len = a3dMesh.faces.length;
			for (i = 0; i < len; i++) {
				var a3dFace:A3DFace = a3dMesh.faces[i];
				var face:Face = mesh.createFace(a3dFace.vertices, i);
				
				var vector2d:A3DVector2D;
				vector2d = a3dFace.aUV;
				if (vector2d != null) {
					face.aUV = new Point(vector2d.x, vector2d.y);
					vector2d = a3dFace.bUV;
					face.bUV = new Point(vector2d.x, vector2d.y);
					vector2d = a3dFace.cUV;
					face.cUV = new Point(vector2d.x, vector2d.y);
				}
			}

			// Разбор поверхностей
			len = a3dMesh.surfaces.length;
			for (i = 0; i < len; i++) {
				var a3dSurface:A3DSurface = a3dMesh.surfaces[i];
				var surface:Surface = mesh.createSurface(a3dSurface.faces, i);
				switch (a3dSurface.materialType) {
					case A3DMaterialType.FILL:
						surface.material = (fillMaterials[a3dSurface.materialIndex] as FillMaterial).clone() as FillMaterial;
						break;
					case A3DMaterialType.TEXTURE:
						surface.material = (textureMaterials[a3dSurface.materialIndex] as TextureMaterial).clone() as TextureMaterial;
						break;
				}
			}
			
			var childObjects:Array;
			// Разбор дочерних объектов
			childObjects = a3dMesh.childMeshes;
			len = childObjects.length;
			for (i = 0; i < len; i++) {
				mesh.addChild(parseMesh(childObjects[i]));
			}

			// Разбор дочерних объектов
			childObjects = a3dMesh.childObjects;
			len = childObjects.length;
			for (i = 0; i < len; i++) {
				mesh.addChild(parseObject3D(childObjects[i]));
			}
			
			return mesh;
		}

		/**
		 * Рекурсивно разбирает объект в формате A3D.
		 * 
		 * @param a3dObject
		 * @param fillMaterials
		 * @param textureMaterials
		 * @return объект в формате 3д-движка
		 */
		private function parseObject3D(a3dObject:A3DObject3D):Object3D {
			var object:Object3D = new Object3D(a3dObject.name);

			object.x = a3dObject.coords.x;
			object.y = a3dObject.coords.y;
			object.z = a3dObject.coords.z;
			
			object.rotationX = a3dObject.rotation.x;
			object.rotationY = a3dObject.rotation.y;
			object.rotationZ = a3dObject.rotation.z;
			
			object.scaleX = a3dObject.scale.x;
			object.scaleY = a3dObject.scale.y;
			object.scaleZ = a3dObject.scale.z;
			
			object.mobility = a3dObject.mobility;
			
			var i:int;
			var len:int;
			
			var childObjects:Array;
			// Разбор дочерних объектов
			childObjects = a3dObject.childMeshes;
			len = childObjects.length;
			for (i = 0; i < len; i++) {
				object.addChild(parseMesh(childObjects[i]));
			}

			// Разбор дочерних объектов
			childObjects = a3dObject.childObjects;
			len = childObjects.length;
			for (i = 0; i < len; i++) {
				object.addChild(parseObject3D(childObjects[i]));
			}
			
			return object;
		}

	}
}