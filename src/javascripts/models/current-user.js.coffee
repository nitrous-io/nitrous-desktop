#= require ./base-model

AIO.CurrentUser = klass = AIO.BaseModel.extend
  username: Em.attr()
  email: Em.attr()
  fullName: Em.attr()

  usedN2o: Em.attr()
  maxN2o: Em.attr()

  usedN2O: Em.computed.alias 'usedN2o'
  maxN2O: Em.computed.alias 'maxN2o'

  freeN2O: (->
    (@get('maxN2O') ? 0) - (@get('usedN2O') ? 0)
  ).property 'usedN2O', 'maxN2O'
  freeN2o: Em.computed.alias 'freeN2O'

klass.reopenClass
  adapter: AIO.SingletonAdapter.create()
  rootKey: 'user'
  url: "#{AIO.get 'config.host'}/api/v0/user"
