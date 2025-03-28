package alternativa.tanks.model {
	import alternativa.object.ClientObject;
	import alternativa.types.Point3D;
	
	public class TargetInfo {

		private static var pool:Array = new Array();
		
		public static function create(distance:Number, clientObject:ClientObject, coords:Point3D):TargetInfo {
			var info:TargetInfo = pool.pop();
			if (info == null) {
				info = new TargetInfo();
			}
			info.clientObject = clientObject;
			info.distance = distance;
			info.coords.copy(coords);
			return info;
		}
		
		public static function destroy(info:TargetInfo):void {
			info.clientObject = null;
			pool.push(info);
		}

		public var distance:Number;
		public var clientObject:ClientObject;
		public var coords:Point3D = new Point3D();

	}
}