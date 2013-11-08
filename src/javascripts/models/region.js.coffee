#= require ./base-model

AIO.Region = klass = AIO.BaseModel.extend
  name: Em.attr()
  description: Em.attr()
  state: Em.attr()

klass.reopenClass
  rootKey: 'region'
  collectionKey: 'regions'
  url: "#{AIO.get 'config.host'}/api/v0/regions"
