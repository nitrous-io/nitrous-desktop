AIO.IndexRoute = Em.Route.extend
  activate: ->
    @transitionTo 'sign-in'
