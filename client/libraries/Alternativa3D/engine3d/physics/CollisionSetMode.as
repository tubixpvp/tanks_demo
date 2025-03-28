package alternativa.engine3d.physics {

	/**
	 * Константы, определяющие режим учёта объектов сцены, заданных в множестве <code>EllipsoidCollider.collisionSet</code>
	 * при определении столкновений.
	 * 
	 * @see EllipsoidCollider#collisionSet
	 */
	public class CollisionSetMode	{
		/**
		 * Грани объектов игнорируются при определении столкновений.
		 */		
		static public const EXCLUDE:int = 1;
		/**
		 * Учитываются только столкновения с гранями, принадлежащим перечисленным в множестве объектам.
		 */		
		static public const INCLUDE:int = 2;

	}
}
