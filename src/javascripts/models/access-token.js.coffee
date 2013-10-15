#= require './base-model'

AIO.AccessToken = klass = AIO.BaseModel.extend
  resourceOwnerId: Em.attr()
  accessToken: Em.attr()
  token: Em.computed.alias 'accessToken'

  username: Em.attr()
  password: Em.attr()

  clientId: Em.attr()
  clientSecret: Em.attr()

  grantType: Em.attr()
  scope: Em.attr()

  init: ->
    @_super.apply this, arguments
    @set 'grantType', 'password'
    @set 'scope', klass.scope

  didSaveRecord: ->
    klass.singleton = this
    @_super()

klass.reopenClass
  adapter: Em.RESTAdapter.create()
  url: "#{AIO.get 'config.host'}/oauth/token"
  scope: 'public boxes push web user'
  primaryKey: 'scope'
  singleton: null

  find: ->
    @_super(@scope)

  saveToStorage: ->
    AIO.localStorage.set 'accessToken', @singleton.toJSON()

  loadFromStorage: ->
    if json = AIO.localStorage.get 'accessToken'
      @load [json]
      klass.find()
