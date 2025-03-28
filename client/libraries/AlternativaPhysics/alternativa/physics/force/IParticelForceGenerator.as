package alternativa.physics.force {
	import alternativa.physics.particle.Particle;
	
	public interface IParticelForceGenerator {
		function updateForce(particle:Particle, time:Number):void;
	}
}