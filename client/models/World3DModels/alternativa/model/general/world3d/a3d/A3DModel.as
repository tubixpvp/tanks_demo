package alternativa.model.general.world3d.a3d {
	import alternativa.engine3d.core.Object3D;
	import alternativa.init.Main;
	import alternativa.model.IObjectLoadListener;
	import alternativa.model.general.world3d.IObject3D;
	import alternativa.model.general.world3d.IObject3DListener;
	import alternativa.model.general.world3d.IPhysicsObject;
	import alternativa.model.general.world3d.physics.RigidBox3D;
	import alternativa.object.ClientObject;
	import alternativa.resource.A3DCollisionResource;
	import alternativa.resource.A3DResource;
	import alternativa.types.Point3D;
	import alternativa.types.Quaternion;
	
	import flash.utils.ByteArray;
	import alternativa.types.Long;
	import alternativa.types.LongFactory;
	
	import platform.models.general.world3d.a3d.A3DModelBase;
	import platform.models.general.world3d.a3d.IA3DModelBase;

	/**
	 * 
	 */
	public class A3DModel extends A3DModelBase implements IA3DModelBase, IObject3D, IObjectLoadListener, IPhysicsObject {

		/**
		 * 
		 */
		public function A3DModel() {
			super();
		}
		
		/**
		 * 
		 * @param clientObject
		 * @param a3dResourceId
		 * @param collisionResourceId
		 */
		public function initObject(clientObject:ClientObject, a3dResourceId:Long, collisionResourceId:Long):void {
			Main.writeToConsole("[A3DModel::initObject] a3dResourceId: " + a3dResourceId + ", collisionResourceId: " + collisionResourceId);

			var a3dResource:A3DResource = Main.resourceRegister.getResource(a3dResourceId) as A3DResource;
			var data:A3DData = new A3DData();
			data.object = a3dResource.object.clone();
			fillPhysicsData(collisionResourceId, data);	
			
			clientObject.putParams(A3DModelBase, data);
		}
		
		/**
		 * Заполняет данные для физического движка.
		 */
		private function fillPhysicsData(collisionResourceId:Long, data:A3DData):void {
			if (collisionResourceId != LongFactory.getLong(0,0)) {
				var collisionResource:A3DCollisionResource = Main.resourceRegister.getResource(collisionResourceId) as A3DCollisionResource;
				var byteArray:ByteArray = collisionResource.getData();
				data.boxes = parseRigidBoxData(byteArray);
			} else {
				// TODO: Убрать закостыленное решение для танка
				data.boxes = new RigidBox3D(60, 110, 30, 1000);
				data.boxes.setObject(data.object);
				data.boxes.setPivot(new Point3D(0, 0, -15));
				data.boxes.body.setAccelerationComponents(0, 0, -300);
			}
		}
		
		/**
		 * Создаёт список физических объектов из бинарного представления.   
		 * 
		 * @param data
		 */
		private function parseRigidBoxData(data:ByteArray):RigidBox3D {
			data.position = 0;
			var boxes:RigidBox3D;
			var last:RigidBox3D;
			var box:RigidBox3D;
			var counter:int;
			var qx:Quaternion = new Quaternion();
			var qy:Quaternion = new Quaternion();
			var qz:Quaternion = new Quaternion();
			while (data.bytesAvailable >= 36) {
				counter++;
				var x:Number = data.readFloat();
				var y:Number = data.readFloat();
				var z:Number = data.readFloat();
				var halfSizeX:Number = data.readFloat();
				var halfSizeY:Number = data.readFloat();
				var halfSizeZ:Number = data.readFloat();
				// По умолчанию создаётся бокс с бесконечной массой
				box = new RigidBox3D(2*halfSizeX, 2*halfSizeY, 2*halfSizeZ, 0);
				box.body.setPositionComponents(x, y, z);
				// Ориентация бокса
				var rotationX:Number = data.readFloat();
				var rotationY:Number = data.readFloat();
				var rotationZ:Number = data.readFloat();
				qx.setFromAxisAngleComponents(1, 0, 0, rotationX);
				qx.normalize();
				qy.setFromAxisAngleComponents(0, 1, 0, rotationY);
				qy.normalize();
				qz.setFromAxisAngleComponents(0, 0, 1, rotationZ);
				qz.normalize();
				qz.multiply(qy);
				qz.normalize();
				qz.multiply(qx);
				qz.normalize();
				box.body.setOrientation(qz);

				if (boxes == null) {
					boxes = last = box;
				} else {
					last = last.setNext(box) as RigidBox3D;
				}
			}
			Main.writeToConsole("[A3DModel.parseRigidBoxData] boxes loaded: " + counter);
			return boxes;
		}
		
		/**
		 * Рассылает оповещение моделям-слушателям загрузки 3д-объекта.
		 */
		public function objectLoaded(clientObject:ClientObject):void {
			var data:A3DData = clientObject.getParams(A3DModelBase) as A3DData;
			if (data == null)  {
				return;
			}
			var object3d:Object3D = data.object;
			var listeners:Array = Main.modelsRegister.getModelsForObject(clientObject, IObject3DListener);
			for each (var listener:IObject3DListener in listeners) {
				listener.object3DLoaded(clientObject, clientObject, object3d);
			}
		}
			
		/**
		 * Рассылает оповещение моделям-слушателям выгрузки загрузки 3д-объекта.
		 */
		public function objectUnloaded(clientObject:ClientObject):void {
			var data:A3DData = clientObject.getParams(A3DModelBase) as A3DData;
			if (data == null)  {
				return;
			}
			var object3d:Object3D = data.object;
			var listeners:Array = Main.modelsRegister.getModelsForObject(clientObject, IObject3DListener);
			for each (var listener:IObject3DListener in listeners) {
				listener.object3DUnloaded(clientObject, clientObject, object3d);
			}
		}
		
		/**
		 * Возвращает трёхмерное представление объекта.
		 */
		public function getObject3D(clientObject:ClientObject):Object3D {
			return (clientObject.getParams(A3DModelBase) as A3DData).object;
		}
		
		/**
		 * Возвращает физическое представление модели.
		 */		
		public function getRigidBox3D(clientObject:ClientObject):RigidBox3D {
			return (clientObject.getParams(A3DModelBase) as A3DData).boxes;
		}
		
	}
}