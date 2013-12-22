Em.RecordArray.reopen
  load: (klass, data) ->
    oldContent = Em.get(this, 'content') ? Em.A()
    newContent = @materializeData(klass, data)
    # invoke 'didUnload' method on removed records
    _.difference(oldContent, newContent).forEach (record) ->
      record.didUnload?()
    Em.set this, 'content', newContent
    @notifyLoaded()
