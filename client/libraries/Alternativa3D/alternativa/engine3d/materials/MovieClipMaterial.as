package alternativa.engine3d.materials {

	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Surface;
	import alternativa.engine3d.events.MouseEvent3D;
	import alternativa.types.Texture;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	use namespace alternativa3d;

	/**
	 * Материал, позволяющий использовать мувиклип в качестве интерактивной текстуры.
	 * <p>
	 * При использовании материала следует учитывать тот факт, что для перерисовки текстуры мувиклипу назначается обработчик события
	 * ENTER_FRAME. Если ссылка на материал будет потеряна, обработчик всё равно будет выполняться. Поэтому при окончании работы с
	 * материалом следует установить свойству <code>movieClip</code> значение <code>null</code> для отключения обработчика.
	 * </p>
	 */
	public class MovieClipMaterial extends TextureMaterial {
		
		private var _movieClip:MovieClip;
		private var texWidth:uint;
		private var texHeight:uint;
		private var _fillRect:Rectangle;
		private var _clipRect:Rectangle;
		private var _matrix:Matrix;
		private var _refreshRate:int;
		private var _refreshCounter:int;
		/**
		 * Цвет, которым заливается текстура материала перед отрисовкой мувиклипа.
		 */
		public var fillColor:uint;

		/**
		 * Создаёт новый экземпляр материала.
		 * 
		 * @param movieClip мувиклип, используемый в качестве текстуры
		 * @param textureWidth ширина текстуры материала
		 * @param textureHeight высота текстуры материала
		 * @param clipRect область мувиклипа, отрисовываемая в текстуру материала. Если передано значение <code>null</code>, будет отрисовываться вся область мувиклипа.
		 * @param matrix матрица трансформации мувиклипа при отрисовке. Если передано значение <code>null</code>, трансформация выполняться не будет.
		 * @param smooth сглаживание текстуры при увеличении масштаба
		 * @param precision точность перспективной коррекции. Может быть задана одной из констант класса
		 *   <code>TextureMaterialPrecision</code> или числом типа Number. Во втором случае, чем ближе заданное значение к единице, тем более
		 *   качественная перспективная коррекция будет выполнена, и тем больше времени будет затрачено на расчёт кадра.
		 * @param fillColor цвет, которым заливается текстура материала перед отрисовкой мувиклипа
		 * @param refreshRate частота обновления текстуры материала. Единица означает перерисовку каждый кадр, двойка &mdash; каждые два кадра и так далее
		 * 
		 * @see TextureMaterialPrecision
		 */
		public function MovieClipMaterial(movieClip:MovieClip, textureWidth:uint, textureHeight:uint, clipRect:Rectangle = null, matrix:Matrix = null, smooth:Boolean = false, precision:Number = 10, fillColor:uint = 0, refreshRate:int = 1) {
			texWidth = textureWidth;
			texHeight = textureHeight;
			_fillRect = new Rectangle(0, 0, texWidth, texHeight);
			if (clipRect != null) {
				_clipRect = clipRect.clone();
			}
			if (matrix != null) {
				_matrix = matrix.clone();
			}
			_texture = new Texture(new BitmapData(texWidth, texHeight));
			this.refreshRate = refreshRate;
			this.movieClip = movieClip;
			this.fillColor = fillColor;
			
			super(_texture, 1, false, smooth, BlendMode.NORMAL, -1, 0, precision);
		}

		/**
		 * Мувиклип, используемый в качестве текстуры.
		 * <p>
		 * При установке свойства указанному мувиклипу назначается обработчик события ENTER_FRAME. Во избежании утечки памяти, при прекращении работы с материалом
		 * следует устанавливать данному свойству значение <code>null</code> для отключения обработчика.
		 * </p>
		 */
		public function get movieClip():MovieClip {
			return _movieClip;
		}
		
		/**
		 * @private
		 */
		public function set movieClip(value:MovieClip):void {
			if (value != _movieClip) {
				if (_movieClip != null) {
					_movieClip.removeEventListener(Event.ENTER_FRAME, redraw);
				}
				_movieClip = value;
				if (_movieClip != null) {
					_movieClip.addEventListener(Event.ENTER_FRAME, redraw);
				} else {
					_texture.bitmapData.fillRect(_fillRect, fillColor);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function redraw(e:Event):void {
			if (_movieClip != null) {
				_refreshCounter++;
				if (_refreshCounter == _refreshRate) {
					_refreshCounter = 0;
					_texture.bitmapData.fillRect(_fillRect, fillColor);
					_texture.bitmapData.draw(_movieClip, _matrix, null, BlendMode.NORMAL, _clipRect, _smooth);
				}
			}
		}
		
		/**
		 * @private
		 */
		override alternativa3d function addToSurface(surface:Surface):void {
			super.addToSurface(surface);
			// Устанавливаем обработчики мышиных событий, которые будут обеспечивать корректное позиционирование мувиклипа
			surface.addEventListener(MouseEvent3D.MOUSE_MOVE, onSurfaceMouseMove);
			surface.addEventListener(MouseEvent3D.MOUSE_OVER, onSurfaceMouseOverOut);
			surface.addEventListener(MouseEvent3D.MOUSE_OUT, onSurfaceMouseOverOut);
		}

		/**
		 * @private
		 */
		override alternativa3d function removeFromSurface(surface:Surface):void {
			super.removeFromSurface(surface);
			// Удаляем обработчики мышиных событий
			surface.removeEventListener(MouseEvent3D.MOUSE_MOVE, onSurfaceMouseMove);
			surface.removeEventListener(MouseEvent3D.MOUSE_OVER, onSurfaceMouseOverOut);
			surface.removeEventListener(MouseEvent3D.MOUSE_OUT, onSurfaceMouseOverOut);
		}
		
		/**
		 * @private
		 */
		private function onSurfaceMouseMove(e:MouseEvent3D):void {
			if (_movieClip != null) {
				// При перемещении мыши над гранью позиционируем мувиклип так, чтобы совместить точку грани под курсором мыши с соотвествующей точкой на мувиклипе
				_movieClip.x = e.view.mouseX - texWidth*e.u;
				_movieClip.y = e.view.mouseY - texHeight*(1 - e.v);
			}
		}
		
		/**
		 * @private
		 */
		private function onSurfaceMouseOverOut(e:MouseEvent3D):void {
			if (_movieClip != null) {
				// Удаляем мувиклип с вьюпорта при уходе мыши с грани и добавляем при наведении мыши на грань.
				// Это нужно, чтобы вьюпорт получал событие MOUSE_MOVE при перемещении мыши над мувиклипом.
				if (e.type == MouseEvent3D.MOUSE_OVER) {
					e.view.addChild(_movieClip);
					_movieClip.alpha = 0;
				} else {
					if (_movieClip.parent == e.view) {
						e.view.removeChild(_movieClip);
					}
				}
			}
		}
		
		/**
		 * @private
		 */
		override public function set texture(value:Texture):void {
		}
		
		/**
		 * Частота обновления текстуры материала. Единица означает перерисовку каждый кадр, двойка &mdash; каждые два кадра и так далее.
		 */
		public function get refreshRate():int {
			return _refreshRate;
		}

		/**
		 * @private 
		 */
		public function set refreshRate(value:int):void {
			_refreshRate = value > 0 ? value : 1;
		}
		
		/**
		 * Область мувиклипа, отрисовываемая в текстуру материала. При установленном значении <code>null</code> будет отрисовываться вся область мувиклипа.
		 */
		public function get clipRect():Rectangle {
			return _clipRect == null ? null : _clipRect.clone();
		}
		
		/**
		 * @private
		 */
		public function set clipRect(value:Rectangle):void {
			_clipRect = value;
		}
		
		/**
		 * Матрица трансформации мувиклипа при отрисовке. При установленном значении <code>null</code> трансформация выполняться не будет.
		 */		
		public function get matrix():Matrix {
			return _matrix == null ? null : _matrix.clone();
		}
		
		/**
		 * @private
		 */
		public function set matrix(value:Matrix):void {
			_matrix = value;
		}
		
		/**
		 * Выполняет клонирование материала.
		 * 
		 * @return копия материала
		 */
		override public function clone():Material {
			return new MovieClipMaterial(_movieClip, texWidth, texHeight, _clipRect, _matrix, _smooth, _precision, fillColor, _refreshRate);
		}

	}
}
