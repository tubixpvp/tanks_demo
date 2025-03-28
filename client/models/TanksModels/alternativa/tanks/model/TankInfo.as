package alternativa.tanks.model {
	import alternativa.engine3d.core.Object3D;
	import alternativa.object.ClientObject;
	import alternativa.types.Point3D;
	
	
	public class TankInfo {
		
		public var clientObject:ClientObject; 
		public var object3D:Object3D; 
		public var coords:Point3D; 
		public var dist:Number; 
		public var angle:Number; 
		public var health:int; 
		public var scores:int; 
		
		public function TankInfo(clientObject:ClientObject, object3D:Object3D, coords:Point3D, dist:Number, angle:Number, health:int, scores:int) {
			this.clientObject = clientObject;
			this.object3D = object3D;
			this.coords = coords;
			this.dist = dist;
			this.angle = angle;
			this.health = health;
			this.scores = scores;
		}

	}
}