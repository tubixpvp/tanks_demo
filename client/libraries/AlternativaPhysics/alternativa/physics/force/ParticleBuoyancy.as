package alternativa.physics.force {
	import alternativa.physics.particle.Particle;
	import alternativa.types.Point3D;

	public class ParticleBuoyancy implements IParticelForceGenerator {
		
		private var force:Point3D = new Point3D();
		
		private var maxDepth:Number;
		private var waterHeight:Number;
		private var volume:Number;
		private var liquidDensity:Number;
		
		public function ParticleBuoyancy(maxDepth:Number, waterHeight:Number, volume:Number, liquidDensity:Number = 1000) {
			this.maxDepth = maxDepth;
			this.waterHeight = waterHeight;
			this.volume = volume;
			this.liquidDensity = liquidDensity;
		}

		public function updateForce(particle:Particle, time:Number):void {
			var depth:Number = particle.position.y;
			if (depth > waterHeight + maxDepth) {
				return;
			}
			
			force.x = 0;
			force.y = 0;
			if (depth <= waterHeight - maxDepth) {
				force.z = liquidDensity*volume;
			} else {
				force.z = liquidDensity*volume*(waterHeight + maxDepth - depth)/maxDepth*0.5;
			}
			particle.addForce(force);
		}
	}
}