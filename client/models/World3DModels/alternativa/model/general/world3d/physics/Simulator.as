package alternativa.model.general.world3d.physics {
	import alternativa.physics.collision.CollisionDetector;
	import alternativa.physics.rigid.RigidWorld;
	import alternativa.physics.rigid.generators.BoxWithBoxContactGenerator;
	import alternativa.physics.rigid.generators.RigidBox;
	
	public class Simulator {
		
		private var world:RigidWorld;
		private var boxes:RigidBox3D;
		private var lastBox:RigidBox3D;
		private var contactGenerator:BoxWithBoxContactGenerator;
		
		public function Simulator(maxContacts:int, iterations:int, calculateIterations:Boolean) {
			world = new RigidWorld(maxContacts, iterations);
			world.calculateIterations = calculateIterations;
			
			contactGenerator = new BoxWithBoxContactGenerator(null, new CollisionDetector(), 0, 0.7);
			world.addContactGenerator(contactGenerator);
		}
		
		public function step(time:Number):void {
			world.startFrame();
			world.runPhysics(time);
			
			update3D();
		}

		public function update3D():void {
			var box:RigidBox3D = boxes;
			while (box != null) {
				box.updateObjectTransform();
				box = box.next as RigidBox3D;
			}
		}
		
		public function addRigidBox(box:RigidBox3D):void {
			var counter:int = 1;
			if (boxes == null) {
				lastBox = boxes = box;
				world.addBody(box.body);
				if (contactGenerator.getBoxes() == null) {
					contactGenerator.setBoxes(box);
				}
				while (lastBox.next != null) {
					counter++;
					lastBox = lastBox.next as RigidBox3D;
				}
			} else {
//				Main.writeToConsole("[Simulator.addRigidBox] " + box);
				lastBox = lastBox.setNext(box) as RigidBox3D;
				while (lastBox.next != null) {
					counter++;
					lastBox = lastBox.next as RigidBox3D;
				}
			}
//			Main.writeToConsole("[Simulator.addRigidBox] added boxes: " + counter);
//			Main.writeToConsole("[Simulator.addRigidBox] boxes in generator: " + contactGenerator.getBoxesCount());
		}
		
		public function removeRigidBox(box:RigidBox3D):void {
			world.removeBody(box.body);
			if (box == boxes) {
				boxes = box.next as RigidBox3D;
				box.next = null;
			} else {
				var curr:RigidBox = boxes;
				var prev:RigidBox = null;
				while (curr != box && curr != null) {
					prev = curr;
					curr = curr.next;
				}
				if (curr != null) {
					if (lastBox == box) {
						lastBox = prev as RigidBox3D;
					}
					prev.next = curr.next;
					curr.next = null;
				}
			}
		}

	}
}