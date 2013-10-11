AIO.AccessToken = klass = Em.Model.extend
  resourceOwnerId: Em.attr()
  accessToken: Em.attr()
  token: Em.computed.alias 'accessToken'

  username: Em.attr()
  password: Em.attr()

  clientId: null
  clientSecret: null

  toJSON: ->
    if json = @_super()
      json.client_id = @get 'clientId'
      json.client_secret = @get 'clientSecret'
      json.grant_type = 'password'
      json.scope = 'public boxes push web user'
    json

klass.reopenClass
  adapter: Em.RESTAdapter.create()
  camelizeKeys: true
  url: "#{AIO.get 'config.host'}/oauth/token"
  primaryKey: 'resourceOwnerId'
