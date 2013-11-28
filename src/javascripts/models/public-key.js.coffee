#= require ./base-model

App.PublicKey = klass = App.BaseModel.extend
  name: Em.attr()
  md5Fingerprint: Em.attr()

klass.reopenClass
  rootKey: 'public_key'
  collectionKey: 'public_keys'
  url: "#{App.get 'config.host'}/api/v0/public_keys"
