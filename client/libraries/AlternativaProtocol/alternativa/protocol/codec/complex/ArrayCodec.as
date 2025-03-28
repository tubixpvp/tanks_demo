package alternativa.protocol.codec.complex {
	
	import alternativa.protocol.codec.AbstractCodec;
	import alternativa.protocol.codec.ICodec;
	import alternativa.protocol.codec.NullMap;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	
	public class ArrayCodec extends AbstractCodec {
		
		private var targetClass:Class;
		private var elementCodec:ICodec;
		private var elementnotnull:Boolean;
		private var depth:int;
		
		public function ArrayCodec(targetClass:Class, elementCodec:ICodec, elementnotnull:Boolean, depth:int = 1) {
			this.targetClass = targetClass;
			this.elementCodec = elementCodec;
			this.elementnotnull = elementnotnull;
			this.depth = depth;
		}
		
		/**
		 * Кодировать объект
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 * @param nullmap карта null-ов на заполнение
		 */		
		override public function encode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void {
			if (!notnull) {
				nullmap.addBit(object == nullValue);
			}
			// не null
			if (object != nullValue) {
				encodeArray(dest, object as Array, nullmap, 1);
			} else {
				if (notnull) {
					throw new Error("Object is null, but notnull expected.");
				}
			}
		}
			
		/**
		 * Декодировать объект
		 * @param reader объект для чтения
		 * @param nullmap карта null-ов
		 * @return разкодированный объект
		 */		
		override public function decode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			return (!notnull && nullmap.getNextBit()) ? nullValue : decodeArray(reader, nullmap, 1);
		}
		
		/**
		 * Рекурсивное декодирование массива вложенности depth
		 * @param reader объект для чтения
		 * @param currentDepth текущий уровень вложенности
		 * @return разкодированный массив
		 */		
		private function decodeArray(reader:IDataInput, nullmap:NullMap, currentDepth:int):Array {
			var result:Array = new Array();
			
			var length:int = LengthCodec.decodeLength(reader);
			if (currentDepth == depth) {
				for (var i:int = 0; i < length; i++) {
					result.push(elementCodec.decode(reader, nullmap, elementnotnull));
				}
			} else {
				currentDepth++;
				for (i = 0; i < length; i++) {
					result.push(decodeArray(reader, nullmap, currentDepth));
				}
			}
			return result;
		}
		
		/**
		 * Рекурсивное кодирование массива вложенности depth
		 * @param dest объект для записи
		 * @param object кодируемый массив
		 * @param currentDepth текущий уровень вложенности
		 */		
		private function encodeArray(dest:IDataOutput, object:Array, nullmap:NullMap, currentDepth:int):void {
			// записываем длину
			LengthCodec.encodeLength(dest, object.length);
			
			if (currentDepth == depth) {
			 	for each (var element:Object in object) {
			  		elementCodec.encode(dest, element, nullmap, elementnotnull);
				}
			} else {
				currentDepth++;
			 	for each (var array:Array in object) {
			 		encodeArray(dest, array, nullmap, currentDepth);
			 	}
			}		 
		}
	    
	}
}