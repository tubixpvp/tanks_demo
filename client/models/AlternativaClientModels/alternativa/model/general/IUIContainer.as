package alternativa.model.general {
	import alternativa.object.ClientObject;
	
	import flash.display.DisplayObjectContainer;
	
	public interface IUIContainer {
		function getContainer(clientObject:ClientObject):DisplayObjectContainer;
	}
}