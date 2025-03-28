package alternativa.gui.widget.list {
	import alternativa.gui.container.WidgetContainer;
	import alternativa.gui.layout.enums.Direction;
	import alternativa.gui.layout.impl.CompletelyFillLayoutManager;
	import alternativa.gui.skin.widget.list.ListItemSkin;
	import alternativa.gui.widget.Label;
	import alternativa.gui.widget.button.ButtonGroup;
	import alternativa.gui.widget.button.IButton;
	import alternativa.gui.widget.button.ITriggerButton;
	import alternativa.gui.widget.button.RadioButtonGroup;
	
	import flash.display.Shape;
	import flash.geom.Point;
	
	/**
	 * Отрисовщик элемента списка
	 */	
	public class ListRenderer extends WidgetContainer implements IListRenderer, IButton, ITriggerButton {
		
		/**
		 * Ссылка на родительский список
		 */		
		protected var _list:List;
		/**
		 * Данные отрисовываемого элемента 
		 */		
		protected var _data:Object = null;
		/**
		 * Флаг выбранности 
		 */		
		protected var _selected:Boolean = false;
		/**
		 * Графика выделения 
		 */		
		protected var selection:Shape;
		/**
		 * Текстовое поле 
		 */		
		protected var textField:Label;
		/**
		 * Скин 
		 */		
		protected var skin:ListItemSkin;
		/**
		 * Группа кнопок для обработки нажатия
		 */		
		protected var _group:ButtonGroup;
	
		
		/**
		 * @param params папаметры отрисовки элемента списка
		 */		
		public function ListRenderer(params:ListRendererParams) {
			
			super(params.marginLeft, params.marginTop, params.marginRight, params.marginBottom);
			
			stretchableH = true;
			
			// Установка менеджера компоновки по умолчанию	
			layoutManager = new CompletelyFillLayoutManager(Direction.HORIZONTAL, params.hAlign, params.vAlign, params.space);
			
			// Текстовое поле
			textField = new Label();
			addObject(textField);
			
			// Создание области выделения
			selection = new Shape();
			selection.alpha = 0;
			addChildAt(selection, 0);
		}
		
		/**
		 * Обновление скина 
		 */
		override public function updateSkin():void {
			skin = ListItemSkin(skinManager.getSkin(getSkinType()));
			super.updateSkin();
			
			with (selection.graphics) {
				clear();
				beginFill(skin.selectionColor);
				drawRect(0, 0, 10, 10);
			}
			switchState();
		}
		
		/**
		 * @private
		 * Определение класса для скинования
		 * @return класс для скинования
		 */		
		protected function getSkinType():Class {
			return ListRenderer;
		}
		
		/**
		 * Отрисовка в заданных размерах, с сохранением текущего размера (сохраняем currentSize)
		 * @param size размеры
		 */
		override public function draw(size:Point):void {
			super.draw(size);
			
			drawSelection();
		}
		
		/**
		 * Отрисовка графики выделения 
		 */		
		protected function drawSelection():void {
			selection.width = currentSize.x;
			selection.height = currentSize.y;
		}
		
		/**
		 * Смена визуального состояния 
		 */		
		 protected function switchState():void {
		 	if (_selected) {
		 		if (over) {
		 			selection.alpha = skin.selectionAlphaOverSelected;
		 		} else {
		 			selection.alpha = skin.selectionAlphaSelected;
		 		}
		 	} else {
		 		if (over) {
		 			selection.alpha = skin.selectionAlphaOver;
		 		} else {
		 			selection.alpha = 0;
		 		}
		 	}
		 }
		
		/**
		 * Флаг наведения
		 */
		override public function set over(value:Boolean):void {
			super.over = value;
			if (isSkined) {
				switchState();
			}
		}

		/**
		 * Флаг нажатия
		 */
		override  public function set pressed(value:Boolean):void {
			super.pressed = value;
			
			if (value) {
				selected = true;
			}
			// Рассылка для группы
			if (group != null) {
				if (_pressed) {
					group.buttonPressed(this);
				} else {
					group.buttonExpressed(this);
				}
			}
		}
		
		/**
		 * Флаг выбранности 
		 */		
		public function get selected():Boolean {
			return _selected;
		}
		public function set selected(value:Boolean):void {
			//trace(_data + " set selected: " + value);
			if (!value) {
				//trace("");
			}
			if (_selected != value) {
				_selected = value;
				// Смена состояния
				if (isSkined) {
					switchState();
				}
				// Рассылка для группы
				if (group != null && group is RadioButtonGroup) {
					RadioButtonGroup(group).buttonSelected(this);
				}
				// Рассылка события
				if (_selected) {
					dispatchEvent(new ListItemEvent(ListItemEvent.SELECT, _data));
				} else {
					dispatchEvent(new ListItemEvent(ListItemEvent.UNSELECT, _data));
				}
			}
		}
		
		/**
		 * Данные отрисовываемого элемента 
		 */		
		public function get data():Object {
			return _data;
		}
		public function set data(value:Object):void {
			_data = value;
			textField.text = String(_data);
		}
		
		/**
		 * Ссылка на родительский список
		 */		
		public function set list(listObject:List):void {
			_list = listObject;
		}
		
		/**
		 * Группа кнопок для обработки нажатия
		 */		
		public function get group():ButtonGroup {
			return _group;
		}
		public function set group(value:ButtonGroup):void {
			_group = value;
		}
		
	}
}