App.EditableListItemView = Em.View.extend
  classNames: ['editable-list-item-view']
  classNameBindings: 'selected'
  templateName: 'editable-list-item'
  tagName: 'li'
  content: null

  selected: (->
    content = @get('content')
    content && (@get('parentView.selectedItem') == content)
  ).property 'parentView.selectedItem', 'content'

  click: ->
    if parentView = @get 'parentView'
      parentView.set 'selectedItem', @get('content')
    false
