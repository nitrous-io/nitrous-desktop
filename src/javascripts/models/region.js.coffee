#= require ./base-model

App.Region = klass = App.BaseModel.extend
  name: Em.attr()
  description: Em.attr()
  state: Em.attr()

klass.reopenClass
  rootKey: 'region'
  collectionKey: 'regions'
  url: "#{App.get 'config.host'}/api/v0/regions"
