#= require ./oauth-rest-adapter

AIO.SingletonAdapter = AIO.OAuthRESTAdapter.extend
  buildURL: (klass, id) ->
    unless urlRoot = Em.get(klass, 'url')
      @_super.apply this, arguments
    urlRoot + ".json"
