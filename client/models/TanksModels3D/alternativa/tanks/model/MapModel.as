package alternativa.tanks.model {
	import alternativa.engine3d.core.Mesh;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Sprite3D;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.materials.SpriteTextureMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.init.Main;
	import alternativa.model.general.world3d.IObject3DListener;
	import alternativa.object.ClientObject;
	
	import flash.display.BlendMode;
	import projects.tanks.models.map.MapModelBase;
	import projects.tanks.models.map.IMapModelBase;

	public class MapModel extends MapModelBase implements IMapModelBase, IObject3DListener {
		public function MapModel() {
			super();
		}
		
		public function object3DLoaded(clientObject:ClientObject, clientObject3D:ClientObject, object3d:Object3D):void {
			Main.writeToConsole("[MapModel.object3DLoaded] setting name of the map object");
			object3d.name = "map";
			object3d.forEach(replaceSprite);
		}
		
		private function replaceSprite(object:Object3D):void {
			if (object is Mesh) {
				var idx:int = object.name.indexOf("@");
				if (idx < 0) {
					return;
				}
				var originStr:String = object.name.substr(0, idx);
				var origins:Array = originStr.split("_");
				var mesh:Mesh = object as Mesh;
				var surface:Surface = mesh.surfaces.peek();
				var material:TextureMaterial = surface.material as TextureMaterial;
				var sprite:Sprite3D = new Sprite3D();
				sprite.coords = mesh.coords;
				var ox:Number = origins[0] == "" ? 0.5 : Number(origins[0]);
				var oy:Number = origins[1] == "" ? 0.5 : Number(origins[1]);
				sprite.material = new SpriteTextureMaterial(material.texture, 1, false, BlendMode.NORMAL, ox, oy);
				mesh.parent.addChild(sprite);
				mesh.parent.removeChild(mesh);
			}
		}
		
		public function object3DUnloaded(clientObject:ClientObject, clientObject3D:ClientObject, object3d:Object3D):void {
			
		}
		
	}
}