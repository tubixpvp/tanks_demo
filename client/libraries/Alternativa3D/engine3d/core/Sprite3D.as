package alternativa.engine3d.core {

	import alternativa.engine3d.*;
	import alternativa.engine3d.materials.SpriteMaterial;

	use namespace alternativa3d;

	/**
	 * Объект представляет собой точку в трёхмерном пространстве. Объекту может быть назначен материал для вывода различных изображений в
	 * месте его нахождения.
	 */
	public class Sprite3D extends Object3D {
		/**
		 * Счетчик имен объектов 
		 */
		private static var counter:uint = 0;

		/**
		 * @private
		 * Обновление материала.
		 */
		alternativa3d var updateMaterialOperation:Operation = new Operation("updateSpriteMaterial", this, updateMaterial, Operation.SPRITE_UPDATE_MATERIAL);
		/**
		 * @private
		 * Примитив.
		 */
		alternativa3d var primitive:SpritePrimitive;
		/**
		 * @private
		 * Материал.
		 */
		alternativa3d var _material:SpriteMaterial;
		/**
		 * @private
		 * Размер материала.
		 */
		alternativa3d var _materialScale:Number;

		/**
		 * Создание экземпляра спрайта.
		 *
		 * @param name имя спрайта
		 */
		public function Sprite3D(name:String = null) {
			super(name);
			// Создаем примитив спрайта
			primitive = new SpritePrimitive();
			primitive.sprite = this;
			// В примитиве одна точка - координата спрайта
			primitive.points = [this.globalCoords];
			primitive.num = 1;
			primitive.mobility = int.MAX_VALUE;
		}

		/**
		 * @private
		 * Расчет перемещения точки спрайта.
		 */
		override alternativa3d function calculateTransformation():void {
			super.calculateTransformation();
			// Произошло перемещение спрайта, необходимо перевставить точку в БСП
			updatePrimitive();
			if (changeRotationOrScaleOperation.queued) {
				// Считаем размер материала
				// Считается для любого материала, без отдельных операций
				var a:Number = _transformation.a;
				var b:Number = _transformation.b;
				var c:Number = _transformation.c;
				var e:Number = _transformation.e;
				var f:Number = _transformation.f;
				var g:Number = _transformation.g;
				var i:Number = _transformation.i;
				var j:Number = _transformation.j;
				var k:Number = _transformation.k;
				_materialScale = (Math.sqrt(a*a + e*e + i*i) + Math.sqrt(b*b + f*f + j*j) + Math.sqrt(c*c + g*g + k*k))/3;
			}
		}

		/**
		 * Перевставка точки спрайта в БСП дереве.
		 */
		private function updatePrimitive():void {
			// Если примитив в BSP-дереве
			if (primitive.node != null) {
				// Удаление примитива
				_scene.removeBSPPrimitive(primitive);
			}
			_scene.addPrimitives.push(primitive);
		}

		/**
		 * Перерисовка скинов спрайта.
		 */
		private function updateMaterial():void {
			if (!calculateTransformationOperation.queued) {
				_scene.changedPrimitives[primitive] = true;
			}
		}

		/**
		 * @inheritDoc
		 */
		override protected function addToScene(scene:Scene3D):void {
			super.addToScene(scene);
			// Подписываем сцену на операции
			calculateTransformationOperation.addSequel(scene.calculateBSPOperation);
			updateMaterialOperation.addSequel(scene.changePrimitivesOperation);
			// Добавляем на сцену материал
			if (_material != null) {
				_material.addToScene(scene);
			}
		}

		/**
		 * @inheritDoc
		 */
		override protected function removeFromScene(scene:Scene3D):void {
			// Удаляем все операции из очереди
			scene.removeOperation(updateMaterialOperation);

			// Если примитив в BSP-дереве
			if (primitive.node != null) {
				// Удаляем примитив из сцены
				scene.removeBSPPrimitive(primitive);
			}

			// Посылаем операцию сцены на расчёт BSP
			scene.addOperation(scene.calculateBSPOperation);

			// Отписываем сцену от операций
			calculateTransformationOperation.removeSequel(scene.calculateBSPOperation);
			updateMaterialOperation.removeSequel(scene.changePrimitivesOperation);
			// Удаляем из сцены материал
			if (_material != null) {
				_material.removeFromScene(scene);
			}
			super.removeFromScene(scene);
		}

		/**
		 * @private
		 * Изменение материала.
		 */
		alternativa3d function addMaterialChangedOperationToScene():void {
			if (_scene != null) {
				_scene.addOperation(updateMaterialOperation);
			}
		}

		/**
		 * Материал для отображения спрайта.
		 */
		public function get material():SpriteMaterial {
			return _material;
		}

		/**
		 * @private
		 */
		public function set material(value:SpriteMaterial):void {
			if (_material != value) {
				if (_material != null) {
					_material.removeFromSprite(this);
					if (_scene != null) {
						_material.removeFromScene(_scene);
					}
				}
				if (value != null) {
					if (value._sprite != null) {
						value._sprite.material = null;
					}
					value.addToSprite(this);
					if (_scene != null) {
						value.addToScene(_scene);
					}
				}
				_material = value;
				// Отправляем операцию изменения материала
				addMaterialChangedOperationToScene();
			}
		}

		/**
		 * Имя объекта по умолчанию.
		 * 
		 * @return имя объекта по умолчанию
		 */
		override protected function defaultName():String {
			return "sprite" + ++counter;
		}
		
		/**
		 * @inheritDoc
		 */		
		protected override function createEmptyObject():Object3D {
			return new Sprite3D();
		}

		/**
		 * @inheritDoc
		 */
		protected override function clonePropertiesFrom(source:Object3D):void {
			super.clonePropertiesFrom(source);
			material = (source as Sprite3D).material.clone() as SpriteMaterial;
		}

	}
}
