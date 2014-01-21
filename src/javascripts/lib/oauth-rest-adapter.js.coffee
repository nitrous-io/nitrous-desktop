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
    ajax

  makeRequest: (record, action, method='GET', params)  ->
    recordClass = record.constructor
    urlRoot = recordClass.url
    id = record.get(recordClass.primaryKey)
    url = @buildURL(recordClass, id).replace /\.json$/, "/#{action}.json"
    @ajax url, params, method
