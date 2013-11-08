#= require ./base-model

AIO.PublicKey = klass = AIO.BaseModel.extend
  name: Em.attr()
  md5Fingerprint: Em.attr()

klass.reopenClass
  rootKey: 'public_key'
  collectionKey: 'public_keys'
  url: "#{AIO.get 'config.host'}/api/v0/public_keys"
