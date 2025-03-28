package alternativa.protocol.codec {
	import alternativa.protocol.codec.primitive.BooleanCodec;
	import alternativa.protocol.factory.ICodecFactory;
	import alternativa.protocol.type.Short;
	import alternativa.resource.ResourceInfo;
	import alternativa.types.Long;
	
	import flash.utils.IDataInput;
	
	
	public class ResourceCodec extends AbstractCodec {
		
		private var codecFactory:ICodecFactory;
		
		public function ResourceCodec(codecFactory:ICodecFactory) {
			super();
			this.codecFactory = codecFactory;
		}
		
		/**
		 * Реализация декодирования объекта
		 * @param reader объект для чтения
		 * @return разкодированный объект
		 */		
		override protected function doDecode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			var id:Long = Long(codecFactory.getCodec(Long).decode(reader, nullmap, true));
			
			var version:Long = Long(codecFactory.getCodec(Long).decode(reader, nullmap, true));
			
			var type:int = int(codecFactory.getCodec(Short).decode(reader, nullmap, true));
			
			var isOptional:Boolean = Boolean(codecFactory.getCodec(Boolean).decode(reader, nullmap, true));
			
			/*Main.writeToConsole("ResourceCodec decode", 0xff0000);
			Main.writeToConsole("	        id: " + id, 0x666666);
			Main.writeToConsole("	   version: " + version, 0x666666);
			Main.writeToConsole("	      type: " + type, 0x666666);
			Main.writeToConsole("	isOptional: " + isOptional, 0x666666);*/
						
			return new ResourceInfo(id, version, type, isOptional);
		}

	}
}