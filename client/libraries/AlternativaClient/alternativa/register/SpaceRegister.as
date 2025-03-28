package alternativa.register {
	import alternativa.service.ISpaceService;
	import alternativa.types.Long;
	
	import flash.utils.Dictionary;
	
	
	/**
	 * Реестр открытых спэйсов 
	 */	
	public class SpaceRegister implements ISpaceService {
		
		/**
		 * Список спэйсов
		 */		
		private var _spaceList:Array;
		/**
		 * Спэйсы по id 
		 */		
		private var _spaces:Dictionary;
		
		
		public function SpaceRegister()	{
			_spaceList = new Array();
			_spaces = new Dictionary();
		}
		
		public function addSpace(space:SpaceInfo):void {
			_spaceList.push(space);
		}
		public function removeSpace(space:SpaceInfo):void {
			_spaceList.splice(_spaceList.indexOf(space), 1);
		}
		
		public function get spaceList():Array {
			return _spaceList;
		}
		public function get spaces():Dictionary {
			return _spaces;
		}
		
		public function setIdForSpace(space:SpaceInfo, id:Long):void {
			space.id = id;
			_spaces[id] = space;
		}

	}
}