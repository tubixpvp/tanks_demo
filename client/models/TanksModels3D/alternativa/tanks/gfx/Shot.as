package alternativa.tanks.gfx {
	
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.types.Matrix3D;
	import alternativa.types.Point3D;
	import alternativa.types.Texture;
	
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	use namespace alternativa3d;
	
	/**
	 * Спецэффект, изображающий огонь из дула в момент выстрела.
	 */
	public class Shot extends Mesh {
		
		[Embed (source="shot.png")]
		private static var shotBmpClass:Class;
		private static var texture:Texture = new Texture(new shotBmpClass().bitmapData);
		
		private var axisX:Point3D = new Point3D();
		private var axisY:Point3D = new Point3D();
		private var axisZ:Point3D = new Point3D();
		private var matrix:Matrix3D = new Matrix3D();
		
		/**
		 * 
		 * @param width
		 * @param length
		 */
		public function Shot(width:Number, length:Number) {
			super();
			
			var hw:Number = width*0.5;
			createVertex(hw, 0, 0, 0);
			createVertex(hw, length, 0, 1);
			createVertex(-hw, length, 0, 2);
			createVertex(-hw, 0, 0, 3);
			
			createFace([0, 1, 2, 3], 0);
			setUVsToFace(new Point(), new Point(1, 0), new Point(1, 1), 0);
			
			createSurface([0], 0);
			setMaterialToSurface(new TextureMaterial(texture), 0);
		}
		
		/**
		 * Ориентирует плоскость текстуры так, чтобы её локальная ось X была параллельна плоскости камеры.
		 * 
		 * @param dir направление локальной оси Y текстурной плоскости
		 * @param camera камера, для которой выполняется ориентирование текстуры
		 */
		public function align(dir:Point3D, camera:Camera3D):void {
			axisY.copy(dir);
			axisY.transformOrientation(camera.cameraMatrix);
			axisY.normalize();
			axisX.x = -axisY.y;
			axisX.y = axisY.x;
			axisX.z = 0;
			axisX.transformOrientation(camera._transformation);
			axisX.normalize();
			axisZ.cross2(axisX, dir);
			matrix.a = axisX.x;
			matrix.e = axisX.y;
			matrix.i = axisX.z;

			matrix.b = dir.x;
			matrix.f = dir.y;
			matrix.j = dir.z;

			matrix.c = axisZ.x;
			matrix.g = axisZ.y;
			matrix.k = axisZ.z;
			
			matrix.getRotations(axisX);
			
			rotationX = axisX.x;
			rotationY = axisX.y;
			rotationZ = axisX.z;
		}
		
		/**
		 * 
		 */
		public function startTimer():void {
			setTimeout(destroy, 50);
		}
		
		/**
		 * 
		 */
		private function destroy():void {
			scene.root.removeChild(this);
		}
		
	}
}