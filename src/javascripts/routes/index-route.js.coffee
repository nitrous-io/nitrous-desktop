AIO.IndexRoute = Em.Route.extend
  activate: ->
    if accessToken = AIO.AccessToken.loadFromStorage()
      AIO.set 'accessToken', accessToken
      @transitionTo 'main'
    else
      @transitionTo 'sign-in'
