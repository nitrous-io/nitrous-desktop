Em.RecordArray.reopen
  load: (klass, data) ->
    oldContent = Em.get(this, 'content') ? Em.A()
    newContent = @materializeData(klass, data)
    # invoke 'didUnload' method on removed records
    _.difference(oldContent, newContent).forEach (record) ->
      record.didUnload?()
    Em.set this, 'content', newContent
    @notifyLoaded()

  reload: ->
    modelClass = @get 'modelClass'
    promises = null

    @set 'isLoaded', false

    # return promise for all of the cases
    if modelClass._findAllRecordArray == this
      modelClass.adapter.findAll modelClass, this
    else if @_query
      modelClass.adapter.findQuery modelClass, this, @_query
    else
      promises = @map (record) ->
        return record.reload()
      Ember.RSVP.all(promises).then (data) =>
        @notifyLoaded()
      promises
