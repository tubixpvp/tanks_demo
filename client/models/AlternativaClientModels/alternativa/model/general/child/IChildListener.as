package alternativa.model.general.child {
	import alternativa.object.ClientObject;
	
	public interface IChildListener {
		function addChild(child:ClientObject, parent:ClientObject):void;
		function removeChild(child:ClientObject, parent:ClientObject):void;
	}
}