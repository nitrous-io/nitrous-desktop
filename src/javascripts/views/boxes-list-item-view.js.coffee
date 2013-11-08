AIO.BoxesListItemView = Em.View.extend
  classNames: ['boxes-list-item-view']
  classNameBindings: 'selected'
  tagName: 'li'
  templateName: 'boxes-list-item'

  selected: (->
    item = @get 'context'
    item && item == @get('controller.selectedItem')
  ).property 'controller.selectedItem', 'context'

  click: ->
    controller = @get 'controller'
    item = @get 'context'
    controller.selectItem item
    false
