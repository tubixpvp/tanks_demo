package alternativa.tanks.sfx {
	import alternativa.types.Point3D;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	/**
	 * Класс для представления звуков.
	 */
	public class Sound3D {

		private var nearRadius:Number;
		private var farRadius:Number;
		private var maxVolume:Number;
		private var farDelimiter:Number;
		
		private var sound:Sound;
		private var channel:SoundChannel;
		private var transform:SoundTransform = new SoundTransform(0);
		private var intervalId:int;
		
		public var fadeCoefficient:Number = 1;
		
		/**
		 * Создаёт новый экземпляр класса.
		 * 
		 * @param near ближний радиус слышимости. В пределах сферы с таким радиусом звук имеет полную громкость.
		 * @param far дальний радиус слышимости. За пределами ближнего радиуса сила звука уменьшается обратно пропорционально квадрату расстояния
		 *   и на расстоянии дальнего радиуса уменьшается в delimiter раз.
		 * @param farDelimiter коэффициент ослабления звука. На расстоянии дальнего радиуса сила звука уменьшается в delimiter раз
		 * @param multiplier максимальная громкость звука
		 */
		public function Sound3D(sound:Sound, near:Number, far:Number, farDelimiter:Number, maxVolume:Number = 1) {
			this.sound = sound;
			this.nearRadius = near;
			this.farRadius = far;
			this.farDelimiter = Math.sqrt(farDelimiter);
			this.maxVolume = maxVolume;
		}
		
		/**
		 * Получение свойств звука в зависимости от взаимного положения источника звука и объекта.
		 * 
		 * @param objectCoords координаты объекта
		 * @param soundCoords координаты источника звука
		 * @param normal нормаль правого уха для определения баланса
		 * @param nearRadius ближний радиус слышимости. В пределах сферы с таким радиусом звук имеет полную громкость.
		 * @param farRadius дальний радиус слышимости. За пределами ближнего радиуса сила звука уменьшается обратно пропорционально квадрату расстояния
		 *   и на расстоянии дальнего радиуса уменьшается в delimiter раз. 
		 * @param delimiter коэффициент ослабления звука. На расстоянии дальнего радиуса сила звука уменьшается в delimiter раз
		 * @param soundTransform
		 */
		public function getSoundProperties(objectCoords:Point3D, soundCoords:Point3D, normal:Point3D, soundTransform:SoundTransform):void {
			var vector:Point3D = Point3D.difference(soundCoords, objectCoords);
			var len:Number = vector.length;
			if (len < nearRadius) {
				// В пределах ближнего радиуса громкость максимальная, баланс в нуле
				soundTransform.volume = 1;
				soundTransform.pan = 0;
			} else {
				var k:Number = 1 + (farDelimiter - 1) * (len - nearRadius) / (farRadius - nearRadius);
				k = 1/(k*k);
				soundTransform.volume = k;
				// Корректировка баланса левого и правого каналов в зависимости от поворота головы
				vector.normalize();
				soundTransform.pan = vector.dot(normal) * (1 - k);
			}				
		}
		
		/**
		 * Установка параметров звука на основании взаимного положения головы (камеры) и источника звука.
		 * 
		 * @param coords координаты камеры
		 * @param normal нормаль правого уха
		 */
		public function checkVolume(coords:Point3D, soundCoords:Point3D, normal:Point3D):void {
			if (channel == null) {
				return;
			}
			getSoundProperties(coords, soundCoords, normal, transform);
			var volume:Number = transform.volume*maxVolume*fadeCoefficient;
			transform.volume = volume;
			channel.soundTransform = transform;
		}
		
		/**
		 * 
		 * @param loops
		 * @param fadeIn
		 */
		public function play(loops:int):SoundChannel {
			return channel = sound.play(0, loops);
		}
		
		/**
		 * 
		 */
		public function stop():void {
			if (channel != null) {
				channel.stop();
				channel = null;
			}
		}
	}
}