package alternativa.model.general.parent {
	import alternativa.object.ClientObject;
	
	public interface IParent {
		
		function getChildren(clientObject:ClientObject):Array;
		
	}
}