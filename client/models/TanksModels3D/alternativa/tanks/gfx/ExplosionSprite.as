package alternativa.tanks.gfx {
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Sprite3D;
	import alternativa.engine3d.materials.SpriteTextureMaterial;
	import alternativa.types.Point3D;
	import alternativa.types.Texture;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	/**
	 * Спецэффект взрыва снаряда.
	 */
	public class ExplosionSprite extends Object3D {
		[Embed (source="fire.png")]
		private static var fireBmpClass:Class;
		private var fireBmp:BitmapData = new fireBmpClass().bitmapData;

		[Embed (source="smoke.png")]
		private static var smokeBmpClass:Class;
		private var smokeBmp:BitmapData = new smokeBmpClass().bitmapData;

		private var intervarlId:int;
		private var flag:int;
		
		private var fireSprite:Sprite3D;
		private var smokeSprite:Sprite3D;
		
		private var animationInterval:uint = uint(1000/30);
		
		private var fireScaleSpeed:Number = 7;
		private var fireAlphaSpeed:Number = 3;
		private var smokeScaleSpeed:Number = 7;
		private var smokeAlphaSpeed:Number = 3;
		
		public function ExplosionSprite(toCamera:Point3D) {
			super(name);
			fireSprite = new Sprite3D();
			fireSprite.material = new SpriteTextureMaterial(new Texture(fireBmp), 1, false, BlendMode.ADD);
			fireSprite.scaleX = 0.5;
			fireSprite.scaleY = 0.5;
			fireSprite.scaleZ = 0.5;

			smokeSprite = new Sprite3D();
			smokeSprite.material = new SpriteTextureMaterial(new Texture(smokeBmp), 1, false, BlendMode.NORMAL);
			smokeSprite.scaleX = 0.05;
			smokeSprite.scaleY = 0.05;
			smokeSprite.scaleZ = 0.05;
			
			addChild(fireSprite);
			addChild(smokeSprite);

			toCamera.multiply(0.2);
			fireSprite.coords = toCamera;
		}
		
		public function startAnimation():void {
			intervarlId = setInterval(animate, animationInterval);
		}
		
		private function animate():void {
			if (flag == 2) {
				clearInterval(intervarlId);
				scene.root.removeChild(this);
				return;
			}
			var time:Number = animationInterval*0.001;
			if (fireSprite.material.alpha > 0) {
				addSpriteScale(fireSprite, fireScaleSpeed*time);
				if (fireSprite.scaleX >= 1) {
					fireSprite.material.alpha -= fireAlphaSpeed*time;
				}
				if (fireSprite.material.alpha <= 0) {
					flag += 1;
				}
			}
			if (smokeSprite.material.alpha > 0) {
				addSpriteScale(smokeSprite, smokeScaleSpeed*time);
				if (smokeSprite.scaleX >= 0.5) {
					smokeSprite.material.alpha -= smokeAlphaSpeed*time;
				}
				if (smokeSprite.material.alpha <= 0) {
					flag += 1;
				}
			}
		}
		
		private function addSpriteScale(sprite:Sprite3D, scale:Number):void {
			sprite.scaleX += scale;
			sprite.scaleY += scale;
			sprite.scaleZ += scale;
		}
		
	}
}