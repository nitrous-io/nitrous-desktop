App.IndexRoute = Em.Route.extend
  activate: ->
    if accessToken = App.AccessToken.loadFromStorage()
      App.set 'accessToken', accessToken
      @transitionTo 'main'
    else
      @transitionTo 'sign-in'
