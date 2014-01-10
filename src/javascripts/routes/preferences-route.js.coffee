App.PreferencesRoute = Em.Route.extend
  renderTemplate: ->
    @render 'preferences', outlet: 'content'
