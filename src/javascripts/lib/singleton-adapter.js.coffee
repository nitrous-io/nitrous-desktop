#= require ./oauth-rest-adapter

App.SingletonAdapter = App.OAuthRESTAdapter.extend
  buildURL: (klass, id) ->
    unless urlRoot = Em.get(klass, 'url')
      @_super.apply this, arguments
    urlRoot + ".json"
