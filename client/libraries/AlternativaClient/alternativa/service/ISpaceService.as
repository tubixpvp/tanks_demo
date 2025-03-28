package alternativa.service {
	import alternativa.register.SpaceInfo;
	import alternativa.types.Long;
	
	import flash.utils.Dictionary;
	
	
	public interface ISpaceService {
		
		function addSpace(space:SpaceInfo):void;
			
		function removeSpace(space:SpaceInfo):void;
		
		function get spaces():Dictionary;
		
		function get spaceList():Array;
		
		function setIdForSpace(space:SpaceInfo, id:Long):void;
		
	}
}