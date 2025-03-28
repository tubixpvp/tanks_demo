package alternativa.tanks.sfx {
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class TankSounds {
		
		private var idleSound3D:Sound3D;
		private var accelerationSound3D:Sound3D;
		private var moveSound3D:Sound3D;
		private var channel:SoundChannel;
		
		private var fadeIntervalId:int = -1;
		
		public var currentSound3D:Sound3D;
		
		private var _state:int = -1;
		
		public function TankSounds(idleSound:Sound, accelerationSound:Sound, moveSound:Sound) {
			var near:Number = 500;
			var far:Number = 1500;
			var delim:Number = 10;
			var volume:Number = 10;
			idleSound3D = new Sound3D(idleSound, near, far, delim, volume*10);
			accelerationSound3D = new Sound3D(accelerationSound, near, far, delim, volume);
			moveSound3D = new Sound3D(moveSound, near, far, delim, volume);
			currentSound3D = idleSound3D;
		}
		
		public function setState(state:int):void {
			if (_state == state) {
				return;
			}
			_state = state;
			switch (state) {
				case 0:
					// decelereation
					if (channel != null) {
						channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
					}
					fadeIntervalId = setInterval(fadeStep, 80);
					break;
				case 1:
					// acceleration
					stopFading();
					currentSound3D.stop();
					currentSound3D = accelerationSound3D;
					currentSound3D.fadeCoefficient = 1;
					channel = currentSound3D.play(1);
					channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
					break;
			}
		}
		
		private function soundComplete(e:Event):void {
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			currentSound3D.stop();
			currentSound3D = moveSound3D;
			currentSound3D.fadeCoefficient = accelerationSound3D.fadeCoefficient;
			currentSound3D.play(10000);
		}
		
		private function fadeStep():void {
			if (currentSound3D.fadeCoefficient > 0.5) {
				currentSound3D.fadeCoefficient -= 0.1;
			} else {
				stopFading();
			}
		}
		
		private function stopFading():void {
			if (fadeIntervalId != -1) {
				clearInterval(fadeIntervalId);
				fadeIntervalId = -1;
			}
			currentSound3D.stop();
			currentSound3D = idleSound3D;
			currentSound3D.play(10000);
		}
		
		private function stopAll():void {
			if (fadeIntervalId != -1) {
				clearInterval(fadeIntervalId);
				fadeIntervalId = -1;
			}
			currentSound3D.stop();
		}

	}
}