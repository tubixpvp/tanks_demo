package alternativa.tanks.gui.lobby {
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Scene3D;
	import alternativa.engine3d.display.View;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.utils.MathUtils;
	
	import flash.display.BlendMode;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * Класс реализует превьюшку для моделей танков.
	 */
	public class TankPreview extends View {
		
		private var scene:Scene3D;
		private var container:Object3D;
		private var timer:Timer;
		private var model:Object3D;
		private var rotationSpeed:Number;
		private var lastTime:uint;
		
		/**
		 * Создаёт новый экземпляр просмотрщика.
		 *  
		 * @param rotationSpeed скорость вращения камеры вокруг вертикальной оси в радинах в секунду
		 * @param angle угол между осью камеры и плоскостью XY
		 */
		public function TankPreview(rotationSpeed:Number = 2, angle:Number = 0.785) {
			this.rotationSpeed = rotationSpeed;

			scene = new Scene3D();
			scene.root = new Object3D("root");
			
			container = new Object3D("cameraContainer");
			camera = new Camera3D();
			camera.viewClipping = false;
			camera.rotationX = -MathUtils.DEG90;
			camera.y = -225;
			container.addChild(camera);
			container.rotationX = -angle;
			container.rotationZ = MathUtils.DEG45;
			scene.root.addChild(container);
			
			/*var plane:Plane = new Plane(100, 100, 8, 8);
			plane.cloneMaterialToAllSurfaces(new FillMaterial(0, 0.5, BlendMode.NORMAL, 0, 0x009900));
			scene.root.addChild(plane);
			plane.mobility = -1;*/
		}

		/**
		 * Устанавливает модель для просмотра.
		 * 
		 * @param model устанавливаемая модель
		 */
		public function setModel(model:Object3D):void {
			if (this.model != null) {
				scene.root.removeChild(this.model);
			}
			this.model = model;
			scene.root.addChild(model);
			scene.calculate();
		}
		
		/**
		 * Устанавливает новый размер области вывода.
		 * 
		 * @param width ширина области вывода
		 * @param height высота области вывода
		 */
		public function resize(width:Number, height:Number):void {
			this.width = width;
			this.height = height;
			
			/*view.graphics.clear();
			view.graphics.beginFill(0, 0.2);
			view.graphics.drawRect(0, 0, width, height);*/
		}
		
		/**
		 * Запускает вращение камеры.
		 */
		public function start():void {
			timer = new Timer(50);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			lastTime = getTimer();
		}

		/**
		 * Останавливает вращение камеры.
		 */
		public function stop():void {
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer = null;
		}
		
		/**
		 * 
		 */		
		private function onTimer(e:TimerEvent):void {
			var time:uint = lastTime;
			lastTime = getTimer();
			container.rotationZ += rotationSpeed*(lastTime - time)*0.001;
			scene.calculate();
		}
	}
}