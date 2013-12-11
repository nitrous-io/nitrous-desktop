App.EditableListView = Em.View.extend
  classNames: ['editable-list-view']
  templateName: 'editable-list'
  content: null
  label: null
  selectedItem: null

  hasNoSelectedItem: Em.computed.not 'selectedItem'

  addingNewItem: false

  willDestroyElement: ->
    @_super()
    @set 'selectedItem', null

  didFinishEditingNewItem: (input) ->
    @set 'addingNewItem', false
    @get('content').add input

  actions:
    add: ->
      @set 'addingNewItem', true

    remove: ->
      list = @get 'content'
      item = @get 'selectedItem'
      list.remove item
      @set 'selectedItem', null

App.EditableListItemTextField = Em.TextField.extend
  classNames: ['editable-list-item-text-field']
  finished: false

  didInsertElement: ->
    @_super()
    parentView = @get 'parentView'
    parentView.$('> ul').scrollTop(@$().position().top)
    @$().focus()

  done: ->
    @set 'finished', true
    @get('parentView').didFinishEditingNewItem @get('value')

  cancel: ->
    @set 'value', null
    @done()

  insertNewline: ->
    @done()

  focusOut: ->
    unless @get 'finished'
      @done()
