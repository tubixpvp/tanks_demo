package alternativa.protocol.factory {
	import alternativa.protocol.codec.ICodec;
	import alternativa.protocol.codec.complex.ArrayCodec;
	import alternativa.protocol.codec.complex.StringCodec;
	import alternativa.protocol.codec.primitive.BooleanCodec;
	import alternativa.protocol.codec.primitive.ByteCodec;
	import alternativa.protocol.codec.primitive.DoubleCodec;
	import alternativa.protocol.codec.primitive.FloatCodec;
	import alternativa.protocol.codec.primitive.IntegerCodec;
	import alternativa.protocol.codec.primitive.LongCodec;
	import alternativa.protocol.codec.primitive.ShortCodec;
	import alternativa.protocol.type.Byte;
	import alternativa.protocol.type.Float;
	import alternativa.protocol.type.Short;
	import alternativa.types.Long;
	
	import flash.utils.Dictionary;
	
	
	public class CodecFactory implements ICodecFactory {
		
		private var codecs:Dictionary;
		private var notnullArrayCodecs:Dictionary;
		private var nullArrayCodecs:Dictionary;
		
		public function CodecFactory() {
			codecs = new Dictionary();
			notnullArrayCodecs = new Dictionary();
			nullArrayCodecs = new Dictionary();
			
			registerCodec(int, new IntegerCodec());
			registerCodec(Short, new ShortCodec());
			registerCodec(Byte, new ByteCodec());
			
			registerCodec(Number, new DoubleCodec());
			registerCodec(Float, new FloatCodec());
			
			registerCodec(Boolean, new BooleanCodec());
			registerCodec(Long, new LongCodec());
			registerCodec(String, new StringCodec());
		}
		
		/**
		 * Регистрация кодека
		 * @param targetClass класс
		 * @param codec кодек
		 */
		public function registerCodec(targetClass:Class, codec:ICodec):void {
			codecs[targetClass] = codec;
		}
		
		/**
	     * Получить кодек для класса
	     * @param targetClass класс
	     * @return кодек
	     */
	    public function getCodec(targetClass:Class):ICodec {
	    	return codecs[targetClass];
	    }
	    
	   	/**
	     * Получить кодек для массива
	     * @param targetClass класс элемента
	     * @param depth уровень вложенности 
	     * @return кодекs
	     */		
	    public function getArrayCodec(targetClass:Class, elementnotnull:Boolean = true, depth:int = 1):ICodec {
	    	var codec:ArrayCodec;
	    	var dict:Dictionary;
	    	if (elementnotnull) {
	    		dict = notnullArrayCodecs;
	    	} else {
	    		dict = nullArrayCodecs;
	    	}
	    	if (dict[targetClass] == null) {
	    		dict[targetClass] = new Dictionary(false);
	    	}
	    	if (dict[targetClass][depth] == null) {
	    		codec = new ArrayCodec(targetClass, getCodec(targetClass), elementnotnull, depth);
				dict[targetClass][depth] = codec;
		 	} else {
		  		codec = dict[targetClass][depth];
		   	}
	    	return codec;
	    }

	}
}