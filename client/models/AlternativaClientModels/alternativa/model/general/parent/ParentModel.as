package alternativa.model.general.parent {
	import alternativa.model.general.child.IChildListener;
	import alternativa.object.ClientObject;
	import alternativa.protocol.codec.NullMap;
	import alternativa.protocol.factory.ICodecFactory;
	import alternativa.types.Set;
	
	import flash.utils.IDataInput;
	import platform.models.core.parent.ParentModelBase;
	import platform.models.core.parent.IParentModelBase;

	public class ParentModel extends ParentModelBase implements IParentModelBase, IChildListener, IParent {

		private var children:Set = new Set();
		
		public function ParentModel() {
			super();
		}
		
		override public function _initObject(clientObject:ClientObject, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void {
			clientObject.putParams(ParentModelBase, new Set());
		}
		
		public function addChild(child:ClientObject, parent:ClientObject):void {
			var children:Set = parent.getParams(ParentModelBase) as Set;
			children.add(child);
		}
		
		public function removeChild(child:ClientObject, parent:ClientObject):void {
			var children:Set = parent.getParams(ParentModelBase) as Set;
			children.remove(child);
		}
		
		public function getChildren(clientObject:ClientObject):Array {
			return children.toArray();
		}
		
	}
}