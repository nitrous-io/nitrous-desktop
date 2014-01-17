App.BoxesListController = Em.ArrayController.extend
  selectedItem: null

  selectItem: (item) ->
    @set 'selectedItem', item
    @send 'boxSelected', item

  selectFirstItem: ->
    if firstItem = @get 'firstObject'
      @selectItem firstItem
