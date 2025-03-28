package alternativa.model.general.world3d.scene {
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Scene3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.primitives.Box;
	import alternativa.init.Main;
	import alternativa.model.IObjectLoadListener;
	import alternativa.model.general.child.IChildListener;
	import alternativa.model.general.world3d.IObject3D;
	import alternativa.model.general.world3d.IObject3DListener;
	import alternativa.model.general.world3d.IPhysicsObject;
	import alternativa.model.general.world3d.physics.RigidBox3D;
	import alternativa.model.general.world3d.physics.Simulator;
	import alternativa.object.ClientObject;
	import alternativa.protocol.codec.NullMap;
	import alternativa.protocol.factory.ICodecFactory;
	import alternativa.types.Map;
	import alternativa.types.Point3D;
	import alternativa.types.Quaternion;
	import alternativa.utils.ColorUtils;
	import alternativa.utils.FPS;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.IDataInput;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import platform.models.general.world3d.scene.Scene3DModelBase;
	import platform.models.general.world3d.scene.IScene3DModelBase;

	/**
	 * Модель поведения трёхмерной сцены.
	 */
	public class Scene3DModel extends Scene3DModelBase implements IScene3DModelBase, IObject3D, IChildListener, IObjectLoadListener {
		
		private var scenes:Map = new Map();
		private var sceneCount:int = 0;
		private var timer:Timer;
		private var lastTime:Number;
		
		private var timerDelay:uint = uint(1000/30);
		
		/**
		 * 
		 */
		public function Scene3DModel() {
			super();
			
			timer = new Timer(timerDelay);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}

		/**
		 * 
		 * @param clientObject
		 * @param codecFactory
		 * @param dataInput
		 * @param nullMap
		 */
		override public function _initObject(clientObject:ClientObject, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void {
			var scene:Scene3D = new Scene3D();
			scenes.add(scene, new Simulator(1000, 1, true));
			scene.root = new Object3D("root");
			clientObject.putParams(Scene3DModelBase, scene);
		}
		
		/**
		 * 
		 * @param child
		 * @param parent
		 */
		public function addChild(child:ClientObject, parent:ClientObject):void {
			Main.writeToConsole("[Scene3DModel::addChild] child id " + child.id);
			var childModel:IObject3D = Main.modelsRegister.getModelForObject(child, IObject3D) as IObject3D;
			var childObject:Object3D = childModel.getObject3D(child);
			Main.writeToConsole("[Scene3DModel::addChild] object3d " + childObject);
			var root:Object3D = getObject3D(parent);
			root.addChild(childObject);
			
			var listeners:Array = Main.modelsRegister.getModelsForObject(parent, IObject3DListener);
			for each (var listener:IObject3DListener in listeners) {
				listener.object3DLoaded(parent, child, childObject);
			}
			
			// Добавление объектов физического мира
			addCollisionBoxes(child, parent, root);
		}
		
		/**
		 * 
		 */
		private function addCollisionBoxes(child:ClientObject, parent:ClientObject, root:Object3D):void {
			var physicsObject:IPhysicsObject = Main.modelsRegister.getModelForObject(child, IPhysicsObject) as IPhysicsObject;
			if (physicsObject != null) {
				// Добавление боксов в симулятор
				var box:RigidBox3D = physicsObject.getRigidBox3D(child);
				var simulator:Simulator = scenes[parent.getParams(Scene3DModelBase)];
				simulator.addRigidBox(box);

//				showCollisionBoxes(box, root);
			}
		}
		
		private function removeCollisionBox(child:ClientObject, parent:ClientObject):void {
			var physicsObject:IPhysicsObject = Main.modelsRegister.getModelForObject(child, IPhysicsObject) as IPhysicsObject;
			if (physicsObject != null) {
				var box:RigidBox3D = physicsObject.getRigidBox3D(child);
				var simulator:Simulator = scenes[parent.getParams(Scene3DModelBase)];
				simulator.removeRigidBox(box);
			}
		}
		
		private function showCollisionBoxes(box:RigidBox3D, root:Object3D):void {
			var point:Point3D = new Point3D();
			var q:Quaternion = new Quaternion();
			var alpha:Number = 0.5;
			var color:uint = 0x00FF00;
			var surafceIds:Array = ["bottom", "back", "left", "front", "right", "top"];
			while (box != null) {
				// Добавление на сцену физической геометрии для дебага
				var size:Point3D = box.collisionBox.halfSize;
				var box3d:Box = new Box(size.x*2, size.y*2, size.z*2);
				box3d.mobility = 1000;
				for (var i:int = 0; i < 6; i++) {
					box3d.setMaterialToSurface(new FillMaterial(ColorUtils.multiply(color, (i + 1)/6), alpha), surafceIds[i]);
				}
				box.body.getPosition(point);
				box3d.coords = point;
				box.body.getOrientation(q);
				q.getEulerAngles(point);
				box3d.rotationX = point.x;
				box3d.rotationY = point.y;
				box3d.rotationZ = point.z;
				root.addChild(box3d);
				
				box = box.next as RigidBox3D;
			}
		}
		
		/**
		 * 
		 */
		private function forEachObject(object:Object3D, func:Function):void {
			func.call(this, object);
			for (var child:* in object.children) {
				forEachObject(child, func);
			}
		}
		
		/**
		 * 
		 */
		private function showObjectName(object:Object3D):void {
			Main.writeToConsole(object.name);
		}
		
		/**
		 * 
		 * @param child
		 * @param parent
		 */
		public function removeChild(child:ClientObject, parent:ClientObject):void {
			var childModel:IObject3D = Main.modelsRegister.getModelForObject(child, IObject3D) as IObject3D;
			var childObject:Object3D = childModel.getObject3D(child);
			Main.writeToConsole("[Scene3DModel.removeChild] " + child.id + " " + childObject);
			getObject3D(parent).removeChild(childObject);
			
			removeCollisionBox(child, parent);			
			
			var listeners:Array = Main.modelsRegister.getModelsForObject(parent, IObject3DListener);
			for each (var listener:IObject3DListener in listeners) {
				listener.object3DUnloaded(parent, child, childObject);
			}
		}

		/**
		 * 
		 * @param clientObject
		 * @return 
		 */
		public function getObject3D(clientObject:ClientObject):Object3D {
			return (clientObject.getParams(Scene3DModelBase) as Scene3D).root;
		}
		
		/**
		 * Запускает пересчёт всех сцен.
		 */
		private function onTimer(e:Event):void {
			var time:Number = lastTime;
			lastTime = getTimer();
			time = (lastTime - time)*0.001;
			if (time > 0.1) {
				time = 0.1;
			}
			// Пересчёт сцен
			for (var key:* in scenes) {
				var simulator:Simulator = scenes[key];
				simulator.step(time);
				var scene:Scene3D = key;
				scene.calculate();
			}
		}
		
		/**
		 * 
		 * @param object
		 * @return 
		 */
		public function getChildren(object:ClientObject):Array {
			return getObject3D(object).children.toArray();
		}
	
		/**
		 * 
		 */
		public function objectLoaded(object:ClientObject):void {
			sceneCount++;
			if (sceneCount == 1) {
				timer.start();
				lastTime = getTimer();
			}
		}
			
		/**
		 * 
		 */
		public function objectUnloaded(clientObject:ClientObject):void {
			Main.writeVarsToConsole("[Scene3DModel::objectUnload] %1", clientObject.id);
			scenes.remove(clientObject);
			sceneCount--;
			if (sceneCount == 0) {
				timer.stop();
			}
		}
		
	}
}