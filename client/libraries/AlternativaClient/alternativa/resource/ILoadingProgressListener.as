package alternativa.resource {
	import alternativa.types.Long;
	
	
	public interface ILoadingProgressListener {
		
		function changeStatus(processId:int, value:String):void;
		
		function changeProgress(processId:int, value:Number):void;
			
	}
	
}