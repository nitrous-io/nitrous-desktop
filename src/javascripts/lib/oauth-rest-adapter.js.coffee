App.OAuthRESTAdapter = Em.RESTAdapter.extend
  ajaxSettings: ->
    settings = @_super.apply this, arguments
    if accessToken = App.get 'accessToken.token'
      settings.headers ?= {}
      settings.headers.Authorization = "Bearer #{accessToken}"
    settings

  ajax: ->
    ajax = @_super.apply this, arguments
    ajax.fail (jqXHR) ->
      if jqXHR.status == 401
        App.trigger 'InvalidAccessToken'
      jqXHR
